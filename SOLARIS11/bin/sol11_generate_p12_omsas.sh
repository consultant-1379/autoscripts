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

while getopts "m:c:i:" arg
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

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

        spawn bash -x /opt/ericsson/secinst/bin/credentialsmgr.sh -msCredentials ${UNIQUE_MASTERSERVICE}
        while {"1" == "1"} {
        expect {
		"Identified as HA Blade system. Script will copy"
		{
			exit 0
		}
                "assword:"
                {
                        send "shroot12\r"
                }
		"Are you sure you want to continue connecting"
		{
			send "yes\r"
		}
                eof
                {
                        catch wait result
	                exit [lindex \$result 3]
                }
        }
EOF
