#!/bin/bash

OS=`uname`
KEY="$1"

LAST_PART="`echo "$KEY" | awk '{print $3}'`"

function populate_authorized_keys ()
{
	DIRECTORY=$1
	FILE=$2
	mkdir -p $DIRECTORY
	touch $FILE
	cat $FILE | grep -v "$LAST_PART$" > $FILE.tmp
	mv $FILE.tmp $FILE
	echo "$KEY" >> $FILE
}
        if [[ "$OS" == "Linux" ]]
        then
                #echo "INFO: Its a Linux OS"
		echo 0 > /selinux/enforce
		populate_authorized_keys $HOME/.ssh/ $HOME/.ssh/authorized_keys2
		populate_authorized_keys $HOME/.ssh/ $HOME/.ssh/authorized_keys

		cat /etc/ssh/sshd_config | egrep -v "^.?RSAAuthentication" | egrep -v "^.?PubkeyAuthentication" > /etc/ssh/sshd_config.tmp
		echo "RSAAuthentication yes" >> /etc/ssh/sshd_config.tmp
		echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config.tmp
		mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
		nohup /etc/init.d/sshd restart &
        elif [[ "$OS" == "SunOS" ]]
        then
                #echo "INFO: Its a Sun OS"
		populate_authorized_keys $HOME/.ssh/ $HOME/.ssh/authorized_keys2
		populate_authorized_keys $HOME/.ssh/ $HOME/.ssh/authorized_keys
		svcadm clear /network/ssh
		svcadm enable /network/ssh
        else
                echo "ERROR: Unrecognized operating system type $ARCH, exiting as don't know how to set it up for passwordless ssh"
                exit 1
        fi

