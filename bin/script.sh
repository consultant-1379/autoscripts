#!/bin/bash

ORG=$1
ESXHOST1=$2
ESXHOST2=$3

if [[ "$ESXHOST2" == "" ]]
then
	echo "Give org esxihost1 esxihost2 as arguments"
	exit 1
fi

/export/scripts/CLOUD/bin/vCloudFunctions.sh --username root --password shroot12 --organization System -f list_vapp_templates_in_org --orgname $ORG | grep -i vapp | awk -F\; '{print $2}' | while read template
do
	echo "---------------------------------------------"
	echo "Working on vapp template $template"
	echo "---------------------------------------------"
	/export/scripts/CLOUD/bin/vCloudFunctions.sh --username root --password shroot12 --organization System -f list_vms_in_vapp_template --vapptemplateid "$template" | awk -F\; '{print $2}' | while read VMNAME
	do
		echo "INFO: Working on vm $VMNAME"
		echo "INFO: Removing serial port"

		output=`ssh -n -q atvcli4.athtem.eei.ericsson.se "source /opt/vmware/vma/bin/vifptarget --set atvcen3.athtem.eei.ericsson.se;/export/scripts/CLOUD/bin/serial.pl --op remove --vmname '$VMNAME'"`
		if [[ $? -ne 0 ]] && [[ ! `echo "$output" | grep "Count not find serial port to remove"` ]]
		then
                	echo "ERROR: Something went wrong removing the serial port"
		else
			if [[ `echo "$output" | grep "Count not find serial port to remove"` ]]
			then
				echo "INFO: It hadn't got a serial port to remove"
			else
				echo "INFO: Serial port removed successfully"
			fi
			echo "INFO: Migrating the vm"
			ssh -n -q atvcli4.athtem.eei.ericsson.se "source /opt/vmware/vma/bin/vifptarget --set atvcen3.athtem.eei.ericsson.se;/export/scripts/CLOUD/bin/migratevm.pl --dst $ESXHOST1 --vmname \"$VMNAME\""
			ssh -n -q atvcli4.athtem.eei.ericsson.se "source /opt/vmware/vma/bin/vifptarget --set atvcen3.athtem.eei.ericsson.se;/export/scripts/CLOUD/bin/migratevm.pl --dst $ESXHOST2 --vmname \"$VMNAME\""
		fi
		echo "---------------------------------------------"
	done
done
