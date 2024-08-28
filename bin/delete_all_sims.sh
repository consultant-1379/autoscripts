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

SIMULATIONS=`ls -1 /netsim/netsimdir/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E '^default$'`

echo "$SIMULATIONS" | while read SIMNAME
do
	MML=".delsim $SIMNAME force"
	su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
	if [[ $? -ne 0 ]]
	then
	        echo "ERROR: Something went wrong running the mml commands"
        	exit 1
	fi
done
