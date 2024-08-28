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

if [[ -f /ericsson/glassfish/bin/config_ldap.sh ]]
then
	$EXPECT - <<EOF
	set force_conservative 1
	set timeout -1

	spawn  /ericsson/glassfish/bin/config_ldap.sh -i
	while {"1" == "1"} {
	expect {
		"Please provide MSADMIN Password"
		{
			sleep 1
			send "$ns_data_migration_pass\r"
			expect "Confirm password:" {
				send "$ns_data_migration_pass\r"
			}
		}
		"Please provide proxyagent Password"
		{
			sleep 1
			send "$proxyagent_pass\r"
			expect "Confirm password:" {
				send "$proxyagent_pass\r"
                        }
		}
		eof {
			catch wait result
			exit [lindex \$result 3]
		}
	}
EOF

fi
