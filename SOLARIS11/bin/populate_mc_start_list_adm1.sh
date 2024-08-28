#!/bin/bash

echo -n "INFO: Waiting for the /etc/opt/ericsson/nms_cif_smssr/ directory to become available, please wait..."
ATTEMPT=1
while [[ $ATTEMPT -le 3600 ]]
do

	if [[ -d /etc/opt/ericsson/nms_cif_smssr/ ]]
	then
	echo "OPS_Server
OsgiFwk
ParameterService
SelfManagementStartStop
SMO_IS_Module
SMO_J20_Module
SMO_RBS_Module
TSSAuthorityMC
SelfManagement
NMSNotificationAgent
NotificationAgent
ActivityManager
cap_pdb_nfh
LaunchService
SelfManagementCore" > /etc/opt/ericsson/nms_cif_smssr/mc_start_list
		echo "OK"
		exit 0
	fi
	sleep 1
	let ATTEMPT=ATTEMPT+1
done

echo "ERROR: The /etc/opt/ericsson/nms_cif_smssr/ directory wasn't found, perhaps ha didnt' come online, hastatus -sum output below"
hastatus -sum
exit 1
