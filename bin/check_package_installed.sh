#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PACKAGE"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$PACKAGE_NAME" ]]
        then
                echo "ERROR: You must say what package to check"
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

while getopts "m:c:p:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	p) PACKAGE_NAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

OUTPUT=`pkginfo -l $PACKAGE_NAME`
if [[ `echo "$OUTPUT" | grep 'STATUS:  completely installed'` ]]
then
	echo "STATUS:  completely installed"
	exit 0
else
	echo "$OUTPUT"
	exit 1
fi
