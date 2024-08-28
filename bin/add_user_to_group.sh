#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -g GROUP -u USERNAME"
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
	if [[ -z "$GROUP" ]]
        then
                echo "ERROR: You must give a group with -g"
                exit 1
        fi
	if [[ -z "$USERNAME" ]]
        then
                echo "ERROR: You must give a username with -u"
                exit 1
        fi
}

while getopts "c:m:g:u:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	g) GROUP="$OPTARG"
	;;
	u) USERNAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done


check_args
. $MOUNTPOINT/expect/expect_functions


TRY_NO=1
TRY_ACQUIRE_LOCK=100
DONE=0
SPECIAL="_+_+_+"
PROMPTS_ALLOWED=20

# Take command line arguments

if [[ "$USERNAME" == "nmsadm" ]]
then
        echo -n "1,You are not permitted to add / remove nmsadm"
        exit 1
fi

if [[ "$USERNAME" == "admin" ]]
then
        echo -n "1,You are not permitted to add / remove admin"
        exit 1
fi

# Added a check for LDAP script.
if pgrep ns-slapd > /dev/null; then
        ADD_USER_TO_GROUP_SCRIPT=/ericsson/sdee/bin/add_user_to_group.sh
else
        ADD_USER_TO_GROUP_SCRIPT=/ericsson/opendj/bin/add_user_to_group.sh
fi

var=$($EXPECT - <<EOF
set force_conservative 1
set timeout 60

set answered 0

spawn ${ADD_USER_TO_GROUP_SCRIPT} -y -u $USERNAME -g $GROUP
while {true} {
	expect	{
		-re "ERROR:(.*)$" {
                        send_user "${SPECIAL}\$expect_out(1,string)"
                        exit 2
                }
		-re "WARNING: (REMOTE.*)$" {
                        send_user "${SPECIAL}\$expect_out(1,string)"
                        exit 2
                }
                -re "Error(.*)$" {
                        send_user "${SPECIAL}\$expect_out(1,string)"
                        exit 2
                }
		"already contains local member" {
			send_user "User already exists in this group"
			exit 0
		}
		"LDAP Directory Manager password:" {send "$dm_pass\r"}
		"... OK" {
				send_user "${SPECIAL}Group $GROUP was created successfully"
                        	exit 0
		}
		timeout {
			send_user "ERROR: Timeout when adding group\n"
			exit 3
		}
	}
	set answered [expr \$answered+1]
        if {\$answered > $PROMPTS_ALLOWED} {
		send_user "${SPECIAL}Unexpected number of prompts given"
                exit 2
        }
}
EOF)
		# Finished expect script, cleaning up
exit_code=$?
if [[ $exit_code -ne 0 ]]
then
        error_msg=`echo "$var" | grep $SPECIAL | tr -d $SPECIAL`
        if [[ "$error_msg" == "" ]]
        then
                error_msg="An unexpected error occured"
        fi
        echo -n "$exit_code,$error_msg"
else
        msg=`echo "$var" | grep $SPECIAL | tr -d $SPECIAL`

        if [[ "$msg" == "" ]]
        then
                msg="Everything seemed to go ok."
        fi

        echo -n "0,$msg"
fi

exit $exit_code
