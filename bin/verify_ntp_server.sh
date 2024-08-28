#!/bin/bash

echo -n "INFO: Verifying ntp server setting: "
DESIRED=$1
ACTUAL="`cat /etc/inet/ntp.conf | grep "^server" | awk '{print $2}' | head -1`"

if [[ "$DESIRED" == "$ACTUAL" ]]
then
	echo "OK"
else
	echo "NOK, ntp server set to $ACTUAL"
fi
