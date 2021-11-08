# linux-rsync
[![support](
https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](
https://brianmacdonald.github.io/Ethonate/address#0xEDa4b087fac5faa86c43D0ab5EfCa7C525d475C2)

Un script shell avec menu pour le choix d'une automatisation de la sauvegarde d'un dossier sur un support externe avec la méthode rsync.

La fenêtre crontab pour l'automatisation devra être ouverte avec nano. 
Sur la dernière ligne, entrez <br>`*/30 *  *   *   *    "PATH"/automate.sh` qui lancera le fichier automate.sh toutes les 30 minutes (changez cette valeur à votre guise).
Pour annuler la sauvegarde, supprimez la ligne ou ajouter un #: `#*/30 *  *   *   *    "PATH"/automate.sh`

N'oubliez pas de changer les chemins de "SOURCE" et de "DESTINATION" pour rsync (s'aider de la documentation) et "PATH" pour le dossier contenant les scripts.

Exemple :<br> `*/30 *  *   *   *    ~/scripts/automate.sh`

Explication pour les options de rsync : 
https://doc.ubuntu-fr.org/rsync

Je vous conseille de mettre le fichier backups.txt sur le support externe, afin de garder une trace des sauvegardes faites.
Je vous ai laissé 10 lignes afin de voir le résultat final. N'oubliez pas que le script va supprimer la 2e ligne à chaque fois qu'il écrira dans le fichier.

S+KOH

``` bash 
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
	
		"$BGN_CRON") crontab -e;; 	#*/30 *  *   *   *    "PATH"/backup.sh
									#ici l'automatisation va lancer le script backup.sh toutes les 30 minutes
	esac
}

chkDef
```
