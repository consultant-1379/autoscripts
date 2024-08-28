#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -r COMMAND"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$COMMAND" ]]
        then
                echo "ERROR: You must give a nascli command to run"
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

while getopts "m:c:r:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	r) COMMAND="$OPTARG"
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

$EXPECT << EOF
set force_conservative 1
set timeout -1
spawn /ericsson/storage/bin/nascli $COMMAND

while 1 {
	expect {
		"Do you really want to continue" {
			send "y\r"
		}
		eof {
			catch wait result
			exit [lindex \$result 3]
		}
	}
}
EOF

