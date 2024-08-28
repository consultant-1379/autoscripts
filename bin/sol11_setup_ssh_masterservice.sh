#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c $CONFIG"
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
. $MOUNTPOINT/expect/expect_functions

PASSPHRASE=""

mkdir /root/.ssh > /dev/null 2>&1
chmod 0700 /root/.ssh
cd /root/.ssh

if [[ -f /root/.ssh/id_rsa ]] && [[ -f /root/.ssh/id_rsa.pub ]]
then
	echo "OK"
else


	$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

	spawn ssh-keygen -t rsa
	expect "Enter file in which to save the key" {send "\r"}
	expect "Enter passphrase" { send "$PASSPHRASE\r" }
	expect "Enter same passphrase again:" {send "$PASSPHRASE\r"}
	expect eof
EOF

fi

$EXPECT - <<EOF
	set force_conservative 1
        set timeout -1

	spawn scp -o StrictHostKeyChecking=no id_rsa.pub $ADM1_HOSTNAME:/home/comnfadm/.ssh/OMINFServer.pub
	while 1 {
		expect {
			"assword:" {
				send "shroot12\r"
			}
			eof {
				exit 0
			}
		}
	}

EOF
