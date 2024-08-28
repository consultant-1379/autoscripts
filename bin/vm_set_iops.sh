#!/bin/bash

MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

VCLI="atvcli4.athtem.eei.ericsson.se"
VCLI="10.45.202.5"

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
		-n|--vmname <Desired vm name>
		-i|--iops <Desired iops limit, use keywoard unlimited for no limit>
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
	if [[ -z "$VMNAME" ]]
        then
                message "ERROR: You must give a vm name\n" ERROR
                usage_msg
        fi

	if [[ -z "$IOPS" ]]
        then
                message "ERROR: You must give an iops limit figure\n" ERROR
                usage_msg
	else
		if [[ "$IOPS" == "unlimited" ]]
		then
			IOPS="-1"
		fi
        fi
}


ARGS=`getopt -o "v:n:i:" -l "vcenter:,vmname:,iops:" -n "$0" -- "$@"`
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
		-n|--vmname)
			VMNAME="$2"
			shift 2;;
		-i|--iops)
			IOPS="$2"
			shift 2;;
		--)
                        shift
			break;;
        esac
done

check_args
ssh -qn $VCLI "source /opt/vmware/vma/bin/vifptarget --set $VCENTER;$MOUNTPOINT/bin/vmware-vsphere-cli-distrib/apps/vm/vm_set_iops.pl --vmname '$VMNAME' --iops $IOPS"
if [[ $? -ne 0 ]]
then
	message "ERROR: The vm didn't seem to be updated successfully, please check the output above\n" ERROR
	exit 1
fi
