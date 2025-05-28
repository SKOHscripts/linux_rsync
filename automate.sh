#!/bin/bash

# Configuration dynamique de l'environnement graphique
export DISPLAY=$(w -hs | awk '$3 ~ /:[0-9]/ {print $3}' | head -n1)
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Configuration des paramètres modifiables
USER=$(whoami)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
# Capturer l'heure de début en secondes depuis Epoch
START_TIME=$(date +%s)
DATE_LISE="$(date +"%A %d %B %Y") à $(date +"%Hh%M")"

# Gestion des arguments
SCRIPT_NAME=$(basename "$0")
SOURCE=""
DESTINATION=""
ADD_CRON="false"

usage() {
    echo "Usage: $SCRIPT_NAME -s <source> -d <destination> [OPTIONS]"
    echo "Synchronize files with advanced rsync automation and system integration"
    echo
    echo "Mandatory arguments:"
    echo "  -s, --source        Source directory to backup"
    echo "  -d, --destination   Destination path for backup"
    echo
    echo "Options:"
    echo "  -c, --cron          Add automatic backup to crontab (every 12 hours)"
    echo "  -h, --help          Display this help message"
    echo
    echo "Examples:"
    echo "  Basic backup: $SCRIPT_NAME -s ~/docs -d /backup/docs"
    echo "  With cron:    $SCRIPT_NAME -s ~/data -d /backup/data -c"
    exit 1
}

# Vérification des arguments obligatoires
check_requirements() {
    if [[ -z "$SOURCE" || -z "$DESTINATION" ]]; then
        echo "[ERROR] Source and destination are required!"
        usage
        exit 1
    fi
}

# Gestion des flags avec validation
while getopts "s:d:ch" opt; do
    case "$opt" in
        s) SOURCE="$OPTARG" ;;
        d) DESTINATION="$OPTARG" ;;
        c) ADD_CRON="true" ;;
        h) usage ;;
        *) usage ;;
    esac
done

check_requirements

# Configuration des chemins
LOG_DIR="${DESTINATION}"
MAIN_LOG="${LOG_DIR}/backup.log"
RSYNC_LOG="${LOG_DIR}/rsync_${TIMESTAMP}.log"

# Création des répertoires
mkdir -p "${DESTINATION}" || {
    echo "[${TIMESTAMP}] ERREUR: Impossible de créer ${DESTINATION}" | tee -a "${MAIN_LOG}"
    exit 1
}

# Gestion de la configuration cron
if [[ "$ADD_CRON" == "true" ]]; then
    SCRIPT_PATH=$(realpath "$0")
    CRON_LINE="0 */12 * * * /bin/bash -c 'export \$(cat /proc/\$(pgrep -u \$USER gnome-session | head -1)/environ | tr \"\\0\" \"\\n\" | grep -E \"DISPLAY|DBUS_SESSION_BUS_ADDRESS\")' && \"$SCRIPT_PATH\" -s \"$SOURCE\" -d \"$DESTINATION\""

    if ! crontab -l | grep -Fq "$CRON_LINE"; then
        (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
        echo "[CRON] Configuration automatique ajoutée avec succès"
    else
        echo "[CRON] La configuration existe déjà"
    fi
fi

# Fonction de notification améliorée
notify() {
    local type=$1 title=$2 message=$3 timeout=${4:-5000}
    local icon=$([ "$type" = "success" ] && echo "emblem-default" || echo "dialog-error")

    # Notification pour environnement graphique
    if [ -n "$DISPLAY" ]; then
        zenity --info --width=400 --title="$title" --text="$message" --icon-name="$icon" 2>/dev/null &
    fi

    # Notification pour environnement terminal
    echo -e "\n$title\n$message" | systemd-cat -t Backup -p $([ "$type" = "success" ] && echo "info" || echo "err")
}

# Optimisation des options Rsync
RSYNC_OPTS=(
    -aHhv
    --info=progress2
    --stats
    --update
    --delete
    --delete-excluded
    --partial
    --log-file="${RSYNC_LOG}"
    # Exclusions génériques
    --exclude="**/[Tt]mp*"
    --exclude="**/[Cc]ache*"
    --exclude="**/[Tt]rash*"
    --exclude=".DS_Store"
    --exclude="Thumbs.db"
    # Exclusions spécifiques aux builds
    --exclude="**/build/"
    --exclude="**/.build/"
    --exclude="**/dist/"
    --exclude="**/obj/"
    --exclude="**/target/"
    --exclude="**/out/"
    --exclude="**/cmake-build-*/"
    --exclude="**/Makefile"
    --exclude="**/CMakeLists.txt"
    # Systèmes de package/dépendances
    --exclude="**/node_modules/"
    --exclude="**/package-lock.json"
    --exclude="**/yarn.lock"
    --exclude="**/.npm/"
    --exclude="**/.yarn/"
    # Environnements virtuels et caches
    --exclude="**/__pycache__/"
    --exclude="**/.mypy_cache/"
    --exclude="**/.pytest_cache/"
    --exclude="**/venv/"
    --exclude="**/.venv/"
    --exclude="**/env/"
    --exclude="**/.env/"
    # IDE/Editeurs
    --exclude="**/.idea/"
    --exclude="**/.vscode/"
    --exclude="**/.project"
    --exclude="**/.classpath"
    # Autres exclusions spécifiques
    --exclude="**/share/icons/*"
    --exclude="**/google-chrome/"
    --exclude="**/.vim/plugged/"
)

# Début de la synchronisation
echo -e "\n[${TIMESTAMP}] Début de la sauvegarde" >> "${MAIN_LOG}"

if rsync "${RSYNC_OPTS[@]}" "${SOURCE}" "${DESTINATION}"; then
    # Calcul des statistiques
    END_TIME=$(date +%s)
    DURATION=$(( END_TIME - START_TIME ))
    HOURS=$(( DURATION / 3600 ))
    MINUTES=$(( (DURATION % 3600) / 60 ))
    SECONDS=$(( DURATION % 60 ))

    # Formatage de la durée
    if (( HOURS > 0 )); then
        FORMATTED_DURATION="${HOURS}h ${MINUTES}m ${SECONDS}s"
    elif (( MINUTES > 0 )); then
        FORMATTED_DURATION="${MINUTES}m ${SECONDS}s"
    else
        FORMATTED_DURATION="${SECONDS}s"
    fi

    # Génération du rapport
    SIZE=$(du -sh "${DESTINATION}" | cut -f1)
    FILES=$(find "${DESTINATION}" | wc -l)

    # Message de succès
    SUCCESS_MSG="✅ Synchronisation réussie!\n\n• Date: ${DATE_LISE}\n• Taille: ${SIZE}\n• Fichiers: ${FILES}\n• Durée: ${FORMATTED_DURATION}\n• Logs: ${MAIN_LOG}, ${RSYNC_LOG}"
    echo "[${TIMESTAMP}] SUCCÈS: ${SUCCESS_MSG}" >> "${MAIN_LOG}"
    notify "success" "Backup Réussi" "${SUCCESS_MSG}" 8000

else
    # Gestion d'erreur détaillée
    ERROR_CODE=$?
    LAST_ERROR=$(tail -n 3 "${RSYNC_LOG}" | sed 's/"/\\"/g')
    ERROR_MSG="🔥 ÉCHEC de la synchronisation!\n• Code: ${ERROR_CODE}\n• Erreurs:\n${LAST_ERROR}\n• Logs: ${MAIN_LOG}, ${RSYNC_LOG}"
    echo "[${TIMESTAMP}] ERREUR: ${ERROR_MSG}" >> "${MAIN_LOG}"
    notify "error" "Échec Backup" "${ERROR_MSG}" 150000
    exit 1
fi

# Rotation des logs
find "${LOG_DIR}" -name "rsync_*.log" -mtime +7 -delete
sed -i '1000,$ d' "${MAIN_LOG}"  # Plus efficace que tail + mv

exit 0
