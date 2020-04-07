#!/bin/sh

clear
echo "\t\033[1;33m CHOIX DE L'AUTOMATISATION\n\033[0m"
echo "Editer crontab\t\t\033[1;32m(1)\033[0m"
echo "Juste faire le backup\t\033[1;32m(2)\033[0m"
echo ""

while read choix
do
	clear
	echo "\t\033[1;33m CHOIX DE L'AUTOMATISATION\n\033[0m"
	echo "Editer crontab\t\t\033[1;32m(1)\033[0m"
	echo "Juste faire le backup\t\033[1;32m(2)\033[0m"
	echo ""
	
	case $choix in
		1) 	crontab -e;; 	#*/30 *  *   *   *    "PATH"/backup.sh
							#ici l'automatisation va lancer le script backup.sh toutes les 30 minutes
		2) 	date=$(date +%d-%m-%Y)
			heure=$(date +%Hh%M)
			#on va maintenant renseigner le fichier backups.txt sur les sauvegardes effectuées.
			#Il faudra ici changer les "SOURCE" et "DESTINATION" pour rsync
			#Il faudra également changer "PATH" pour le fichier backups.txt
			echo -n "Backup effectué le $date à $heure     " >> "PATH"/backups.txt && rsync -arv --stats --delete -h "SOURCE" "DESTINATION" && echo "OK" >> "PATH"/backups.txt && sed -i 2'd' "PATH"/backups.txt && echo "" && echo "" && echo "\033[1;33mBACKUP EFFECTUE AVEC SUCCES LE $date à $heure\033[0m\n" && exit 0 || echo "\033[1;31mERREUR !!! IL FAUT DEMONTER LA PARTITION ET RECOMMENCER\033[0m\n" && exit 1;;
	esac
done

