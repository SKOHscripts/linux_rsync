#!/bin/sh
date=$(date +%d-%m-%Y)
heure=$(date +%Hh%M)

TXT="/media/user/USB/backups.txt"
SOURCE="/home/user/Documents/"
DESTINATION="/media/user/USB/Documents"

#pas de changement radical pour ce script en comparaison au script rsync.sh
#sauf qu'ici plus d'interface homme-machine, le script peut être fait de façon automatique
echo -n "Backup effectué le $date à $heure     " >> $TXT && rsync -ar --delete $SOURCE $DESTINATION && echo "OK     (automatique)" >> $TXT && sed -i 2'd' $TXT && notify-send -i dialog-ok "Backup automatique" "Terminé avec succès le $date à $heure" -t 500 && exit 0 || zenity --warning --height 80 --width 400 --title "EREUR" --text "Il y a eu une erreur avec le crontab de synchronisation automatique. Veuillez démonter la partition et recommencer ou désactiver la sauvegarde automatique." && echo "ERREUR" >> $TXT
