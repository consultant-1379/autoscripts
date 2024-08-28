#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT"
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

while getopts "c:m:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

VERSION_RUNNING="`ps -ef | grep platf_indep | grep netsim | awk '{print $8}' | awk -F/ '{print $3}' | head -1`"
if [[ "$VERSION_RUNNING" != "" ]]
then
	if [[ -d /netsim/$VERSION_RUNNING/ ]]
	then
		echo "INFO: Stopping netsim version $VERSION_RUNNING"
		su - netsim -c "/netsim/$VERSION_RUNNING/stop_netsim"
		exit $?
	fi
fi
echo "INFO: Netsim already stopped, not stopping again"
