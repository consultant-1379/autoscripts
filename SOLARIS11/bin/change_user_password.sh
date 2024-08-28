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
	if [[ -z "$PASSWORD" ]]
        then
                echo "ERROR: You must give a password with -p"
                exit 1
        fi
}

while getopts "c:m:u:p:" arg
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

if [[ "$USERNAME" == "admin" ]]
then
        echo -n "1,You are not permitted to change admin password"
        exit 1
fi

# Added a check for LDAP script.
if pgrep ns-slapd > /dev/null; then
	l_ldap_dir=/ericsson/sdee/bin
        CHG_USER_PASSWORD_SCRIPT=$l_ldap_dir/chg_user_password.sh
else
	l_ldap_dir=/ericsson/opendj/bin
        CHG_USER_PASSWORD_SCRIPT=$l_ldap_dir/chg_user_password.sh
fi

var=$($EXPECT - <<EOF
set force_conservative 1
set timeout 60

set answered 0

spawn ${CHG_USER_PASSWORD_SCRIPT}
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
		"$l_ldap_dir/chg_user_password.sh: not found" {
		send_user "${SPECIAL}This doesn't look like an infra server, can't find the chg_user_password.sh script, please check the Infra Server hostname and fix in HW tracker if necessary"
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
		"Local user name:" {send "$USERNAME\r"}
		"Start of uidNumber search range" {send "\r"}
		"New password:" {send "$PASSWORD\r"}
		"Re-enter password:" {send "$PASSWORD\r"}
		"Password:" {send "$shroot\r"}
		"Are you sure you want to continue connecting (yes/no)" {send "yes\r"}
		"Enter passphrase for" {send "$key_passphrase\r"}
		"]: OK" {
				send_user "${SPECIAL}Password reset for $USERNAME to $PASSWORD successfully"
                        	exit 0
		}
		timeout {
			send_user "ERROR: Timeout when changing user password\n"
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
        echo "$error_msg"
else
        msg=`echo "$var" | grep $SPECIAL | tr -d $SPECIAL`

        if [[ "$msg" == "" ]]
        then
                msg="Everything seemed to go ok."
        fi

        echo "$msg"
fi
exit $exit_code
