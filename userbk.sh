#10/05/2022 
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


limit=$1
user=$2
directory=$3


status=0
TAR=$(which tar)


#function for backup


backup () {

	local limit=$1
	local user=$2
	local directory=$3
	local date=$(date +"%Y-%m-%d")
	local time=$(date +%H%M)


	#compress directory with tar
	tar cvzf $directory/$user-$date-$time.tgz $home

	#test if file generation was correct
	if [ $? -ne 0 ]: then
		echo "$PROG: An error has happened during the backup file generation"
		return $ERR_BACKUP
	fi
return 0
}

#function to remove old backups

purge () {

	local limit=$1
	local user=$2
	local directory=$3
	local file
	local filenumber=0
	local counter=0
	local status=0

	filenumber=$(find "$directory" -iname "$user*.tgz" |wc -l)

	if [ $filenumber -gt $limit ]; then
		while [ $filenumber -gt $limit ]
		do
			file=$(find "$directory" -iname "$user*.tgz"|sort|head -n 1)
			rm $file 
				if [ $? -ne 0 ]; then			
					echo "Error deleting $file" #an error does not stop the loop. We keep deleting files
					status=$ERR_DELETION
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
    echo "ERROR $PROG :Must be root to execute script"
    exit $ERR_NOROOT
fi

#test if tar executable exists


if [ -z "$TAR" ]; then
    echo "Error $PROG: tar executable not found."
    exit $ERR_NOTAR
fi


#number of argument control
if [$# -eq 3]; then

#number or retention control
    if [ $limit -ge 1 && $limit -le 12 ]; then

#existence of user control
        if id "$user"  > /dev/null 2>&1 ; then;
        homedir=$(grep "^$user:" /etc/passwd | cut -d ":" -f6)

#home directory is correct control
            if [ -d $homedir ]; then      

                #call the backup function
                backup $limit $user $directory  
				
				if [ $? -ne 0]; then
				
					echo "$PROG: ERROR during the backup file generation"
					exit $?  #FIX THIS
				
				else
					#call the deletion function			
					purge $limit $user $directory 
				
					if [ $? -ne 0]; then
						echo "$PROG: ERROR during deletion of old backups"
						exit $?  #backup and deletion of extra files has happened but in case of errors during the process exit code is not 0
					fi
				
            else
				echo "ERROR: $PROG.  The home directory for that user does not exist or is unreachable"
				echo "USAGE userbk.sh [number retentions (1-12)] [user] [target directory]"
				exit $ERR_BADHOME
        fi   
            fi

        else
            echo "ERROR: $PROG.  The specified user do not exist"
			echo "USAGE userbk.sh [number retentions (1-12)] [user] [target directory]"
			exit $ERR_BADUSER
        fi

    else
        echo "ERROR: $PROG.  Specified number of backups to keep is to low or to high. "
		echo "USAGE userbk.sh [number retentions (1-12)] [user] [target directory]"
		exit $ERR_BADPARM
    fi

else
    echo "ERROR: $PROG.  Incorrect number of parameters"
	echo "USAGE userbk.sh [number retentions (1-12)] [user] [target directory]"
	exit $ERR_BADPARM
fi

exit 0

