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
	if [[ -z "$USERNAME" ]]
	then
		echo "ERROR: You must give a username with -u"
		exit 1
	fi
	if [[ -z "$CATEGORY" ]]
        then
                echo "ERROR: You must give a category with -s"
                exit 1
        fi
	if [[ -z "$PASSWORD" ]]
        then
                echo "ERROR: You must give a password with -p"
                exit 1
        fi
}

while getopts "c:m:u:p:s:n:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	u) USERNAME="$OPTARG"
	;;
	p) PASSWORD="$OPTARG"
	;;
	s) CATEGORY="$OPTARG"
	;;
	n) NEW_UID="$OPTARG"
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
        ADD_USER_SCRIPT=/ericsson/sdee/bin/add_user.sh
else
        ADD_USER_SCRIPT=/ericsson/opendj/bin/add_user.sh
fi

var=$($EXPECT - <<EOF
set force_conservative 1
set timeout 60

set answered 0

spawn ${ADD_USER_SCRIPT} -d $LDAPDOMAIN
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
		"Bad passphrase, try again"  {
			send_user "${SPECIAL}ERROR, it looks like you used the wrong key passphrase, please check it"
			exit 2
		}
		"${ADD_USER_SCRIPT}: not found" {
		send_user "${SPECIAL}This doesn't look like an infra server, can't find the add_user.sh script, please check the Infra Server hostname and fix in HW tracker if necessary"
			exit 2
		}
		"LDAP domain <e.g. ldap.companyname.com>" {send "$LDAPDOMAIN\r"}
		"LDAP Directory Manager DN" {
			set timeout 2

			expect {
				"LDAP Directory Manager password:" {
					send "$dm_pass\r"
				}
				"]:" {
					send "\r"
				}
				timeout {
					expect {
						"cn=" { }
						timeout {
							send "\r"
						}
					}
				}
			}
			set timeout 60
		 }
		"LDAP Directory Manager password:" {send "$dm_pass\r"}
		"OSS-RC Master Server hostname:" {send "$UNIQUE_MASTERSERVICE\r"}
		"New local user name:" {send "$USERNAME\r"}
		"User login name:" {send "$USERNAME\r"}
		"Start of uidNumber search range" {send "\r"}
		"End of uidNumber search range" {send "\r"}
		"New local user uidNumber" {send "$NEW_UID\r"}
		"User login uidNumber" {send "$NEW_UID\r"}
		"Enter Description about user" {send "\r"}
		"New local user description" {send "\r"}
		"New local user password:" {send "$PASSWORD\r"}
		"User login password:" {send "$PASSWORD\r"}
		"Re-enter password:" {send "$PASSWORD\r"}
		"New local user category" {send "$CATEGORY\r"}
		"User category" {send "$CATEGORY\r"}
		"Continue to create local user" {
			send "y\r"
			set timeout 120
		}
		"y,n,?" {
			send "y\r"
			set timeout 120
		}
		"Password:" {send "$shroot\r"}
		"Are you sure you want to continue connecting (yes/no)" {send "yes\r"}
		"Enter passphrase for" {send "$key_passphrase\r"}
		-re "Added new user.*on OSS-RC Master Server: OK" {
				send_user "${SPECIAL}User $USERNAME was created successfully"
                        	exit 0
		}
		"OK: Account created"
		{
			send_user "${SPECIAL}User $USERNAME was created successfully"
			exit 0
		}
		timeout {
			send_user "ERROR: Timeout when adding user\n"
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
        echo -n "$error_msg"
else
        msg=`echo "$var" | grep $SPECIAL | tr -d $SPECIAL`

        if [[ "$msg" == "" ]]
        then
                msg="Everything seemed to go ok."
        fi

        echo -n "$msg"
fi

exit $exit_code
