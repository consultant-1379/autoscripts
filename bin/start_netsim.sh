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

CURRENT_VERSION=`ls -ltrh /netsim/inst | awk -F/ '{print $5}'`
VERSION_RUNNING="`ps -ef | grep platf_indep | grep netsim | awk '{print $8}' | awk -F/ '{print $3}' | head -1`"
if [[ "$VERSION_RUNNING" != "$CURRENT_VERSION" ]] && [[ "$VERSION_RUNNING" != "" ]] && [[ -d /netsim/$VERSION_RUNNING/ ]]
then
	$MOUNTPOINT/bin/stop_netsim.sh -c $CONFIG -m $MOUNTPOINT
fi

if [[ "$VERSION_RUNNING" != "$CURRENT_VERSION" ]]
then
	echo "INFO: Starting netsim version $CURRENT_VERSION"
	su - netsim -c "/netsim/inst/start_netsim"
else
	echo "INFO: Netsim already started, not starting again"
fi
