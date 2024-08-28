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

cp /etc/resolv.conf /etc/resolv.conf_$$
svccfg -s /network/dns/client setprop config/search = astring: $DNSDOMAIN
svccfg -s /network/dns/client<<EOF
setprop config/nameserver=net_address: ("$NAMESERVERS")
exit
EOF
svcadm disable "dns/client"  
svcadm enable "dns/client"  
svcadm refresh "dns/client"

cp /etc/nsswitch.conf /etc/nsswitch.conf_$$
svccfg -s name-service/switch setprop config/host = astring: '("files dns")'

