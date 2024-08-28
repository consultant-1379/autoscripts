#!/bin/bash

INPUT_HOSTNAME=$1
INPUT_USERNAME=$2
INPUT_PASSWORD=$3
date="`date +"%m-%d-%y"`"
OUTPUT_FILENAME=${INPUT_HOSTNAME}_${date}.xml
expect <<EOF
set timeout 120
spawn /opt/Navisphere/bin/naviseccli -h $INPUT_HOSTNAME -User $INPUT_USERNAME -Password $INPUT_PASSWORD -Scope 0 arrayconfig -capture -output /tmp/backup/$OUTPUT_FILENAME
while {"1" == "1"} {
expect {
	"Please input your selection" {
		send "1\r"
	}
	"Do you wish to overwrite it" {
		send "y\r"
	}
	timeout {
		send_user "Timed out creating the xml, is 2 minutes enough?\n"
		exit 1
	}
	eof {
		exit 0
	}
}
}

EOF

if [[ ! -f /tmp/backup/$OUTPUT_FILENAME ]]
then
	echo "ERROR: The xml didn't seem to get created in /tmp/backup/$OUTPUT_FILENAME"
	exit 1
fi
