#!/bin/bash

DEVICE=`cat /boot/solaris/bootenv.rc | grep " bootpath" | awk '{print $3}' | sed "s/'//g" | sort -u | head -1`
DISK=`ls -ltrh /dev/dsk/ | grep "$DEVICE" | awk '{print $9}'`
RAW_DISK="$DISK"
RAW_NAME=`echo "$RAW_DISK" | sed 's/..$//g'`
echo -n "${RAW_NAME}"
