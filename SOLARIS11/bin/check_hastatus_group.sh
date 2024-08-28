#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -g GROUP -s SYSTEM"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$GROUP" ]]
        then
                echo "ERROR: You must say what group to check"
                exit 1
        fi
	if [[ -z "$SYSTEM" ]]
        then
                echo "ERROR: You must say what group to check"
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

while getopts "m:c:g:s:" arg
do
    case $arg in
		m) MOUNTPOINT="$OPTARG"
        ;;
		g) GROUP="$OPTARG"
		;;
		c) CONFIG="$OPTARG"
		;;
		s) SYSTEM="$OPTARG"
		;;
		\?) usage_msg
            exit 1
        ;;
    esac
done

check_args

OUTPUT_LINE=`/opt/VRTS/bin/hastatus -sum 2>&1 | grep "$GROUP " |grep "$SYSTEM" | head -1`
OUTPUT_RESULT=`echo "$OUTPUT_LINE" | awk '{print $6}'`
echo "$OUTPUT_LINE"
if [[ "$OUTPUT_RESULT" == "ONLINE" ]]
then
	exit 0
else
	exit 1
fi
