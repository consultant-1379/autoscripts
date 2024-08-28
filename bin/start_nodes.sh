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

        if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
                . $MOUNTPOINT/bin/load_config
        fi
}

while getopts "c:m:n:s:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	n) SIMNAME="$OPTARG"
	;;
	s) SIMNODES="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

if [[ -z "$SIMNODES" ]]
then
	echo "INFO: Starting all nodes"
	NODES_TO_SELECT="network"
else
	MML=".open $SIMNAME
.show simnes"
	NODE_LIST_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
	if [[ $? -ne 0 ]]
	then
		echo "ERROR: Something went wrong running the mml commands, here was the output, $NODE_LIST_FULL"
		exit 1
	fi
	NODE_LIST=`echo "$NODE_LIST_FULL" | grep -v "In Address" | grep -v "OK" | grep -v ">>" | awk '{print $1, $3, $6}'`

	SEARCH_NODE_RANGE_START=`echo $SIMNODES | awk -F, '{print $1}'`
	SEARCH_NODE_RANGE_END=`echo $SIMNODES | awk -F, '{print $2}'`
	if [[ "$SEARCH_NODE_RANGE_END" == "end" ]]
	then
		SEARCH_NODE_RANGE_END="`echo \"$NODE_LIST\" | wc -l`"
	fi
	echo "INFO: Starting nodes $SEARCH_NODE_RANGE_START to $SEARCH_NODE_RANGE_END"
	SEARCH_NODE_SIZE=$((SEARCH_NODE_RANGE_END-SEARCH_NODE_RANGE_START+1))
	SPECIFIC_NODE_LIST="`echo \"$NODE_LIST\" | head -$SEARCH_NODE_RANGE_END | tail -$SEARCH_NODE_SIZE`"

	NODES_TO_SELECT=$(echo "$SPECIFIC_NODE_LIST" | awk '{print $1}' | while read line
	do
		echo -n "$line|"
	done)
fi

MML=".open $SIMNAME
.select $NODES_TO_SELECT
.start -parallel"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
	echo "ERROR: Something went wrong running the mml commands"
	exit 1
fi
