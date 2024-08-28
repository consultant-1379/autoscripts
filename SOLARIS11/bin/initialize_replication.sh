#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -t TO -m MOUNTPOINT"
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

	if [[ -z $TO ]]
	then
		echo "ERROR: You must set the to variable -t"
		usage_msg
	fi
}

while getopts "c:t:m:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
	t) TO="$OPTARG"
	    ;;
	m) MOUNTPOINT="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

# Added a check for LDAP script.
if pgrep ns-slapd > /dev/null; then
        PREP_REPLICATION_SCRIPT=/ericsson/sdee/bin/prepReplication.sh
	l_opt=4
else
        PREP_REPLICATION_SCRIPT=/ericsson/opendj/bin/prepReplication.sh
	l_opt=3
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout 60
        spawn ${PREP_REPLICATION_SCRIPT}
        expect "LDAP Directory Manager password:" {send "$dm_pass\r"}
        expect "Enter option number:" {send "$l_opt\r"}
        expect "Enter Replication destination FQHN" {send "$TO\r"}
        expect "Continue to Initialize Replication from" {send "Y\r"}
        expect "Do you want return to the main menu" {send "n\r"}
        expect eof
EOF
