#!/bin/bash


usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT"
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
. $MOUNTPOINT/expect/expect_functions

# citrix setup
    $EXPECT - <<EOF
    set force_conservative 1
    set timeout 30

    spawn /opt/CTXSmf/sbin/ctxfarm -c
    while {true} {
        expect {
            "Farm name" { send "${ADM1_HOSTNAME}farm\r" }
            "arm passphrase" { send "shroot\r" }
            eof {break}

        }
    }
EOF

$EXPECT - <<EOF
        set force_conservative 1
        set timeout 30

        spawn /opt/CTXSmf/sbin/ctxlsdcfg
    expect "License Config" {
        send "server $CITRIX_LICENSE_SERVER\r"
        expect "License Config" {
            send "exit\r"
            expect "Do you wish to save your changes" {
                send "y\r"
                expect eof
            }
        }
    }
EOF
DOMAIN_NAME=`grep domain /etc/resolv.conf | awk '{print$2}'`
if [[ ! `grep "${UAS1_HOSTNAME}.$DOMAIN_NAME" /etc/inet/hosts` ]]
then
	cat /etc/hosts | sed "s/^${UAS1_IP_ADDR}[	 ]/${UAS1_IP_ADDR} ${UAS1_HOSTNAME}.$DOMAIN_NAME /g" > /etc/hosts.tmp
	mv /etc/hosts.tmp /etc/inet/hosts
fi
l_cmd=`/usr/bin/sed 's/ServerFQDN='$UAS1_HOSTNAME'/ServerFQDN='$UAS1_HOSTNAME'.'$DOMAIN_NAME'/g' /var/CTXSmf/ctxxmld.cfg > /var/tmp/ctxxmld.cfg`
/usr/bin/cp /var/tmp/ctxxmld.cfg /var/CTXSmf/ctxxmld.cfg
