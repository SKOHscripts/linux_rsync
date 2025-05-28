# linux-rsync
[![support](
https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](
https://brianmacdonald.github.io/Ethonate/address#0xEDa4b087fac5faa86c43D0ab5EfCa7C525d475C2)

# Système de Sauvegarde Automatisé avec Rsync et Intégration Cron

Solution robuste pour la synchronisation et la sauvegarde de répertoires sous Linux, avec gestion avancée des exclusions, journalisation détaillée et intégration transparente avec cron.

## Fonctionnalités Clés
- **Sauvegarde incrémentielle** avec rsync pour une efficacité optimale
- **Planification automatique** via cron avec gestion des variables d'environnement graphique
- **Journalisation complète** avec rotation automatique des logs
- **Notifications visuelles** (zenity) et système (systemd-cat)
- **Exclusions intelligentes** des répertoires temporaires, caches et environnements de développement
- **Gestion des erreurs** détaillée avec codes de sortie explicites

## Installation
```console
git clone https://github.com/votre-utilisateur/linux_rsync.git
cd linux_rsync
chmod +x automate.sh
```

## Utilisation Basique
```console
./automate.sh -s /chemin/source -d /chemin/destination
```

### Options Principales
| Option | Description |
|--------|-------------|
| `-s`   | Répertoire source à sauvegarder (obligatoire) |
| `-d`   | Destination de la sauvegarde (obligatoire) |
| `-c`   | Activer la planification cron toutes les 12h |
| `-h`   | Afficher l'aide |

## Configuration Avancée
### Exclusions Types
--exclude="/node_modules/"
--exclude="/pycache/"
--exclude="**/.idea/"

_Liste complète des modèles d'exclusion dans le script [source](automate.sh)_

### Variables d'Environnement
```shell
export DISPLAY=:0 # Pour les notifications graphiques
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
```

## Gestion des Journaux
| Fichier | Description |
|---------|-------------|
| `backup.log` | Journal principal des opérations |
| `rsync_*.log` | Logs détaillés par session rsync |
Rotation automatique après 7 jours
find "${DESTINATION}" -name "rsync_*.log" -mtime +7 -delete

## Intégration Cron
Pour activer les sauvegardes planifiées :
``` console
./automate.sh -s /home/user -d /backup -c
```

_Commande cron générée :_
```shell
0 */12 * * * /bin/bash -c 'export $(cat /proc/$(pgrep -u $USER gnome-session | head -1)/environ | tr "\0" "\n" | grep -E "DISPLAY|DBUS_SESSION_BUS_ADDRESS")' && /chemin/absolu/automate.sh -s /home/user -d /backup
```

## Dépannage
### Erreurs Courantes
1. **Permissions insuffisantes**
```console
chmod 700 /chemin/destination
```

2. **Dépendances manquantes**
Installer rsync et zenity :
```console
sudo apt install rsync zenity
```

4. **Problèmes d'environnement cron**
Vérifier les variables DISPLAY/DBUS avec :
```console
env | grep -E 'DISPLAY|DBUS'
```

## Contribution
Les contributions sont les bienvenues via pull requests. Merci de respecter les guidelines :
- Tests sur multiples distributions Linux
- Documentation mise à jour
- Validation ShellCheck

## Licence
GPL-3.0 - Voir le fichier [LICENSE](LICENSE)

---

**Compatibilité** : Testé sur Debian 12, EndeavourOS (2025.02.08, Mercury) based on Arch Linux
**Dépendances** : rsync >= 3.2.3, zenity >= 3.32.0, systemd >= 247
