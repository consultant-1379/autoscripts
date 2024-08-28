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

echo "INFO: Unblocking disk access"
/opt/ericsson/sck/bin/split_cluster unblock_disk_access
if [[ $? -ne 0 ]]
then
        echo "ERROR: There was a problem unblocking disk access"
        exit 1
fi

echo "INFO: Resyncing the mirrors"
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1
	spawn /ericsson/dmr/bin/dmtool sy
	while {"1" == "1"} {
		expect {
			"Enter selection" {
				sleep 1
				send "2\r"
			}
			"Skip Re-Mirror of root disk" {
				sleep 1
				send "y\r"
			}
			"Continue" {
				sleep 1
				send "y\r"
			}
			"Do you want to re-mirror one side" {
				sleep 1
				send "y\r"
			}
			"But cannot access" {
				sleep 1
				send_user "\nERROR: Wasn't expecting to see this question, please check why it was asked\n"
				exit 1
			}
			eof {
				catch wait result
				exit [lindex \$result 3]
		        }
		}
	}
EOF

if [[ $? -ne 0 ]]
then
        echo "ERROR: There was a problem syncing the mirrors"
        exit 1
fi

/dmr/dmtool m 2

echo "INFO: Removing ERICusck package"
pkgrm -n ERICusck
if [[ $? -ne 0 ]]
then
        echo "ERROR: There was a problem removing ERICusck"
        exit 1
fi
