#!/bin/bash


LOCK="/tmp/atvts_hostnames.lock"
/export/scripts/CLOUD/bin/get_lock.sh -f $LOCK -p 1234 -t 14400 -r yes
wget -q -O - --no-check-certificate https://atvcloud3.athtem.eei.ericsson.se/Vapps/network
wget -q -O - --no-check-certificate https://atvcloud.athtem.eei.ericsson.se/Vapps/network
/export/scripts/CLOUD/bin/clear_lock.sh -f $LOCK -p 1234
