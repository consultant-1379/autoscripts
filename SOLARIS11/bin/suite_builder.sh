#!/bin/bash

# Figure out the mountpoint
MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

# Define the path to the vcloud functions wrapper
VCLOUD_PHP_FUNCTION="$MOUNTPOINT/bin/vCloudFunctions_php.sh --username=script --vcloudphphostname=atvcloud3.athtem.eei.ericsson.se"

# Colors
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

# Setup the terminal
echo -e $white
clear

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

function build_suite ()
{
	local CONFIG_FILE="$1"

	# Make the variables read in from config local
	local ORGVDCNAME
	local CATALOG
	local ORIGIN_VAPP_TEMPLATE_NAME
	local SUITE_NAME
	local VM_KEEP_LIST

	echo "============================================================================================================="
	message "INFO: Reading config file $CONFIG_FILE\n" INFO
	echo "============================================================================================================="

	. $CONFIG_FILE
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Couldn't read the config file $CONFIG_FILE\n" ERROR
		exit 1
	fi

	# Validate that the variables are set
	requires_variable ORGVDCNAME
	requires_variable CATALOG
	requires_variable ORIGIN_VAPP_TEMPLATE_NAME
	requires_variable SUITE_NAME
	requires_variable VM_KEEP_LIST

	# Set some other variabels based on those above
	local TEMP_VAPP_NAME="${SUITE_NAME}_temp"
	local TEMP_VAPP_SUITE_NAME="${SUITE_NAME}_temp_suite"

	# Start the sequence
	message "INFO: Searching for the original vapp template called ${ORIGIN_VAPP_TEMPLATE_NAME} in catalog $CATALOG\n" INFO
	ORIGIN_VAPP_TEMPLATE_ID="`$VCLOUD_PHP_FUNCTION -f list_vapp_templates_in_catalog --catalogname \"$CATALOG\" | grep \"^${ORIGIN_VAPP_TEMPLATE_NAME};\" | awk -F\; '{print $2}'`"
	if [[ $? -ne 0 ]]
	then
	        message "$ORIGIN_VAPP_TEMPLATE_ID\n" ERROR
	        message "ERROR: Something went wrong searching for the original vapp template, see output above\n" ERROR
	        exit 1
	fi
	if [[ "$ORIGIN_VAPP_TEMPLATE_ID" == "" ]]
        then
                message "ERROR: Couldn't seem to find the original vapp template, make sure it exist?\n" ERROR
                exit 1
        fi
	message "INFO: Found it: $ORIGIN_VAPP_TEMPLATE_ID\n" INFO

	#message "INFO: Consolidating the vms in the original vapp template\n" INFO
	#OUTPUT="`$VCLOUD_PHP_FUNCTION -f consolidate_vapp_template --vapptemplateid $ORIGIN_VAPP_TEMPLATE_ID`"
	#if [[ $? -ne 0 ]]
        #then
        #        message "$OUTPUT\n" ERROR
        #        message "ERROR: Something went wrong consolidating the vms in the vapp template, see the error above\n" ERROR
        #        exit 1
        #fi

	message "INFO: Building a suite called $SUITE_NAME from original vapp template $ORIGIN_VAPP_TEMPLATE_NAME\n" INFO

	message "INFO: Searching for any old existing vapps in the $ORGVDCNAME datacenter called $TEMP_VAPP_NAME\n" INFO
	OLD_VAPP_ID=`$VCLOUD_PHP_FUNCTION -f list_vapps_in_orgvdc --orgvdcname "$ORGVDCNAME"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $OLD_VAPP_ID\n" ERROR
                message "ERROR: Something went wrong searching for the old temp vapp in the datacenter, see above\n" ERROR
		exit 1
        else
		OLD_VAPP_ID=`echo "$OLD_VAPP_ID" | grep "^${TEMP_VAPP_NAME};" | awk -F\; '{print $2}'`
                if [[ "$OLD_VAPP_ID" != "" ]]
                then
                        message "INFO: Found it: $OLD_VAPP_ID, deleting it\n" INFO
			DELETE_OUTPUT=`$VCLOUD_PHP_FUNCTION -f delete_vapp --vappid $OLD_VAPP_ID`
			if [[ $? -ne 0 ]]
			then
				message "$DELETE_OUTPUT\n" ERROR
				message "ERROR: Something went wrong deleting the old temp vapp, see above\n" ERROR
				exit 1
			fi
                else
                        message "INFO: Couldn't find any old temp vapp, maybe it didn't exist\n" INFO
                fi
        fi

	message "INFO: Deploying this master vapp template from the catalog $CATALOG into the datacenter $ORGVDCNAME before working on it\n" INFO
	VAPP_ID_OUTPUT="`$VCLOUD_PHP_FUNCTION -f deploy_from_catalog --linkedclone true --destorgvdcname \"$ORGVDCNAME\" --vapptemplateid $ORIGIN_VAPP_TEMPLATE_ID --newvappname \"$TEMP_VAPP_NAME\" --startvapp no`"
	if [[ $? -ne 0 ]]
        then
                message "$VAPP_ID_OUTPUT\n" ERROR
                message "ERROR: Something went wrong deploying the original vapp, see the error above\n" ERROR
                exit 1
        fi
	VAPP_ID_OUTPUT=`echo "$VAPP_ID_OUTPUT" | grep "NEWVAPPID" | awk '{print $2}'`

	VM_LIST=`$VCLOUD_PHP_FUNCTION -f list_vms_in_vapp --vappid=$VAPP_ID_OUTPUT 2>&1`
	if [[ $? -ne 0 ]]
        then
                message "$VM_LIST\n" ERROR
                message "ERROR: Something went wrong listing the vms in this vapp, see above\n" ERROR
                exit 1
        fi

	# Loop through the vms
	while read vm
	do
		vm_name=`echo "$vm" | awk -F\; '{print $1}'`
		VMID=`echo "$vm" | awk -F\; '{print $3}'`
		if [[ `echo "$VM_KEEP_LIST" | grep "^$vm_name$"` ]]
		then
			message "INFO: Keeping $vm_name (ie $VMID) as it was in the keep list\n" INFO
			if [[ "$vm_name" == "master_sfs" ]] && [[ "$SFS_POOLS_REQUIRED" != "" ]]
			then
				message "INFO: This is the sfs vm, and a specific list of pools required has been set\n" INFO
				FULL_DISK_LIST=""
				while read SFS_POOL_REQUIRED
				do
					DISKS=`echo "$SFS_POOLS_DISK_DEFINITIONS" | grep "$SFS_POOL_REQUIRED" | awk '{print $2}'`
					if [[ "$DISKS" == "" ]]
					then
						message "ERROR: There were no disk details found for a pool called $SFS_POOL_REQUIRED\n" ERROR
						exit 1
					fi
					if [[ "$FULL_DISK_LIST" == "" ]]
					then
						FULL_DISK_LIST="$DISKS"
					else
						FULL_DISK_LIST="$FULL_DISK_LIST,$DISKS"
					fi
				done  < <(echo "$SFS_POOLS_REQUIRED" | sed '/^$/d' | sort -u)

				message "INFO: The full list of disks being kept on the sfs are $FULL_DISK_LIST. The rest will now be deleted\n" INFO
				DELETE_DISKS_OUTPUT="`$VCLOUD_PHP_FUNCTION -f delete_disks_rest --vmid=$VMID --diskstokeep=$FULL_DISK_LIST`"
				if [[ $? -ne 0 ]]
				then
					message "$DELETE_DISKS_OUTPUT\n" ERROR
					message "ERROR: Something went wrong deleting the disks from this vm $VMID, please see output above\n" ERROR
					exit 1
				fi
			fi
		else
			message "INFO: Deleting $vm_name (ie $VMID) as it wasn't in the keep list\n" INFO
			DELETE_OUTPUT="`$VCLOUD_PHP_FUNCTION -f delete_vm --vmid=$VMID`"
			if [[ $? -ne 0 ]]
			then
				message "$DELETE_OUTPUT\n" ERROR
				message "ERROR: Something went wrong deleting this vm $VMID, please see output above\n" ERROR
				exit 1
			fi
		fi
	done < <(echo "$VM_LIST")

	message "INFO: Searching for any old existing temp vapp templates in the catalog called ${TEMP_VAPP_SUITE_NAME}\n" INFO
        ORIGIN_VAPP_TEMPLATE_SUITE_ID="`$VCLOUD_PHP_FUNCTION -f list_vapp_templates_in_catalog --catalogname \"$CATALOG\"`"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $ORIGIN_VAPP_TEMPLATE_SUITE_ID\n" ERROR
                message "ERROR: Something went wrong searching for the original vapp, see above\n" ERROR
		exit 1
        else
                ORIGIN_VAPP_TEMPLATE_SUITE_ID=`echo "$ORIGIN_VAPP_TEMPLATE_SUITE_ID"  | grep "^${TEMP_VAPP_SUITE_NAME};" | awk -F\; '{print $2}'`
                if [[ "$ORIGIN_VAPP_TEMPLATE_SUITE_ID" != "" ]]
                then
                        message "INFO: Found it: $ORIGIN_VAPP_TEMPLATE_SUITE_ID, deleting it now\n" INFO
                        DELETE_OUTPUT=`$VCLOUD_PHP_FUNCTION -f delete_vapp_template --vapptemplateid $ORIGIN_VAPP_TEMPLATE_SUITE_ID`
                        if [[ $? -ne 0 ]]
                        then
                                message "$DELETE_OUTPUT\n" ERROR
                                message "ERROR: Something went wrong deleting it, see above\n" ERROR
                                exit 1
                        fi
                else
                        message "INFO: Couldn't find any original temp vapp template, maybe it didn't exist\n" INFO
                fi
        fi

	message "INFO: Adding the vapp back to the catalog as $TEMP_VAPP_SUITE_NAME\n" INFO
	NEW_CATALOG_ID=`$VCLOUD_PHP_FUNCTION -f add_vapp_to_catalog --vappid $VAPP_ID_OUTPUT --newvapptemplatename "$TEMP_VAPP_SUITE_NAME" --destcatalogname "$CATALOG"`
	if [[ $? -ne 0 ]]
	then
		message "$NEW_CATALOG_ID\n" ERROR
		message "ERROR: Something went wrong adding the vapp back to the catalog, check above\n" ERROR
		exit 1
	fi
	NEW_CATALOG_ID=`echo "$NEW_CATALOG_ID" | grep "NEWVAPPTEMPLATEID" | awk '{print $2}'`

	message "INFO: Removing the temp vapp $TEMP_VAPP_NAME from the datacenter as its no longer needed\n" INFO
	DELETE_OUTPUT=`$VCLOUD_PHP_FUNCTION -f delete_vapp --vappid $VAPP_ID_OUTPUT`
	if [[ $? -ne 0 ]]
        then
                message "$DELETE_OUTPUT\n" ERROR
                message "ERROR: Something went wrong deleting the vapp, check above\n" ERROR
                exit 1
        fi

	message "INFO: Consolidating the vms in the new vapp template\n" INFO
        OUTPUT="`$VCLOUD_PHP_FUNCTION -f consolidate_vapp_template --vapptemplateid $NEW_CATALOG_ID`"
        if [[ $? -ne 0 ]]
        then
                message "$OUTPUT\n" ERROR
                message "ERROR: Something went wrong consolidating the vms in the vapp template, see the error above\n" ERROR
                exit 1
        fi

	message "INFO: Searching for any existing vapp template in the catalog called ${SUITE_NAME}\n" INFO
        ORIGIN_VAPP_TEMPLATE_SUITE_ID="`$VCLOUD_PHP_FUNCTION -f list_vapp_templates_in_catalog --catalogname \"$CATALOG\"`"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $ORIGIN_VAPP_TEMPLATE_SUITE_ID\n" ERROR
                message "ERROR: Something went wrong searching for the original vapp, see above\n" ERROR
        else
                ORIGIN_VAPP_TEMPLATE_SUITE_ID=`echo "$ORIGIN_VAPP_TEMPLATE_SUITE_ID"  | grep "^${SUITE_NAME};" | awk -F\; '{print $2}'`
                if [[ "$ORIGIN_VAPP_TEMPLATE_SUITE_ID" != "" ]]
                then
                        message "INFO: Found it: $ORIGIN_VAPP_TEMPLATE_SUITE_ID, deleting it now\n" INFO
                        DELETE_OUTPUT=`$VCLOUD_PHP_FUNCTION -f delete_vapp_template --vapptemplateid $ORIGIN_VAPP_TEMPLATE_SUITE_ID`
                        if [[ $? -ne 0 ]]
                        then
                                message "$DELETE_OUTPUT\n" ERROR
                                message "ERROR: Something went wrong deleting it, see above\n" ERROR
                                exit 1
                        fi
                else
                        message "INFO: Couldn't find any original vapp template called ${SUITE_NAME}, maybe it didn't exist\n" INFO
                fi
        fi

	message "INFO: Renaming the temp vapp template from $TEMP_VAPP_SUITE_NAME to ${SUITE_NAME}\n" INFO
	RENAME_OUTPUT=`$VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NEW_CATALOG_ID --newvapptemplatename "${SUITE_NAME}"`
	if [[ $? -ne 0 ]]
        then
		message "ERROR: $RENAME_OUTPUT\n" ERROR
                message "ERROR: Couldn't rename the vapp template, please check output above\n" ERROR
        fi

	message "INFO: Successfully created the new vapp template ${SUITE_NAME}\n" INFO

}

function usage_msg ()
{
	message "Usage: $0 -c <CONFIG FILE> or $0 -d <DIR FILE>\n" ERROR
	exit 1
}

function requires_variable ()
{
    local VARTEST=`eval echo \\$$1`
    if [[ -z $VARTEST ]]
    then
        message "ERROR: The variable $1 wasn't set in any of your config files, please check why not\n" ERROR
        exit 1
    fi
}

function check_args ()
{
	if [[ -z "$CONFIG" ]] && [[ -z "$DIR" ]]
        then
                message "ERROR: You must give a config name or dir name\n" ERROR
                usage_msg
        fi
}

while getopts "c:d:" arg
do
	case $arg in
		c) CONFIG="$OPTARG"
		;;
		d) DIR="$OPTARG"
                ;;
		\?) usage_msg
		exit 1
		;;
	esac
done

check_args

SFS_POOL_DISK_DEFINITIONS_FILE=/export/scripts/CLOUD/configs/suites/sfs_pool_disk_definitions.txt
. $SFS_POOL_DISK_DEFINITIONS_FILE
if [[ $? -ne 0 ]]
then
	message "ERROR: Couldn't read the config file containing the sfs pool disk definitions $SFS_POOL_DISK_DEFINITIONS_FILE\n" ERROR
	exit 1
fi

# Build a suite for one config, or a directory of configs
if [[ "$CONFIG" != "" ]]
then
	build_suite "$CONFIG"
else
	# Find the config files in that directory, and run the suite builder against each
	ls -r $DIR/* | while read CONFIG
	do
		build_suite "$CONFIG"
	done
fi
