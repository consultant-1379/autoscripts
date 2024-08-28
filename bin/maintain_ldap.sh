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
	$EXPECT - <<EOF
	set force_conservative 1
	set timeout -1

	spawn /opt/ericsson/sck/bin/maintain_ldap.bsh -y
	while {"1" == "1"} {
	expect {
		"LDAP maintenance bind password:"
		{
			send "$ns_data_maintenence_pass\r"
		}
		"LDAP maintenance bind DN "
		{
			send "\r"
		}
		"LDAP domain name DN "
		{
			send "\r"
		}
		"LDAP DS IP address list " { send "\r"}
		"Continue to update LDAP" { send "y\r"}
		"Are the values ok" { send "y\r" }
		eof {
                        catch wait result
                        exit [lindex \$result 3]
                }
	}
EOF
