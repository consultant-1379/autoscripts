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

cat /ericsson/config/cluster.ini | grep -v "UseFence" > /ericsson/config/cluster.ini.tmp
mv /ericsson/config/cluster.ini.tmp /ericsson/config/cluster.ini
