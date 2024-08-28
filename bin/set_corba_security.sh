#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -n SIMNAME -s SIMNODES"
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
	if [[ -z "$LEVEL" ]]
        then
                echo "ERROR: You must say what security level to use, no, yes or no->yes"
                exit 1
        fi
	if [[ -z "$SEC_DEF_NAME" ]]
        then
                echo "ERROR: You must say what the security definition name is"
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

while getopts "c:m:n:l:d:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	n) SIMNAME="$OPTARG"
	;;
	l) LEVEL="$OPTARG"
	;;
	d) SEC_DEF_NAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

SUPPORTED_SSL_TYPES="RNC
RBS
RXI
ERBS"

MML=".open $SIMNAME
.show simnes"
NODE_LIST_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
NODE_LIST=`echo "$NODE_LIST_FULL" | grep -v "In Address" | grep -v "OK" | grep -v ">>" | awk '{print $1, $3}'`
FIRST_NODE_TYPE="`echo \"$NODE_LIST\" | head -1 | awk '{print $2}'`"
if [[ ! `echo "$SUPPORTED_SSL_TYPES" | grep "^$FIRST_NODE_TYPE$"` ]]
then
        echo "INFO: Not setting up corba security for $SIMNAME as it has a node type that doesn't support ssl, $FIRST_NODE_TYPE"
        exit 0
fi

MML=".open $SIMNAME
.select network
.stop -parallel
.set ssliop $LEVEL $SEC_DEF_NAME
.set save"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
