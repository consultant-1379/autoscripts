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

CURRENT_VERSION=`ls -ltrh /netsim/inst | awk -F/ '{print $5}'`
cd $MOUNTPOINT/files/netsim/versions/$CURRENT_VERSION/license/
LATEST_LICENCE_FILENAME=`ls *.zip | tail -1`
cp $MOUNTPOINT/files/netsim/versions/$CURRENT_VERSION/license/$LATEST_LICENCE_FILENAME /netsim/inst/
su - netsim -c "echo .install license $LATEST_LICENCE_FILENAME | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
