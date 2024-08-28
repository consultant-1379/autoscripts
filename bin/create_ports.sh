#!/bin/bash

function create_port ()
{
	PORT_NAME="$1"
	IP_ADDRESS="$2"
	echo "INFO: Creating netsim port $PORT_NAME"
	MML=".select configuration
.config add port $PORT_NAME iiop_prot `hostname`
.config port address $PORT_NAME nehttpd $IP_ADDRESS 56834 56836 no_value
.config save"
	su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_shell"
}


IPV4_GATEWAY="192.168.100.1"
IPV6_GATEWAY="fd37:96e7:fe4a:600::64:3dc"

create_port NetSimPort4 $IPV4_GATEWAY
create_port NetSimPort6 $IPV6_GATEWAY

