#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -n SIMNAME"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
        if [[ -z "$SIMNAME" ]]
        then
                echo "ERROR: You must say what simname to match"
                exit 1
        fi
	if [[ -z "$SIM_FILENAME" ]]
        then
                echo "ERROR: You must say what sim filename to match"
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

while getopts "c:m:n:f:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
        n) SIMNAME="$OPTARG"
        ;;
	f) SIM_FILENAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

if [[ -d /netsim/netsimdir/$SIMNAME ]]
then
	echo "INFO: Deleting existing simulation"
	MML=".delsim $SIMNAME force"
	su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
	if [[ $? -ne 0 ]]
	then
	        echo "ERROR: Something went wrong running the mml commands"
	        exit 1
	fi
fi

MML=".uncompressandopen $SIM_FILENAME force"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
