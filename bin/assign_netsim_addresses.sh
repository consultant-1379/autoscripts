#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -s SIMNODES -n SIMNAME -i <IPV6 yes or no>"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$SIMNODES" ]]
        then
                #echo "ERROR: You must say what nodes to assign addresses to"
                exit 0
        fi
	if [[ -z "$SIMNAME" ]]
        then
                echo "ERROR: You must say what simname to match"
                exit 1
        fi
	if [[ -z "$IPV6" ]]
        then
                echo "ERROR: You must say whether its ipv6 or not"
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

while getopts "c:m:s:n:i:" arg
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
	i) IPV6="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
# Find addresses assigned in sims
SIMULATIONS=`ls -1 /netsim/netsimdir/*/simulation.netsimdb | sed -e "s/.simulation.netsimdb//g" -e "s/^[^*]*[*\/]//g" |grep -v -E '^default$'`

LOCAL_IP_ADDRESS=`host $HOSTNAME | awk '{print $4}'`

# Find possible addresses using the ip address cache files
if [[ "$IPV6" == "yes" ]]
then
	POSSIBLE_ADDRESSES=`cat /tmp/ipv6_address_cache.txt`
	IPVERSION=6
else
	POSSIBLE_ADDRESSES=`cat /tmp/ipv4_address_cache.txt`
	IPVERSION=4
fi


MML=".open $SIMNAME
.show simnes"
NODE_LIST_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
NODE_LIST=`echo "$NODE_LIST_FULL" | grep -v "In Address" | grep -v "OK" | grep -v ">>" | awk '{print $1, $3}'`

for entry in $SIMNODES
do
SEARCH_NODE_TYPE=`echo $entry | awk -F, '{print $1}'`
SPECIFIC_NODE_LIST_UNFILTERED="`echo \"$NODE_LIST\" | egrep \" $SEARCH_NODE_TYPE\"`"
SEARCH_NODE_RANGE_START=`echo $entry | awk -F, '{print $2}'`
SEARCH_NODE_RANGE_END=`echo $entry | awk -F, '{print $3}'`
if [[ "$SEARCH_NODE_RANGE_END" == "end" ]]
then
	SEARCH_NODE_RANGE_END="`echo \"$SPECIFIC_NODE_LIST_UNFILTERED\" | wc -l`"
fi
SEARCH_NODE_SIZE=$((SEARCH_NODE_RANGE_END-SEARCH_NODE_RANGE_START+1))
SPECIFIC_NODE_LIST="`echo \"$SPECIFIC_NODE_LIST_UNFILTERED\" | head -$SEARCH_NODE_RANGE_END | tail -$SEARCH_NODE_SIZE`"

MML=$(echo "$SIMULATIONS" | while read sim
do
  echo ".open $sim"
  echo ".show simnes"
done)

USED_ADDRESSES_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi

USED_ADDRESSES=`echo "$USED_ADDRESSES_FULL" | awk '{print $6}' | sort -u`
FREE_ADDRESSES=$(echo "$POSSIBLE_ADDRESSES" | while read possible
do

	if [[ ! `echo "$USED_ADDRESSES" | grep "^$possible$"` ]]
	then
		echo "$possible"
	fi
done
)

NODE_MML=$(echo "$SPECIFIC_NODE_LIST" | while read node_output
do

	node=`echo "$node_output" | awk '{print $1}'`
	node_type=`echo "$node_output" | awk '{print $2}'`
	let COUNTER=COUNTER+1
	IP_ADDRESS=`echo "$FREE_ADDRESSES" | head -$COUNTER | tail -1`
	echo ".select $node"
	PORTNAME=""
	DESTINATION=""
	if [[ "$node_type" == "RNC" ]] || [[ "$node_type" == "RBS" ]] || [[ "$node_type" == "RXI" ]] || [[ "$node_type" == "ERBS" ]]
	then
		PORTNAME="nehttpd"
	elif [[ "$node_type" == "STN" ]]
	then
		PORTNAME="stn"
		DESTINATION="stndd"
	elif [[ "$node_type" == "MSRBS-V2" ]]
	then
		PORTNAME="netconf_prot"
		DESTINATION="netconf_protdd"
	elif [[ "$node_type" == "SGSN" ]]
	then
		PORTNAME="netconf_prot"
		DESTINATION="netconf_protdd"
	else
		echo "ERROR: This is an unknown node type, '$node_type' so I can't assign an ip address to it"
		echo "ERROR: I don't know which netsim port to give it, please update this script to handle this node type"
		exit 1
	fi
	if [[ "$DESTINATION" != "" ]]
	then
		echo ".set external ${DESTINATION}${IPVERSION}"
	fi
	echo ".set port ${PORTNAME}${IPVERSION}"
	echo ".modifyne set_subaddr $IP_ADDRESS subaddr no_value"
	echo ".set save"
done
)

# Update used ip address list
MML=".open $SIMNAME
$NODE_MML
"
su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
done
