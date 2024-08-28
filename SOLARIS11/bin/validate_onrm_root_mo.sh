#!/bin/bash

echo -n "INFO Validating Root Mo: "
DESIRED=$1
#CURRENT="`/opt/ericsson/nms_cif_cs/etc/unsupported/bin/cstest -s ONRM_CS lrm | head -1 | awk -F= '{print $2}'`"
CURRENT="`grep im_root= /ericsson/config/system.ini | head -1 | awk -F= '{print $2}'`"
if [[ "$DESIRED" == "$CURRENT" ]]
then
	echo "OK"
else
	echo "NOK, it was $CURRENT instead of $DESIRED"
fi
