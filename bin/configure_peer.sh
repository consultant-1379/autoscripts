#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PEER_PREFIX (eg PEER1)"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
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

while getopts "m:c:p:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	p) PEER_PREFIX="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions


## Workaround for missing virtual nics
if [[ ! `grep Virtual_e1000g /ericsson/peer_tools/bin/configure_ipmp` ]]
then
	echo "INFO: Performing workaround on /ericsson/peer_tools/bin/configure_ipmp for missing Virtual nics"
	sed 's/Gen8_bnxe/Virtual_e1000g)my_nics=(e1000g0 e1000g1 e1000g2 e1000g3 e1000g4 e1000g5);;Gen8_bnxe/g' /ericsson/peer_tools/bin/configure_ipmp > /ericsson/peer_tools/bin/configure_ipmp.tmp
	mv /ericsson/peer_tools/bin/configure_ipmp.tmp /ericsson/peer_tools/bin/configure_ipmp
	chmod 777 /ericsson/peer_tools/bin/configure_ipmp
fi

#PEERX_VAR=`eval echo \\$${PEER_PREFIX}_VAR`
#PEERX_IP_ADDR=`eval echo \\$${PEER_PREFIX}_IP_ADDR`
PEERX_PUB_BASE_IP1=`eval echo \\$${PEER_PREFIX}_PUB_BASE_IP1`
PEERX_PUB_BASE_IP2=`eval echo \\$${PEER_PREFIX}_PUB_BASE_IP2`
PEERX_STOR_BASE_IP1=`eval echo \\$${PEER_PREFIX}_STOR_BASE_IP1`
PEERX_STOR_BASE_IP2=`eval echo \\$${PEER_PREFIX}_STOR_BASE_IP2`
PEERX_STOR_BASE_VIP=`eval echo \\$${PEER_PREFIX}_STOR_BASE_VIP`
PEERX_BACKUP_IP=`eval echo \\$${PEER_PREFIX}_BACKUP_IP`

$EXPECT - <<EOF
set force_conservative 1
set timeout -1

spawn /ericsson/peer_tools/bin/configure_peer
	while {"1" == "1"} {
	expect {
		"Do you want to accept these defaults"
		{
			send "YES\r"
		}
		"Public physical IP address for"
		{
			send "$PEERX_PUB_BASE_IP1\r"
			expect "Public physical IP address for" {
				send "$PEERX_PUB_BASE_IP2\r"
			}
		}
		"Default router IP address"
		{
			send "$PUB_ROUTER\r"
		}
		"Public VLAN netmask"
		{
			send "$PUB_NETMASK\r"
		}
		"Backup physical IP address for"
		{
			send "$PEERX_BACKUP_IP\r"
		}
		"Backup VLAN netmask"
		{
			send "$BACKUP_NETMASK\r"
		}
		"Storage physical IP address for"
		{
                        send "$PEERX_STOR_BASE_IP1\r"
			expect "Storage physical IP address for" {
	                        send "$PEERX_STOR_BASE_IP2\r"
                	}
                }
		"Storage VIP address"
		{
                        send "$PEERX_STOR_BASE_VIP\r"
                }
		"Storage VLAN Netmask"
		{
                        send "$STOR_NETMASK\r"
                }
		"Do you want to accept these changes"
		{
			send "YES\r"
		}

		eof
		{
			exit 0
		}
	}
EOF
