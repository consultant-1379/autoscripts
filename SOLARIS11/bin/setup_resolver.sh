#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG"
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

echo "domain $DNSDOMAIN" > /etc/resolv.conf
echo "$NAMESERVERS" | while read line
do
	echo "nameserver $line" >> /etc/resolv.conf
done

sed 's/^hosts:.*/hosts:      files dns/g' /etc/nsswitch.conf > /etc/nsswitch.conf.temp
mv /etc/nsswitch.conf.temp /etc/nsswitch.conf
