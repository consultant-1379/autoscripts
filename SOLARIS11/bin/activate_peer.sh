#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT"
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

	if [[ -z "$THE_SERVER" ]]
        then
                echo "ERROR: You must set the server hostname using -s hostname"
                exit 1
        fi

	if [[ -z "$IP_ADDR" ]]
        then
                echo "ERROR: You must set the ip address using -i ip"
                exit 1
        fi
}

while getopts "c:m:s:i:e:b:h:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
	m) MOUNTPOINT="$OPTARG"
	;;
	s) THE_SERVER="$OPTARG"
	;;
	i) IP_ADDR="$OPTARG"
	;;
	e) IS_AN_EBAS="$OPTARG"
	;;
	b) STOR_VIP="$OPTARG"
	;;
	h) STOR_HOSTNAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

STORAGE_PART="-s $STOR_VIP -o $STOR_HOSTNAME -force"

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1
        spawn /opt/ericsson/sck/peer_management/activate_peer -i $IP_ADDR -n $THE_SERVER $STORAGE_PART
	while {"1" == "1"} {
	expect {
	-re {overwrite with $THE_SERVER.*\)} {
		send "y\r"
	}
	-re {Continue to update LDAP.*q\]} {
		send "y\r"
	}
	-re {LDAP domain.*\]:} {
		send "\r"
	}
	-re {LDAP DS IP address list.*\]:} {
		send "\r"
	}
	-re {LDAP maintenance bind DN.*\]:} {
		send "\r"
	}
	-re {LDAP maintenance bind password:} {
		send "$ns_data_maintenence_pass\r"
	}
	-re {values ok.*q\]} {
		send "y\r"
	}
	"Password:" {
		send "shroot\r"
	}
	eof {
		catch wait result
		exit [lindex \$result 3]
	}
	}
}
EOF
