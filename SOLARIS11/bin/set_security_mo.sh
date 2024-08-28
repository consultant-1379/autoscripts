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
	if [[ -z "$SEC_LEVEL" ]]
        then
                echo "ERROR: You must say what security level to set"
                exit 1
        fi
	#if [[ -z "$SIMNODES" ]]
        #then
        #        echo "ERROR: You must say what nodes to create the xml for"
        #        exit 1
        #fi

        if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
                . $MOUNTPOINT/bin/load_config
        fi
}

while getopts "c:m:s:n:l:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	s) SIMNODES="$OPTARG"
	;;
	n) SIMNAME="$OPTARG"
	;;
	l) SEC_LEVEL="$OPTARG"
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
        echo "INFO: Not setting the security mo for $SIMNAME as it has a node type that doesn't support ssl, $FIRST_NODE_TYPE"
        exit 0
fi

MML=".open $SIMNAME
.selectallsimne
.start -parallel
setmoattribute:mo=\\\"ManagedElement=1,SystemFunctions=1,Security=1\\\", attributes=\\\"requestedSecurityLevel=$SEC_LEVEL\\\";
setmoattribute:mo=\\\"ManagedElement=1,SystemFunctions=1,Security=1\\\", attributes=\\\"operationalSecurityLevel=$SEC_LEVEL\\\";
"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
