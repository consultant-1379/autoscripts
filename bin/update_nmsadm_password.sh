#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -o CURRENT_PASS -n NEW_PASS"
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
	if [[ -z "$CURRENT_PASS" ]]
        then
                echo "ERROR: You must give the current password"
                exit 1
        fi

}

while getopts "m:n:o:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	o) CURRENT_PASS="$OPTARG"
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

echo "INFO: Updating the nmsadm password"
$EXPECT - <<EOF
set force_conservative 1
set timeout 20

spawn /opt/ericsson/sck/bin/update_nmsadm.ksh
while 1 {
        expect {
                "Enter current nmsadm password" {send "$CURRENT_PASS\r"}
                "ew Password:" {send "$NEW_PASS\r"}
        eof { break }
}
EOF
