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

pkginfo -q ERICaiws
if [[ $? -ne 0 ]]
then
	exit 0
fi

svcs -a
/opt/ericsson/secinst/bin/config.sh -p ERICcsa:deploy -f
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn bash -x /opt/ericsson/secinst/bin/config.sh -p ERICaiws:gennetconfmgr
while {"1" == "1"} {
expect {
	"Do you wish to generate"
        {
                sleep 1
                send "y\r"
        }
        "assword:"
        {
                send "shroot\r"
        }
        "Are you sure you want to continue connecting"
        {
                send "yes\r"
        }
	eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
EOF

if [[ $? -ne 0 ]]
then
	exit 1
fi

if [[ `grep piconotargetusr /opt/ericsson/secinst/bin/inc/config_ERICaiws.sh.inc` ]]
then
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn bash -x /opt/ericsson/secinst/bin/config.sh -p ERICaiws:piconotargetusr
while {"1" == "1"} {
expect {
        "Do you wish to create"
        {
                sleep 1
                send "y\r"
        }
        "assword:"
        {
                send "shroot\r"
        }
        "Are you sure you want to continue connecting"
        {
                send "yes\r"
        }
	eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
EOF
fi
