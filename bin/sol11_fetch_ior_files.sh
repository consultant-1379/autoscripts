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

# Compare ERICcadm package pstamp to the one that introduced visisupport change
ERICcadm_PSTAMP=`pkginfo -l ERICcadm | grep PSTAMP | awk -F'bx' '{print $2}' | sed 's/^.//'`
if [[ "$ERICcadm_PSTAMP"  -ge "20150312171347" ]] ; then
	CONFIG_PATH="/opt/ericsson/secinst/bin/config.sh -p ERICcadm:msior -p ERICcadm:smfservice -p ERICcadm:visisupport"
else
       CONFIG_PATH="/opt/ericsson/secinst/bin/config.sh -p ERICcadm:msior -p ERICcadm:smfservice "
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn  ${CONFIG_PATH} 
while {"1" == "1"} {
expect {

	"and fetch the IOR"
        {
                send "y\r"
        }
	"and fetch the\r\nIOR"
	{
		send "y\r"
	}
        "*assword:"
        {
                send "shroot12\r"
        }
        "Do you wish to connect to"
        {
                send "y\r"
        }

	eof
	{
		catch wait result
		exit [lindex \$result 3]
	}

}
EOF
