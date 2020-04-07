#!/bin/sh
date=$(date +%d-%m-%Y)
heure=$(date +%Hh%M)

#pas de changement radical pour ce script en comparaison au script rsync.sh
#sauf qu'ici plus d'interface homme-machine, le script peut être fait de façon automatique
echo -n "Backup effectué le $date à $heure     " >> "PATH"/backups.txt && rsync -ar --delete "SOURCE" "DESTINATION" && echo "OK     (automatique)" >> "PATH"/backups.txt

sed -i 2'd' "PATH"/backups.txt
