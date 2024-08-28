#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -n network_type -u aif_username -p aif_password -s slave_service_name"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$NET_TYPE" ]]
        then
                echo "ERROR: You must say what network type"
                exit 1
        fi
	if [[ -z "$AIF_USER" ]]
        then
                echo "ERROR: You must say what the aif username is"
                exit 1
        fi
	if [[ -z "$AIF_PASS" ]]
        then
                echo "ERROR: You must say what the aif user password is"
                exit 1
        fi
	if [[ -z "$SLAVE_SERVICE" ]]
        then
                echo "ERROR: You must say what the slave service name is"
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

while getopts "m:c:n:u:p:s:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	n) NET_TYPE="$OPTARG"
	;;
	u) AIF_USER="$OPTARG"	
	;;
	p) AIF_PASS="$OPTARG"
	;;
	s) SLAVE_SERVICE="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn /opt/ericsson/nms_bismrs_mc/bin/configure_smrs.sh add aif
while {"1" == "1"} {
expect {
	"Enter Network Type" {
		send "$NET_TYPE\r"
	}
	"What is the name for this user" {
		send "$AIF_USER\r"
	}
	"the password for this user" {
		send "$AIF_PASS\r"
	}
	"Would you like to create autoIntegration FtpService for that user" {
		send "yes\r"
	}
	"Do you wish to restart BI_SMRS_MC on the OSS master if required" {
		send "yes\r"
	}
	-re {SMRS Slave Service.*\(([0-9]+)\) $SLAVE_SERVICE.*Please enter number of required option:} {
		send "\$expect_out(1,string)\r"
	}
	eof {
		catch wait result
		exit [lindex \$result 3]
	}
	}
}
EOF
