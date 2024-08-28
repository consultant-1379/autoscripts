#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG"
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

cd /
$EXPECT - <<EOF
set force_conservative 1
set timeout -1

spawn /opt/ericsson/sck/bin/system_upgrade.bsh -jump_start ${MWS_BACKUP_IP}@${ADM1_APPL_MEDIA_LOC}
while {"1" == "1"} {
	expect {
		"FATAL ERROR in stage" {
			sleep 5
			send "\r"
			sleep 5
			exit 1
		}
		"System Upgrade is complete" {
			exit 0
		}
		"This upgrade script is not intended for this release, please verify current installed ERICusck" {
			exit 1
		}
		-re {Upgrade OSS-RC} {
			sleep 5
			exit 0
		}
		"Do you want to proceed from that stage" {
			sleep 1
			send "n\r"
		}
		"Please press Return to go back to your normal shell"
		{
			send_user "\nERROR: Exited the system_upgrade.bsh with a message that we havn't seen before, please update scripts to handle this\n"
			exit 1
		}
		eof
                {
                        catch wait result
                        exit [lindex \$result 3]
                }
	}
}
EOF
