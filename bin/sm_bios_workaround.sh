#!/bin/bash

for (( ; ; ))
do
	SMBIOS_PID=`ps -ef | grep smbios| grep -v grep| awk '{print $2}'`
	if [[ -n "$SMBIOS_PID" ]]
	then
		kill -9 $SMBIOS_PID
		sleep 1
	else
		sleep 10
	fi
done
