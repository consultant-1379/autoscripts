#!/bin/bash

NAME=$1
MOUNTPATH=$2
REMOTE_LOCATION=$3

#HOSTNAME=`/usr/bin/hostname`
HOSTNAME=`hostname`
mkdir -p $MOUNTPATH
FILECOUNT=`ls $MOUNTPATH | wc -l`
if [[ "$FILECOUNT" -gt 0 ]]
then
	exit 0
fi
if [[ -f /opt/VRTS/bin/haconf ]]
then
/opt/VRTS/bin/haconf -makerw
/opt/VRTS/bin/hagrp -add Mounts
/opt/VRTS/bin/hagrp -modify Mounts SystemList $HOSTNAME 1
/opt/VRTS/bin/hagrp -modify Mounts AutoStartList $HOSTNAME
#/opt/VRTS/bin/haconf -dump -makero

#/opt/VRTS/bin/haconf -makerw
/opt/VRTS/bin/hares -add $NAME Mount Mounts
/opt/VRTS/bin/hares -modify $NAME MountPoint "$MOUNTPATH"
/opt/VRTS/bin/hares -modify $NAME BlockDevice "$REMOTE_LOCATION"
/opt/VRTS/bin/hares -modify $NAME FSType nfs
/opt/VRTS/bin/hares -modify $NAME MountOpt rw
/opt/VRTS/bin/hares -modify $NAME Critical 0
/opt/VRTS/bin/hares -modify $NAME Enabled 1
/opt/VRTS/bin/haconf -dump -makero
sleep 10
/opt/VRTS/bin/hagrp -clear Mounts -sys $HOSTNAME
/opt/VRTS/bin/hagrp -online Mounts -sys $HOSTNAME
/opt/VRTS/bin/hares -clear $NAME -sys $HOSTNAME
/opt/VRTS/bin/hares -online $NAME -sys $HOSTNAME

elif [[ -f /etc/vfstab ]]
then
        ENTRY="$REMOTE_LOCATION       -       $MOUNTPATH       nfs     -       yes     -"
        if [[ ! `grep "$ENTRY" /etc/vfstab` ]]
        then
                echo "$ENTRY" >> /etc/vfstab
		mountall
        fi
elif [[ -f /etc/fstab ]]
then
	ENTRY="$REMOTE_LOCATION $MOUNTPATH nfs rw,auto,user,exec 0 0"
	if [[ ! `grep "$ENTRY" /etc/fstab` ]]
        then
                echo "$ENTRY" >> /etc/fstab
                mount -a
        fi
fi

ATTEMPT=1
while [[ $ATTEMPT -le 6 ]]
do
	FILECOUNT=`ls $MOUNTPATH | wc -l`
	if [[ "$FILECOUNT" -gt 0 ]]
	then
		exit 0
	else
		sleep 10
	fi
	let ATTEMPT=ATTEMPT+1
done

echo "ls of $MOUNTPATH results below"
echo "------------------------------"
ls $MOUNTPATH
echo "------------------------------"
exit 1
