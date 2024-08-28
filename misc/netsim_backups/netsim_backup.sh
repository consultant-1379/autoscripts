#!/bin/bash

function usage_msg ()
{
        echo "USAGE: $0 -t <test_area_name> -u <username> -a <backup | restore | list> -n <unique name of the backup> -f [to force overwriting old backups]"
	echo "EXAMPLE: $0.sh -t eth1 -u ekemark -a restore -n lte_1225_backup"
        exit 1
}

function check_args()
{

	if [[ `whoami` != "root" ]]
	then
		echo "ERROR: You must run this script as user root"
		exit 1
	fi


	if [[ -z "$ACTION" ]]
        then
                usage_msg
        else
                if [[ "$ACTION" != "backup" ]] && [[ "$ACTION" != "restore" ]] && [[ "$ACTION" != "list" ]]
                then
                        usage_msg
                fi
        fi

	if [[ "$ACTION" != "list" ]]
	then
		if [[ -z "$USERNAME" ]]
	        then
			echo "ERROR: You must specify a username using -u"
	                usage_msg
		fi
		if [[ -z "$TESTAREA" ]]
	        then
			echo "ERROR: You must specify a testarea using -t"
	                usage_msg
	        fi
	
		if [[ -z "$UNIQUE_NAME" ]]
	        then
			echo "ERROR: You must specify a unique backup name using -n"
	                usage_msg
		fi
	fi
}

while getopts "t:n:u:a:f" arg
do
    case $arg in
        a) ACTION="$OPTARG"
        ;;
	n) UNIQUE_NAME="$OPTARG"
	;;
	u) USERNAME="$OPTARG"
	;;
	t) TESTAREA="$OPTARG"
	;;
	f) FORCE="yes"
	;;
        \?) usage_msg
        exit 1
        ;;
    esac
done

check_args

LOCATION="/netsim_backups/backups/$TESTAREA/$USERNAME/$UNIQUE_NAME/"

if [[ "$ACTION" = "backup" ]]
then
	if [[ -d $LOCATION ]]
	then
		if [[ "$FORCE" == "yes" ]]
		then
			INPUT="y"
		else
			echo -n "WARNING: A backup with this unique name already exists, do you want to overwrite it? (y\n): "
			read INPUT
		fi
		if [[ "$INPUT" == "y" ]]
		then
			echo "INFO: Removing existing backup with this name"
			rm -rf "$LOCATION"
		else
			echo "INFO: Not overwriting.."
			exit 1
		fi
	fi

	# Remove any old backups locally
        rm -rf /netsim/backup/ > /dev/null 2>&1
        rm -rf /netsim/backup.zip > /dev/null 2>&1

	# Backup the sims
	echo "INFO: Backing up sims"
	mkdir -p /netsim/backup/sims/

	SIMS=`su - netsim -c "echo '.show simulations' | /netsim/inst/netsim_pipe" | grep -v '.zip' | head -n -1 | tail -n +2`
	total=`echo "$SIMS" | wc -l`
	counter=1
	for sim in $SIMS
	do
		echo "INFO: Saving and compressing $sim, ($counter of $total)"
        	su - netsim -c "echo $sim | sed -e 's/\(.*\)/.open \1\n.saveandcompress force/' | /netsim/inst/netsim_pipe"
		cp /netsim/netsimdir/$sim.zip /netsim/backup/sims/
		let counter=counter+1
	done

	# Backup the configuration
	echo "INFO: Backuping up configuration"
	mkdir -p /netsim/backup/conf/

	su - netsim -c "echo -e '.select configuration\n.config export savedconf force\$\$ Description' | /netsim/inst/netsim_pipe"
        cp /netsim/netsimdir/exported_items/savedconf.configuration /netsim/backup/conf/

        # Make the backup zip containing sims and configuration
	echo "INFO: Zipping all backup files before moving to remote server"
        cd /netsim/
        zip -r backup.zip backup/

	# Copy the zip to remote server
	echo "INFO: Copying backup file to remote server"
	mkdir -p "$LOCATION"
	mv backup.zip "$LOCATION"
	# Remove any old backups locally
        rm -rf /netsim/backup/ > /dev/null 2>&1
        rm -rf /netsim/backup.zip > /dev/null 2>&1
	echo $(date +%d_%m_%Y) > "$LOCATION/date.txt"
	if [[ $? -eq 0 ]]
	then
		echo "INFO: Complete"
	else
		echo "ERROR: Something went wrong copying backup to the remote server"
	fi
elif [[ "$ACTION" == "restore" ]]
then

	if [[ ! -f "$LOCATION/backup.zip" ]] || [[ ! -f "$LOCATION/date.txt" ]]
	then
		echo "ERROR: Couldn't find a backup file to restore matching your inputs"
		exit 1
	fi

	# Remove any old backups locally
        rm -rf /netsim/backup/ > /dev/null 2>&1
	rm -rf /netsim/backup.zip > /dev/null 2>&1

	echo "INFO: Copying backup zip from backup location"
	cp "$LOCATION/backup.zip" /netsim/

	echo "INFO: Unzipping the backup"
        cd /netsim/
        unzip backup.zip

	cd /netsim/backup/sims
	SIMS="`ls *.zip`"
        mv /netsim/backup/sims/*.zip /netsim/netsimdir/

	echo "INFO: Restoring sims from backup"
	total=`echo "$SIMS" | wc -l`
        counter=1
	for sim in $SIMS
	do
		echo "INFO: Restoring $sim ($counter of $total)"
        	su - netsim -c "echo $sim | sed -e 's/\(.*\)/.uncompressandopen \1 force/' | /netsim/inst/netsim_pipe"
        	let counter=counter+1
	done

	echo "INFO: Restoring saved configuration"
        mv /netsim/backup/conf/savedconf.configuration /netsim/netsimdir/exported_items/
        su - netsim -c "echo -e '.select configuration\n.config import savedconf' | /netsim/inst/netsim_pipe"
	
	# Remove any old backups locally
        rm -rf /netsim/backup/ > /dev/null 2>&1
        rm -rf /netsim/backup.zip > /dev/null 2>&1

	echo "INFO: Restore complete"
elif [[ "$ACTION" == "list" ]]
then
	if [[ -z $TESTAREA ]]
	then
		TESTAREA="*"
	fi
	if [[ -z $USERNAME ]]
        then
		USERNAME="*"
        fi
	if [[ -z $UNIQUE_NAME ]]
        then
                UNIQUE_NAME="*"
        fi

	cd /netsim_backups/backups/
	ls -d $TESTAREA 2>/dev/null | while read ta
	do
		#echo "Test Area: $ta"
		cd /netsim_backups/backups/$ta/
		ls -d $USERNAME 2>/dev/null | while read user
		do
			cd /netsim_backups/backups/$ta/$user/
			ls -d $UNIQUE_NAME 2>/dev/null | while read unique
			do
				if [[ -f /netsim_backups/backups/$ta/$user/$unique/backup.zip ]] && [[ -f /netsim_backups/backups/$ta/$user/$unique/date.txt ]]
				then
					echo "TA: $ta -> User: $user -> Name: $unique -> Date: `cat /netsim_backups/backups/$ta/$user/$unique/date.txt`"
				fi
			done
		done
	done
fi

