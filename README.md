# linux-rsync

Un script shell avec menu pour le choix d'une automatisation de la sauvegarde d'un dossier sur un support externe avec la méthode rsync.

La fenêtre crontab pour l'automatisation devra être ouverte avec nano. 
Sur la dernière ligne, entrez `*/30 *  *   *   *    "PATH"/automate.sh` qui lancera le fichier automate.sh toutes les 30 minutes
Pour annuler la sauvegarde, supprimez la ligne ou ajouter un #: `#*/30 *  *   *   *    "PATH"/automate.sh`

N'oubliez pas de changer les chemins de "SOURCE" et de "DESTINATION" pour rsync (s'aider de la documentation) et "PATH" pour le dossier contenant les scripts.

Exemple : `*/30 *  *   *   *    ~/scripts/automate.sh`

Je vous conseille de mettre le fichier backups.txt sur le support externe, afin de garder une trace des sauvegardes faites.
Je vous ai laissé 10 lignes afin de voir le résulat final. N'oubliez pas que script va supprimer la 2ème ligne à chaque fois qu'il écrira dans le fichier.

N'oubliez pas qu'une bonne sauvegarde est une sauvegarde régulière.
S+KOH
