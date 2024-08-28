#!/bin/bash

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
		-u|--username <LOGIN USERNAME>
		-p|--password <LOGIN PASSWORD>
		-o|--organization <LOGIN ORG NAME>
		-f|--function <FUNCTION NAME>
                --vcdname vCloud Director server in format https://fully.qualified.domain.name/
			## Function List ##

			# Vapp Template Related
			list_vapp_templates_in_org --orgname <org name>
			add_vapp_to_catalog --vappid <vappid> --newvapptemplatename <new vapp template name> --destcatalogname <destination catalog name>
			deploy_from_catalog --destorgvdcname <destination org vdc name> --vapptemplateid <vapptemplateid> --newvappname <new vapp name> --linkedclone <true or false>
			copy_vapp_template --vapptemplateid <vapptemplateid> --newvapptemplatename <new vapp template name> --destcatalogname <destination catalog name | use the name 'same' to keep it in the same catalog>
			consolidate_vapp_template --vapptemplateid <vapptemplateid>
			delete_vapp_template --vapptemplateid <vapptemplateid>
			update_storage_lease_vapp_template --vapptemplateid <vapptemplateid>
			get_catalog_of_vapp_template --vapptemplateid <vapptemplateid>
			get_org_of_vapp_template --vapptemplateid <vapptemplateid>
			get_orgvdc_of_vapp_template --vapptemplateid <vapptemplateid>
			rename_vapp_template --vapptemplateid <vapptemplateid> --newvapptemplatename <vapp template name>
			
			# Vapp Related
			list_vapps_in_org --orgname <org name>
			get_vapp_id_by_gateway_ip --gatewayip <gateway ip>
			get_vapp_id_by_gateway_hostname --gatewayhostname <gateway hostname>
			start_vapp --vappid <vappid>
			stop_vapp --vappid <vappid>
			poweroff_vapp --vappid <vappid>
			shutdown_vapp --vappid <vappid>
			force_stop_vapp --vappid <vappid>
			suspend_vapp --vappid <vappid>
			clone_vapp --vappid <vappid> --linkedclone <true or false> --newvappname <new vapp name>
			consolidate_vapp --vappid <vappid>
			delete_vapp --vappid <vappid>
			update_storage_lease_vapp --vappid <vappid> --leaseseconds <lease time in seconds>
			update_runtime_lease_vapp --vappid <vappid> --leaseseconds <lease time in seconds>
			rename_vapp --vappid <vappid> --newvappname <vapp name>

			# VM Related
			list_vms_in_vapp --vappid <vappid>
			list_vms_in_vapp_template --vapptemplateid <vapptemplateid>
			list_nics_on_vm --vmid <vmid>
			delete_vm --vmid <vmid>
			poweron_vm --vmid <vmid>
			poweroff_vm --vmid <vmid>
			shutdown_vm --vmid <vmid>
			reset_vm --vmid <vmid>
			reboot_vm --vmid <vmid>
			suspend_vm --vmid <vmid>
			set_cpus_vm --vmid <vmid> --cpucount <cpu count>
			set_memory_vm --vmid <vmid> --memorymb <memory size in mb>
			
			# Gateway Related
			update_org_network_gateway --vappid <vappid>
			reset_mac_gateway --vappid <vappid>
			poweron_gateway --vappid <vappid>
" WARNING
        exit 1
}
function check_args()
{
	if [[ -z "$USERNAME" ]]
        then
                message "ERROR: You must give a username\n" ERROR
                usage_msg
        fi
	if [[ -z "$PASSWORD" ]]
        then
                message "ERROR: You must give a password\n" ERROR
                usage_msg
        fi
	if [[ -z "$ORGANIZATION" ]]
        then
                message "ERROR: You must give a organization\n" ERROR
                usage_msg
        fi
        if [[ -z "$FUNCTION" ]]
        then
                message "ERROR: You must give a function\n" ERROR
                usage_msg
        fi
        if [[ -z "$VCDNAME" ]]
        then
                VCDNAME="https://atvcd1.athtem.eei.ericsson.se/"
        fi

        if [[ ! `type $FUNCTION 2>/dev/null | grep "is a function"` ]]
        then
                message "$FUNCTION is not a valid function\n" ERROR
                usage_msg
        fi
}

function requires_variable ()
{
    local VARTEST=`eval echo \\$$1`
    if [[ -z $VARTEST ]]
    then
        message "ERROR: The variable $1 wasn't set, please check why not\n" ERROR
        exit 1
    fi
}
function get_vapp_id_by_gateway_ip ()
{
	requires_variable GATEWAYIP
	$VCLOUD $FUNCTION "$GATEWAYIP"
}
function get_vapp_id_by_gateway_hostname ()
{
	requires_variable GATEWAYHOSTNAME
	GATEWAYIP="`host $GATEWAYHOSTNAME`"
	EXIT_CODE=$?
	GATEWAYIP="`echo "$GATEWAYIP" | awk '{print $4}' | head -1`"
	if [[ $EXIT_CODE -ne 0 ]] ||  [[ "$GATEWAYIP" == "" ]]
	then
		message "ERROR: Couldn't figure out the gateway ip from its hostname\n" ERROR
		exit 1
	fi
        $VCLOUD get_vapp_id_by_gateway_ip "$GATEWAYIP"
}
function deploy_from_catalog ()
{
	requires_variable DESTORGVDCNAME
	requires_variable VAPPTEMPLATEID
	requires_variable NEWVAPPNAME
	requires_variable LINKEDCLONE
	$VCLOUD $FUNCTION "$DESTORGVDCNAME" $VAPPTEMPLATEID "$NEWVAPPNAME" $LINKEDCLONE
}
function update_org_network_gateway ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function reset_mac_gateway ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function poweron_gateway ()
{
	requires_variable VAPPID
	$VCLOUD $FUNCTION $VAPPID
}
function list_nics_on_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function delete_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function rename_vapp ()
{
	requires_variable VAPPID
	requires_variable NEWVAPPNAME
	$VCLOUD $FUNCTION $VAPPID $NEWVAPPNAME
}
function rename_vapp_template ()
{
        requires_variable VAPPTEMPLATEID
        requires_variable NEWVAPPTEMPLATENAME
        $VCLOUD $FUNCTION $VAPPTEMPLATEID $NEWVAPPTEMPLATENAME
}
function set_cpus_vm()
{
        requires_variable VMID
	requires_variable CPUCOUNT
        $VCLOUD $FUNCTION $VMID $CPUCOUNT
}
function set_memory_vm()
{
        requires_variable VMID
        requires_variable MEMORYMB
        $VCLOUD $FUNCTION $VMID $MEMORYMB
}
function poweron_vm ()
{
	requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function poweroff_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function shutdown_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function reset_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function reboot_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function suspend_vm ()
{
        requires_variable VMID
        $VCLOUD $FUNCTION $VMID
}
function start_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function stop_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function poweroff_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function shutdown_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function force_stop_vapp()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function suspend_vapp()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function delete_vapp()
{
        requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}

function delete_vapp_template()
{
        requires_variable VAPPTEMPLATEID
        $VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function list_vms_in_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function list_vms_in_vapp_template ()
{
        requires_variable VAPPTEMPLATEID
        $VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function update_storage_lease_vapp ()
{
	requires_variable VAPPID
        requires_variable LEASESECONDS
        $VCLOUD $FUNCTION $VAPPID $LEASESECONDS
}
function update_runtime_lease_vapp ()
{
	requires_variable VAPPID
        requires_variable LEASESECONDS
        $VCLOUD $FUNCTION $VAPPID $LEASESECONDS
}
function update_storage_lease_vapp_template ()
{
	requires_variable VAPPTEMPLATEID
	requires_variable LEASESECONDS
        $VCLOUD $FUNCTION $VAPPTEMPLATEID $LEASESECONDS
}
function consolidate_vapp ()
{
	requires_variable VAPPID
        $VCLOUD $FUNCTION $VAPPID
}
function get_catalog_of_vapp_template ()
{
	requires_variable VAPPTEMPLATEID
        $VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function get_org_of_vapp_template ()
{
        requires_variable VAPPTEMPLATEID
        $VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function get_orgvdc_of_vapp_template ()
{
        requires_variable VAPPTEMPLATEID
        $VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function consolidate_vapp_template ()
{
	requires_variable VAPPTEMPLATEID
	$VCLOUD $FUNCTION $VAPPTEMPLATEID
}
function clone_vapp ()
{
	requires_variable VAPPID
	requires_variable NEWVAPPNAME
	requires_variable LINKEDCLONE
        $VCLOUD $FUNCTION $VAPPID $LINKEDCLONE "$NEWVAPPNAME"
}

function copy_vapp_template ()
{
	requires_variable VAPPTEMPLATEID
	requires_variable NEWVAPPTEMPLATENAME
	requires_variable DESTCATALOGNAME
        $VCLOUD $FUNCTION $VAPPTEMPLATEID "$NEWVAPPTEMPLATENAME" "$DESTCATALOGNAME"
}
function add_vapp_to_catalog ()
{
	requires_variable VAPPID
	requires_variable NEWVAPPTEMPLATENAME
	requires_variable DESTCATALOGNAME
	$VCLOUD $FUNCTION $VAPPID "$NEWVAPPTEMPLATENAME" "$DESTCATALOGNAME"
}
function list_vapps_in_org ()
{
	requires_variable ORGNAME
	$VCLOUD $FUNCTION "$ORGNAME"
}
function list_vapp_templates_in_org ()
{
	requires_variable ORGNAME
        $VCLOUD $FUNCTION "$ORGNAME"
}

# Execute getopt
ARGS=`getopt -o "u:p:o:f:" -l "username:,password:,organization:,function:,vappid:,vmid:,vapptemplateid:,leaseseconds:,destorgvdcname:,newvappname:,newvapptemplatename:,linkedclone:,orgname:,gatewayip:,gatewayhostname:,destcatalogname:,memorymb:,cpucount:,newvappname:,newvapptemplatename:,vcdname:" -n "$0" -- "$@"`
if [[ $? -ne 0 ]]
then
	usage_msg
        exit 1
fi

eval set -- $ARGS

# Now go through all the options
while true;
do
        case "$1" in
                -u|--username)
			USERNAME=$2
                        shift 2;;

                -p|--password)
			PASSWORD=$2
                        shift 2;;

                -o|--organization)
			ORGANIZATION=$2
                        shift 2;;

                -f|--function)
			FUNCTION=$2
			shift 2;;

		--vappid)
			VAPPID=$2
			shift 2;;

		--vmid)
                        VMID=$2
                        shift 2;;

		--vapptemplateid)
			VAPPTEMPLATEID=$2
			shift 2;;

		--leaseseconds)
			LEASESECONDS=$2
			shift 2;;

		--destorgvdcname)
			DESTORGVDCNAME="$2"
			shift 2;;

		--linkedclone)
			LINKEDCLONE=$2
			shift 2;;

		--orgname)
			ORGNAME="$2"
			shift 2;;

		--newvappname)
                        NEWVAPPNAME="$2"
                        shift 2;;

		--newvapptemplatename)
			NEWVAPPTEMPLATENAME="$2"
			shift 2;;

		--gatewayip)
			GATEWAYIP="$2"
			shift 2;;

		--gatewayhostname)
			GATEWAYHOSTNAME="$2"
			shift 2;;

		--destcatalogname)
			DESTCATALOGNAME="$2"
			shift 2;;

		--cpucount)
			CPUCOUNT="$2"
			shift 2;;

		--memorymb)
			MEMORYMB="$2"
			shift 2;;

		--newvappname)
			NEWVAPPNAME="$2"
			shift 2;;

		--newvapptemplatename)
                        NEWVAPPTEMPLATENAME="$2"
                        shift 2;;

		--vcdname)
                        VCDNAME="$2"
                        shift 2;;
                --)
                        shift
                        break;;
        esac
done

check_args

# Define the basic vcloud java call
VCLOUD="/export/scripts/CLOUD/bin/java/jre/`uname -i`/*/bin/java -jar /export/scripts/CLOUD/bin/java/VCloudFunctions/dist/VCloudFunctions.jar $VCDNAME $USERNAME@$ORGANIZATION $PASSWORD"

# Call the function
$FUNCTION
