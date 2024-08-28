#!/bin/bash


usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -p SERVER_PREFIX"
        exit 1
}
check_args()
{
	if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$SERVER_PREFIX" ]]
        then
                echo "ERROR: You must give a server prefix, eg EBAS"
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

while getopts "c:m:p:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
	m) MOUNTPOINT="$OPTARG"
	;;
	p) SERVER_PREFIX="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

X_STOR_BASE_VIP=`eval echo \\$${SERVER_PREFIX}_STOR_BASE_VIP`
X_STOR_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_STOR_HOSTNAME`
X_STOR_BASE_NIC=`eval echo \\$${SERVER_PREFIX}_STOR_BASE_NIC`

if [[ "$X_STOR_BASE_VIP" != "" ]] && [[ ! `grep "$X_STOR_HOSTNAME" /etc/hosts` ]]
then
#	ifconfig $X_STOR_BASE_NIC plumb
#	ifconfig $X_STOR_BASE_NIC inet $X_STOR_BASE_VIP netmask $STOR_NETMASK up
        ipadm create-ip $X_STOR_BASE_NIC
        ipadm create-addr -T static -a local=$X_STOR_BASE_VIP $X_STOR_BASE_NIC
	echo "$STOR_NETWORK $STOR_NETMASK" >> /etc/netmasks
#	echo "$X_STOR_HOSTNAME" > /etc/hostname.${X_STOR_BASE_NIC}
	echo "$X_STOR_BASE_VIP $X_STOR_HOSTNAME" >>/etc/hosts
fi

