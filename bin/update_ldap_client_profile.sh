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

# Added a check for LDAP script.
if pgrep ns-slapd > /dev/null; then
        PREP_REPLICATION_SCRIPT=/ericsson/sdee/bin/prepReplication.sh
	l_opt=8
else
        PREP_REPLICATION_SCRIPT=/ericsson/opendj/bin/prepReplication.sh
	l_opt=5
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout 60
        spawn ${PREP_REPLICATION_SCRIPT}
        expect "LDAP Directory Manager password:" {send "$dm_pass\r"}
        expect "Enter option number:" {send "$l_opt\r"}
        expect "Enter Replication destination FQHN" {send "$OMSERVS_FQHN\r"}
        expect "Continue to update defaultserverlist with" {send "Y\r"}
        expect "Do you want return to the main menu" {send "n\r"}
        expect eof
EOF
