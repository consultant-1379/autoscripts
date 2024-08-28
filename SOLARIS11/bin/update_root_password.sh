#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -n NEW_PASS"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$NEW_PASS" ]]
        then
                echo "ERROR: You must give the new password"
                exit 1
        fi

}

while getopts "m:n:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	n) NEW_PASS="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

echo -n "INFO: Updating the root password on `hostname`: "
output=$($EXPECT - <<EOF
set force_conservative 1
set timeout 20

spawn passwd 
while 1 {
        expect {
                "assword:" {send "$NEW_PASS\r"}
        	eof { break }
}
EOF
)
echo "OK"
