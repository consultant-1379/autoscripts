#!/bin/bash

MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'
# Setup the terminal
#echo -en $white
#clear
function message ()
{

        local MESSAGE="$1"
        local TYPE=$2

        COLOR=$white
        if [[ "$TYPE" == "ERROR" ]]
        then
                COLOR=$red
        fi
        if [[ "$TYPE" == "LINE" ]]
        then
                COLOR=$magenta
        fi
        if [[ "$TYPE" == "WARNING" ]]
        then
                COLOR=$yellow
        fi
        if [[ "$TYPE" == "SUMMARY" ]]
        then
                COLOR=$green
        fi
        if [[ "$TYPE" == "SCRIPT" ]]
        then
                COLOR=$cyan
        fi
        if [[ `echo "$MESSAGE" | egrep "^INFO:|^ERROR:|^WARNING:"` ]]
        then
                local FORMATTED_DATE="`date | awk '{print $2 "_" $3}'`"
                local FORMATTED_TIME="`date | awk '{print $4}'`"
                MESSAGE="[$FORMATTED_DATE $FORMATTED_TIME] $MESSAGE"
        fi
        echo -en $COLOR
        echo -en "$MESSAGE"
        echo -en $white

}

function usage_msg ()
{
        message "$0
                -v|--vcenter <vcenter hostname>
                -c|--cluster <Desired cluster>
" WARNING
        exit 1
}
function check_args()
{
        if [[ -z "$VCENTER" ]]
        then
                message "ERROR: You must give a vcenter using --vcenter <vcenter hostname>\n" ERROR
                usage_msg
        fi
        if [[ -z "$CLUSTER" ]]
        then
                message "ERROR: You must give a cluster\n" ERROR
                usage_msg
        fi
}


ARGS=`getopt -o "v:c:" -l "vcenter:,cluster:" -n "$0" -- "$@"`
if [[ $? -ne 0 ]]
then
        usage_msg
        exit 1
fi

eval set -- $ARGS

while true;
do
        case "$1" in
                -v|--vcenter)
                        VCENTER="$2"
                        shift 2;;
                -c|--cluster)
                        CLUSTER="$2"
                        shift 2;;
                --)
                        shift
                        break;;
        esac
done

check_args
OUTPUT=`$MOUNTPOINT/bin/list_hosts_in_cluster.sh -c "$CLUSTER" -v $VCENTER 2>&1`
if [[ $? -ne 0 ]]
then
	echo "error"
	echo "$OUTPUT"
else
	COUNT=`echo "$OUTPUT" | grep '[a-zA-Z0-9]' | wc -l`
	if [[ "$COUNT" == "0" ]]
	then
		echo -n "00"
	else
		echo -n $COUNT
	fi
fi
