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

full_oss_version=`grep CP_STATUS /var/opt/ericsson/sck/data/cp.status | awk '{print $2}' | sed 's/_Shipment_/ /g'`
oss_release=`echo -n $full_oss_version | awk '{print $1}'`
oss_shipment=`echo -n $full_oss_version | awk '{print $2}'`
if [[ "$oss_shipment" == "" ]] || [[ "$oss_release" == "" ]]
then
	echo "ERROR: Couldn't figure out oss release and shipment, from cp.status, see below"
	grep CP_STATUS /var/opt/ericsson/sck/data/cp.status
	exit 1
fi
#echo "Detected OSS Release $oss_release Shipment $oss_shipment"
DATE_STRING=`date | awk '{print $2 "_" $3 "_" $NF "_" $4}'`
OUTPUT=`$MOUNTPOINT/bin/baseline_compare_evo.sh -c "${DATE_STRING}_$$" -b ii -r $oss_release -s $oss_shipment`
NUMBER_MISSING=`echo "$OUTPUT" | grep "No. of Packages missing" | awk -F: '{print $2}'`
if [[ "$NUMBER_MISSING" != "0" ]]
then
	echo "$OUTPUT"
	exit 1
else
	echo "OK"
	exit 0
fi
