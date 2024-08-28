#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
		. $MOUNTPOINT/bin/load_config
        fi
}

while getopts "m:c:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

if [[ -d /var/opt/ericsson/sck/log/ ]]
then
	touch /var/opt/ericsson/sck/log/HA_start_upg_proc_`date +%Y-%m-%d-%H-%M`.log
fi
# Check does the mount point exist from before
if [[ -d /tmp/temp_mount_point/ossrc_base_sw/ ]]
then
	umount /tmp/temp_mount_point
	if [[ $? -ne 0 ]]
	then
	        echo "ERROR: Couldn't unmount /tmp/temp_mount_point, see error above"
	        exit 1
	fi
	rm -rf /tmp/temp_mount_point
fi

# Make the mountpoint
mkdir /tmp/temp_mount_point
mount ${MWS_BACKUP_IP}:${ADM1_APPL_MEDIA_LOC} /tmp/temp_mount_point
if [[ $? -ne 0 ]]
then
	echo "ERROR: Couldn't mount ${MWS_BACKUP_IP}:${ADM1_APPL_MEDIA_LOC} into /tmp/temp_mount_point, see error above"
	exit 1
fi

# Copy urwmom and update usck
cp /tmp/temp_mount_point/ossrc_base_sw/eric_app/common/ERICurwmom.pkg /ossrc/upgrade/
/tmp/temp_mount_point/ossrc_base_sw/inst_config/common/upgrade/update_usck.bsh -p /tmp/temp_mount_point/ossrc_base_sw/inst_config
if [[ $? -ne 0 ]]
then
	echo "ERROR: Something went wrong running update_usck.bsh, see error above"
	exit 1
fi

# Ummount
cd /
umount /tmp/temp_mount_point
rm -rf /tmp/temp_mount_point
