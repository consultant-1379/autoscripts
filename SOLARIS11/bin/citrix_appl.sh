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

. $MOUNTPOINT/expect/expect_functions
$EXPECT - <<EOF
        set force_conservative 1
        set timeout 30

        spawn /ericsson/ocs/bin/conf_citrix_appl_server.sh
    while 1 {
        expect {
            "name for" { send "\r" }
                "the hostname of the OSSRC system" { send "$UNIQUE_MASTERSERVICE\r" }
            eof {break}
        }
        }
EOF
