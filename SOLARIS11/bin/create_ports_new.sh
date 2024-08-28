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

function create_nehttpd_port ()
{
	local PORT_NAME="$1"
	local IP_ADDRESS="$2"
	echo "INFO: Creating netsim port $PORT_NAME"
	MML=".select configuration
.config add port $PORT_NAME iiop_prot `hostname`
.config port address $PORT_NAME nehttpd $IP_ADDRESS 56834 56836 no_value
.config save"
	su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
	if [[ $? -ne 0 ]]
	then
	        echo "ERROR: Something went wrong running the mml commands"
	        exit 1
	fi
}

function create_stn_port ()
{
        local PORT_NAME="$1"
        local IP_ADDRESS="$2"
        echo "INFO: Creating netsim port $PORT_NAME"
        local MML=".select configuration
.config add port $PORT_NAME snmp_ssh_prot `hostname`
.config port address $PORT_NAME $IP_ADDRESS 161 public 1 %unique %simname_%nename authpass privpass 2 2
.config save"
        su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
        if [[ $? -ne 0 ]]
        then
                echo "ERROR: Something went wrong running the mml commands"
                exit 1
        fi
}

function create_netconf_port ()
{
        local PORT_NAME="$1"
        local IP_ADDRESS="$2"
        echo "INFO: Creating netsim port $PORT_NAME"
        local MML=".select configuration
.config add port $PORT_NAME netconf_prot `hostname`
.config port address $PORT_NAME $IP_ADDRESS 1161 public 2 %unique 1 %simname_%nename authpass privpass 2 2
.config save"
        su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
        if [[ $? -ne 0 ]]
        then
                echo "ERROR: Something went wrong running the mml commands"
                exit 1
        fi
}

function create_default_destination ()
{
	local DEST_NAME="$1"
	local TYPE="$2"
        local IP_ADDRESS="$3"
        echo "INFO: Creating netsim default destination $DEST_NAME of type $TYPE"
        local MML=".select configuration
.config add external $DEST_NAME $TYPE
.config external address $DEST_NAME $IP_ADDRESS 162 1
.config save"
        su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
        if [[ $? -ne 0 ]]
        then
                echo "INFO: Something went wrong running the mml commands, but its normal when creating default destinations"
                #exit 0
        fi
}

IPV6_PORT=`ifconfig -a | grep -i "inet6 " | grep "Scope:Global" | awk '{print $3}' | sort -u | awk -F\/ '{print $1}' | head -1`
LOCAL_IP_ADDRESS=`host $HOSTNAME | awk '{print $4}'`
IPV4_PORT=`ifconfig -a | grep -i "inet " | awk '{print $2}' | awk -F: '{print $2}' | sort -ut. -k1,1 -k2,2n -k3,3n -k4,4n |  grep -v "127.0.0.1" | grep -v "^$LOCAL_IP_ADDRESS$" | head -1`

IPV4_GATEWAY="192.168.100.1"
IPV6_GATEWAY="fd37:96e7:fe4a:600::64:3dc"

create_stn_port stn4 $IPV4_PORT
create_stn_port stn6 $IPV6_PORT
create_nehttpd_port nehttpd4 $IPV4_PORT
create_nehttpd_port nehttpd6 $IPV6_PORT
create_netconf_port netconf_prot4 $IPV4_PORT
create_netconf_port netconf_prot6 $IPV6_PORT
create_default_destination stndd4 snmp_ssh_prot $VIP_OSSFS
create_default_destination stndd6 snmp_ssh_prot $VIP_IPV6_OSSFS
create_default_destination netconf_protdd4 netconf_prot $VIP_OSSFS
create_default_destination netconf_protdd6 netconf_prot $VIP_IPV6_OSSFS
