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
}

function disable_ntp_solaris ()
{
	svcadm disable svc:/network/ntp:default
}

OS=`uname`
if [[ "$OS" == "SunOS" ]]
then
		# If it is a om_serv_master or om_serv_slave
		if [[ `/usr/bin/egrep "om_serv_master|om_serv_slave" /ericsson/config/ericsson_use_config` ]]
		then
			l_cmd=`svcs -a | grep ntp`
			echo $l_cmd
			echo "INFO: Setting up infra server as ntp master"
			populate_ntp_server_conf_solaris
			disable_ntp_solaris
			enable_ntp_solaris
		else
			echo "INFO: Setting up server as ntp client"
			populate_ntp_client_conf_solaris
			disable_ntp_solaris
			enable_ntp_solaris
		fi
	
	# For vApps that have been powered off for a while, make sure ntp is updated at boot so ntp doesn't go into maintenance mode
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		echo "INFO: Setting up ntpUpdate start script /etc/rc3.d/S99ntpUpdate"
		cp $MOUNTPOINT/bin/S99ntpUpdate_sol11 /etc/rc3.d/S99ntpUpdate
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
