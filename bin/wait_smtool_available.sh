#!/bin/bash

SMTOOL=/opt/ericsson/nms_cif_sm/bin/smtool
SMTOOL_TIMEOUT=30
SMTOOL_ATTEMPTS=40

# Check is OSS up by doing smtool prog and checking return code
echo -n "INFO: Waiting for smtool to become available..."

SMTOOL_WORKING=0
while [[ $SMTOOL_WORKING -ne 1 && $TRY_NO -lt $SMTOOL_ATTEMPTS ]]
do

        smout="`$SMTOOL list 2>&1`"
        if [[ $? -ne 0 ]]
        then
                sleep $SMTOOL_TIMEOUT
                TRY_NO=$(( $TRY_NO+1 ))
        else
                SMTOOL_WORKING=1
        fi
done

if [[ "$SMTOOL_WORKING" -ne 1 ]]
then
        echo "ERROR: Smtool didn't respond after $SMTOOL_ATTEMPTS attempts with $SMTOOL_TIMEOUT between each attempt.."
        exit 1
else
        echo "OK"
	$SMTOOL prog
	sleep 1
	$SMTOOL prog
fi
