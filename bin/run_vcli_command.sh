#!/bin/bash

MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

usage_msg()
{
    echo "Usage: $0 -r COMMAND -v VCEN_HOSTNAME"
    exit 1
}
check_args()
{
    if [[ -z "$COMMAND" ]]
    then
        echo "ERROR: You must say what the command is using -r COMMAND"
        exit 1
    fi
    if [[ -z "$VCEN_HOSTNAME" ]]
    then
        echo "ERROR: You must say what the vcenter server hostname is"
        exit 1
    fi
}

while getopts "r:v:" arg
do
    case $arg in
        r) COMMAND="$OPTARG"
        ;;
        v) VCEN_HOSTNAME="$OPTARG"
        ;;
        \?) usage_msg
        exit 1
        ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

function send_alarm ()
{
    local MESSAGE="$1"
    local FORMATTED_DATE="`date | awk '{print $2 "_" $3}'`"
    local FORMATTED_TIME="`date | awk '{print $4}'`"
    MESSAGE="[$FORMATTED_DATE $FORMATTED_TIME] $MESSAGE"
    echo "$MESSAGE" >> /export/scripts/CLOUD/logs/run_vcli_command.log
}

function run_vcli_command()
{
    # Take inputs
    local COMMAND="$1"
    local VCEN_HOSTNAME="$2"

    # Setup some variables
    local ATTEMPTS=10
    local TRY_NO=1
    local RETRY_TIMEOUT=10
    local COMMAND_WORKED=0
    local OUTPUT=""

    # Prepare full command
    local FULL_COMMAND="source $MOUNTPOINT/bin/check_and_save_vma_session.sh -v $VCEN_HOSTNAME 2>&1;$COMMAND"

    # Vcli hostname list, one per line, with hostname<space>password. Read them in, in random order so that issues on vcli servers can be found earlier
    local VCLI_HOSTNAMES=`cat /export/scripts/CLOUD/configs/templates/vcli/vcli_servers.txt | sort -R`

    # Retry loop
    while [[ $TRY_NO -le $ATTEMPTS ]]
    do
        # During this attempt, try each vcli server in the list
        while read VCLI_LINE
        do
            VCLI_HOSTNAME=`echo "$VCLI_LINE" | awk '{print $1}'`
            VCLI_PASSWORD=`echo "$VCLI_LINE" | awk '{print $2}'`

            PASSWORDLESS_TEST=`ssh -o "NumberOfPasswordPrompts 0" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q $VCLI_HOSTNAME date 2>&1`
            PASSWORDLESS_TEST_EXIT_CODE=$?
            if [[ $PASSWORDLESS_TEST_EXIT_CODE -eq 0 ]]
            then
                OUTPUT=`ssh -o "NumberOfPasswordPrompts 0" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q $VCLI_HOSTNAME "$FULL_COMMAND 2>&1"`
            else
                # Try running the command
                OUTPUT=$($EXPECT - <<EOF
set force_conservative 1
set timeout 600
spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -q $VCLI_HOSTNAME "$FULL_COMMAND 2>&1"
while {"1" == "1"} {
expect {
    "Do you wish to generate"
    {
        sleep 1
        send "y\r"
    }
    "assword:"
    {
        send "$VCLI_PASSWORD\r"
    }
    "Are you sure you want to continue connecting"
    {
        send "yes\r"
    }
    timeout {
        send_user "ERROR: The vcli command didn't complete within the timeout period, is the vcenter or vcli server having problems?"
        exit 1
    }
    eof {
        catch wait result
        exit [lindex \$result 3]
    }
}
EOF
)
            fi
            EXIT_CODE=$?
            # Remove any \r characters that don't output very well in logs
            OUTPUT=`echo "$OUTPUT" | tr -d '\r'`
            if [[ $EXIT_CODE -ne 0 ]]
            then
                send_alarm "Failed command on vcli server $VCLI_HOSTNAME from `hostname`: Output was $OUTPUT, command was $FULL_COMMAND"
            else
                # echo out the output, minus the spawn and password prompt
                echo -n "$OUTPUT" | grep -v "spawn ssh" | grep -v "assword:"
                COMMAND_WORKED=1
                break 2
            fi
        done < <(echo "$VCLI_HOSTNAMES")

        # Sleep before going around and trying again
        sleep $RETRY_TIMEOUT
        TRY_NO=$(( $TRY_NO+1 ))
    done

    # Give up and throw an error
    if [[ "$COMMAND_WORKED" -ne 1 ]]
    then
        echo "ERROR: All $ATTEMPTS attempts to run the vm command failed, exiting. Heres the output"
        echo "$OUTPUT"
        exit 1
    fi
}
run_vcli_command "$COMMAND" "$VCEN_HOSTNAME"
