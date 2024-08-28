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

enable_sunds_replication()
{
$EXPECT - <<EOF
        set force_conservative 1
        set timeout 60
        spawn /ericsson/sdee/bin/prepReplication.sh
        expect "LDAP Directory Manager password:" {send "$dm_pass\r"}
        expect "Enter option number:" {send "1\r"}
        expect "Do you want return to the main menu" {send "y\r"}
        expect "Enter option number:" {send "2\r"}
        expect "Enter Replication destination FQHN" {send "$TO\r"}
        expect {
                "Do you want return to the main menu" {
                        send "n\r"
                        expect eof
                }
                "password:" {
                        send "$dm_pass\r"
                        expect "password:" {send "$dm_pass\r"}
                        expect "Continue to setup replication" {send "Y\r"}
                        expect "Do you want return to the main menu" {send "n\r"}
                        expect eof
                }
        }
EOF
}

enable_opendj_replication()
{
$EXPECT - <<EOF
        set force_conservative 1
        set timeout 60
        spawn /ericsson/opendj/bin/prepReplication.sh
        expect "LDAP Directory Manager password:" {send "$dm_pass\r"}
        expect "Enter option number:" {send "1\r"}
        #expect "Do you want return to the main menu" {send "y\r"}
        #expect "Enter option number:" {send "2\r"}
        expect "Enter Replication destination FQHN" {send "$TO\r"}
        expect {
                "Do you want return to the main menu" {
                        send "n\r"
                        expect eof
                }
                "password:" {
                        send "$dm_pass\r"
                        expect "password:" {send "$dm_pass\r"}
                        expect "Continue to setup replication" {send "Y\r"}
                        expect "Do you want return to the main menu" {send "n\r"}
                        expect eof
                }
        }
EOF
}

# Added a check for LDAP backward compatibility.
if pgrep ns-slapd > /dev/null; then
	enable_sunds_replication
else
	enable_opendj_replication
fi
