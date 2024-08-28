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

touch /var/opt/ericsson/sck/log/HA_split_cluster_proc_`date +%Y-%m-%d-%H-%M`.log

$EXPECT - <<EOF
set force_conservative 1
set timeout -1

spawn /opt/ericsson/sck/bin/split_cluster
while {"1" == "1"} {
	expect {
		"The Split Cluster has already finished or has been run before on this system" {
			sleep 1
			send "n\r"
		}
		"Confirm execution from stage 1" {
			send "y\r"
		}
		"assword:" {
			send "shroot\r"
		}
		-re {Stage . failed} {
			sleep 1
			send_user "\nERROR: Detected a stage failing during split cluster, see above output\n"
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
