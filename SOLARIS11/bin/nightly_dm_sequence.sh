## Remove when variable is in media.txt
        requires_variable VERSION_LABEL

        # Check that the version label meets the rules
        if [[ `echo "$VERSION_LABEL" | grep "_" ` ]]
        then
                message "ERROR: The VERSION_LABEL must not contain any underscores\n" ERROR
                exit 1
        fi
        FORMATTED_DATE=`date +"%Y.%m.%d_%H.%M.%S"`
        NIGHTLY_VAPP_NAME="ossrc_${VERSION_LABEL}_${FORMATTED_DATE}"

        ##############################################################################

        message "INFO: Searching for id for ${VAPPTEMPLATE}\n" INFO
        message "$VCLOUD_PHP_FUNCTION -f list_vapp_templates_in_catalog --catalogname $SOURCECATALOGNAME | grep \"${VAPPTEMPLATE};\"\n" INFO
        MASTER_PRIVATE_BUILD_TEMPLATE_ID="`$VCLOUD_PHP_FUNCTION -f list_vapp_templates_in_catalog --catalogname $SOURCECATALOGNAME | grep "${VAPPTEMPLATE};" | awk -F\; '{print $2}'`"
        if [[ $? -ne 0 ]]
        then
                message "$MASTER_PRIVATE_BUILD_TEMPLATE_ID\n" ERROR
                message "ERROR: Something went wrong searching for the id for ${VAPPTEMPLATE}\n" ERROR
                exit 1
        fi
        message "$MASTER_PRIVATE_BUILD_TEMPLATE_ID\n" INFO

        ##############################################################################

        message "INFO: Creating nightly vapp $NIGHTLY_VAPP_NAME\n" INFO
        message "$VCLOUD_PHP_FUNCTION -f deploy_from_catalog --linkedclone true --destorgvdcname $VDCNAME --vapptemplateid $MASTER_PRIVATE_BUILD_TEMPLATE_ID --newvappname \"$NIGHTLY_VAPP_NAME\" --startvapp yes\n" INFO
        NIGHTLY_VAPP_ID_OUTPUT="`$VCLOUD_PHP_FUNCTION -f deploy_from_catalog --linkedclone true --destorgvdcname $VDCNAME --vapptemplateid $MASTER_PRIVATE_BUILD_TEMPLATE_ID --newvappname \"$NIGHTLY_VAPP_NAME\" --startvapp yes`"
        if [[ $? -ne 0 ]]
        then
                message "$NIGHTLY_VAPP_ID_OUTPUT\n" ERROR
                message "ERROR: Something went wrong creating the vapp\n" ERROR
                exit 1
        fi
        NIGHTLY_VAPP_ID=`echo "$NIGHTLY_VAPP_ID_OUTPUT" | grep "NEWVAPPID" | awk '{print $2}'`
        message "$NIGHTLY_VAPP_ID\n" INFO

        ##############################################################################
        #VM Specific updates
        message "INFO: Retrieving the list of vms in the vapp: " INFO
        NIGHTLY_VM_IDS="`$VCLOUD_PHP_FUNCTION -f list_vms_in_vapp --vappid $NIGHTLY_VAPP_ID`"
        if [[ $? -ne 0 ]]
        then
                message "$NIGHTLY_VM_IDS\n" ERROR
                message "ERROR: Something went wrong listing the vms in the vapp\n" ERROR
                exit 1
        fi
        message "OK\n" INFO

        # Figure out ossmaster id
        #ADM1_MASTER_VM_ID=`echo "$NIGHTLY_VM_IDS" | grep "ossmaster" | awk -F\; '{print $3}'`

        #message "INFO: Setting the memory on the ossmaster to be 64gb: " INFO
        #$VCLOUD_PHP_FUNCTION -f set_memory_vm --vmid "$ADM1_MASTER_VM_ID" --memorymb 65536
        #if [[ $? -ne 0 ]]
	#then
        #        message "ERROR: Something went wrong updating the ram on the vm\n" ERROR
        #        exit 1
        #fi
        #message "OK\n" INFO

	#message "INFO: Setting the cpu count on the ossmaster to be 5: " INFO
        #$VCLOUD_PHP_FUNCTION -f set_cpus_vm --vmid "$ADM1_MASTER_VM_ID" --cpucount 5
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong updating the cpu count on the vm\n" ERROR
        #        exit 1
        #fi
        #message "OK\n" INFO

        message "INFO: Getting the atvtsXXX name of the gateway: " INFO
        NIGHTLY_VAPP_GATEWAY_IP_OUTPUT="`$VCLOUD_PHP_FUNCTION -f get_vapp_ipaddress --vappid $NIGHTLY_VAPP_ID`"
        if [[ $? -ne 0 ]]
        then
                message "$NIGHTLY_VAPP_GATEWAY_IP_OUTPUT\n" ERROR
                message "ERROR: Something went wrong getting the atvtsXXX name of the gateway\n" ERROR
                exit 1
        fi
        #get_vapp_ipaddress
        NIGHTLY_VAPP_GATEWAY_IP=`echo "$NIGHTLY_VAPP_GATEWAY_IP_OUTPUT" | grep "IPADDRESS" | awk '{print $2}'`

        NIGHTLY_VAPP_GATEWAY_HOSTNAME=`nslookup "$NIGHTLY_VAPP_GATEWAY_IP" 159.107.173.12 | grep name | awk '{print $4}' | awk -F. '{print $1}'`
        message "$NIGHTLY_VAPP_GATEWAY_HOSTNAME\n" INFO

        ##############################################################################
        $MOUNTPOINT/bin/$MASTER_SCRIPT -c $CONFIG:/export/scripts/CLOUD/configs/dm/install_options.txt -g $NIGHTLY_VAPP_GATEWAY_HOSTNAME -f rollout_config
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the rollout\n" ERROR
                # Rename to bad here, also need to be able to continue from here if workarounds performed
                exit 1
        fi

        ##############################################################################
	#$MOUNTPOINT/bin/$MASTER_SCRIPT -c $CONFIG -g $NIGHTLY_VAPP_GATEWAY_HOSTNAME -f basic_smoke_test
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong during the basic smoke tests\n" ERROR
        #        exit 1
        #fi

        ##############################################################################

        # Power down the vapp
        #message "INFO: Stopping the vapp: " INFO
        #$VCLOUD_PHP_FUNCTION -f stop_vapp --vappid $NIGHTLY_VAPP_ID
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong stopping the vapp\n" ERROR
        #        exit 1
        #fi
        #message "OK\n" INFO

        ##############################################################################

        #message "INFO: Copying the vapp to the catalog as ${NIGHTLY_VAPP_NAME}_testing: " INFO
        #NIGHTLY_VAPP_II_COMPLETED_OUTPUT=`$VCLOUD_PHP_FUNCTION -f add_vapp_to_catalog --vappid $NIGHTLY_VAPP_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_testing" --destcatalogname ${CATALOGNAME}`
        #if [[ $? -ne 0 ]]
        #then
        #        message "$NIGHTLY_VAPP_II_COMPLETED_OUTPUT\n" ERROR
        #        message "ERROR: Something went wrong adding the vapp to the catalog\n" ERROR
        #        exit 1
        #fi
        #NIGHTLY_VAPP_II_COMPLETED_ID=`echo "$NIGHTLY_VAPP_II_COMPLETED_OUTPUT" | grep "NEWVAPPTEMPLATEID" | awk '{print $2}'`
        #message "$NIGHTLY_VAPP_II_COMPLETED_ID\n" INFO

        ##############################################################################

        # Power back up the vapp to perform common post steps

        #message "INFO: Starting the vapp: " INFO
        #$VCLOUD_PHP_FUNCTION -f start_vapp --vappid $NIGHTLY_VAPP_ID
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong starting the vapp\n" ERROR
        #        message "INFO: Renaming the vapp in the catalog to ${NIGHTLY_VAPP_NAME}_bad\n" INFO
        #        $VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NIGHTLY_VAPP_II_COMPLETED_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_bad"
        #        exit 1
        #fi
        #message "OK\n" INFO

        ##############################################################################

        # Change here to do rollout_config, and variables file has to have their variables?
        #message "INFO: Performing the common_post_steps\n" INFO
        #$MOUNTPOINT/bin/$MASTER_SCRIPT -c $CONFIG -g $NIGHTLY_VAPP_GATEWAY_HOSTNAME -f common_post_steps
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong during the common post steps\n" ERROR
	#	message "INFO: Renaming the vapp in the catalog to ${NIGHTLY_VAPP_NAME}_bad\n" INFO
        #        $VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NIGHTLY_VAPP_II_COMPLETED_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_bad"
        #        exit 1
        #fi

	##############################################################################

        message "INFO: Creating user atossusr in the vapp: " INFO
        $MOUNTPOINT/bin/$MASTER_SCRIPT -c $CONFIG -g $NIGHTLY_VAPP_GATEWAY_HOSTNAME -f create_users_config
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong creating new user atossusr on the vapp\n" ERROR
		#message "INFO: Renaming the vapp in the catalog to ${NIGHTLY_VAPP_NAME}_bad\n" INFO
                #$VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NIGHTLY_VAPP_II_COMPLETED_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_bad"
                exit 1
        fi
        message "OK\n" INFO

        ##############################################################################

	#message "INFO: Performing netsim network rollout: " INFO
        #$MOUNTPOINT/bin/$MASTER_SCRIPT -c $CONFIG:/export/scripts/CLOUD/configs/netsim_configs/wran_lte_13.2.8_L1.txt -g $NIGHTLY_VAPP_GATEWAY_HOSTNAME -f netsim_rollout_config
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong during the netsim network rollout\n" ERROR
                #message "INFO: Renaming the vapp in the catalog to ${NIGHTLY_VAPP_NAME}_bad\n" INFO
		#$VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NIGHTLY_VAPP_II_COMPLETED_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_bad"
        #        exit 1
        #fi
        #message "OK\n" INFO
	
	##############################################################################

	# Atoss / Squish tests go here when ready

        ##############################################################################

        ###message "INFO: Renaming the vapp in the catalog to ${NIGHTLY_VAPP_NAME}_good\n" INFO
        ###$VCLOUD_PHP_FUNCTION -f rename_vapp_template --vapptemplateid $NIGHTLY_VAPP_II_COMPLETED_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_good"

        ##############################################################################

        message "INFO: Stopping the vapp: " INFO
        $VCLOUD_PHP_FUNCTION -f stop_vapp --vappid $NIGHTLY_VAPP_ID
        #$VCLOUD_FUNCTION -f poweroff_vapp --vappid $NIGHTLY_VAPP_ID
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong stopping the vapp\n" ERROR
                exit 1
        fi
        message "OK\n" INFO

        ##############################################################################

        message "INFO: Copying the installed vapp to the catalog for upgrade testing as ${NIGHTLY_VAPP_NAME}_testing: " INFO
        NIGHTLY_VAPP_FULL_COMPLETED_OUTPUT=`$VCLOUD_PHP_FUNCTION -f add_vapp_to_catalog --vappid $NIGHTLY_VAPP_ID --newvapptemplatename "${NIGHTLY_VAPP_NAME}_testing" --destcatalogname ${DESTCATALOGNAME}`
        if [[ $? -ne 0 ]]
        then
		message "$NIGHTLY_VAPP_FULL_COMPLETED_OUTPUT\n" ERROR
                message "ERROR: Something went wrong adding the vapp to the catalog\n" ERROR
                exit 1
        fi
        NIGHTLY_VAPP_FULL_COMPLETED_ID=`echo "$NIGHTLY_VAPP_FULL_COMPLETED_OUTPUT" | grep "NEWVAPPTEMPLATEID" | awk '{print $2}'`
        message "$NIGHTLY_VAPP_FULL_COMPLETED_ID\n" INFO

        ##############################################################################

        #message "INFO: Removing the vapp: " INFO
        #$VCLOUD_PHP_FUNCTION -f delete_vapp --vappid $NIGHTLY_VAPP_ID
        #if [[ $? -ne 0 ]]
        #then
        #        message "ERROR: Something went wrong deleting the vapp\n" ERROR
        #        exit 1
        #fi
        #message "OK\n" INFO

        ##############################################################################
	
	message "INFO: Starting the vapp: " INFO
        $VCLOUD_PHP_FUNCTION -f start_vapp --vappid $NIGHTLY_VAPP_ID
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong powering on the vapp\n" ERROR
                exit 1
        fi
        message "OK\n" INFO

        ##############################################################################
