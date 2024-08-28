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
}

while getopts "c:m:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
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

COMMAND="
lcd /ericsson/config
cd /ericsson/config
get ossrc.p12
bye"
                        $EXPECT - <<EOF
                        set force_conservative 1
                        set timeout 60

                        # autologin variables
                        set prompt ".*(%|#|\\$|>):? $"


                        # set login variables before attempting to login
                        set loggedin "0"
                        set entered_password "0"
                        set exited_unexpectedly "0"
                        set timedout_unexpectedly "0"

                        spawn sftp $ADM1_HOSTNAME
                                expect {
                                        "Are you sure" {
                                                send "yes\r"
                                                #exp_continue -continue_timer
                                                exp_continue
                                        }
                                        "assword:" {
                                                send "shroot12\r"
                                                #set entered_password "1"
                                                #exp_continue -continue_timer
						exp_continue
                                        }
					"sftp>" {
                                                set loggedin "1"
                                        }
                                        -re \$prompt {
                                                set loggedin "1"
                                        }
                                        timeout {
                                                set timedout_unexpectedly "1"
                                        }
                                }
                                if {\$loggedin == "1"} {
                                        send_user "\nLogged in fine, running command\n"
                                        send "$COMMAND\r"
                                        set timeout 10
                                        expect {
                                                "eof" {
                                                        send_user "\nFinished sftp of p12 file\n"
                                                        exit 0
                                                }
                                        }

                                        expect eof
                                } else {
                                        send_user "\nERROR: Failed to sftp rootca.cer\n"
                                        exit 1
                              }
EOF

if [[ -f /ericsson/config/ossrc.p12 ]]
then
	chown nmsadm:nms /ericsson/config/ossrc.p12
	chmod 400 /ericsson/config/ossrc.p12
else
	exit 1
fi
