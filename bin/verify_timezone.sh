#!/bin/bash

DESIRED=$1

echo -n "INFO: Verifying timezone: "
if [[ "$DESIRED" == "$TZ" ]]
then
	echo "OK"
	exit 0
else
	echo "NOK, timezone set to $TZ instead of $DESIRED"
	exit 1
fi
