#!/bin/bash

path=$2
#backupCall=/home/vlr/skola/script

function logger {
	name=$1
	fileName=$2
	datum=$3

	# Creates logfile if it doesn't exist.
	if [ ! -f "/home/vlr/skola/script/backup.log" ] ; then
		touch "/home/vlr/skola/script/backup.log"
	fi

	# If backup was successfull, log it. Otherwise log an error message.
	if [ -f $fileName ]; then

	local -i size=$(du -k $fileName | cut -f1)
	cat >>/home/vlr/skola/script/backup.log <<EOL
	A backup of directory $name has been done on $datum
	The file generated is $fileName and ocupies $size kilobytes. 

EOL
	else
	cat >>/home/vlr/skola/script/backup.log <<EOL
	An error occured when trying to make a backup of $fileName at $datum

EOL
	fi
}

# Does the actual tar command and creates the backup
function bu_action {
	path=$1
	name=$(basename $path)
	datum=$(date +%Y-%m-%d-%H%M)
	fileName="/home/vlr/skola/script/tar-backups/$name-$datum.tgz"

	tar -czvf $fileName $path
	logger $path/$name $fileName $datum 
	#echo "Backup finished"
}

function makeBackup {
	path=$1
	# Checking if directory exists
	if [ -d $path ]; then
		echo "We are going to backup the directory $path"
		echo -e "Do you want to proceed(y/n)? \c"
		read yesOrNo

		if [ $yesOrNo = "y" ]; then
			bu_action $path
		else
			echo "Going back.."
		fi
	else 
		echo "Directory doesn't exist"
	fi
}

function crontabIt {

	name=$(basename $1)
	datum=$(date +%Y-%m-%d)

	echo -e "Hour for the backup (0:00-23:59): \c"
	read hour
	echo -e "Minute for the backup (0-59): \c"
	read minute
	
	# calls the callBackup script with a 9 so that it can do the backup without confirmation from the user.
	echo "$minute $hour * * * /home/vlr/skola/script/callBackup.sh 9 $path" >> mycron
	crontab mycron
}

# Extracting chosen file
function recreateBackup {
	if [ -f $path ]; then
		tar -xzvf $path --directory /home/vlr/skola/script/ExtractedTmp
	else
		echo "cant find file"
	fi
}

# Depending on choise in meny an action will be done.
# The path of the directory or file will be checked.
if [ $1 -eq 1 ]; then
	if [ -d $path -o -f $path ]; then
		makeBackup $path
	else
		echo "Directory does not exist.."
	fi
elif [ $1 -eq 2 ]; then
		if [ -d $path -o -f $path ]; then
		crontabIt $path
	else
		echo "Directory does not exist.."
	fi
elif [ $1 -eq 3 ]; then
		if [ -f $path -o -f $path ]; then
		recreateBackup $path
	else
		echo "File does not exist.."
	fi
elif [ $1 -eq 9 ]; then
	if [ -d $path ]; then
		bu_action $path
	else
		echo "Directory does not exist.."
	fi		
fi


