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

echo "INFO: Stopping ha"
hastop -all
if [[ $? -ne 0 ]]
then
	echo "ERROR: There was a problem running the hastop -all command"
	exit 1
fi

echo "INFO: Waiting for ha to go offline"
TIMEOUT=10
ATTEMPTS=360

HA_STOPPED=0
while [[ $HA_STOPPED -ne 1 && $TRY_NO -lt $ATTEMPTS ]]
do
        output="`hastatus -sum 2>&1`"
        if [[ $? -eq 0 ]]
        then
                sleep $TIMEOUT
                TRY_NO=$(( $TRY_NO+1 ))
        else
                HA_STOPPED=1
        fi
done

if [[ "$HA_STOPPED" -ne 1 ]]
then
	echo "ERROR: Ha didn't stop after $ATTEMPTS attempts with $TIMEOUT between each attempt.."
	exit 1
fi

echo "INFO: Disabling the vcs service"
/usr/sbin/svcadm disable -s svc:/system/vcs:default
if [[ $? -ne 0 ]]
then
	echo "ERROR: There was a problem disabling the vcs service"
	exit 1
fi
