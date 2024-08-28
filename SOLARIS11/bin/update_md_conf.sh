#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
}

while getopts "m:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

if [ ! -r /kernel/drv/md.conf.sav ] ; then
	cp /kernel/drv/md.conf /kernel/drv/md.conf.sav
fi
echo "md_devid_destroy=1;" > /kernel/drv/md.conf
cat /kernel/drv/md.conf.sav >> /kernel/drv/md.conf

echo "INFO: Finished updating the md.conf file."
cat /kernel/drv/md.conf
echo "-----------------------------------------"
