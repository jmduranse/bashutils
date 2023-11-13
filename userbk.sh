#!/bin/bash
#24/05/2022 
#
#Juan M. Duran para eac3
#
#Must be root to execute script
#USAGE userbk.sh [number retentions (1-12)] [user] [target directory]

PROG=$(basename "$0")
ERR_BADPARM=3
ERR_NOROOT=1
ERR_NOTAR=2
ERR_BACKUP=4
ERR_BADUSER=5
ERR_BADHOME=6
ERR_DELETION=7
ERR_BACKUPDIR=8
ERR_BADRETEN=9
status=0

limit=$1
user=$2
directory=$3
homedir=""

status=0
TAR=$(which tar)


#function for backup
# Parameters : backup [user] [directory to store the file]



backup () {

	local user=$1
	local directory=$2
	local date=$(date +"%Y-%m-%d")
	local time=$(date +%H%M)
	local tarfile


	if [ ! -d "$directory" ] ; then
		echo "$PROG Error: We cant reach $directory for backup"  >> /dev/stderr
		return $ERR_BACKUPDIR
	fi

	#compress directory with tar
	tarfile=$directory/$user-$date-$time.tgz
	$TAR -zcPf "$tarfile" "$homedir"

	#test if file generation was correct
	if [ $? -ne 0 ]; then
		echo "$PROG: An error has happened during the backup file generation"  >> /dev/stderr
		return $ERR_BACKUP
	else
		echo "$tarfile has been generated"
	fi
	return 0
}

#function to remove old backups
# Parameters : backup [number of retentions] [user] [directory to store the file]

purge () {

	local limit=$1
	local user=$2
	local directory=$3
	local file

	local counter=0
	local status=0

	if [ "$(find "$directory" -iname "$user*.tgz" |wc -l)" -gt $limit ]; then

		while [ "$(find "$directory" -iname "$user*.tgz" |wc -l)" -gt $limit ]
		do
			file=$(find "$directory" -iname "$user*.tgz"|sort|head -n 1)
			rm "$file" 
				if [ $? -ne 0 ]; then
					echo "Error deleting $file"  >> /dev/stderr
					return  $ERR_DELETION
				else
					((counter++))
				fi
		done
		echo "$PROG: $counter files deleted succesfully"
	else
		echo "$PROG: No files deleted"    
	fi
	return $status
}


#main program


#test if we are root 

if [ $UID -ne 0 ]; then
    echo "ERROR $PROG :Must be root to execute script"  >> /dev/stderr
    exit $ERR_NOROOT
fi

#test if tar executable exists


if [ -z "$TAR" ]; then
    echo "Error $PROG: tar executable not found."  >> /dev/stderr
    exit $ERR_NOTAR 
fi


#number of argument control
if [ $# -eq 3 ]; then

#number or retention control
    if [[ $limit -ge 1 && $limit -le 12 ]]; then

#existence of user control
        if id "$user"  > /dev/null 2>&1 ; then
        homedir=$(grep "^$user:" /etc/passwd | cut -d ":" -f6)

#home directory is correct control
            if [ -d $homedir ]; then

                #call the backup function
                backup $user $directory
				status=$?

				if [ $status -eq 0 ]; then

					#call the deletion function
					purge $limit $user $directory 
					status=$? 

					if [ $status -ne 0 ]; then
						#deletion of extra files has happened but in case of errors during the process exit code is not 0
						echo ERROR  "$PROG: Could not delete some of the old backups"  >> /dev/stderr
					fi

				else

					echo "$PROG: ERROR during the backup file generation" >> /dev/stderr
					exit $status
				fi
            else
				echo "ERROR: $PROG.  The home directory for that user does not exist or is unreachable"  >> /dev/stderr
				echo "USAGE: userbk.sh [number retentions (1-12)] [user] [target directory]"
				exit $ERR_BADHOME

            fi

        else
            echo "ERROR: $PROG.  The specified user do not exist"  >> /dev/stderr
			echo "USAGE: userbk.sh [number retentions (1-12)] [user] [target directory]"
			exit $ERR_BADUSER
        fi

    else
        echo "ERROR: $PROG.  Specified number of backups to keep is too low or too high. "  >> /dev/stderr
		echo "USAGE: userbk.sh [number retentions (1-12)] [user] [target directory]"
		exit $ERR_BADRETEN
    fi

else
    echo "ERROR: $PROG.  Incorrect number of parameters"  >> /dev/stderr
    echo "USAGE: userbk.sh [number retentions (1-12)] [user] [target directory]"
    exit $ERR_BADPARM
fi

exit $status
