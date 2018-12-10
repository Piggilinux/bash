#!/bin/bash
. /etc/bash_completion

#/home/vlr/skola/script/tmpBackup
#path="/home/vlr/skola/script"

letsGo=1

while [[ letsGo -eq 1 ]]; do

	echo "ASO 2018-2019"
	echo "Linus Rosenholm"
	echo "Backup tool for directories"
	echo "---------------------------"
	echo "Menu"
	echo "1) Perform a backup"
	echo "2) Program a backup with cron"
	echo "3) Restore the content of a backup"
	echo "4) Exit" 

	echo -e "Option: \c"
	read choice

	# Makes a backup of chosen directory.
	if [ $choice -eq 1 ]; then
		echo -e "Path of the directory: \c"
		read path

		/home/vlr/skola/script/callBackup.sh $choice $path
	# Makes a backup of chosen directory with cron
	elif [ $choice -eq 2 ]; then
		echo -e "Absolute path of the directory: \c"
		read path

		/home/vlr/skola/script/callBackup.sh $choice $path
	# Extracts a chosen zip file.	
	elif [ $choice -eq 3 ]; then
		echo "The list of existing backups is:"
		# Shows a chosen directory where all backups end up.
		ls /home/vlr/skola/script/tar-backups/*tgz
		echo -e "Which one you want to recover: \c"
		read path

		/home/vlr/skola/script/callBackup.sh $choice $path
	else
		echo "Exiting"
		letsGo=0
	fi
	#clear
done