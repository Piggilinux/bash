#!/bin/bash



function makeBackup {

#checking if directory exists
if [ -d $backup_files ]; then
	echo "We are going to backup the directory $backup_files"
	echo -e "Do you want to proceed(y/n)? \c"
	read yesOrNo

	if [ $yesOrNo = "y" ]; then
		#Where to backup to and filename.
		dest="/home/vlr"
		
		name=$(basename $backup_files)
		datum=$(date +%Y-%m-%d-%H%M)
		fileName="$name-$datum.tgz"

		echo "Backing up $backup_files to $dest"
		tar -czvf $fileName $backup_files 

		to_log $name $fileName $datum
		echo "Backup finished"
		#listing files of backup destination
		ls -lh $backup_files
	else
		echo "Going back.."
	fi
else 
	echo "Directory of file doesn't exist"
fi
}


function to_log {
	if [ ! -f "/home/vlr/skola/script/backup.log" ] ; then
		touch "/home/vlr/skola/script/backup.log"
	fi
	name=$1
	fileName=$2
	$datum=$3
	#echo -e "A backup of directory $1 has been done on $(date +%Y-%m-%d) at $(date +%H%M)" >> backup.log
	local -i size=$(du -k $2 | cut -f1)
	cat >>backup.log <<EOL
	A backup of directory $name has been done on $datum
	The file generated is $fileName and ocupies <$size> kilo bytes. 

EOL
}

# Extracting chosen file
function recreateBackup {
	if [ -f $restoration ]; then
		tar -xzvf $restoration --directory ExtractedTmp
	else
		echo "cant find file"
	fi
	}

	function crontabIt {

	name=$(basename $backup_files)
	datum=$(date +%Y-%m-%d)
	#fileName="$name-$datum.tgz"

	#write out current crontab
	crontab -l > mycron

	echo -e "Hour for the backup (0:00-23:59): \c"
	read hour
	echo -e "Minute for the backup (0-59): \c"
	read minute
	fileName="$name-$datum-$hour$minute.tgz"


	#echo "$minute $hour * * * tar -czf $fileName.tgz $backup_files" >> mycron

	if [ ! -f "/home/vlr/skola/script/backup.log" ] ; then
		touch "/home/vlr/skola/script/backup.log"
	fi

	#local -i size=$(du -k $fileName | cut -f1)
	#puts backups in /home/vlr/skola/script/tar-backups/
	cat >>mycron <<EOL
	$minute $hour * * * tar -czf /home/vlr/skola/script/tar-backups/$fileName $backup_files
	$minute $hour * * * echo "\tA backup of directory $name has been done on $datum-$hour$minute\n" >> /home/vlr/skola/script/backup.log
	$minute $hour * * * echo "\tThe file generated is $fileName and ocupies <$(du -k /home/vlr/skola/script/tar-backups/$fileName | cut -f1)> kilo bytes.\n" >> /home/vlr/skola/script/backup.log
EOL
	#echo new cron into cron file
	crontab mycron

}

######################## MAIN ########################


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

	if [ $choice -eq 1 ]; then
		echo -e "Path of the directory: \c"
		read backup_files
		#echo $backup_files

		makeBackup backup_files
	elif [ $choice -eq 2 ]; then
		echo -e "Absolute path of the directory: \c"
		read backup_files

		crontabIt backup_files
	elif [ $choice -eq 3 ]; then
		echo "The list of existing backups is:"
		ls /home/vlr/*tgz
		echo -e "Which one you want to recover: \c"
		read restoration

		recreateBackup restoration
	else
		echo "Exiting"
		letsGo=0
	fi
	#clear
done