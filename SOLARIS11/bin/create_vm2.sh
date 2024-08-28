#!/bin/bash

VCLI="atvcli4.athtem.eei.ericsson.se"

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
		-f|--file <path to the input file, it should be under the /export/scripts/CLOUD/configs/ directory somewhere>
		-v|--vcenter <vcenter hostname>
		-e|--esxihost <ESXI fully qualified hostname or a cluster name (in which case the first host in that cluster is used)>
		-d|--datastore <Datastore to store the vm on>
		-n|--vmname <Desired vm name>
" WARNING
	exit 1
}
function check_args()
{
        if [[ -z "$FILEPATH" ]]
        then
                message "ERROR: You must give a file path using --file <file path>\n" ERROR
                usage_msg
        fi
	if [[ -z "$VCENTER" ]]
        then
                message "ERROR: You must give a vcenter using --vcenter <vcenter hostname>\n" ERROR
                usage_msg
        fi
	if [[ -z "$ESXIHOST" ]]
        then
                message "ERROR: You must give an esxi host or cluster using --esxi host <cluster or esxi host>\n" ERROR
                usage_msg
        fi
	if [[ -z "$DATASTORE" ]]
        then
                message "ERROR: You must give a datastore to store the vm using --datastore <datastore name>\n" ERROR
                usage_msg
        fi
	if [[ -z "$VMNAME" ]]
        then
                message "ERROR: You must give a vm name\n" ERROR
                usage_msg
        fi
}


ARGS=`getopt -o "f:v:e:d:n:" -l "file:,vcenter:,esxihost:,datastore:,vmname:" -n "$0" -- "$@"`
if [[ $? -ne 0 ]]
then
        usage_msg
        exit 1
fi

eval set -- $ARGS

while true;
do
        case "$1" in
                -f|--file)
                        FILEPATH="$2"
                        shift 2;;
		-v|--vcenter)
			VCENTER="$2"
			shift 2;;
		-e|--esxihost)
                        ESXIHOST="$2"
                        shift 2;;
		-d|--datastore)
                        DATASTORE="$2"
                        shift 2;;
		-n|--vmname)
			VMNAME="$2"
			shift 2;;
		--)
                        shift
			break;;
        esac
done

check_args

ssh -q $VCLI "source /opt/vmware/vma/bin/vifptarget --set $VCENTER;/export/scripts/CLOUD/bin/vmware-vsphere-cli-distrib/apps/vm/vmcreate_new2.pl --filepath '$FILEPATH' --esxihost '$ESXIHOST' --datastore '$DATASTORE' --vmname '$VMNAME'"
if [[ $? -eq 0 ]]
then
	message "INFO: The vm seemed to have been created successfully\n" INFO
else
	message "ERROR: The vm didn't seem to be created successfully, please check the output above\n" ERROR
fi
