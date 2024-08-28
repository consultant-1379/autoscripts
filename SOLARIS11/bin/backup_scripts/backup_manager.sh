#!/bin/bash

# Setup some variables
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Find subdirectories that are for specific backup types
cd $SCRIPT_HOME
BACKUP_TYPES=`ls */backup.sh | sed 's/\/backup.sh//g'`
# Create a temporary backup directory name to house all of the backups
TEMP_BACKUP_DIR=`date | awk '{print $2 "_" $3 "_" $NF}'`_`date | awk '{print $4}'`
BACKUP_DESTINATION=/cloud_backups/
BACKUP_QUANTITY=14
rm -rf /tmp/email_required > /dev/null 2>&1

# The send email function.
function send_email ()
{
	EMAIL_ADDRESSES=`cat /$SCRIPT_HOME/email_list.txt 2>/dev/null`
        local SUBJECT="$1"
        local CONTENTS="$2"
        if [[ "$EMAIL_ADDRESSES" != "" ]]
        then
                EMAIL_ADDRESSES=`echo "$EMAIL_ADDRESSES" | sed 's/;/\n/g' | sed 's/,/\n/g'`
                echo "$EMAIL_ADDRESSES" | while read ADDRESS
                do
                        echo "INFO: Emailing result to $ADDRESS"
                        /usr/sbin/sendmail -oi -t << EOF
From: noreply@ericsson.com
To: $ADDRESS
Subject: $SUBJECT
$CONTENTS
EOF
                done
        fi
}

# Start the script

# Remove the temporary backup directory if its there (unlikely)
if [[ -d /tmp/$TEMP_BACKUP_DIR ]]
then
	rm -rf /tmp/$TEMP_BACKUP_DIR
fi
mkdir -p /tmp/$TEMP_BACKUP_DIR

# Start creating the email_contents variable, which is sent if theres any problems with backups
echo -e "There were problems running the CLOUD Backup Scripts, see the issues below. Please fix these so that the next backup will be successful\n\n" > /tmp/email_contents
# Loop through tbe backup types found
for backup_type in $BACKUP_TYPES
do
	echo "==========================================================================="
	echo "Performing $backup_type backups"
	if [[ ! -f $SCRIPT_HOME/$backup_type/backup.sh ]] || [[ ! -f $SCRIPT_HOME/$backup_type/list.txt ]]
	then
		echo "ERROR: Couldn't find the two necessary files for this type of backup, ie $SCRIPT_HOME/$backup_type/backup.sh and $SCRIPT_HOME/$backup_type/list.txt"
		continue
	fi

	# Cleanup any old backup directories
	mkdir -p /tmp/backup/
	chmod 777 /tmp/backup/
	rm -rf /tmp/backup/*

	# Loop through the list for this backup type, calling its backup.sh script with each entry in the list
	cat $SCRIPT_HOME/$backup_type/list.txt | while read entry
	do
		echo "----------------------------------------------------------------------------"
		echo "Running $SCRIPT_HOME/$backup_type/backup.sh with arguments $entry"
		cd $SCRIPT_HOME/$backup_type/
		OUTPUT="`./backup.sh $entry 2>&1`"
		if [[ $? -eq 0 ]]
		then
			echo "INFO: The backup went ok"
			echo "$OUTPUT"
		else
			touch /tmp/email_required
			temp_contents="----------------------------------------------------------\nERROR: There was a problem with a backup of type $backup_type with arguments $entry. See output below.\n$OUTPUT\n"
			echo -e "$temp_contents" >> /tmp/email_contents
			echo -e "$temp_contents"
		fi
	done
	
	echo "----------------------------------------------------------------------------"
	echo "INFO: Moving the backup directory for all of the $backup_type backups /tmp/backup/ to the master backup directory /tmp/$TEMP_BACKUP_DIR/$backup_type/"
	mkdir -p /tmp/$TEMP_BACKUP_DIR/$backup_type/
	mv /tmp/backup/* /tmp/$TEMP_BACKUP_DIR/$backup_type/
	rm -rf /tmp/backup/
	echo "==========================================================================="
done

echo "INFO: Moving all of the backups, to the backup destination $BACKUP_DESTINATION"
# Move the entire backup directory, to the backup destination
mkdir -p $BACKUP_DESTINATION
OUTPUT=`mv /tmp/$TEMP_BACKUP_DIR/ /$BACKUP_DESTINATION/`
if [[ $? -ne 0 ]]
then
	temp_contents="\n\nERROR: There was a problem moving the temporary backup files to the destination directory /$BACKUP_DESTINATION/, see output below.\n$OUTPUT\n\n"
	touch /tmp/email_required
	echo -e "$temp_contents" >> /tmp/email_contents
	echo -e "$temp_contents"
else
	echo "INFO: Cleaning out old backups"
	# Keep only last 3 backups in the destination directory
	KEEPERS=`ls -tr $BACKUP_DESTINATION | tail -$BACKUP_QUANTITY`
	ls $BACKUP_DESTINATION | while read backup
	do
		if [[ ! `echo "$KEEPERS" | grep "^$backup$"` ]]
		then
			rm -rf $BACKUP_DESTINATION/$backup
		fi	
	done
fi
# Send summary email if needs be
if [[ -f /tmp/email_required ]]
then
	email_contents=`cat /tmp/email_contents`
	send_email "CLOUD Backup Script Issues - Please Check" "$email_contents"
fi

rm -rf /tmp/email_required > /dev/null 2>&1
rm -rf /tmp/email_contents > /dev/null 2>&1
