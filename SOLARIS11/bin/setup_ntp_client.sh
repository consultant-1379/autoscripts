#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG"
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

while getopts "m:c:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
        c) CONFIG="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

function populate_ntp_client_conf_solaris ()
{
	cp /etc/inet/ntp.client /etc/inet/ntp.conf
	cat /etc/inet/ntp.conf | grep -v multicastclient | grep -v "^server" > /etc/inet/ntp.conf.temp
	mv /etc/inet/ntp.conf.temp /etc/inet/ntp.conf

	echo "server $NTP_SOURCE" >> /etc/inet/ntp.conf
	echo "enable pll" >> /etc/inet/ntp.conf
}


function populate_ntp4_client_conf_solaris ()
{
        cp /etc/inet/ntp4.client /etc/inet/ntp.conf
        cat /etc/inet/ntp.conf | grep -v multicastclient | grep -v "^server" > /etc/inet/ntp.conf.temp
        mv /etc/inet/ntp.conf.temp /etc/inet/ntp.conf

        echo "server $OMSERVM_IP_ADDR" >> /etc/inet/ntp.conf
}

function populate_ntp4_server_conf_solaris ()
{
        cp /etc/inet/ntp4.server /etc/inet/ntp.conf
        cat /etc/inet/ntp.conf | grep -v multicastclient | grep -v "^server" > /etc/inet/ntp.conf.temp
        mv /etc/inet/ntp.conf.temp /etc/inet/ntp.conf

        echo "server $NTP_SOURCE" >> /etc/inet/ntp.conf
}
function populate_ntp_server_conf_solaris ()
{
        cp /etc/inet/ntp.server /etc/inet/ntp.conf
        cat /etc/inet/ntp.conf | grep -v multicastclient | grep -v "^server" > /etc/inet/ntp.conf.temp
        mv /etc/inet/ntp.conf.temp /etc/inet/ntp.conf

        echo "server $NTP_SOURCE" >> /etc/inet/ntp.conf
        echo "enable pll" >> /etc/inet/ntp.conf
}

function enable_ntp_solaris ()
{
	svcadm enable svc:/network/ntp:default
	svcadm restart svc:/network/ntp:default
	svcadm clear svc:/network/ntp:default
	svcadm enable svc:/network/ntp:default
}

function enable_ntp4_solaris ()
{
	svcadm disable svc:/network/ntp4:default
	svcadm enable -s svc:/network/ntp4:default
}

function disable_ntp_solaris ()
{
	svcadm disable svc:/network/ntp:default
}

OS=`uname`
if [[ "$OS" == "SunOS" ]]
then
	# if we are dealing with a cominf servers
	if [[ `egrep 'infra_omsas|om_serv_master|om_serv_slave|appserv' /ericsson/config/ericsson_use_config` ]]
	then
		# Compare Ericocs package pstamp to the one that introduced the ntp4 change
		ERICOCS_PSTAMP=`pkginfo -l ERICocs | grep PSTAMP | awk -F: '{print $2}' | sed 's/[^0-9]*//g'`
		if [[ "$ERICOCS_PSTAMP"  -ge "20150217151902" ]] ; then
			# If its a uas or infra_omsas 
			if [[ `/usr/bin/egrep "infra_omsas|appserv" /ericsson/config/ericsson_use_config` ]]
			then
				l_cmd=`svcs -a | grep ntp`
				echo $l_cmd
				echo "INFO: Setting up server as ntpv4 client"
				populate_ntp4_client_conf_solaris
				disable_ntp_solaris
				enable_ntp4_solaris
				l_cmd=`svcs -a | grep ntp`
				echo $l_cmd
			# If it is a om_serv_master or om_serv_slave
			else [[ `/usr/bin/egrep "om_serv_master|om_serv_slave" /ericsson/config/ericsson_use_config` ]]
				l_cmd=`svcs -a | grep ntp`
				echo $l_cmd
				echo "INFO: Setting up server as ntpv4 master"
				populate_ntp4_server_conf_solaris
				disable_ntp_solaris
				enable_ntp4_solaris
				l_cmd=`svcs -a | grep ntp`
				echo $l_cmd
			fi
		else
			populate_ntp_client_conf_solaris
			enable_ntp_solaris
		fi
	elif [[ `egrep 'smrs_slave' /ericsson/config/ericsson_use_config` ]] ; then
		SHIPMENT=`grep om_sw_locate /ericsson/config/bootargs|awk -F= '{print $2}'|awk -F/ '{print $NF}'| sed 's/[^0-9]*//g'`
		if [[ "$SHIPMENT" -ge "1524" ]] ; then
			l_cmd=`svcs -a | grep ntp`
			echo $l_cmd
			echo "INFO: Setting up server as ntpv4 client"
			populate_ntp4_client_conf_solaris
			disable_ntp_solaris
			enable_ntp4_solaris
			l_cmd=`svcs -a | grep ntp`
			echo $l_cmd
		else
			populate_ntp_client_conf_solaris
			enable_ntp_solaris
		fi
	else
		populate_ntp_client_conf_solaris
		enable_ntp_solaris
	fi
	# For vApps that have been powered off for a while, make sure ntp is updated at boot so ntp doesn't go into maintenance mode
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		echo "INFO: Setting up ntpUpdate start script /etc/rc3.d/S99ntpUpdate"
		cp $MOUNTPOINT/bin/S99ntpUpdate /etc/rc3.d/S99ntpUpdate
		/etc/rc3.d/S99ntpUpdate start
	fi
elif [[ "$OS" == "Linux" ]]
then
	cat /etc/ntp.conf | grep -v "^server" > /etc/ntp.conf.tmp
	echo "server $NTP_SOURCE" >> /etc/ntp.conf.tmp
	mv /etc/ntp.conf.tmp /etc/ntp.conf
	cd /
	service ntp restart
fi
