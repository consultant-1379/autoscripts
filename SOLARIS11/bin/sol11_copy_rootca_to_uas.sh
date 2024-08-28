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

                if [[ "$OMSAS_HOSTNAME" != "" ]]
                then
                        echo "Getting rootca.cer from omsas"
                        root_ca_server="$OMSAS_IP_ADDR"
COMMAND="
lcd /var/tmp/
cd /opt/ericsson/csa/certs/
get DSCertCA.pem rootca.cer
bye"
                else
                        echo "Getting rootca.cer from infra"
                        root_ca_server="$OMSERVM_IP_ADDR"
COMMAND="
lcd /var/tmp/
cd /var/tmp/
get rootca.cer
bye"
                fi
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

                        spawn sftp $root_ca_server
                                expect {
                                        "Are you sure" {
                                                send "yes\r"
                                                exp_continue -continue_timer
                                        }
                                        "assword:" {
                                                send "shroot12\r"
                                                set entered_password "1"
                                                exp_continue -continue_timer
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
                                                        send_user "\nFinished sftp of rootca.cer\n"
                                                        exit 0
                                                }
                                        }

                                        expect eof
                                } else {
                                        send_user "\nERROR: Failed to sftp rootca.cer\n"
                                        exit 1
                              }
EOF

