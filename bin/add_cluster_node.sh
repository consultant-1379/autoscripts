#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PREFIX"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$PREFIX" ]]
        then
                echo "ERROR: You must say what the prefix of the node to add is"
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
	p) PREFIX="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
X_IPV6_ADDR=`eval echo \\$${PREFIX}_IPV6_ADDR`
X_ROUTER_IP_ADDR_V6=`eval echo \\$${PREFIX}_ROUTER_IP_ADDR_V6`
X_IP_ADDR=`eval echo \\$${PREFIX}_IP_ADDR`
X_CLIENT_IP_ADDR_V6=`eval echo \\$${PREFIX}_CLIENT_IP_ADDR_V6`

if [[ "$PREFIX" == "ADM2" ]]
then
	PREFIXWADM="ADM2_"
fi

X_STOR_BASE_IP1=`eval echo \\$${PREFIXWADM}STOR_BASE_IP1`
X_STOR_BASE_IP2=`eval echo \\$${PREFIXWADM}STOR_BASE_IP2`
X_STOR_BASE_VIP=`eval echo \\$${PREFIXWADM}STOR_BASE_VIP`
X_BASE_IP1=`eval echo \\$${PREFIXWADM}BASE_IP1`
X_BASE_IP2=`eval echo \\$${PREFIXWADM}BASE_IP2`
X_BACKUP_IP=`eval echo \\$${PREFIXWADM}BACKUP_IP`

number_of_disk_mirrors=`vxdisk list | awk '{print $3}' | grep disk | grep -c mirr`
if [[ $number_of_disk_mirrors -gt 0 ]]
then
        # Mirrored
        mirror_number="2"
else
        mirror_number="1"
fi

X_IPV6_PREFIX=`echo "$X_CLIENT_IP_ADDR_V6" | awk -F/ '{print $2}'`

$EXPECT - <<EOF
set force_conservative 1
set timeout -1

spawn /ericsson/core/cluster/bin/add_cluster_node
	while {"1" == "1"} {
	expect {
		"The following systems are defined"
		{
			expect {
				"SYSTEM_2"
				{
					expect "Do you want to add/modify a system" {
						send "n\r"
						exit 7
					}
				}
				"Do you want to add/modify a system"
				{
					send "y\r"
				}
			}
		}
		"IPv6address"
		{
			send "$X_IPV6_ADDR\r"
		}
		"IPv6 subnet prefix length"
		{
			send "$X_IPV6_PREFIX\r"
		}
		"Default IPv6 router"
		{
			send "$X_ROUTER_IP_ADDR_V6\r"
		}
		"Enter hostname of system to add or modify"
		{
			send "$X_HOSTNAME\r"
		}
		"$X_HOSTNAME]:"
		{
			send "\r"
		}
		"IPaddress"
		{
			send "$X_IP_ADDR\r"
		}
		"root PASSWD for"
		{
			send "shroot\r"
		}
		"First Storage LAN NIC (NIC1) Base IP address"
		{
			send "$X_STOR_BASE_IP1\r"
		}
		"Second Storage LAN NIC (NIC2) Base IP address"
		{
			send "$X_STOR_BASE_IP2\r"
		}
		"First Storage LAN NIC (NIC1)"
		{
			send "\r"
		}
		"Second Storage LAN NIC (NIC2)"
		{
			send "\r"
		}
		"Storage IP Address"
		{
			send "$X_STOR_BASE_VIP\r"
		}
		"Storage LAN Netmask"
		{
			send "$STOR_NETMASK\r"
		}
		"First Public LAN NIC (NIC1) Base IP address"
		{
			send "$X_BASE_IP1\r"
		}
		"Second Public LAN NIC (NIC2) Base IP address"
		{
			send "$X_BASE_IP2\r"
		}
		"First Public LAN NIC (NIC1)"
		{
			send "\r"
		}
		"Second Public LAN NIC (NIC2)"
		{
			send "\r"
		}
		"Public LAN Netmask"
		{
			send "$PUB_NETMASK\r"
		}
		"Public LAN default router"
		{
			send "$PUB_ROUTER\r"
		}
		"First Cluster Heartbeat NIC (NIC1)"
		{
			send "\r"
		}
		"Second Cluster Heartbeat NIC (NIC2)"
		{
			send "\r"
		}
		"Private LAN NIC IP address"
		{
			send "\r"
		}
		"Private LAN NIC"
		{
			send "\r"
		}
		"Private LAN Netmask"
		{
			send "\r"
		}
		"Backup LAN NIC IP address"
		{
			send "$X_BACKUP_IP\r"
		}
		"Backup LAN NIC"
		{
			send "\r"
		}
		"Backup LAN Netmask"
		{
			send "$BACKUP_NETMASK\r"
		}
		"Are these values correct"
		{
			send "y\r"
		}
		"How many mirrors should be defined" {
                        send "$mirror_number\r"
                }
                "Is this a good mirror definition" {
                        send "y\r"
                }
		"Fix now"
		{
			send "y\r"
		}
		"or more"
		{
			send "y\r"
		}
		eof {
			catch wait result
			exit [lindex \$result 3]
		}
	}
EOF
