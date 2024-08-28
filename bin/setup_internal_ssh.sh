#!/bin/bash

HOSTNAME=`hostname`
IP=`getent hosts $HOSTNAME | awk '{print $1}'`

SSHD_ENTRY="ListenAddress $IP"
SSHD_ENTRY2="ListenAddress 127.0.0.1"

if [[ ! `grep "^$SSHD_ENTRY$" /etc/ssh/sshd_config` ]] || [[ ! `grep "^$SSHD_ENTRY2$" /etc/ssh/sshd_config` ]]
then
	echo "INFO: Setting up Internal SSH"
	cat /etc/ssh/sshd_config | grep -v "^ListenAddress" > /etc/ssh/sshd_config.tmp
	mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
	echo "$SSHD_ENTRY" >> /etc/ssh/sshd_config
	echo "$SSHD_ENTRY2" >> /etc/ssh/sshd_config
	pkill -HUP sshd
fi
