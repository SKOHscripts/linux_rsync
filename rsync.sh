#!/bin/bash

BGN_CRON="Editer crontab"
BGN_BACKUP="Faire le backup"

#On va maintenant renseigner le fichier backups.txt sur les sauvegardes effectuées.
#Il faudra ici changer les "SOURCE" et "DESTINATION" pour rsync
#Il faudra également changer "TXT" pour le fichier backups.txt

TXT="/media/user/USB/backups.txt"
SOURCE="/home/user/Documents/"
DESTINATION="/media/user/USB/Documents"

CHK_REP=$(zenity --entry --title="Backup" --text "Que voulez-vous faire ?" --entry-text="$BGN_BACKUP" "$BGN_CRON" "")
if [ $? -ne 0 ] ; then
	exit
fi

chkDef() {
	case "$CHK_REP" in
		"$BGN_BACKUP") 	date=$(date +%d-%m-%Y)
						heure=$(date +%Hh%M)
						#on va maintenant renseigner le fichier backups.txt sur les sauvegardes effectuées.
						#Il faudra ici changer les "SOURCE" et "DESTINATION" pour rsync
						#Il faudra également changer "PATH" pour le fichier backups.txt
						echo -n "Backup effectué le $date à $heure     " >> $TXT && rsync -arv --stats --delete -h $SOURCE $DESTINATION && echo "OK" >> $TXT && sed -i 2'd' $TXT && echo "" && echo "" && notify-send -i dialog-ok "Backup" "Terminée avec succès le $date à $heure" -t 500 && exit 0 || zenity --warning --height 80 --width 400 --title "EREUR" --text "Il y a eu une erreur de synchronisation des dossiers. Veuillez démonter la partition et recommencer." && echo "ERREUR" >> $TXT && exit 1;;
	
		"$BGN_CRON") crontab -e;; 	#*/30 *  *   *   *    "PATH"/backup.sh
						#ici l'automatisation va lancer le script backup.sh toutes les 30 minutes
	esac
}

chkDef


