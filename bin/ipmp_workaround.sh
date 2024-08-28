#!/bin/bash

STOR_BASE_IP2=`grep storBaseIPaddress2 /ericsson/config/cluster.ini | awk -F= '{print $2}'`

if [[ "$STOR_BASE_IP2" != "" ]]
then
        OUTPUT=`grep "^$STOR_BASE_IP2 " /etc/hostname.* 2>/dev/null | head -1`
        if [[ "$OUTPUT" != "" ]]
        then
                FILENAME=`echo "$OUTPUT" | awk -F: '{print $1}'`
                ENTRY=`echo "$OUTPUT" | awk -F: '{print $2}'`
                echo "IP found in $FILENAME, it was '$ENTRY'"

                if [[ `echo "$ENTRY" | grep "standby"` ]]
                then
                        echo "standby already seems to be set"
                else
                        NIC=`echo "$FILENAME" | sed 's/\/etc\/hostname.//g'`
                        echo "Running 'ifconfig $NIC deprecated -failover standby up'"
                        ifconfig $NIC deprecated -failover standby up

                        NEWENTRY=`echo "$ENTRY" | sed 's/ up/ standby up/g'`
                        echo "Putting '$NEWENTRY' into $FILENAME to make this permanent"
                        echo "$NEWENTRY" > $FILENAME
                fi
        else
                echo "Couldn't find $STOR_BASE_IP2 in /etc/hostname.*"
        fi
else
        echo "Not going to run ipmp workaround as its not appropriate for this environment"
fi
