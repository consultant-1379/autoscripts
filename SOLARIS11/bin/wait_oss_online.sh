#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -s SERVER_HOSTNAME"
        exit 1
}
check_args()
{
        if [[ -z "$SERVER_HOSTNAME" ]]
        then
                echo "ERROR: You must say what the server hostname is"
                exit 1
        fi
}

while getopts "s:" arg
do
    case $arg in
	s) SERVER_HOSTNAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

ATTEMPT=1
while [[ $ATTEMPT -le 20 ]]
do
	echo "INFO: Checking if Oss is ONLINE, attempt $ATTEMPT of 20"
	HASTATUS=`/opt/VRTS/bin/hastatus -sum 2>&1 | egrep 'Oss ' | grep Y | grep "$SERVER_HOSTNAME" | head -1 | awk '{print $6}'`
	if [[ "${HASTATUS}" != "ONLINE" ]]
	then
		echo "INFO: Its not ONLINE yet, waiting for 60 seconds for Oss to come on ONLINE"
		#/opt/VRTS/bin/hastatus -sum
		sleep 60
	else
		#echo "INFO: Its ONLINE, lets wait for 60 seconds just to be sure"
		#sleep 60
		echo "INFO: Final output of hastatus -sum below"
		/opt/VRTS/bin/hastatus -sum
		exit 0
	fi
	let ATTEMPT=ATTEMPT+1
done

echo "ERROR: hastatus -sum output below"
/opt/VRTS/bin/hastatus -sum
exit 1
