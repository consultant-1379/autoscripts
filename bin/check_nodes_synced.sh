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

# Sleep to let the ying / yang file get an update after last arne import
sleep 60

while true
do
	LATEST_STATUS_FILE=`ls -tr /var/opt/ericsson/nms_umts_cms_nead_seg/neadStatus.log.* | tail -1`
	STATUS=`cat "$LATEST_STATUS_FILE" | egrep '^TOTAL_NODES|^NEVERCONNECTED_NODES|^DEAD_NODES|^ALIVE_NODES|^SYNCED_NODES|^COMPATIBLE_NODES|^ATTRIBUTE_SYNC_NODES|^TOPOLOGY_SYNC_NODES|^UNSYNCED_NODES|^SYNCHRONIZATION_ONGOING_RNC|^SYNCHRONIZATION_ONGOING_RBS|^SYNCHRONIZATION_ONGOING_RANAG' | tail -12`
	TOTAL=`echo "$STATUS" | grep "^TOTAL_NODES" | awk '{print $3}'`
	SYNCED=`echo "$STATUS" | grep "^SYNCED_NODES" | awk '{print $3}'`

	if [[ "$SYNCED" == "$TOTAL" ]]
	then
		echo "Total: $TOTAL"
	        echo "Synced: $SYNCED"
		exit 0
	fi

	if [[ "$STATUS" != "$PREV_STATUS" ]]
	then
		TRYNO=0
	else
		let TRYNO=TRYNO+1
		if [[ $TRYNO -eq 7 ]]
		then
			echo "Total: $TOTAL"
		        echo "Synced: $SYNCED"
			exit 1
		fi
	fi
	PREV_STATUS="$STATUS"
	sleep 10
done
