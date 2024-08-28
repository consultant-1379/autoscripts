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

NEW_URL="https://${OMSERVS_HOSTNAME}:8443/ericsson/servlet/sls"

if [[ `/opt/ericsson/saoss/bin/security.ksh -settings | grep "^$NEW_URL$"` ]]
then
	echo "INFO: This sls url $NEW_URL already exists, not adding again."
	exit 0
fi
	$EXPECT - <<EOF
	set force_conservative 1
	set timeout -1

	spawn /opt/ericsson/saoss/bin/security.ksh -addSlsUrl
	while {"1" == "1"} {
	expect {
		"End of example" {
			expect "Enter SLS URL: >" {
				send "$NEW_URL\r"
			}
			expect "Confirm SLS URL by entering it again: >" {
				send "$NEW_URL\r"
			}
		}
		"Do you want to proceed"
		{
			send "Yes\r"
		}
		eof
		{
			exit 0
		}
	}
EOF
