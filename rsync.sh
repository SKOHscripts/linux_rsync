#!/bin/bash

BGN_CRON="Editer crontab"
BGN_BACKUP="Faire le backup"

TXT="/media/user/USB/backups.txt"
SOURCE="/home/user/Documents/"
DESTINATION="/media/user/USB/Documents"

which zenity > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y zenity
fi

which notify-send > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y libnotify-bin
fi

which rsync > /dev/null
if [ $? = 1 ]
then
	sudo apt install -y rsync
fi

# Vérification que le script n'est pas lancé directement avec sudo (le script contient déjà les sudos pour les actions lorsque c'est nécessaire)
if [ "$UID" -eq "0" ]
then
    zenity --warning --height 80 --width 400 --title "EREUR" --text "Merci de lancez le script sans sudo : \n<b>./rsync.sh</b>\nVous devrez entrer le mot de passe root par la suite."
    exit
fi

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
						echo -n "Backup effectué le $date à $heure     " >> $TXT && rsync -arv --stats --delete -h $SOURCE $DESTINATION && echo "OK" >> $TXT && sed -i 2'd' $TXT && echo "" && echo "" && notify-send -i dialog-ok "Backup" "Terminé avec succès le $date à $heure" -t 500 && exit 0 || zenity --warning --height 80 --width 400 --title "EREUR" --text "Il y a eu une erreur de synchronisation des dossiers. Veuillez démonter la partition et recommencer." && echo "ERREUR" >> $TXT && exit 1;;
	
		"$BGN_CRON") crontab -e;; 	#*/30 *  *   *   *    "PATH"/backup.sh
									#ici l'automatisation va lancer le script backup.sh toutes les 30 minutes
	esac
}

chkDef


