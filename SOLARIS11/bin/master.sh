#!/bin/bash
  
# Set some variables
SCRIPTHOSTS="10.45.202.11"
MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`
#SCRIPTMOUNT=`echo "$MOUNTPOINT" | sed 's/CLOUD_xlaxain\/$//g'`
SCRIPTMOUNT='/export/scripts/'
LOCAL_CONFIG_MOUNT='/export/configs/'
PARENT_BASHPID="$$"
LOCAL_CONFIG_DIR=$LOCAL_CONFIG_MOUNT/
SSH="/usr/bin/ssh -o StrictHostKeyChecking=no"
MASTER_SCRIPT=`basename $0`
LOG_DIRECTORY=/logs
VCD_API_OUTPUT=""
CIPORTAL_URL="https://cifwk-oss.lmera.ericsson.se/"
JSDIR=/etc/dhcp_js
DHCP_AI="/etc/dhcp_ai/"
DHCP_SERVER='ieatmws89'
DHCP_SERVER_IP='10.45.16.24'
DHCP_SERVER_ROOT_PASS='ciexec17b'
ACTUAL_DHCP_SERVER='ieatmws89'
ACTUAL_DHCP_SERVER_IP='10.45.16.24'
ACTUAL_DHCP_SERVER_ROOT_PASS='ciexec17b'


# Friendly output for failed steps

INITIAL_INSTALL_ADM1_PART1_TITLE="Initial install admin 1 part 1"
INITIAL_INSTALL_ADM1_PART2_TITLE="Initial install admin 1 part 2"
INITIAL_INSTALL_OSS2_ADM1_PART1_TITLE="Initial install OSS2 admin 1 part 1"
INITIAL_INSTALL_OSS2_ADM1_PART2_TITLE="Initial install OSS2 admin 1 part 2"
INITIAL_INSTALL_ADM2_PART1_TITLE="Initial install admin 2 part 1"
INITIAL_INSTALL_ADM2_PART2_TITLE="Initial install admin 2 part 2"
INITIAL_INSTALL_OMSAS_PART1_TITLE="Initial install omsas part 1"
INITIAL_INSTALL_OMSAS_PART2_TITLE="Initial install omsas part 2"
INITIAL_INSTALL_OMSERVM_PART1_TITLE="Initial install omservm part 1"
INITIAL_INSTALL_OMSERVM_PART2_TITLE="Initial install omservm part 2"
INITIAL_INSTALL_OMSERVS_PART1_TITLE="Initial install omservs part 1"
INITIAL_INSTALL_OMSERVS_PART2_TITLE="Initial install omservs part 2"
INITIAL_INSTALL_UAS1_PART1_TITLE="Initial install uas1 part 1"
INITIAL_INSTALL_UAS1_PART2_TITLE="Initial install uas1 part 2"
INITIAL_INSTALL_PEER1_PART1_TITLE="Initial install peer1 part 1"
INITIAL_INSTALL_PEER1_PART2_TITLE="Initial install peer1 part 2"
INITIAL_INSTALL_NEDSS_PART1_TITLE="Initial install nedss part 1"
INITIAL_INSTALL_NEDSS_PART2_TITLE="Initial install nedss part 2"
INITIAL_INSTALL_EBAS_PART1_TITLE="Initial install ebas part 1"
INITIAL_INSTALL_EBAS_PART2_TITLE="Initial install ebas part 2"
INITIAL_INSTALL_MWS_PART1_TITLE="Initial install mws part 1"
INITIAL_INSTALL_MWS_PART2_TITLE="Initial install mws part 2"
INITIAL_INSTALL_ENIQE_PART1_TITLE="Initial install eniqe part 1"
INITIAL_INSTALL_ENIQE_PART2_TITLE="Initial install eniqe part 2"
INITIAL_INSTALL_CEP_PART1_TITLE="Initial install cep part 1"
INITIAL_INSTALL_CEP_PART2_TITLE="Initial install cep part 2"
INITIAL_INSTALL_ENIQS_PART1_TITLE="Initial install eniqs part 1"
INITIAL_INSTALL_ENIQS_PART2_TITLE="Initial install eniqs part 2"
INITIAL_INSTALL_ENIQSC_PART1_TITLE="Initial install eniqs coordinator part 1"
INITIAL_INSTALL_ENIQSC_PART2_TITLE="Initial install eniqs coordinator part 2"
INITIAL_INSTALL_ENIQSE_PART1_TITLE="Initial install eniqs engine part 1"
INITIAL_INSTALL_ENIQSE_PART2_TITLE="Initial install eniqs engine part 2"
INITIAL_INSTALL_ENIQSR1_PART1_TITLE="Initial install eniqs reader 1 part 1"
INITIAL_INSTALL_ENIQSR1_PART2_TITLE="Initial install eniqs reader 1 part 2"
INITIAL_INSTALL_ENIQSR2_PART1_TITLE="Initial install eniqs reader 2 part 1"
INITIAL_INSTALL_ENIQSR2_PART2_TITLE="Initial install eniqs reader 2 part 2"
INITIAL_INSTALL_SON_VIS_PART1_TITLE="Initial install son_vis part 1"
INITIAL_INSTALL_SON_VIS_PART2_TITLE="Initial install son_vis part 2"
INITIAL_INSTALL_NETSIM_PART1_TITLE="Initial install netsim part 1"
INITIAL_INSTALL_NETSIM_PART2_TITLE="Initial install netsim part 2"
INITIAL_INSTALL_TOR_PART1_TITLE="Initial install tor part 1"
POST_INSTALL_ADM1_TITLE="Post install admin 1"
POST_INSTALL_OSS2_ADM1_TITLE="Post install oss2 admin 1"
POST_INSTALL_ADM2_TITLE="Post install admin 2"
POST_INSTALL_OMSAS_TITLE="Post install omsas"
POST_INSTALL_OMSERVM_TITLE="Post install omservm"
POST_INSTALL_OMSERVS_TITLE="Post install omservs"
POST_INSTALL_UAS1_TITLE="Post install uas1"
POST_INSTALL_PEER1_TITLE="Post install peer1"
POST_INSTALL_NEDSS_TITLE="Post install nedss"
POST_INSTALL_EBAS_TITLE="Post install ebas"
POST_INSTALL_MWS_TITLE="Post install mws"
POST_INSTALL_NETSIM_TITLE="Post install netsim"
ENM_NETSIM_ROLLOUT_TITLE="ENM Netsim Rollout"

# Test if the place where the script is being run can use getopt properly
$MOUNTPOINT/bin/test_opts.sh --test=ok
if [[ $? -ne 0 ]]
then
	echo "ERROR: This server isn't compatible with this script, please use a more suitable server to run this script from"
	echo "ERROR: If in doubt, please contact the CLOUD team."
	exit 1
fi
# Read in expect functions
. $MOUNTPOINT/expect/expect_functions

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

# Parallel related variables
processes_remaining_last=999
parallel_pids=""
parallel_strings=()
parallel_logs=()
parallel_exit_codes=()
### Function: set_parallel_variables ###
#
#   Sets parallel variables and arrays per parallel process for use in parallel_status and parallel_wait functions
#
# Arguments:
#       none
# Return Values:
#       none
function set_parallel_variables()
{
	last_pid="$!"
	parallel_pids="$parallel_pids $last_pid"
	parallel_strings[$last_pid]="$PARALLEL_STATUS_STRING"
	#parallel_logs[$last_pid]="/tmp/$BASHPID/logs/$PARALLEL_ID.log"
	parallel_logs[$last_pid]="$LOG_FILE"
	parallel_exit_codes[$last_pid]=999
	#echo "Registering $last_pid for $LOG_FILE"
}

### Function: reset_parallel_variables ###
#
#   Resets parallel variables and arrays for use in parallel_status and parallel_wait functions
#
# Arguments:
#       none
# Return Values:
#       none

function reset_parallel_variables ()
{
	processes_remaining_last=999
	parallel_pids=""
	parallel_strings=()
	parallel_logs=()
	parallel_exit_codes=()
	LOG_FILE=""
	PARALLEL_STATUS_STRING=""
	PARALLEL_ID=""
	SHOW_STATUS_UPDATES="YES"
	SHOW_OUTPUT_BORDERS="YES"
	PARALLEL_STATUS_HEADER=""
}

### Function: parallel_status ###
#
#   Used in processes to check status of parallel processes
#
# Arguments:
#       none
# Return Values:
#       none
function parallel_status() 
{
	if [[ "$parallel_pids" != "" ]]
        then
                set $parallel_pids
        fi
	local pid=""
	for pid in "$@"
	do
		shift
		if [[ ${parallel_exit_codes[$pid]} -eq 999 ]]
		then
			set -- "$@" "$pid"
		fi
	done
	processes_remaining_now="$#"

	if [[ $processes_remaining_last -ne $processes_remaining_now ]]
	then
		local output=$(
		if [[ "$parallel_pids" != "" ]]
                then
                        set $parallel_pids
                fi
		echo "    |====================================================================|"
		echo "    | Parallel Status: $PARALLEL_STATUS_HEADER"
		echo "    |--------------------------------------------------------------------|"
		local pid=""
		for pid in "$@"
		do
			shift
			if [[ ${parallel_exit_codes[$pid]} -eq 999 ]]
			then
				echo "    | INFO:  ${parallel_strings[$pid]}: Running (Log ${parallel_logs[$pid]} on `hostname` )"
				set -- "$@" "$pid"
			else
				local EXIT_CODE=${parallel_exit_codes[$pid]}
				if [[ $EXIT_CODE -eq 0 ]]
				then
					if [[ -f ${parallel_logs[$pid]} ]]
					then
						mv ${parallel_logs[$pid]} $COMPLETED_LOG_DIR
					fi

					echo "    | INFO:  ${parallel_strings[$pid]}: Completed"
				else
					if [[ -f ${parallel_logs[$pid]} ]]
					then
						mv ${parallel_logs[$pid]} $FAILED_LOG_DIR
					fi

					if [[ $EXIT_CODE -eq 123 ]]
					then
						EXIT_MESSAGE="Failed due to one of its dependencies failing."
					else
						EXIT_MESSAGE="Failed with exit code $EXIT_CODE."
					fi
					message "    | ERROR: ${parallel_strings[$pid]}: $EXIT_MESSAGE\n" ERROR
					#message "    | ERROR: ${parallel_strings[$pid]}: $EXIT_MESSAGE Please check ${parallel_logs[$pid]} on `hostname`\n" ERROR
				fi
			fi
		done
		echo "    |--------------------------------------------------------------------|"
		echo "    | Parallel Summary: Processes Remaining: $processes_remaining_now "
		echo "    |====================================================================|"
		)
		echo "$output"
	else
		echo "$processes_remaining_last $processes_remaining_now"	
	fi
	processes_remaining_last="$#"
}

### Function: parallel_finish ###
#
#   Used in functions to finish off a paralle process, output its logfile, retrieve its return code etc
#
# Arguments:
#       none
# Return Values:
#       none

function parallel_finish()
{
	local PARALLEL_EXIT_CODE="$?"
	local output=$(
	if [[ "$SHOW_OUTPUT_BORDERS" != "NO" ]]
	then
		echo "|==============================================================================|"
		echo "| Start Of Output For: $PARALLEL_STATUS_STRING"
		echo "|------------------------------------------------------------------------------|"
	fi

	cat $LOG_FILE

	if [[ "$SHOW_OUTPUT_BORDERS" != "NO" ]]
	then
		echo "|------------------------------------------------------------------------------|"
		echo "| End Of Output For: $PARALLEL_STATUS_STRING"
		echo "|==============================================================================|"
	fi
	)
	echo "$output"

	#rm -rf $LOG_FILE
	# set step that needs to be rerun
	if [[ $PARALLEL_EXIT_CODE -ne 0 ]]
	then
		echo "${PART_OF_STAGE}" >> /tmp/$PARENT_BASHPID/status/retry

		# Handle the special case if the adm1 part1 fails, also make the initial jump part fail incase its not caught
		if [[ $PARALLEL_ID == "adm1_part1" ]]
		then
			echo "1" > /tmp/$PARENT_BASHPID/status/adm1_initial_jump_complete.status
		fi
	fi
	echo "$PARALLEL_EXIT_CODE" > /tmp/$PARENT_BASHPID/status/$PARALLEL_ID.status
	exit "$PARALLEL_EXIT_CODE"
}

### Function: parallel_wait ###
#
#   Used in functions to wait for parallel processes to finish
#
# Arguments:
#       none
# Return Values:
#       none

function parallel_wait() 
{
	if [[ "$SHOW_STATUS_UPDATES" != "NO" ]]
	then
		local output=$(
		echo "|==============================================================================================|"
		echo "| Starting Parallel Processes: $PARALLEL_STATUS_HEADER"
		echo "|----------------------------------------------------------------------------------------------|"
		)
		echo "$output"
		parallel_status
	fi
	if [[ "$parallel_pids" != "" ]]
        then
                set $parallel_pids
        fi
	while :; do
	        #echo "Processes remaining: $#"
		local pid=""
		for pid in "$@"
		do
			#echo "Checking on $pid"
			shift
			if kill -0 "$pid" 2>/dev/null; then
				#         echo "$pid is still running"
				set -- "$@" "$pid"
			else
				wait "$pid"
				local EXIT_CODE="$?"
				parallel_exit_codes[$pid]=$EXIT_CODE
				# A process just finished, print out the parallel status
				if [[ "$SHOW_STATUS_UPDATES" != "NO" ]]
				then
					parallel_status
				fi
			fi
		done
	        if [[ "$#" == 0 ]]
	        then
			break
	        fi
        	sleep 1
	done

	if [[ "$SHOW_STATUS_UPDATES" != "NO" ]]
	then
		local output=$(
	        echo "|----------------------------------------------------------------------------------------------|"
	        echo "| Completed Parallel Processes: $PARALLEL_STATUS_HEADER"
	        echo "|==============================================================================================|"
	        )
        	echo "$output"
	fi


	# Exit script if one of the processes had a non 0 return code

	if [[ "$parallel_pids" != "" ]]
        then
                set $parallel_pids
        fi
	while :; do
		local pid=""
	        for pid in "$@"
		do
			#       echo "Checking on $pid"
			shift
			if kill -0 "$pid" 2>/dev/null; then
				#         echo "$pid is still running"
				set -- "$@" "$pid"
			else
				# A process just finished, print out the parallel status
				local EXIT_CODE=${parallel_exit_codes[$pid]}
				if [[ $EXIT_CODE -ne 0 ]]
				then
					message "ERROR: At least one of the parallel processes ended with non 0 exit code, exiting script\n" ERROR
					message "-------------------------------------------------------------------------\n" WARNING
					message "To reattempt the steps that failed, you need to rerun the following steps\n" WARNING
					message "-------------------------------------------------------------------------\n" WARNING
					cat /tmp/$PARENT_BASHPID/status/retry | sort -u | while read FAILED_STEP
					do
						local TITLE=`eval echo \\$${FAILED_STEP}_TITLE`
						message "$TITLE\n" WARNING
					done
					message "-------------------------------------------------------------------------\n" WARNING
					exit $EXIT_CODE
				fi
			fi
		done
		if [[ "$#" == 0 ]]
		then
			break
		fi
		sleep 1
	done
	reset_parallel_variables
}
function sm_bios_workaround ()
{
	local SERVER="$1"
	mount_scripts_directory $SERVER
	message "INFO: Running smbios workaround in the background\n" INFO
	$SSH -n $SERVER  "nohup $MOUNTPOINT/bin/sm_bios_workaround.sh > /dev/null 2>&1 &"
}
function find_matching_remote_sim ()
{
	local SERVER="$1"
        local SIMDIR="$2"
        local SIMNAME="$3"
        local OUTPUT=""
        mount_scripts_directory $SERVER

        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/find_matching_remote_sim.sh -c '$CONFIG' -m $MOUNTPOINT -s '$SIMDIR' -n '$SIMNAME'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't find the remote sim $SIMNAME from directory $SIMDIR, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}
function create_p12_pems ()
{
	mount_scripts_directory $ADM1_HOSTNAME
	local OUTPUT=""
	OUTPUT=`$SSH -qTn $ADM1_HOSTNAME "cd /;rm -rf *.pem;$MOUNTPOINT/bin/createpem.sh /ericsson/config/ossrc.p12;$MOUNTPOINT/bin/createpem.pl -certfile total.pem -certdir .;ls /*.pem'"`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Something went wrong creating the pem files from the ossrc.p12 file, please check why\n" ERROR
		message "$OUTPUT\n" ERROR
		exit 1
	fi
}
function create_ports ()
{
        local netsim_server=$1
	$SSH -qTn $netsim_server "$MOUNTPOINT/bin/create_ports_new.sh -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong creating the netsim ports, please check why\n" ERROR
                exit 1
        fi
}
function netsim_rollout_part1 ()
{
        netsim_install
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during netsim rollout part1\n" ERROR
                exit 1
        fi
        simdep_call
        if [[ $? -ne 0 ]]
        then
            message "ERROR: Something went wrong during the simdep rollouts\n" ERROR
            exit 1
        fi
}

function netsim_rollout_part2 ()
{
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qTn $ADM1_HOSTNAME "rm -rf /cloud_network_xmls/* > /dev/null 2>&1"
        $SSH -qTn $ADM1_HOSTNAME "mkdir /cloud_network_xmls/ > /dev/null 2>&1"

        copy_arne_and_applytls
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the simdep rollouts\n" ERROR
                exit 1
        fi
}

function netsim_install ()
{
        #for netsim_server in $(echo "$NETSIM_SERVERS")
        echo "$NETSIM_SERVERS" | sed '/^$/d' | while read netsim_server
        do
                wait_until_services_started $netsim_server
                install_vmware_tools $netsim_server no
                mount_scripts_directory $netsim_server
                install_netsim_config_force
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/start_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
                $SSH -qTn $netsim_server "su - netsim -c /netsim/inst/restart_gui > /dev/null 2>&1"
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/delete_all_sims.sh -c '$CONFIG' -m $MOUNTPOINT"
        done
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the netsim rollouts\n" ERROR
                exit 1
        fi
}

function copy_arne_and_applytls
{
        functionName="copy_arne_and_applytls"
        message "INFO:-$functionName starting... \n" INFO
        [[ -z $NETSIM_SERVERS ]] && { echo "NETSIM_SERVERS variable is not set"; NETSIM_SERVERS="netsim"; }
        echo "$NETSIM_SERVERS" | sed '/^$/d' | while read netsim_server
        do
                message "INFO:-$functionName: Mounting cloud script folder on $netsim_server\n" INFO
                mount_scripts_directory $netsim_server
                message "INFO:-$functionName: start executing simdep_caller.sh\n" INFO
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/simdep_caller.sh ${SIMULATIONDROP} \"ROLLOUT2\""
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during the simdep execution for tls setting \n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: end simdep_caller.sh execution for tls setting sucessfully completed\n" INFO
        done
        message "INFO:-$functionName ended... \n" INFO
}

function netsim_post_rollout
{
        functionName="netsim_post_rollout"
        message "INFO:-$functionName starting... \n" INFO
        [[ -z $NETSIM_SERVERS ]] && { echo "NETSIM_SERVERS variable is not set"; NETSIM_SERVERS="netsim"; }
        echo "$NETSIM_SERVERS" | sed '/^$/d' | while read netsim_server
        do
                message "INFO:-$functionName: Mounting cloud script folder on $netsim_server\n" INFO
                mount_scripts_directory $netsim_server
                restart_netsim
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during restart of netsim \n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: start executing simdep_caller.sh\n" INFO
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/simdep_caller.sh ${POSTSIMULATIONDROP} \"POSTROLLOUT\""
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during the simdep execution for post rollout \n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: end simdep_caller.sh execution for post rollout sucessfully completed\n" INFO
        done
        message "INFO:-$functionName ended... \n" INFO
}

function enm_netsim_rollout_config ()
{
        mount_scripts_directory $NETSIM_HOSTNAME
        $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/cache_ip_address_list.sh"
        $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/start_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
        $SSH -qTn $NETSIM_HOSTNAME "su - netsim -c /netsim/inst/restart_gui > /dev/null 2>&1"
        $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/delete_all_sims.sh -c '$CONFIG' -m $MOUNTPOINT"
        # Create ports / default destinations, may change to have all ports
        create_ports $NETSIM_HOSTNAME

        # Loop through each sim and begin its rollout on the netsim server
	SIMNO=0
        while read simentry
        do
                SIMNO=$((SIMNO+1))
                local SIMNAME=`echo "$simentry" | awk -F\; '{print $2}'`

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="sim_rollout_${SIMNO}_${SIMNAME}"
                PART_OF_STAGE="ENM_NETSIM_ROLLOUT"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Sim rollout for sim $SIMNO, $SIMNAME"
                ###################################
                (
                (
                    enm_rollout_sim_part1 "$NETSIM_HOSTNAME" "$simentry"
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        done < <(echo "$sim_list" | grep ";")
        parallel_wait
}

function enm_rollout_sim_part1 ()
{
        local netsim_server=$1
        local simentry=$2

        local SIMDIR=`echo "$simentry" | awk -F\; '{print $1}'`
        local SIMNAME=`echo "$simentry" | awk -F\; '{print $2}'`
        local SIMNODES_START=`echo "$simentry" | awk -F\; '{print $3}'`
        local SIMNODES_IPV4="*,1,end"

        local EXACT_SIM_FILENAME=""
        local EXACT_SIM_NAME=""
        #Perform actions on this sim
        EXACT_SIM_FILENAME=`find_matching_remote_sim "$netsim_server" "$SIMDIR" "$SIMNAME"`
        if [[ $? -ne 0 ]]
        then
                message "$EXACT_SIM_FILENAME\n" ERROR
                exit 1
        fi
        EXACT_SIM_NAME=`echo $EXACT_SIM_FILENAME | sed 's/.zip$//g'`

        download_sim "$netsim_server" "$SIMDIR" "$EXACT_SIM_FILENAME"
        uncompress_sim "$netsim_server" "$EXACT_SIM_NAME" "$EXACT_SIM_FILENAME"
        assign_netsim_addresses "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_IPV4" "no"
        start_nodes "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_START"
}

function netsim_full_sim_rollout ()
{
	mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qTn $ADM1_HOSTNAME "rm -rf /cloud_network_xmls/* > /dev/null 2>&1"
	$SSH -qTn $ADM1_HOSTNAME "mkdir /cloud_network_xmls/ > /dev/null 2>&1"

        [[ -z $NETSIM_SERVERS ]] && { echo "NETSIM_SERVERS variable is not set"; NETSIM_SERVERS="netsim"; } 

        #for netsim_server in $(echo "$NETSIM_SERVERS")
        echo "$NETSIM_SERVERS" | sed '/^$/d' | while read netsim_server
        do
		mount_scripts_directory $netsim_server
                $SSH -qTn $netsim_server "rm -rf /netsim/netsimdir/exported_items/* > /dev/null 2>&1"

                #wait_until_services_started $netsim_server
                #install_vmware_tools $netsim_server no
                mount_scripts_directory $netsim_server
                #install_netsim_config_force
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/start_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
                $SSH -qTn $netsim_server "su - netsim -c /netsim/inst/restart_gui > /dev/null 2>&1"
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/delete_all_sims.sh -c '$CONFIG' -m $MOUNTPOINT"

        done
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the netsim rollouts\n" ERROR
                exit 1
        fi

	simdep_call
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the simdep rollouts\n" ERROR
                exit 1
        fi
}
function simdep_call ()
{
        functionName="simdep_call"
        message "INFO:-$functionName starting... \n" INFO
        [[ -z $NETSIM_SERVERS ]] && { echo "NETSIM_SERVERS variable is not set"; NETSIM_SERVERS="netsim"; }
        echo "$NETSIM_SERVERS" | sed '/^$/d' | while read netsim_server
        do
                message "INFO:-$functionName: Mounting cloud script folder on $netsim_server\n" INFO
                mount_scripts_directory $netsim_server
                message "INFO:-$functionName: start simdep package download on $netsim_server\n" INFO
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/simdep_download.sh ${SIMULATIONDROP}"
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during the simdep package download\n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: end simdep package download on $netsim_server\n" INFO

                message "INFO:-$functionName: start overriding default simdep config if any input given\n" INFO
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/simdep_update_conf.sh -c '$CONFIG' -m $MOUNTPOINT"
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during the simdep config file update\n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: end overriding default simdep config file \n" INFO

                message "INFO:-$functionName: start executing simdep_caller.sh\n" INFO
                $SSH -qTn $netsim_server "$MOUNTPOINT/bin/simdep_caller.sh ${SIMULATIONDROP} \"ROLLOUT1\""
                if [[ $? -ne 0 ]]
                then
                        message "ERROR:-$functionName: Something went wrong during the simdep execution\n" ERROR
                        exit 1
                fi
                message "INFO:-$functionName: end simdep_caller.sh execution sucessfully completed\n" INFO
        done
        message "INFO:-$functionName ended... \n" INFO

}

function netsim_post_steps ()
{
	copy_extra_network_xmls
	arne_import
	check_nodes_synced
}
function copy_extra_network_xmls ()
{
	if [[ "$NETWORK_XML_DIR" != "" ]]
	then
		message "INFO: Copying xmls from $NETWORK_XML_DIR to /cloud_network_xmls/ on $ADM1_HOSTNAME\n" INFO
		mount_scripts_directory $ADM1_HOSTNAME
		$SSH -qTn $ADM1_HOSTNAME "mkdir /cloud_network_xmls/ > /dev/null 2>&1"
		$SSH -qTn $ADM1_HOSTNAME "cp $NETWORK_XML_DIR/* /cloud_network_xmls/"
	fi
}
function netsim_rollout_config ()
{
	message "INFO: Setting unlimited iops on vms, please wait...: " INFO
	vm_set_iops_all unlimited
	echo "OK"
	netsim_rollout_part1
	netsim_rollout_part2
        #arne_validate
	netsim_post_steps
	message "INFO: Setting limited iops on vms, please wait...: " INFO
	vm_set_iops_all 300
	echo "OK"
}
function rollout_sim_part1 ()
{
	local netsim_server=$1
	local simentry=$2

	local SIMDIR=`echo "$simentry" | awk -F\; '{print $1}'`
	local SIMNAME=`echo "$simentry" | awk -F\; '{print $2}'`
	local SIMNODES_IPV4=`echo "$simentry" | awk -F\; '{print $3}'`
	local SIMNODES_IPV6=`echo "$simentry" | awk -F\; '{print $4}'`
	local SIMSL=`echo "$simentry" | awk -F\; '{print $5}'`
	local SIMNODES_SUBNETWORKS=`echo "$simentry" | awk -F\; '{print $6}'`

	local EXACT_SIM_FILENAME=""
	local EXACT_SIM_NAME=""
	#Perform actions on this sim
	EXACT_SIM_FILENAME=`find_matching_remote_sim "$netsim_server" "$SIMDIR" "$SIMNAME"`
	if [[ $? -ne 0 ]]
	then
		message "$EXACT_SIM_FILENAME\n" WARNING
		return
	fi
	EXACT_SIM_NAME=`echo $EXACT_SIM_FILENAME | sed 's/.zip$//g'`
	
	download_sim "$netsim_server" "$SIMDIR" "$EXACT_SIM_FILENAME"
	uncompress_sim "$netsim_server" "$EXACT_SIM_NAME" "$EXACT_SIM_FILENAME"
	assign_netsim_addresses "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_IPV4" "no"
	assign_netsim_addresses "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_IPV6" "yes"
}
function rollout_sim_part2 ()
{
        local netsim_server=$1
        local simentry=$2

        local SIMDIR=`echo "$simentry" | awk -F\; '{print $1}'`
        local SIMNAME=`echo "$simentry" | awk -F\; '{print $2}'`
        local SIMNODES_IPV4=`echo "$simentry" | awk -F\; '{print $3}'`
        local SIMNODES_IPV6=`echo "$simentry" | awk -F\; '{print $4}'`
        local SIMSL=`echo "$simentry" | awk -F\; '{print $5}'`
        local SIMNODES_SUBNETWORKS=`echo "$simentry" | awk -F\; '{print $6}'`

	# Set security related variables needed later on
	local CORBA_ON=""
	if [[ "$SIMSL" == "" ]]
        then
                SIMSL=0
        fi
        if [[ $SIMSL -gt 0 ]]
        then
		CORBA_ON="yes"
        else
                CORBA_ON="no"
        fi

        local EXACT_SIM_FILENAME=""
        local EXACT_SIM_NAME=""
        #Perform actions on this sim
        EXACT_SIM_FILENAME=`find_matching_remote_sim "$netsim_server" "$SIMDIR" "$SIMNAME"`
        if [[ $? -ne 0 ]]
        then
                message "$EXACT_SIM_FILENAME\n" WARNING
                return
        fi
        EXACT_SIM_NAME=`echo $EXACT_SIM_FILENAME | sed 's/.zip$//g'`

	create_sim_ssl_definition "$netsim_server" "$EXACT_SIM_NAME" secdefsl2 secdefsl2 /netsim/netsim_security/secdefsl2/cert.pem /netsim/netsim_security/secdefsl2/cacert.pem /netsim/netsim_security/secdefsl2/key.pem netsim
	set_corba_security "$netsim_server" "$EXACT_SIM_NAME" "$CORBA_ON" secdefsl2
	set_security_mo "$netsim_server" "$EXACT_SIM_NAME" "$SIMSL"
	start_nodes "$netsim_server" "$EXACT_SIM_NAME"

	# Create ipv4 xmls
	create_arne "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_SUBNETWORKS" "no"

	# Create ipv6 xmls
	create_arne "$netsim_server" "$EXACT_SIM_NAME" "$SIMNODES_SUBNETWORKS" "yes"
}
function create_sim_ssl_definition ()
{
	local SERVER=$1
	local SIMNAME="$2"
	local DEFINITION_NAME="$3"
	local DESCRIPTION="$4"
	local CERT_PATH="$5"
	local CACERT_PATH="$6"
	local KEY_PATH="$7"
	local KEY_PASSWORD="$8"
	$SSH -qTn $SERVER "$MOUNTPOINT/bin/create_sim_ssl_definition.sh -s $SIMNAME -n $DEFINITION_NAME -d $DESCRIPTION -c $CERT_PATH -a $CACERT_PATH -k $KEY_PATH -p $KEY_PASSWORD"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong creating the security definition\n" ERROR
                exit 1
        fi
}
function set_corba_security ()
{
	local SERVER=$1
	local SIMNAME="$2"
	local LEVEL="$3"
	local SEC_DEF_NAME="$4"
	mount_scripts_directory $SERVER
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/set_corba_security.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' -d '$SEC_DEF_NAME' -l '$LEVEL'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong setting the corba security definition\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}
function create_ssl_definition_wlr ()
{
	$SSH -qt $netsim_server "$MOUNTPOINT/bin/create_ssl_definition.sh -n 'netsim' -d 'netsim' -c /netsim/netsim_security/secdefsl2/cert.pem -a /netsim/netsim_security/secdefsl2/cacert.pem -k /netsim/netsim_security/secdefsl2/key.pem -p netsim"
}
function copy_p12_pems_to_netsim ()
{
	local SERVER=$1
	if [[ "$SERVER" == "" ]]
	then
		SERVER=$NETSIM_HOSTNAME
	fi
	mount_scripts_directory $SERVER
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qTn $SERVER "mkdir -p /netsim/netsim_security/secdefsl2/ > /dev/null 2>&1"

$EXPECT - <<EOF
set force_conservative 1
set timeout -1
spawn scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$ADM1_HOSTNAME:/*.pem root@$SERVER:/netsim/netsim_security/secdefsl2/
while {"1" == "1"} {
        expect {
                "assword:" {send "shroot12\r"}
                eof {
                        catch wait result
                        exit [lindex \$result 3]
                }
        }
}

EOF
}
function check_nodes_synced()
{
	message "INFO: Checking are all nodes on oss synced\n" INFO
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qtn $ADM1_HOSTNAME "$MOUNTPOINT/bin/check_nodes_synced.sh -c '$CONFIG' -m $MOUNTPOINT" 2> /dev/null
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the sync check, please check output above\n" ERROR
                #exit 1
        else
                echo "$OUTPUT"
        fi
}
function arne_import ()
{
	message "INFO: Starting arne imports\n" INFO
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qTn $ADM1_HOSTNAME "$MOUNTPOINT/bin/arne_import.sh -c '$CONFIG' -m $MOUNTPOINT -o 'import' -t yes"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the arne imports, please check output above\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}

function arne_validate ()
{
	message "INFO: Starting arne validations\n" INFO
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qTn $ADM1_HOSTNAME "$MOUNTPOINT/bin/arne_import.sh -c '$CONFIG' -m $MOUNTPOINT -o 'val:rall' -t yes"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong during the arne validations, please check output above\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}


function upload_arne ()
{
        local SERVER="$1"
        mount_scripts_directory $SERVER
	mount_scripts_directory $ADM1_HOSTNAME

	$EXPECT - <<EOF
set force_conservative 1
set timeout -1
spawn $SSH -qt $ADM1_HOSTNAME "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$SERVER:/netsim/netsimdir/exported_items/*.xml /cloud_network_xmls/"
while {"1" == "1"} {
        expect {
		"assword:" {send "shroot12\r"}
		eof {
			catch wait result
	                exit [lindex \$result 3]
		}
	}
}

EOF
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong uploading the arne xmls, please check output above\n" ERROR
                exit 1
        fi
}



function set_security_mo ()
{

	local SERVER="$1"
        local SIMNAME="$2"
	local SEC_LEVEL="$3"
        mount_scripts_directory $SERVER
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/set_security_mo.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' -l '$SEC_LEVEL'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't set the security mo, please check output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi

}
function start_nodes ()
{
	local SERVER="$1"
        local SIMNAME="$2"
	local SIMNODES="$3"
	local SIMNODES_ARG=""
	if [[ "$SIMNODES" == "" ]]
	then
		SIMNODES_ARG=""
	else
		SIMNODES_ARG=" -s '$SIMNODES'"
	fi

	mount_scripts_directory $SERVER
        message "INFO: Starting nodes for sim $SIMNAME\n" INFO
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/start_nodes.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' $SIMNODES_ARG"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't start the desired nodes on sim $SIMNAME, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}
function create_arne ()
{
        local SERVER="$1"
        local SIMNAME="$2"
	local SIMNODES="$3"
	local IPV6="$4"
        mount_scripts_directory $SERVER
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/create_arne.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' -s '$SIMNODES' -i '$IPV6'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong creating the xmls for $SIMNAME, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
        else
                echo "$OUTPUT"
        fi
}
function assign_netsim_addresses()
{
        local SERVER="$1"
        local SIMNAME="$2"
        local SIMNODES="$3"
	local IPV6="$4"
        mount_scripts_directory $SERVER
        ADDRESSES_LOCK="/tmp/$PARENT_BASHPID/locks/addresses.lock"
        get_lock $ADDRESSES_LOCK local na 7200 yes
        message "INFO: Assigning ip addresses for sim $SIMNAME\n" INFO
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/assign_netsim_addresses.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' -s '$SIMNODES' -i '$IPV6'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't assign ip addresses to nodes on sim $SIMNAME, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                clear_lock $ADDRESSES_LOCK local na
                exit 1
        else
                echo "$OUTPUT"
                clear_lock $ADDRESSES_LOCK local na
        fi
}
function download_sim ()
{
	local SERVER="$1"
	local SIMDIR="$2"
	local SIMNAME="$3"
	local OUTPUT=""
	mount_scripts_directory $SERVER

	OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/download_sim.sh -c '$CONFIG' -m $MOUNTPOINT -s '$SIMDIR' -n '$SIMNAME'"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't download the sim $SIMNAME from directory $SIMDIR, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                exit 1
	else
		echo "$OUTPUT"
	fi
}
function uncompress_sim ()
{
	local SERVER="$1"
        local SIMNAME="$2"
	local SIM_FILENAME="$2"
        local OUTPUT=""
        mount_scripts_directory $SERVER
        UNCOMPRESS_LOCK="/tmp/$PARENT_BASHPID/locks/uncompress.lock"
        get_lock $UNCOMPRESS_LOCK local na 7200 yes
        message "INFO: Uncompressing and opening sim $SIMNAME\n" INFO
        OUTPUT=`$SSH -qTn $SERVER "$MOUNTPOINT/bin/uncompress_and_open_new.sh -c '$CONFIG' -m $MOUNTPOINT -n '$SIMNAME' -f '$SIM_FILENAME'"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't uncompress and open the sim $SIMNAME, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$OUTPUT" ERROR
                message "\n---------------------------------------------------------\n" ERROR
                clear_lock $UNCOMPRESS_LOCK local na
                exit 1
        else
                echo "$OUTPUT"
                clear_lock $UNCOMPRESS_LOCK local na
        fi
}
function install_netsim_internal ()
{
	local SERVER="$1"
	local NETSIM_VERSION="$2"
	local FORCE="$3"
	NETSIM_VERSIONS=`ls $MOUNTPOINT/files/netsim/versions/ | sort -ur`
        NETSIM_N=`echo "$NETSIM_VERSIONS" | head -1 | tail -1`
        NETSIM_N_1=`echo "$NETSIM_VERSIONS" | head -2 | tail -1`
        NETSIM_N_2=`echo "$NETSIM_VERSIONS" | head -3 | tail -1`

	if [[ "$NETSIM_VERSION" == "N" ]]
        then
                ACTUAL_NETSIM_VERSION="$NETSIM_N"
        elif [[ "$NETSIM_VERSION" == "N_1" ]]
        then
                ACTUAL_NETSIM_VERSION="$NETSIM_N_1"
        elif [[ "$NETSIM_VERSION" == "N_2" ]]
        then
                ACTUAL_NETSIM_VERSION="$NETSIM_N_2"
        else
		ACTUAL_NETSIM_VERSION="$NETSIM_VERSION"
                #message "ERROR: Don't know what version $NETSIM_VERSION is, please use N, N_1 or N_2\n" ERROR
                #exit 1
        fi

	message "INFO: Installing netsim $ACTUAL_NETSIM_VERSION on $SERVER\n" INFO
	mount_scripts_directory $SERVER
	setup_ntp_client_netsim
	$SSH -qTn $SERVER "$MOUNTPOINT/bin/setup_internal_ssh.sh"
	$SSH -qTn $SERVER "$MOUNTPOINT/bin/install_netsim.sh -c '$CONFIG' -m $MOUNTPOINT -v $ACTUAL_NETSIM_VERSION -f $FORCE"
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Something wen't wrong installing netsim, check output above\n" ERROR
		exit 1
	fi
}
function install_netsim_n ()
{
	requires_variable NETSIM_HOSTNAME
	install_netsim_internal $NETSIM_HOSTNAME N no
}
function install_netsim_n1 ()
{
	requires_variable NETSIM_HOSTNAME
        install_netsim_internal $NETSIM_HOSTNAME N_1 no
}
function install_netsim_n2 ()
{
	requires_variable NETSIM_HOSTNAME
        install_netsim_internal $NETSIM_HOSTNAME N_2 no
}
function install_netsim_config ()
{
	requires_variable NETSIM_HOSTNAME
	if [[ "$NETSIM_VERSION" == "" ]]
	then
		message "INFO: Netsim version not set in NETSIM_VERSION variable, defaulting to NETSIM_VERSION=\"N\"\n" INFO
		NETSIM_VERSION="N"
	fi
	install_netsim_internal $NETSIM_HOSTNAME $NETSIM_VERSION no
}

function install_netsim_n_force ()
{
        requires_variable NETSIM_HOSTNAME
        install_netsim_internal $NETSIM_HOSTNAME N yes
}
function install_netsim_n1_force ()
{
        requires_variable NETSIM_HOSTNAME
        install_netsim_internal $NETSIM_HOSTNAME N_1 yes
}
function install_netsim_n2_force ()
{
        requires_variable NETSIM_HOSTNAME
        install_netsim_internal $NETSIM_HOSTNAME N_2 yes
}
function install_netsim_config_force ()
{
        requires_variable NETSIM_HOSTNAME
        if [[ "$NETSIM_VERSION" == "" ]]
        then
                message "INFO: Netsim version not set in NETSIM_VERSION variable, defaulting to NETSIM_VERSION=\"N\"\n" INFO
                NETSIM_VERSION="N"
        fi
        install_netsim_internal $NETSIM_HOSTNAME $NETSIM_VERSION yes
}

function update_netsim_license ()
{
	requires_variable NETSIM_HOSTNAME
	mount_scripts_directory $NETSIM_HOSTNAME
	$SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/update_netsim_license.sh -c '$CONFIG' -m $MOUNTPOINT"
}
function stop_netsim ()
{
	requires_variable NETSIM_HOSTNAME
	mount_scripts_directory $NETSIM_HOSTNAME
	$SSH -qt $NETSIM_HOSTNAME "$MOUNTPOINT/bin/stop_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
}
function restart_netsim ()
{
        requires_variable NETSIM_HOSTNAME
        mount_scripts_directory $NETSIM_HOSTNAME
        $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/restart_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
}
function start_netsim ()
{
        requires_variable NETSIM_HOSTNAME
        mount_scripts_directory $NETSIM_HOSTNAME
        $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/start_netsim.sh -c '$CONFIG' -m $MOUNTPOINT"
}
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

function retry_message ()
{
	INPUT_MESSAGE="$1"
	ISSUE_TYPE="$2"
        message "$INPUT_MESSAGE" "$ISSUE_TYPE"
        echo "$INPUT_MESSAGE" >> $RETRY_LOG_DIR/retry.log
}

function usage_msg ()
{
        message "$0
		-c <relative path to config files, you can seperate multiple config files using a colon, eg -c ../configs/file1.txt:../configs/file2.txt>
		-g <GATEWAY>
		-e <EMAIL ADDRESSES seperated by semicolons>
		-f <FUNCTION NAME>

			## Main Rollout Related Functions
			initial_rollout # Installs each server as far as it can go without attaching them together, broken down into two phases which can be run individually if needs be
				initial_rollout_part1 # Runs the initial rollout up until after the servers finish their II and reach the console login prompt
				initial_rollout_part2 # Runs post steps that run immediately after the II on each server, like vmware tools, ntp clients, removing serial ports
			common_post_steps # Performs post configuration on each server
			full_rollout # Runs both initial_rollout and common_post_steps in one go

			rollout_config # Performs any combination of initial rollout and post steps, based on these entries in youre config
			               # Set them to either yes or no
					INITIAL_INSTALL_ADM1=
						INITIAL_INSTALL_ADM1_PART1=
						INITIAL_INSTALL_ADM1_PART2=
					INITIAL_INSTALL_OSS2_ADM1=
						INITIAL_INSTALL_OSS2_ADM1_PART1=
						INITIAL_INSTALL_OSS2_ADM1_PART2=
                                        INITIAL_INSTALL_ADM2=
						INITIAL_INSTALL_ADM2_PART1=
						INITIAL_INSTALL_ADM2_PART2=
					INITIAL_INSTALL_OMSAS=
						INITIAL_INSTALL_OMSAS_PART1=
						INITIAL_INSTALL_OMSAS_PART2=
					INITIAL_INSTALL_OMSERVM=
						INITIAL_INSTALL_OMSERVM_PART1=
						INITIAL_INSTALL_OMSERVM_PART2=
					INITIAL_INSTALL_OMSERVS=
						INITIAL_INSTALL_OMSERVS_PART1=
						INITIAL_INSTALL_OMSERVS_PART2=
					INITIAL_INSTALL_UAS1=
						INITIAL_INSTALL_UAS1_PART1=
						INITIAL_INSTALL_UAS1_PART2=
					INITIAL_INSTALL_PEER1=
                                                INITIAL_INSTALL_PEER1_PART1=
                                                INITIAL_INSTALL_PEER1_PART2=
					INITIAL_INSTALL_NEDSS=
						INITIAL_INSTALL_NEDSS_PART1=
						INITIAL_INSTALL_NEDSS_PART2=
					INITIAL_INSTALL_EBAS=
						INITIAL_INSTALL_EBAS_PART1=
						INITIAL_INSTALL_EBAS_PART2=
					INITIAL_INSTALL_MWS=
						INITIAL_INSTALL_MWS_PART1=
						INITIAL_INSTALL_MWS_PART2=
					INITIAL_INSTALL_ENIQE=
                                                INITIAL_INSTALL_ENIQE_PART1=
                                                INITIAL_INSTALL_ENIQE_PART2=
					INITIAL_INSTALL_CEP=
						INITIAL_INSTALL_CEP_PART1=
						INITIAL_INSTALL_CEP_PART2=
					INITIAL_INSTALL_ENIQS=
                                                INITIAL_INSTALL_ENIQS_PART1=
                                                INITIAL_INSTALL_ENIQS_PART2=
					INITIAL_INSTALL_ENIQSC=
                                                INITIAL_INSTALL_ENIQSC_PART1=
                                                INITIAL_INSTALL_ENIQSC_PART2=
					INITIAL_INSTALL_ENIQSE=
                                                INITIAL_INSTALL_ENIQSE_PART1=
                                                INITIAL_INSTALL_ENIQSE_PART2=
					INITIAL_INSTALL_ENIQSR1=
                                                INITIAL_INSTALL_ENIQSR1_PART1=
                                                INITIAL_INSTALL_ENIQSR1_PART2=
					INITIAL_INSTALL_ENIQSR2=
                                                INITIAL_INSTALL_ENIQSR2_PART1=
                                                INITIAL_INSTALL_ENIQSR2_PART2=
					INITIAL_INSTALL_SON_VIS=
                                                INITIAL_INSTALL_SON_VIS_PART1=
                                                INITIAL_INSTALL_SON_VIS_PART2=
                                        INITIAL_INSTALL_TOR=
                                                INITIAL_INSTALL_TOR_PART1=

					POST_INSTALL_ADM1=
					POST_INSTALL_ADM2=
					POST_INSTALL_OMSAS=
					POST_INSTALL_OMSERVM=
					POST_INSTALL_OMSERVS=
					POST_INSTALL_UAS1=
					POST_INSTALL_PEER1=
					POST_INSTALL_NEDSS=
					POST_INSTALL_EBAS=

			## Private Gateway Related
			config_gateway
			install_vmware_tools_gateway

			## ADM1 Related
			create_config_files_adm1
			add_dhcp_client_remote_adm1
			boot_from_network_adm1
			install_adm1
			wait_oss_online_adm1
			update_sentinel_license
			manage_mcs_critical_5 | manage_mcs_config | manage_mcs_all | manage_mcs_initial | manage_mcs_config_check_only
				## manage_mcs_initial can read the variable INITIAL_INSTALL_MCS= in your config.
			expand_databases
		        dmr_config
			create_caas_user_tss_adm1
			update_nmsadm_password_config # Updates the nmsadm password based on your config
			setup_ntp_client_adm1
			setup_adm1_ldap_client
			set_external_gateway_adm1
			set_prompt_adm1
			set_eeprom_text_adm1
			install_vmware_tools_adm1
			update_scs_properties # Populates the scs.properties file with ip adddresses of omservm / omservs
			enable_ms_security # Enables security on the master server

			## ADM2 Related
                        create_config_files_adm2
                        add_dhcp_client_remote_adm2
			boot_from_network_adm2
                        install_adm2
			set_external_gateway_adm2
			add_second_root_disk_adm2 # Not working yet
			switch_sybase_adm2 # Not working yet

			## OMSERVM Related
			create_config_files_omservm
			add_dhcp_client_remote_omservm
			boot_from_network_omservm
			install_omservm
			setup_resolver_omservm
			setup_ntp_client_omservm
			install_caas_omservm
			configure_csa_omservm
			setup_ssh_masterservice_omservm
			set_external_gateway_omservm
			set_prompt_omservm
			set_eeprom_text_omservm
			install_vmware_tools_omservm
			plumb_storage_nic_omservm
			create_users_config # Creates ossrc users based on the USER_LIST variable set in your config.
			                    # The entries must be of the form USERNAME PASSWORD CATEGORY UID (optional)
			                    # eg: 
			                    # USER_LIST='ekemark ekemark01 sys_adm
			                    # eeishky eeishky01 sys_adm 1005'
			add_users_to_groups_config # Creates ldap groups and adds existing ossrc users to the groups based on the GROUP_LIST variable set in your config
			                           # The entries must be of the form USERNAME GROUP UID (optional)
			                           # eg:
			                           # GROUP_LIST='ekemark ebas_group
			                           # eeishky group1
			                           # eeishky group2'
			remove_users_config # Same usage as create_users_config

			## OMSERVS Related
                        create_config_files_omservs
                        add_dhcp_client_remote_omservs
			boot_from_network_omservs
                        install_omservs
                        setup_resolver_omservs
			setup_ntp_client_omservs
                        install_caas_omservs
                        configure_csa_omservs
                        setup_ssh_masterservice_omservs
			set_external_gateway_omservs
			set_prompt_omservs
			set_eeprom_text_omservs
                        install_vmware_tools_omservs
			add_omservs_sls_url_adm1
			plumb_storage_nic_omservs
	
			## OMSAS Related
                        create_config_files_omsas
                        add_dhcp_client_remote_omsas
			boot_from_network_omsas
                        install_omsas
			setup_resolver_omsas
			setup_ntp_client_omsas
			install_caas_omsas
			configure_csa_omsas
			setup_ssh_masterservice_omsas
			set_external_gateway_omsas
			set_prompt_omsas
			set_eeprom_text_omsas
			install_vmware_tools_omsas
			generate_p12_omsas
			copy_ms_certs_omsas
			fetch_ior_files # Fetches ior files after security is enabled on the master server, called from enable_ms_security

			## COMInf Related
			setup_replication_detect # Choose the correct replication steps to run based on the types of servers in config
			setup_replication_config # Chooses the correct replication steps to run based on config
			setup_replication_single # For env with OMSAS + OMSERVM
			setup_replication_standard # For env with OMSERVM + OMSERVS
			setup_replication_enhanced # For env with OMSAS + OMSERVM + OMSERVS

			## LDAP Related
			ldap_modify # Runs all sub functions below
				disable_password_expiry
				disable_password_lockout
				disable_password_must_change
				remove_password_change_history
				reduce_min_password_length
				update_ldap_rules_omservm # Changes minimum / maximum uids, password rules etc, on the omservm

			## UAS1 Related
                        create_config_files_uas1
                        add_dhcp_client_remote_uas1
			activate_uas_uas1
			boot_from_network_uas1
			install_uas1_initial_only
			install_uas1
			uas_post_steps_uas1
			setup_resolver_uas1
			setup_ntp_client_uas1
			set_external_gateway_uas1
			set_prompt_uas1
			set_eeprom_text_uas1
			install_vmware_tools_uas1
			plumb_storage_nic_uas1

			## PEER1 Related
                        create_config_files_peer1
                        add_dhcp_client_remote_peer1
                        activate_peer_peer1
                        boot_from_network_peer1
                        install_peer1_initial_only
                        install_peer1
                        uas_post_steps_peer1
                        setup_ntp_client_peer1
                        set_external_gateway_peer1
                        set_prompt_peer1
                        set_eeprom_text_peer1
                        install_vmware_tools_peer1
			configure_peer_peer1

			## NEDSS Related
			create_config_files_nedss
			add_dhcp_client_remote_nedss
			boot_from_network_nedss
			install_nedss
			setup_ntp_client_nedss
			setup_resolver_nedss
			set_external_gateway_nedss
			set_prompt_nedss
			set_eeprom_text_nedss
			install_vmware_tools_nedss
			create_and_share_smrs_filesystems
			plumb_storage_nic_nedss
			configure_smrs_master_service
			configure_smrs_add_nedss_nedss
			configure_smrs_add_slave4_service_nedss
			configure_smrs_add_slave6_service_nedss
			add_aif_nedss

			## EBAS Related
			create_config_files_ebas
			add_dhcp_client_remote_ebas
			activate_uas_ebas
			boot_from_network_ebas
			install_ebas_initial_only
			install_ebas
			post_steps_ebas
			setup_ntp_client_ebas
			set_external_gateway_ebas
			set_prompt_ebas
			set_eeprom_text_ebas
			install_vmware_tools_ebas
			plumb_storage_nic_ebas

			## MWS Related
			create_config_files_mws
			add_dhcp_client_remote_mws
			#activate_uas_mws
			boot_from_network_mws
			install_mws
			post_steps_mws
			setup_ntp_client_mws
			set_external_gateway_mws
			set_prompt_mws
			set_eeprom_text_mws
			install_vmware_tools_mws
			plumb_storage_nic_mws

			## ENIQE Related
                        create_config_files_eniqe
                        add_dhcp_client_remote_eniqe
                        boot_from_network_eniqe
                        install_eniqe
                        setup_ntp_client_eniqe
                        set_external_gateway_eniqe
                        set_prompt_eniqe
                        set_eeprom_text_eniqe
                        install_vmware_tools_eniqe

			## ENIQS Related
                        create_config_files_eniqs
                        add_dhcp_client_remote_eniqs
                        boot_from_network_eniqs
                        install_eniqs
                        setup_ntp_client_eniqs
                        set_external_gateway_eniqs
                        set_prompt_eniqs
                        set_eeprom_text_eniqs
                        install_vmware_tools_eniqs

			## SON_VIS Related
                        create_config_files_son_vis
                        add_dhcp_client_remote_son_vis
                        boot_from_network_son_vis
                        install_son_vis
                        setup_ntp_client_son_vis
                        set_external_gateway_son_vis
                        set_prompt_son_vis
                        set_eeprom_text_son_vis
                        install_vmware_tools_son_vis

			## Netsim Related
			update_netsim_license # Updates the license to the latest locally stored license file
			install_netsim_config # Installs netsim version specified in config file by variable NETSIM_VERSION, eg
				NETSIM_VERSION=N # Specifies to install latest netsim version (This is the default, if the NETSIM_VERSION variable isn't set
				NETSIM_VERSION=N_1 # Specifies to install 1 netsim version back
				NETSIM_VERSION=N_2 # Specifies to install 2 netsim versions back
			install_netsim_config_force # Same as above but installs netsim even if its already installed

			install_netsim_n # Installs latest netsim version explicity
			install_netsim_n_force # Installs latest netsim version explicity even if its already installed

			install_netsim_n1 # Installs 1 netsim version back explicity
			install_netsim_n1_force # Installs 1 netsim version back explicity even if its already installed

			install_netsim_n2 # Installs 2 netsim versions back explicity
			install_netsim_n2_force # Installs 2 netsim versions back explicity even if its already installed

			install_vmware_tools_netsim

			## TA Specific
			all_rno_post_steps # Mounts 3 rational directories on the adm1 server
			all_eth_post_steps
			eba_netsim_steps # Runs commands from RTT Ticket 308854, ie copying zome zips and creating softlinks on the netsim
			all_security_post_steps # Steps specific to security like root password, /etc/hosts populating, mounts
				security_netsim_steps # Runs security TA commands from RTT Ticket 300326
			all_wlr_post_steps
" WARNING
        exit 1
}
function security_netsim_steps ()
{
	if [[  "$NETSIM_HOSTNAME" == "" ]]
	then
		message "INFO: You don't have a netsim hostname set, not doing security netsim related steps\n" INFO
		return 0
	fi
	message "INFO: Running security netsim related steps\n" INFO
	mount_scripts_directory $NETSIM_HOSTNAME
	# Create the ipv4 and ipv6 ports
	$SSH -qt $NETSIM_HOSTNAME "$MOUNTPOINT/bin/create_ports.sh"

	# Copy the security specific pem files
	message "INFO: Copying security pems to netsim\n" INFO
	$SSH -qt $NETSIM_HOSTNAME "su - netsim -c \"cp $MOUNTPOINT/files/ta_specific/security/*.pem /netsim/netsimdir/\""

	# Create the security ssl definition
	$SSH -qt $NETSIM_HOSTNAME "$MOUNTPOINT/bin/create_ssl_definition.sh -n 'CORBAdefault' -d 'default SSL for CORBA' -c /netsim/netsimdir/cert.pem -a /netsim/netsimdir/cacert.pem -k /netsim/netsimdir/key.pem -p abcd1234"

	# Create LRAN NE type
	message "INFO: Copying and uncompressing the LRAN NE type file\n" INFO
	$SSH -qt $NETSIM_HOSTNAME "su - netsim -c \"cp $MOUNTPOINT/files/ta_specific/security/ERBSC170_R24D.zip /netsim/netsimdir/\""
	$SSH -qt $NETSIM_HOSTNAME "$MOUNTPOINT/bin/uncompress_and_open.sh ERBSC170_R24D"
}
function resize_volume ()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory "$ADM1_HOSTNAME"
	message "INFO: Resizing volume $1 to $2$3: " INFO
	local OUTPUT=""
	OUTPUT=`$SSH -qtn $ADM1_HOSTNAME  "$MOUNTPOINT/bin/resize_volume.sh  -c '$CONFIG' -m $MOUNTPOINT -n $1 -s $2 -u $3" 2>/dev/null`
	if [[ $? -eq 0 ]]
	then
		message "OK\n" INFO
	else
		message "NOK, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
	fi
}

function ldap_modify ()
{
        disable_password_expiry
        disable_password_lockout
        disable_password_must_change
	reduce_min_password_length
        update_ldap_rules_omservm
}

function set_prompt_adm1 ()
{
	set_prompt $ADM1_HOSTNAME
}

function set_prompt_oss2_adm1 ()
{
	set_prompt $OSS2_ADM1_HOSTNAME
}

function set_prompt_adm2 ()
{
        set_prompt $ADM2_HOSTNAME
}
function set_prompt_omservm ()
{
        set_prompt $OMSERVM_HOSTNAME
}
function set_prompt_omservs ()
{
        set_prompt $OMSERVS_HOSTNAME
}
function set_prompt_omsas ()
{
        set_prompt $OMSAS_HOSTNAME
}
function set_prompt_nedss ()
{
        set_prompt $NEDSS_HOSTNAME
}
function set_prompt_uas1 ()
{
        set_prompt $UAS1_HOSTNAME
}
function set_prompt_peer1 ()
{
        set_prompt $PEER1_HOSTNAME
}
function set_prompt_ebas ()
{
        set_prompt $EBAS_HOSTNAME
}
function set_prompt_mws ()
{
        set_prompt $MWS_HOSTNAME
}
function set_prompt_eniqe ()
{
        set_prompt $ENIQE_HOSTNAME
}
function set_prompt_eniqs ()
{
        set_prompt $ENIQS_HOSTNAME
}
function set_prompt_eniqsc ()
{
        set_prompt $ENIQSC_HOSTNAME
}
function set_prompt_eniqse ()
{
        set_prompt $ENIQSE_HOSTNAME
}
function set_prompt_eniqsr1 ()
{
        set_prompt $ENIQSR1_HOSTNAME
}
function set_prompt_eniqsr2 ()
{
        set_prompt $ENIQSR2_HOSTNAME
}
function set_prompt_son_vis ()
{
        set_prompt $SON_VIS_HOSTNAME
}
function set_prompt ()
{
	if [[ "$BEHIND_GATEWAY" != "yes" ]]
        then
                return 0
        fi

	local SERVER_IN=$1
	mount_scripts_directory $SERVER_IN
	$SSH -qtn  $SERVER_IN "$MOUNTPOINT/bin/setprompt.sh" 2>/dev/null
}
function disable_cde_login_eniqe ()
{
        disable_cde_login_internal $ENIQE_HOSTNAME
}
function disable_cde_login_eniqs ()
{
        disable_cde_login_internal $ENIQS_HOSTNAME
}
function disable_cde_login_eniqsc ()
{
        disable_cde_login_internal $ENIQSC_HOSTNAME
}
function disable_cde_login_eniqse ()
{
        disable_cde_login_internal $ENIQSE_HOSTNAME
}
function disable_cde_login_eniqsr1 ()
{
        disable_cde_login_internal $ENIQSR1_HOSTNAME
}
function disable_cde_login_eniqsr2 ()
{
        disable_cde_login_internal $ENIQSR2_HOSTNAME
}
function disable_cde_login_son_vis ()
{
        disable_cde_login_internal $SON_VIS_HOSTNAME
}
function disable_cde_login_internal ()
{
	local SERVER=$1
	message "INFO: Disabling the cde-login service on $SERVER\n" INFO
	$SSH -qt $SERVER "svcadm disable -s /application/graphical-login/cde-login"
}
function create_group ()
{
	local GROUP=$1
	local GID=$2
	local GID_OPTION=""

	if [[ "$GID" == "" ]]
	then
		GID_OPTION=""
	else
		GID_OPTION="-n $GID"
	fi
        mount_scripts_directory $OMSERVM_HOSTNAME
        $SSH -qtn  $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/create_group.sh  -c '$CONFIG' -m $MOUNTPOINT -g $GROUP $GID_OPTION" 2>/dev/null
}
function remove_user ()
{
        local USERNAME=$1
        mount_scripts_directory $OMSERVM_HOSTNAME
        $SSH -qtn  $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/remove_user.sh  -c '$CONFIG' -m $MOUNTPOINT -u $USERNAME" 2>/dev/null
}
function create_user ()
{
	local USERNAME=$1
	local PASSWORD=$2
	local CATEGORY=$3
	local NEW_UID=$4
	local UID_OPTION=""

	if [[ "$NEW_UID" == "" ]]
	then
		UID_OPTION=""
	else
		UID_OPTION="-n $NEW_UID"
	fi
	mount_scripts_directory $OMSERVM_HOSTNAME
	$SSH -qtn  $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/create_user.sh  -c '$CONFIG' -m $MOUNTPOINT -u $USERNAME -p $PASSWORD -s $CATEGORY $UID_OPTION" 2>/dev/null
}
function change_user_password ()
{
        local USERNAME=$1
        local PASSWORD=$2

        mount_scripts_directory $OMSERVM_HOSTNAME
        $SSH -qtn $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/change_user_password.sh  -c '$CONFIG' -m $MOUNTPOINT -u $USERNAME -p $PASSWORD" 2>/dev/null
}
function add_user_to_group()
{
        local USERNAME=$1
        local GROUP=$2
	local NEW_GID=$3
        mount_scripts_directory $OMSERVM_HOSTNAME
        $SSH -qtn  $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/add_user_to_group.sh  -c '$CONFIG' -m $MOUNTPOINT -u $USERNAME -g $GROUP" 2>/dev/null
}
function echo_line ()
{
	message "-------------------------------------------------------------------------\n" LINE
}
function echo_equals ()
{
	message "=========================================================================\n" LINE
}
function remove_users_internal ()
{
        #wait_oss_online_adm1
        requires_variable OMSERVM_HOSTNAME
        local USER_LIST=$1
        echo "$USER_LIST" | while read line
        do
                local USERNAME=`echo "$line" | awk '{print $1}'`
                if [[ "$USERNAME" == "" ]]
                then
                        message "WARNING: Removing User: Invalid format, skipping this user, check your config file\n" WARNING
                else
                        message "INFO: Removing User: $USERNAME, please wait..." INFO
                        local output=""
                        output=`remove_user $USERNAME`
                        if [[ "$?" == "0" ]]
                        then
                                message "Removed Successfully\n" INFO
                        else
                                message "ERROR: Error Found, Output Below\n" ERROR
                                message "${output}\n\n" ERROR
                        fi
                fi
        done
}
function create_users_internal ()
{
	#wait_oss_online_adm1
	requires_variable OMSERVM_HOSTNAME
	local USER_LIST=$1
	echo "$USER_LIST" | while read line
        do
                local USERNAME=`echo "$line" | awk '{print $1}'`
                local PASSWORD=`echo "$line" | awk '{print $2}'`
                local CATEGORY=`echo "$line" | awk '{print $3}'`
                local NEW_UID=`echo "$line" | awk '{print $4}'`
		if [[ "$NEW_UID" != "" ]]
		then
			UID_STRING="with UID $NEW_UID,"
		else
			UID_STRING=""
		fi
                if [[ "$USERNAME" == "" ]] || [[ "$PASSWORD" == "" ]] || [[ "$CATEGORY" == "" ]]
                then
                        message "WARNING: Adding User: Invalid format, skipping this user, check your config file\n" WARNING
                else
                        message "INFO: Adding User: $USERNAME with Password: $PASSWORD in Category: $CATEGORY, $UID_STRING please wait..." INFO
			local output=""
                        output=`create_user $USERNAME $PASSWORD $CATEGORY $NEW_UID`
                        if [[ "$?" == "0" ]]
                        then
                                message "Added Successfully\n" INFO
                        else
                                message "ERROR: Error Found, Output Below\n" ERROR
                                message "${output}\n\n" ERROR
                        fi
                fi
        done
}

function add_users_to_groups_internal ()
{
	requires_variable OMSERVM_HOSTNAME
        local GROUP_LIST=$1
        echo "$GROUP_LIST" | while read line
        do
                local USERNAME=`echo "$line" | awk '{print $1}'`
                local GROUP=`echo "$line" | awk '{print $2}'`
		local GID=`echo "$line" | awk '{print $3}'`

                if [[ "$USERNAME" == "" ]] || [[ "$GROUP" == "" ]]
                then
                        message "WARNING: Adding User to group: Invalid format, skipping this user, check youre config file\n" WARNING
                else
                        message "INFO: Adding User $USERNAME to group $GROUP, please wait..." INFO
			local output=""
                        output=`create_group $GROUP $GID`
                        if [[ "$?" == "0" ]]
                        then
                                message "Group Created Successfully: " INFO
                        else
                                message "ERROR: Error Creating Group Found, Output Below\n" ERROR
                                message "${output}\n\n" ERROR
				continue
                        fi
			output=`add_user_to_group $USERNAME $GROUP`
                        if [[ "$?" == "0" ]]
                        then
                                message "User Added To Group Successfully\n" INFO
                        else
                                message "ERROR: Error Found, Output Below\n" ERROR
                                message "${output}\n\n" ERROR
                        fi
                fi
        done
}

function remove_users_config ()
{
        requires_variable USER_LIST
        remove_users_internal "$USER_LIST"
}
function create_users_config ()
{
	requires_variable USER_LIST
	create_users_internal "$USER_LIST"
}
function add_users_to_groups_config ()
{
	requires_variable GROUP_LIST
	add_users_to_groups_internal "$GROUP_LIST"
}
function manage_mcs_all()
{
        manage_mcs_internal ADM1 ALL 
}
function manage_mcs_initial()
{
	if [[ "$INITIAL_INSTALL_MCS" != "" ]]
	then
		manage_mcs_internal ADM1 $INITIAL_INSTALL_MCS
	elif [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
        	manage_mcs_internal ADM1 CRITICAL_5
	else
		manage_mcs_internal ADM1 INITIAL
	fi
}
function manage_mcs_config_check_only ()
{
	manage_mcs_internal ADM1 CONFIG no
}
function manage_mcs_config ()
{
	manage_mcs_internal ADM1 CONFIG
}
function manage_mcs_critical_5 ()
{
	manage_mcs_internal ADM1 CRITICAL_5
}
function manage_mcs_all_oss2_adm1()
{
        manage_mcs_internal OSS2_ADM1 ALL 
}
function manage_mcs_initial_oss2_adm1()
{
	if [[ "$OSS2_INITIAL_INSTALL_MCS" != "" ]]
	then
		manage_mcs_internal OSS2_ADM1 $OSS2_INITIAL_INSTALL_MCS
	elif [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
        	manage_mcs_internal OSS2_ADM1 CRITICAL_5
	else
		manage_mcs_internal OSS2_ADM1 INITIAL
	fi
}
function manage_mcs_config_check_only_oss2_adm1 ()
{
	manage_mcs_internal OSS2_ADM1 CONFIG no
}
function manage_mcs_config_oss2_adm1 ()
{
	manage_mcs_internal OSS2_ADM1 CONFIG
}
function manage_mcs_critical_5_oss2_adm1 ()
{
	manage_mcs_internal OSS2_ADM1 CRITICAL_5
}
function manage_mcs_internal ()
{
        local PREFIX=$1
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
        local SMALL_PREFIX=`echo "$1" | tr '[:upper:]' '[:lower:]'`
        local MC_LIST_TYPE=$2
	local FIX=$3
	local EXIT_ON_ERROR=$4
	if [[ "$FIX" == "no" ]]
	then
		FIX_VAR="-f no"
	else
		FIX_VAR=""
	fi

	requires_variable X_HOSTNAME
	mount_scripts_directory $X_HOSTNAME

	message "INFO: Making sure mc's are as specified in the $MC_LIST_TYPE list, please wait...\n" INFO
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
	get_lock $MC_LOCK local na 7200 yes
	wait_smtool_available_${SMALL_PREFIX}
	$SSH -qt $X_HOSTNAME "$MOUNTPOINT/bin/manage_mcs.sh -c '$CONFIG' -m $MOUNTPOINT -t $MC_LIST_TYPE $FIX_VAR"
	local EXIT_CODE=$?
	clear_lock $MC_LOCK local na
	if [[ $EXIT_CODE -eq 0 ]]
        then
                message "Managing of mcs completed without problems\n" INFO
		return 0
        else
                message "NOK, output above\n" ERROR
		if [[ "$EXIT_ON_ERROR" == "yes" ]]
		then
			return 1
		else
			return 0
		fi
        fi

}
function update_nmsadm_password_initial ()
{
	update_nmsadm_password_internal nms275 $ADM1_NMSADM_PASS
}
function update_nmsadm_password_initial_oss2_adm ()
{
	update_nmsadm_password_internal nms275 $OSS2_ADM1_NMSADM_PASS
}

function update_nmsadm_password_config ()
{
	requires_variable ADM1_NMSADM_PASS
	update_nmsadm_password_ldap $ADM1_NMSADM_PASS
}

function update_nmsadm_password_ldap ()
{
        local NEW_PASS=$1
	change_user_password nmsadm $NEW_PASS
	update_nmsadm_password_internal $NEW_PASS $NEW_PASS
}

function update_nmsadm_password_internal ()
{
	local CURRENT_PASS=$1
	local NEW_PASS=$2
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/update_nmsadm_password.sh -m $MOUNTPOINT -o $CURRENT_PASS -n $NEW_PASS"
}
function generate_p12_omsas ()
{
	requires_variable OMSAS_HOSTNAME
	#wait_oss_online_adm1
        mount_scripts_directory $OMSAS_HOSTNAME
	# loop through the configuration script and retry if there are any issues
	exec_configuration_script "bin/sol11_generate_p12_omsas.sh"
	local EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: Something went wrong configuring sol11_generate_p12_omsas, please check output above" ERROR
		exit 1
	fi
}
function cep_post_steps ()
{
	mount_scripts_directory $CEP_HOSTNAME
	$SSH -qt $CEP_HOSTNAME "$MOUNTPOINT/bin/cep_post_steps.sh -m $MOUNTPOINT -c '$CONFIG'"
	local EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: Something went wrong during the CEP post steps, please check output above\n" ERROR
		exit 1
	fi
}
function copy_ms_certs_omsas ()
{
        requires_variable OMSAS_HOSTNAME
	#wait_oss_online_adm1
        mount_scripts_directory $OMSAS_HOSTNAME
	# loop through the configuration script and retry if there are any issues
	exec_configuration_script "bin/sol11_copy_ms_certs_omsas.sh"
	local EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: Something went wrong configuring sol11_copy_ms_certs_omsas, please check output above\n" ERROR
		exit 1
	fi
}
function enable_ms_security ()
{
	requires_variable ADM1_HOSTNAME
	#wait_oss_online_adm1
	mount_scripts_directory $ADM1_HOSTNAME
	message "INFO: Enabling security on the master server, this restarts all mc's so it may take some time..: " INFO

	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        get_lock $MC_LOCK local na 7200 yes
	wait_smtool_available_adm1
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/enable_ms_security.sh -m $MOUNTPOINT"
	if [[ $? -eq 0 ]]
	then
		message "OK\n" INFO
	else
		message "NOK, output above\n" ERROR
		clear_lock $MC_LOCK local na
		exit 1
	fi
	fetch_ior_files
	clear_lock $MC_LOCK local na
	omsas_config_aiws
}

function pwadmin_commands ()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME

	message "INFO: Update Password information for scsuser" INFO
	$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/pwAdmin -changePw infra SFTP scsuser -pw $SCSUSER_PASS" 
	local EXIT_CODE=$?
	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: Something went wrong with the password change for scsuser, please check output above\n" ERROR
		exit 1
	fi

	message "INFO: Update Password information for neuser" INFO
	$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/pwAdmin -changePw infra SFTP neuser -pw $NEUSER_PASS" 
	local EXIT_CODE=$?
	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: Something went wrong with the password change for neuser, please check output above\n" ERROR
		exit 1
	fi
}

function uas_post_steps_internal ()
{
	local SERVER=$1
	l_citrix_services=/opt/CTXSmf/sbin/ctxsrv
	mount_scripts_directory $SERVER
set -x
	$SSH -qt $SERVER "$MOUNTPOINT/bin/sol11_uas_post_steps.sh -m $MOUNTPOINT -c '$CONFIG'"
	$SSH -o StrictHostKeychecking=no $SERVER $l_citrix_services stop all
	$SSH -o StrictHostKeychecking=no $SERVER $l_citrix_services start all
	$SSH -qt $SERVER "$MOUNTPOINT/bin/citrix_appl.sh -m $MOUNTPOINT -c '$CONFIG'"
set +x
}
function configure_peer_internal ()
{
        local PEER_PREFIX=$1
	local SERVER=`eval echo \\$${PEER_PREFIX}_HOSTNAME`
        mount_scripts_directory $SERVER

        $SSH -qt $SERVER "$MOUNTPOINT/bin/configure_peer.sh -m $MOUNTPOINT -c '$CONFIG' -p $PEER_PREFIX"
	wait_until_not_pingable $SERVER
	wait_until_services_started $SERVER
}
function uas_post_steps_uas1 ()
{
	requires_variable UAS1_HOSTNAME
	uas_post_steps_internal $UAS1_HOSTNAME
}
function configure_peer_peer1 ()
{
        configure_peer_internal PEER1
}
function update_ldap_rules_omservm ()
{
	requires_variable OMSERVM_HOSTNAME
	mount_scripts_directory $OMSERVM_HOSTNAME
        $SSH -qt $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/update_ldap_rules_omservm.sh"
}
function set_external_gateway ()
{
	if [[ "$BEHIND_GATEWAY" != "yes" ]]
        then
		return 0
	fi

	local SERVER=$1
        mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/set_external_gateway.sh -m $MOUNTPOINT -c '$CONFIG'" 2>/dev/null
}
function set_external_gateway_uas1 ()
{
        requires_variable UAS1_HOSTNAME
        set_external_gateway $UAS1_HOSTNAME
}
function set_external_gateway_peer1 ()
{
        requires_variable PEER1_HOSTNAME
        set_external_gateway $PEER1_HOSTNAME
}
function set_external_gateway_omsas ()
{
        requires_variable OMSAS_HOSTNAME
        set_external_gateway $OMSAS_HOSTNAME
}
function set_external_gateway_omservm ()
{
        requires_variable OMSERVM_HOSTNAME
        set_external_gateway $OMSERVM_HOSTNAME
}
function set_external_gateway_omservs ()
{
        requires_variable OMSERVS_HOSTNAME
        set_external_gateway $OMSERVS_HOSTNAME
}

function set_external_gateway_adm1 ()
{
        requires_variable ADM1_HOSTNAME
        set_external_gateway $ADM1_HOSTNAME
}

function set_external_gateway_oss2_adm1 ()
{
        requires_variable OSS2_ADM1_HOSTNAME
        set_external_gateway $OSS2_ADM1_HOSTNAME
}

function set_external_gateway_adm2 ()
{
        requires_variable ADM2_HOSTNAME
        set_external_gateway $ADM2_HOSTNAME
}
function set_external_gateway_ebas ()
{
        requires_variable EBAS_HOSTNAME
        set_external_gateway $EBAS_HOSTNAME
}
function set_external_gateway_mws ()
{
        requires_variable MWS_HOSTNAME
        set_external_gateway $MWS_HOSTNAME
}
function set_external_gateway_nedss ()
{
        requires_variable NEDSS_HOSTNAME
        set_external_gateway $NEDSS_HOSTNAME
}
function set_external_gateway_eniqe ()
{
        requires_variable ENIQE_HOSTNAME
        set_external_gateway $ENIQE_HOSTNAME
}
function set_external_gateway_eniqs ()
{
        requires_variable ENIQS_HOSTNAME
        set_external_gateway $ENIQS_HOSTNAME
}
function set_external_gateway_eniqsc ()
{
        requires_variable ENIQSC_HOSTNAME
        set_external_gateway $ENIQSC_HOSTNAME
}
function set_external_gateway_eniqse ()
{
        requires_variable ENIQSE_HOSTNAME
        set_external_gateway $ENIQSE_HOSTNAME
}
function set_external_gateway_eniqsr1 ()
{
        requires_variable ENIQSR1_HOSTNAME
        set_external_gateway $ENIQSR1_HOSTNAME
}
function set_external_gateway_eniqsr2 ()
{
        requires_variable ENIQSR2_HOSTNAME
        set_external_gateway $ENIQSR2_HOSTNAME
}
function set_external_gateway_son_vis ()
{
        requires_variable SON_VIS_HOSTNAME
        set_external_gateway $SON_VIS_HOSTNAME
}
function cleanup ()
{
	SCRIPT_EXIT_CODE=$?
	EXIT_REASON="$1"
	trap - INT TERM EXIT
	if [[ "$SCRIPT_LOGFILE" == "" ]]
        then
		return 0
	fi
	
	echo_line
	message "INFO: Timing Summary\n" SUMMARY
	FORMATTED_DATE="`date | awk '{print $2 "_" $3 "_" $NF}'`"
	FORMATTED_TIME="`date | awk '{print $4}'`"
        message "INFO: Script started:  $STARTED_FORMATTED_DATE - $STARTED_TIME\n" SUMMARY
        message "INFO: Script finished: $FORMATTED_DATE - $FORMATTED_TIME\n" SUMMARY

	FINISHED_SECONDS=$(perl -e 'print int(time)')
	TIME_SPENT=$(($FINISHED_SECONDS-$STARTED_SECONDS))
	((h=$TIME_SPENT/3600))
	((m=$TIME_SPENT%3600/60))
	((s=$TIME_SPENT%60))

	TIME_TAKEN=""
	message "INFO: The script took" SUMMARY
	if [[ $h -gt 1 ]]
	then
		TIME_TAKEN="$TIME_TAKEN $h hours"
	elif [[ $h -gt 0 ]]
	then
		TIME_TAKEN="$TIME_TAKEN $h hour"
	fi

	if [[ $m -gt 1 ]]
        then
		TIME_TAKEN="$TIME_TAKEN $m minutes"
	elif [[ $m -gt 0 ]]
	then
		TIME_TAKEN="$TIME_TAKEN $m minute"
        fi

	if [[ $s -gt 1 ]]
	then
		TIME_TAKEN="$TIME_TAKEN $s seconds"
	elif [[ $s -gt 0 ]]
	then
		TIME_TAKEN="$TIME_TAKEN $s second"
	fi
	if [[ "$TIME_TAKEN" == "" ]]
	then
		TIME_TAKEN=" less than 1 second"
	fi

	message "$TIME_TAKEN to complete\n" SUMMARY
	echo_line
	#############################################
	message "INFO: Performing cleanup..\n" SCRIPT
	jobs -p | while read line
        do
                killtree $line 9 > /dev/null 2>&1
        done
	jobs -p | while read line
        do
                killtree $line 9 > /dev/null 2>&1
        done
	# Clear any old locks we might still have
	if [[ -f /tmp/$PARENT_BASHPID/cleanup_list/cleanup.list ]]
        then
		cat /tmp/$PARENT_BASHPID/cleanup_list/cleanup.list | sort -u | while read entry
		do
			clear_lock $entry
        	done
	fi

	# Move the running logs to not completed
	mv $RUNNING_LOG_DIR $UNCOMPLETED_LOG_DIR > /dev/null 2>&1

	# Clear temp directories if we can
	rm -rf /tmp/$PARENT_BASHPID/ > /dev/null 2>&1

	#  Output a summary of script completion
	message "INFO: Complete\n" SCRIPT
	message "INFO: Output log stored to $SCRIPT_LOGFILE on `hostname`\n" SCRIPT
	message "INFO: Individual logs stored to $INDIVIDUAL_LOG_DIR/ on `hostname`\n" SCRIPT
	if [[ $SCRIPT_EXIT_CODE -ne 0 ]]
        then
                EXIT_TYPE="ERROR"
		WITH_WITHOUT="with"
		SCRIPT_EXIT_CODE=1
        else
                EXIT_TYPE="INFO"
		WITH_WITHOUT="without"
        fi

	message "$EXIT_TYPE: The script completed with exit code $SCRIPT_EXIT_CODE\n" $EXIT_TYPE

	if [[ "$EXIT_REASON" != "EXIT" ]]
	then
		message "ERROR: The script didn't exit by itself, it exited with signal $EXIT_REASON\n" ERROR
	fi

	# Send email
	send_email "master.sh function $FUNCTION completed on `hostname` $WITH_WITHOUT errors" "Output log stored to $SCRIPT_LOGFILE on `hostname`"
	
	# Stop logging
	rm $npipe > /dev/null 2>&1

	# Status completed
	rm -rf $RUNNING_STATUS_FILE
	touch $COMPLETED_STATUS_FILE

	# Remove traps again
        trap - TERM INT EXIT
	
	# Exit
	exit
}

function send_email ()
{
	local SUBJECT="$1"
	local CONTENTS="$2"
	if [[ "$EMAIL_ADDRESSES" != "" ]]
	then
		EMAIL_ADDRESSES=`echo "$EMAIL_ADDRESSES" | sed 's/;/\n/g' | sed 's/,/\n/g'`
		echo "$EMAIL_ADDRESSES" | while read ADDRESS
		do
			message "INFO: Emailing result to $ADDRESS\n" INFO
			/usr/sbin/sendmail -oi -t << EOF
From: noreply@ericsson.com
To: $ADDRESS
Subject: $SUBJECT
$CONTENTS
EOF
		done
	fi
}

function killtree ()
{
    local _pid=$1
    local _sig=${2-TERM}
    for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
        killtree ${_child} ${_sig}
    done
    kill -${_sig} ${_pid} > /dev/null 2>&1

}

function activate_uas_ebas ()
{
	activate_uas $EBAS_HOSTNAME $EBAS_IP_ADDR "$EBAS_STOR_BASE_VIP" "$EBAS_STOR_HOSTNAME" yes
}
function activate_uas_uas1 ()
{
	activate_uas $UAS1_HOSTNAME $UAS1_IP_ADDR "$UAS1_STOR_BASE_VIP" "$UAS1_STOR_HOSTNAME" no
}
function activate_peer_peer1 ()
{
        activate_peer $PEER1_HOSTNAME $PEER1_IP_ADDR "$PEER1_STOR_BASE_VIP" "$PEER1_STOR_HOSTNAME"
}
function copy_p12_to_server_peer1 ()
{
	copy_p12_to_server_prefix PEER1
}
function copy_p12_to_server_prefix ()
{
	local PREFIX=$1
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
	mount_scripts_directory $X_HOSTNAME
	$SSH -qt $X_HOSTNAME "$MOUNTPOINT/bin/sol11_copy_p12_to_ebas.sh  -c '$CONFIG' -m $MOUNTPOINT"
}
function activate_uas ()
{
	#wait_oss_online_adm1
	ACTIVATE_LOCK="/tmp/$PARENT_BASHPID/locks/activate_uas.lock"
        get_lock $ACTIVATE_LOCK local na 3600 yes
	local THE_SERVER=$1
	local IP_ADDR=$2
	local STOR_VIP=$3
	local STOR_HOSTNAME=$4
	local IS_AN_EBAS=$5

	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/activate_uas.sh  -c '$CONFIG' -m $MOUNTPOINT -s $THE_SERVER -i $IP_ADDR -e $IS_AN_EBAS -b '$STOR_VIP' -h '$STOR_HOSTNAME'"

        if [[ $? -ne 0 ]]
        then
		if [[ $IS_AN_EBAS = "no" ]]
		then
                message "ERROR: Something went wrong while performing activate_uas of uas  \n" ERROR
		else
		message "ERROR: Something went wrong while performing activate_uas of ebas  \n" ERROR
		fi
		exit 1
        fi


	clear_lock $ACTIVATE_LOCK local na
}

function activate_peer ()
{
        #wait_oss_online_adm1
        ACTIVATE_LOCK="/tmp/$PARENT_BASHPID/locks/activate_uas.lock"
        get_lock $ACTIVATE_LOCK local na 3600 yes
        local THE_SERVER=$1
        local IP_ADDR=$2
        local STOR_VIP=$3
        local STOR_HOSTNAME=$4

        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/activate_peer.sh  -c '$CONFIG' -m $MOUNTPOINT -s $THE_SERVER -i $IP_ADDR -b '$STOR_VIP' -h '$STOR_HOSTNAME'"
	
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong while performing activate_peer script \n" ERROR
                exit 1
        fi

        clear_lock $ACTIVATE_LOCK local na
}

function setup_adm1_ldap_client ()
{
	#wait_oss_online_adm1
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "TERM=xterm; $MOUNTPOINT/bin/sol11_setup_adm1_ldap_client.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Something went wrong setting up adm1 as an ldap client, see above for errors\n" ERROR
		exit 1
	fi

	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/maintain_ldap.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
		message "ERROR: Something went wrong running the maintain ldap command, see above for errors\n" ERROR
                exit 1
        fi
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/config_ldap.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
		message "ERROR: Something went wrong running the config_ldap command, see above for errors\n" ERROR
                exit 1
        fi
}
function setup_replication()
{
	mount_scripts_directory $1
	$SSH -qt $1 "$MOUNTPOINT/bin/setup_replication.sh  -c '$CONFIG' -t $2 -m $MOUNTPOINT"
}

function initialize_replication ()
{
	mount_scripts_directory $1
	$SSH -qt $1 "$MOUNTPOINT/bin/initialize_replication.sh  -c '$CONFIG' -t $2 -m $MOUNTPOINT"
}
function update_ldap_client_profile ()
{

	mount_scripts_directory $OMSERVM_HOSTNAME
	$SSH -qt $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/update_ldap_client_profile.sh -c '$CONFIG' -m '$MOUNTPOINT'"
}

function setup_replication_enhanced ()
{
	message "INFO: Setting up replication, Enhanced\n" INFO

	requires_variable OMSERVM_HOSTNAME
	requires_variable OMSERVS_HOSTNAME
	requires_variable OMSAS_HOSTNAME
	requires_variable OMSERVM_FQHN
	requires_variable OMSERVS_FQHN
	requires_variable OMSAS_FQHN

        ## 6.3 Enhanced
        setup_replication $OMSERVM_HOSTNAME $OMSERVS_FQHN
        setup_replication $OMSERVM_HOSTNAME $OMSAS_FQHN

        #setup_replication $OMSERVS_HOSTNAME $OMSERVM_FQHN
        #setup_replication $OMSERVS_HOSTNAME $OMSAS_FQHN

        #setup_replication $OMSAS_HOSTNAME $OMSERVM_FQHN
        #setup_replication $OMSAS_HOSTNAME $OMSERVS_FQHN

        initialize_replication $OMSERVM_HOSTNAME $OMSERVS_FQHN
        initialize_replication $OMSERVM_HOSTNAME $OMSAS_FQHN

        update_ldap_client_profile
}
function setup_replication_standard ()
{
        message "INFO: Setting up replication, Standard\n" INFO

	requires_variable OMSERVM_HOSTNAME
        requires_variable OMSERVS_HOSTNAME
        requires_variable OMSERVM_FQHN
        requires_variable OMSERVS_FQHN

        ## 6.2
        setup_replication $OMSERVM_HOSTNAME $OMSERVS_FQHN
        setup_replication $OMSERVS_HOSTNAME $OMSERVM_FQHN

        initialize_replication $OMSERVM_HOSTNAME $OMSERVS_FQHN

        update_ldap_client_profile
}
function setup_replication_single()
{
	message "INFO: Setting up replication, single infra and omsas INFO\n" INFO

	requires_variable OMSERVM_HOSTNAME
        requires_variable OMSAS_HOSTNAME
        requires_variable OMSERVM_FQHN
        requires_variable OMSAS_FQHN

        ## 6.4
        setup_replication $OMSERVM_HOSTNAME $OMSAS_FQHN
        setup_replication $OMSAS_HOSTNAME $OMSERVM_FQHN
        initialize_replication $OMSERVM_HOSTNAME $OMSAS_FQHN

}
function setup_replication_detect ()
{

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$OMSERVM_HOSTNAME" != "" ]]
        then
		setup_replication_enhanced
	elif [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$OMSERVM_HOSTNAME" != "" ]]
	then
		setup_replication_standard
	elif [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$OMSERVM_HOSTNAME" != "" ]]
	then
		setup_replication_single
	else
		message "INFO: Couldn't find a suitable replication type to setup\n" INFO
	fi
	
}
function setup_replication_config()
{
	requires_variable OMSERVM_DEPL_TYPE
	if [[ "$OMSERVM_DEPL_TYPE" == "Single" ]]
        then
                setup_replication_single
        elif [[ "$OMSERVM_DEPL_TYPE" == "Standard" ]]
        then
                setup_replication_standard
        elif [[ "$OMSERVM_DEPL_TYPE" == "Enhanced" ]]
	then
                setup_replication_enhanced
        fi
}
function boot_from_network ()
{
	if [ "$1" == "BLADE" ]
	then
		local CHASSIS_ADDRESS="$2"
		local CHASSIS_USER="$3"
		local CHASSIS_PASS="$4"
		local CHASSIS_BAY="$5"
		local OUTPUT=""
		OUTPUT=`set_blade_boot_device pxe $CHASSIS_ADDRESS $CHASSIS_USER $CHASSIS_PASS $CHASSIS_BAY`
		if [[ $? -ne 0 ]]
		then
			message "$OUTPUT\n" WARNING
			message "WARNING: Something went wrong running the set server boot command, see above, retrying in 30 seconds\n" WARNING
			sleep 30
			OUTPUT=`set_blade_boot_device pxe $CHASSIS_ADDRESS $CHASSIS_USER $CHASSIS_PASS $CHASSIS_BAY`
			if [[ $? -ne 0 ]]
			then
				message "$OUTPUT\n" ERROR
				message "ERROR: Something went wrong again running the set server boot command, see above, exiting\n" ERROR
				exit 1
			fi
		fi
	else
		local THE_HOSTNAME="$1"
		local VSP_SERVER="$2"
		local VM_NAME_CONFIG="$3"
		VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
		if [[ $? -ne 0 ]]
		then
			message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
			message "$VM_NAME\n" ERROR
			exit 1
		fi
		boot_from_network_virtual $THE_HOSTNAME "$VM_NAME"
	fi
}

function boot_from_disk ()
{
    if [[ "$1" == "BLADE" ]]
	then
		return 0
	fi
	local THE_HOSTNAME="$1"
	local VSP_SERVER="$2"
	local VM_NAME_CONFIG="$3"
        VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        boot_from_disk_virtual $THE_HOSTNAME "$VM_NAME"
}

function boot_from_floppy ()
{
	if [ "$1" == "BLADE" ]
	then
		local CHASSIS_ADDRESS="$2"
		local CHASSIS_USER="$3"
		local CHASSIS_PASS="$4"
		local CHASSIS_BAY="$5"
		local OUTPUT=""
		OUTPUT=`set_blade_boot_device rbsu $CHASSIS_ADDRESS $CHASSIS_USER $CHASSIS_PASS $CHASSIS_BAY`
		if [[ $? -ne 0 ]]
                then
                        message "$OUTPUT\n" WARNING
                        message "WARNING: Something went wrong running the set server boot command, see above, retrying in 30 seconds\n" WARNING
                        sleep 30
                        OUTPUT=`set_blade_boot_device rbsu $CHASSIS_ADDRESS $CHASSIS_USER $CHASSIS_PASS $CHASSIS_BAY`
                        if [[ $? -ne 0 ]]
                        then
                                message "$OUTPUT\n" ERROR
                                message "ERROR: Something went wrong again running the set server boot command, see above, exiting\n" ERROR
                                exit 1
                        fi
                fi
	else
        local THE_HOSTNAME="$1"
        local VSP_SERVER="$2"
        local VM_NAME_CONFIG="$3"
        VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        boot_from_floppy_virtual $THE_HOSTNAME "$VM_NAME"
	fi
}
function poweron_server ()
{
	if [ "$1" == "BLADE" ]
	then
		local ILO_ADDRESS="$2"
		local ILO_USER="$3"
		local ILO_PASS="$4"
		power_control_blade on $ILO_ADDRESS $ILO_USER $ILO_PASS
	fi
}
function poweroff_server ()
{
	if [ "$1" == "BLADE" ]
	then
		local ILO_ADDRESS="$2"
		local ILO_USER="$3"
		local ILO_PASS="$4"
		power_control_blade off $ILO_ADDRESS $ILO_USER $ILO_PASS
	fi
}

function set_blade_boot_device ()
{
	local BOOT_DEVICE="$1"
	local CHASSIS_ADDRESS="$2"
	local CHASSIS_USER="$3"
	local CHASSIS_PASS="$4"
	local CHASSIS_BAY="$5"
	local CHASSIS_PROMPT="> "

	expect << EOF
spawn ssh -o StrictHostKeyChecking=no -l $CHASSIS_USER $CHASSIS_ADDRESS	
set force_conservative 1
set timeout 60

	while {"1" == "1"} {
		expect {
			"assword:" {
				send "$CHASSIS_PASS\r"
				expect {
					-re "$CHASSIS_PROMPT" {
						send "set server boot once $BOOT_DEVICE $CHASSIS_BAY\r"
						expect {
							"boot order changed to" {
								exit 0
							}
							-re "$CHASSIS_PROMPT" {
								exit 1
							}
						}
					}	
					"FAILED" {
						exit 1
					}
					timeout {
						exit 1
					}		
				}
			}
			eof {
				exit 1
			}
			timeout {
				send_user "Timed out\n"
				exit 1
			}
		}
	}
EOF
}

function power_control_blade ()
{
	local POWER_ACTION="$1"
	local ILO_ADDRESS="$2"
	local ILO_USER="$3"
	local ILO_PASS="$4"
	local ILO_PROMPT="->"
	case $POWER_ACTION in
	on) COMMAND="start /system1"
	    ACTION=On
		OPP_ACTION=Off
	;;
	off) COMMAND="stop /system1"
		 ACTION=Off
		 OPP_ACTION=On
	;;
	esac
	expect << EOF
spawn ssh -o StrictHostKeyChecking=no -l $ILO_USER $ILO_ADDRESS	
set force_conservative 1
set timeout 60


while {"1" == "1"} {
	expect {
		"assword:" {
			send "$ILO_PASS\r"
		}
		-re "$ILO_PROMPT" {
			if {[string match $ACTION "On"]} {
				send "power\r"
				expect {
					-re "currently: On" {
						send "reset /system1\r"
						expect {
							"COMPLETED" {
							exit 0
							}
						}
					}
				}
			}
			send "$COMMAND\r"
			expect {
				-re $ILO_PROMPT {
						send_user "$COMMAND sent\n"
					}
				while 1 {
					send "\r"
					expect {
						-re $ILO_PROMPT {
							send "power\r"
							expect {
								"power: server power is currently: $OPP_ACTION" {
									sleep 20
									send "$COMMAND\r"
								}
								"power: server power is currently: $ACTION" {
									exit 0
								}
							}
						}
					}
				}
				timeout {
					exit 1
				}
			}
		}
		eof {
			exit 1
		}
		timeout {
			send_user "Timed out\n"
			exit 1
		}
	}
}
EOF
}
function boot_from_network_virtual ()
{
	local THE_HOSTNAME="$1"
	local VM_NAME="$2"

        message "INFO: Setting boot device to network for vm $VM_NAME\n" INFO
	local boot_order_vcli_command="$MOUNTPOINT/bin/BootOrder.pl --vmname '$VM_NAME' --bootWith allow:net"
	run_vcli_command "$boot_order_vcli_command" $VCEN_HOSTNAME

	message "INFO: Powering on the vm $VM_NAME incase its not powered on\n" INFO
	poweronvm "$VM_NAME" "$THE_HOSTNAME"

	message "INFO: Resetting the vm $VM_NAME\n" INFO
	resetvm "$VM_NAME" "$THE_HOSTNAME"
}
function boot_from_disk_virtual ()
{
	local THE_HOSTNAME="$1"
        local VM_NAME="$2"

	message "INFO: Setting boot device to disk for vm $VM_NAME\n" INFO
	local boot_order_vcli_command="$MOUNTPOINT/bin/BootOrder.pl --vmname '$VM_NAME' --bootWith allow:hd,net"
	run_vcli_command "$boot_order_vcli_command" $VCEN_HOSTNAME
}
function boot_from_floppy_virtual ()
{
        local THE_HOSTNAME="$1"
        local VM_NAME="$2"

	local boot_order_vcli_command="$MOUNTPOINT/bin/BootOrder.pl --vmname '$VM_NAME' --bootWith allow:fd"
	local output=""
	output=`run_vcli_command "$boot_order_vcli_command" $VCEN_HOSTNAME`

	#message "INFO: Powering on the vm $VM_NAME incase its not powered on\n" INFO
        poweronvm "$VM_NAME" "$THE_HOSTNAME"

        #message "INFO: Resetting the vm $VM_NAME\n" INFO
        resetvm "$VM_NAME" "$THE_HOSTNAME"
}

function boot_from_floppy_prefix ()
{
	local SERVER_PREFIX=$1

        local X_SERVER_TYPE=`eval echo \\$${SERVER_PREFIX}_SERVER_TYPE`
	local X_CHASSIS_ADDRESS=`eval echo \\$${SERVER_PREFIX}_CHASSIS_ADDRESS`
	local X_CHASSIS_USER=`eval echo \\$${SERVER_PREFIX}_CHASSIS_USER`
	local X_CHASSIS_PASS=`eval echo \\$${SERVER_PREFIX}_CHASSIS_PASS`
	local X_CHASSIS_BAY=`eval echo \\$${SERVER_PREFIX}_CHASSIS_BAY`
	local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local X_VM_NAME=`eval echo \\$${SERVER_PREFIX}_VM_NAME`
	
	if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                requires_variable X_CHASSIS_ADDRESS
                requires_variable X_CHASSIS_USER
                requires_variable X_CHASSIS_PASS
                requires_variable X_CHASSIS_BAY
                boot_from_floppy BLADE $X_CHASSIS_ADDRESS $X_CHASSIS_USER $X_CHASSIS_PASS $X_CHASSIS_BAY
        else
                requires_variable X_HOSTNAME
                requires_variable X_VSP_SERVER
                boot_from_floppy $X_HOSTNAME $X_VSP_SERVER "$X_VM_NAME"
        fi
}
function boot_from_floppy_adm1 ()
{
	boot_from_floppy_prefix ADM1
}
function boot_from_floppy_oss2_adm1 ()
{
	boot_from_floppy_prefix OSS2_ADM1
}
function boot_from_floppy_adm2 ()
{
	boot_from_floppy_prefix ADM2
}
function boot_from_floppy_omsas ()
{
	boot_from_floppy_prefix OMSAS
}
function boot_from_floppy_nedss ()
{
	boot_from_floppy_prefix NEDSS
}
function boot_from_floppy_omservm ()
{
	boot_from_floppy_prefix OMSERVM
}
function boot_from_floppy_omservs ()
{
	boot_from_floppy_prefix OMSERVS
}
function boot_from_floppy_uas1 ()
{
	boot_from_floppy_prefix UAS1
}
function boot_from_floppy_peer1 ()
{
	boot_from_floppy_prefix PEER1
}
function boot_from_floppy_ebas ()
{
	boot_from_floppy_prefix EBAS
}
function boot_from_floppy_mws ()
{
	boot_from_floppy_prefix MWS
}
function boot_from_floppy_eniqe ()
{
	boot_from_floppy_prefix ENIQE
}
function boot_from_floppy_cep ()
{
	boot_from_floppy_prefix CEP
}
function boot_from_floppy_eniqs ()
{
	boot_from_floppy_prefix ENIQS
}
function boot_from_floppy_eniqsc ()
{
	boot_from_floppy_prefix ENIQSC
}
function boot_from_floppy_eniqse ()
{
	boot_from_floppy_prefix ENIQSE
}
function boot_from_floppy_eniqsr1 ()
{
	boot_from_floppy_prefix ENIQSR1
}
function boot_from_floppy_eniqsr2 ()
{
	boot_from_floppy_prefix ENIQSR2
}
function boot_from_floppy_son_vis ()
{
	boot_from_floppy_prefix SON_VIS
}
function boot_from_network_prefix ()
{
        local SERVER_PREFIX=$1

        local X_SERVER_TYPE=`eval echo \\$${SERVER_PREFIX}_SERVER_TYPE`
        local X_CHASSIS_ADDRESS=`eval echo \\$${SERVER_PREFIX}_CHASSIS_ADDRESS`
        local X_CHASSIS_USER=`eval echo \\$${SERVER_PREFIX}_CHASSIS_USER`
        local X_CHASSIS_PASS=`eval echo \\$${SERVER_PREFIX}_CHASSIS_PASS`
        local X_CHASSIS_BAY=`eval echo \\$${SERVER_PREFIX}_CHASSIS_BAY`
        local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
        local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
        local X_VM_NAME=`eval echo \\$${SERVER_PREFIX}_VM_NAME`

        if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                requires_variable X_CHASSIS_ADDRESS
                requires_variable X_CHASSIS_USER
                requires_variable X_CHASSIS_PASS
                requires_variable X_CHASSIS_BAY
                boot_from_network BLADE $X_CHASSIS_ADDRESS $X_CHASSIS_USER $X_CHASSIS_PASS $X_CHASSIS_BAY
        else
                requires_variable X_HOSTNAME
                requires_variable X_VSP_SERVER
                boot_from_network $X_HOSTNAME $X_VSP_SERVER "$X_VM_NAME"
        fi
}
function boot_from_network_adm1 ()
{
        boot_from_network_prefix ADM1
}
function boot_from_network_oss2_adm1 ()
{
        boot_from_network_prefix OSS2_ADM1
}
function boot_from_network_adm2 ()
{
        boot_from_network_prefix ADM2
}
function boot_from_network_omsas ()
{
        boot_from_network_prefix OMSAS
}
function boot_from_network_nedss ()
{
        boot_from_network_prefix NEDSS
}
function boot_from_network_omservm ()
{
        boot_from_network_prefix OMSERVM
}
function boot_from_network_omservs ()
{
        boot_from_network_prefix OMSERVS
}
function boot_from_network_uas1 ()
{
        boot_from_network_prefix UAS1
}
function boot_from_network_peer1 ()
{
        boot_from_network_prefix PEER1
}
function boot_from_network_ebas ()
{
        boot_from_network_prefix EBAS
}
function boot_from_network_mws ()
{
        boot_from_network_prefix MWS
}
function boot_from_network_eniqe ()
{
        boot_from_network_prefix ENIQE
}
function boot_from_network_cep ()
{
	boot_from_network_prefix CEP
}
function boot_from_network_eniqs ()
{
        boot_from_network_prefix ENIQS
}
function boot_from_network_eniqsc ()
{
        boot_from_network_prefix ENIQSC
}
function boot_from_network_eniqse ()
{
        boot_from_network_prefix ENIQSE
}
function boot_from_network_eniqsr1 ()
{
        boot_from_network_prefix ENIQSR1
}
function boot_from_network_eniqsr2 ()
{
        boot_from_network_prefix ENIQSR2
}
function boot_from_network_son_vis ()
{
        boot_from_network_prefix SON_VIS
}
function boot_from_network_ms ()
{
        boot_from_network_prefix MS
}
function boot_from_network_sc1 ()
{
        boot_from_network_prefix SC1
}
function boot_from_network_sc2 ()
{
        boot_from_network_prefix SC2
}
function boot_from_disk_prefix ()
{
	local SERVER_PREFIX=$1

        local X_SERVER_TYPE=`eval echo \\$${SERVER_PREFIX}_SERVER_TYPE`
	if [[ "$X_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
	local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local X_VM_NAME=`eval echo \\$${SERVER_PREFIX}_VM_NAME`
	requires_variable X_HOSTNAME
	requires_variable X_VSP_SERVER
	boot_from_disk $X_HOSTNAME $X_VSP_SERVER "$X_VM_NAME"
}
function boot_from_disk_adm1 ()
{
        boot_from_disk_prefix ADM1
}
function boot_from_disk_oss2_adm1 ()
{
        boot_from_disk_prefix OSS2_ADM1
}
function boot_from_disk_adm2 ()
{
        boot_from_disk_prefix ADM2
}
function boot_from_disk_omsas ()
{
        boot_from_disk_prefix OMSAS
}
function boot_from_disk_nedss ()
{
        boot_from_disk_prefix NEDSS
}
function boot_from_disk_omservm ()
{
        boot_from_disk_prefix OMSERVM
}
function boot_from_disk_omservs ()
{
        boot_from_disk_prefix OMSERVS
}
function boot_from_disk_uas1 ()
{
        boot_from_disk_prefix UAS1
}
function boot_from_disk_peer1 ()
{
        boot_from_disk_prefix PEER1
}
function boot_from_disk_ebas ()
{
        boot_from_disk_prefix EBAS
}
function boot_from_disk_mws ()
{
        boot_from_disk_prefix MWS
}
function boot_from_disk_eniqe ()
{
        boot_from_disk_prefix ENIQE
}
function boot_from_disk_cep ()
{
        boot_from_disk_prefix CEP
}
function boot_from_disk_eniqs ()
{
        boot_from_disk_prefix ENIQS
}
function boot_from_disk_eniqsc ()
{
        boot_from_disk_prefix ENIQSC
}
function boot_from_disk_eniqse ()
{
        boot_from_disk_prefix ENIQSE
}
function boot_from_disk_eniqsr1 ()
{
        boot_from_disk_prefix ENIQSR1
}
function boot_from_disk_eniqsr2 ()
{
        boot_from_disk_prefix ENIQSR2
}
function boot_from_disk_son_vis ()
{
        boot_from_disk_prefix SON_VIS
}
function boot_from_disk_ms ()
{
        boot_from_disk_prefix MS
}
function boot_from_disk_sc1 ()
{
        boot_from_disk_prefix SC1
}
function boot_from_disk_sc2 ()
{
        boot_from_disk_prefix SC2
}
function get_vm_name_from_spc ()
{
    local THE_HOSTNAME=$1
    local VSP_SERVER=$2

	if [[ "$VSP_SERVER" == "" ]]
	then
		message "ERROR: You havn't set a VSP_SERVER for this vm, please set this in your config file, or explicitly set its VM_NAME\n" ERROR
		exit 1
	fi

	local ATTEMPT=1
	while [[ $ATTEMPT -le 100 ]]
	do
	        local OUTPUT="`$MOUNTPOINT/bin/vSPC.py $VSP_SERVER`"
	        local RESULT=`echo "$OUTPUT" | grep "$THE_HOSTNAME" | awk -F: '{print $1}'`
	        if [[ "$RESULT" == "" ]]
	        then
			if [[ $ATTEMPT -gt 3 ]]
			then
		                message "ERROR: Couldn't get the vsp port for $THE_HOSTNAME from $VSP_SERVER, maybe reboot it and try again\n" ERROR
		                message "$OUTPUT\n" ERROR
		                exit 1
			fi
	        else
	                COUNT_RESULTS=`echo "$RESULT" | wc -l`
	                if [[ $COUNT_RESULTS -gt 1 ]]
	                then
				if [[ $ATTEMPT -gt 3 ]]
				then
		                        message "There were $COUNT_RESULTS vsp ports with this hostname $THE_HOSTNAME and vapp name $VAPP_NAME, see below. Make sure your vapp name is unique\n\n" ERROR
		                        message "$OUTPUT\n" ERROR
		                        exit 1
				fi
			else
		                echo -n "$RESULT"
				exit 0
			fi
	        fi
		sleep 1
                let ATTEMPT=ATTEMPT+1
	done
}
function get_vsp_port_prefix ()
{
	local PREFIX=$1
	local GRACEFUL="$2"

	local THE_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
	local VSP_SERVER=`eval echo \\$${PREFIX}_VSP_SERVER`
	local VM_NAME_CONFIG=`eval echo \\$${PREFIX}_VM_NAME`
	# If we are on the gateway, force the spc to be the gateway, its pointless to set for public boxes as we couldn't get
	# their vm name without the serial port being set in the first place
	#if [[ "$ON_THE_GATEWAY" == "yes" ]]
	#then
		VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
		if [[ $? -ne 0 ]]
		then
			message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
			message "$VM_NAME\n" ERROR
			return 1
		fi

		local OUTPUT=""
		OUTPUT=`create_serial_port_prefix $PREFIX "$GRACEFUL"`
		if [[ $? -ne 0 ]]
		then
			message "ERROR: Couldn't set the spc for $VM_NAME\n" ERROR
			message "$OUTPUT\n" ERROR
			return 1
		fi
	#fi

	local ATTEMPT=1
	while [[ $ATTEMPT -le 200 ]]
        do
		# Now try to get output from the VSP Server
		local OUTPUT="`$MOUNTPOINT/bin/vSPC.py $VSP_SERVER 2>&1`"
	        local RESULT=`echo "$OUTPUT" | grep "$VM_NAME" | awk -F: '{print $3}'`
	        if [[ "$RESULT" == "" ]]
	        then
			if [[ $ATTEMPT -gt 150 ]]
			then
		                message "ERROR: Couldn't get the vsp port for $THE_HOSTNAME from $VSP_SERVER, maybe reboot it and try again\n" ERROR
		                message "$OUTPUT\n" ERROR
	        	        exit 1
			else
				sleep 2
			fi
	        else
	                COUNT_RESULTS=`echo "$RESULT" | wc -l`
	                if [[ $COUNT_RESULTS -gt 1 ]]
	                then
				if [[ $ATTEMPT -gt 3 ]]
				then
		                        message "There were $COUNT_RESULTS vsp ports with this hostname $THE_HOSTNAME, see below. Make sure your vapp name is unique\n\n" ERROR
		                        message "$OUTPUT\n" ERROR
		                        exit 1
				fi
			else
		                echo -n "$RESULT"
				exit 0
			fi
		fi
		sleep 1
		let ATTEMPT=ATTEMPT+1
	done
}
function remove_password_change_history ()
{
        #change_domain_setting pwdInHistory 0
	$SSH -qt $OMSERVM_HOSTNAME "nohup pgrep ns-slapd > /dev/null"
        LDAP_STAT=$(echo $?)
        if [[ $LDAP_STAT == 0 ]]; then
                change_domain_setting pwdInHistory 0
        else
                change_domain_setting password-history-count 0
        fi

}
function disable_password_expiry ()
{
	#change_domain_setting pwdMaxAge 0
	#change_domain_setting passwordExp off
	$SSH -qt $OMSERVM_HOSTNAME "nohup pgrep ns-slapd > /dev/null"
        LDAP_STAT=$(echo $?)
        if [[ $LDAP_STAT == 0 ]]; then
                change_domain_setting pwdMaxAge 0
                change_domain_setting passwordExp off
        else
                change_domain_setting max-password-age 0s
        fi
}
function disable_password_lockout ()
{
	#change_domain_setting pwdLockout FALSE
	 $SSH -qt $OMSERVM_HOSTNAME "nohup pgrep ns-slapd > /dev/null"
        LDAP_STAT=$(echo $?)
        if [[ $LDAP_STAT == 0 ]]; then
                change_domain_setting pwdLockout FALSE
        else
                change_domain_setting lockout-duration 0s
        fi

}
function disable_password_must_change ()
{
	#change_domain_setting pwdMustChange FALSE
	 $SSH -qt $OMSERVM_HOSTNAME "nohup pgrep ns-slapd > /dev/null"
        LDAP_STAT=$(echo $?)
        if [[ $LDAP_STAT == 0 ]]; then
                change_domain_setting pwdMustChange FALSE
        else
                change_domain_setting force-change-on-add FALSE
                change_domain_setting force-change-on-reset FALSE
        fi

}
function reduce_min_password_length ()
{
	#change_domain_setting pwdMinLength 3
	$SSH -qt $OMSERVM_HOSTNAME "nohup pgrep ns-slapd > /dev/null"
        LDAP_STAT=$(echo $?)
        if [[ $LDAP_STAT == 0 ]]; then
                change_domain_setting pwdMinLength 3
        else
                change_domain_setting ds-cfg-min-password-length 3
        fi
}
function change_domain_setting ()
{
	local PARAMETER=$1
	local VALUE=$2
	requires_variable OMSERVM_HOSTNAME
	mount_scripts_directory $OMSERVM_HOSTNAME
	$SSH -qt $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/change_domain_setting.sh  -c '$CONFIG' -m $MOUNTPOINT -p $PARAMETER -v $VALUE"
}
function wait_until_sshable_adm1 ()
{
	requires_variable ADM1_HOSTNAME
	wait_until_sshable $ADM1_HOSTNAME
}
function wait_until_sshable_oss2_adm1 ()
{
	requires_variable OSS2_ADM1_HOSTNAME
	wait_until_sshable $OSS2_ADM1_HOSTNAME
}
function wait_until_sshable_adm2 ()
{
        requires_variable ADM2_HOSTNAME
        wait_until_sshable $ADM2_HOSTNAME
}
function wait_until_sshable_omsas ()
{
        requires_variable OMSAS_HOSTNAME
        wait_until_sshable $OMSAS_HOSTNAME
}
function wait_until_sshable_omservm ()
{
        requires_variable OMSERVM_HOSTNAME
        wait_until_sshable $OMSERVM_HOSTNAME
}
function wait_until_sshable_omservs ()
{
        requires_variable OMSERVS_HOSTNAME
        wait_until_sshable $OMSERVS_HOSTNAME
}
function wait_until_sshable_nedss ()
{
        requires_variable NEDSS_HOSTNAME
        wait_until_sshable $NEDSS_HOSTNAME
}
function wait_until_sshable_ebas ()
{
        requires_variable EBAS_HOSTNAME
        wait_until_sshable $EBAS_HOSTNAME
}
function wait_until_sshable_mws ()
{
        requires_variable MWS_HOSTNAME
        wait_until_sshable $MWS_HOSTNAME
}
function wait_until_sshable_uas1()
{
        requires_variable UAS1_HOSTNAME
        wait_until_sshable $UAS1_HOSTNAME
}
function wait_until_sshable_peer1()
{
        requires_variable PEER1_HOSTNAME
        wait_until_sshable $PEER1_HOSTNAME
}
function wait_until_sshable_eniqe ()
{
	requires_variable ENIQE_HOSTNAME
	wait_until_sshable $ENIQE_HOSTNAME
}
function wait_until_sshable_cep ()
{
	requires_variable CEP_HOSTNAME
	wait_until_sshable $CEP_HOSTNAME
}
function wait_until_sshable_eniqs ()
{
        requires_variable ENIQS_HOSTNAME
        wait_until_sshable $ENIQS_HOSTNAME
}
function wait_until_sshable_eniqsc ()
{
        requires_variable ENIQSC_HOSTNAME
        wait_until_sshable $ENIQSC_HOSTNAME
}
function wait_until_sshable_eniqse ()
{
        requires_variable ENIQSE_HOSTNAME
        wait_until_sshable $ENIQSE_HOSTNAME
}
function wait_until_sshable_eniqsr1 ()
{
        requires_variable ENIQSR1_HOSTNAME
        wait_until_sshable $ENIQSR1_HOSTNAME
}
function wait_until_sshable_eniqsr2 ()
{
        requires_variable ENIQSR2_HOSTNAME
        wait_until_sshable $ENIQSR2_HOSTNAME
}
function wait_until_sshable_son_vis ()
{
        requires_variable SON_VIS_HOSTNAME
        wait_until_sshable $SON_VIS_HOSTNAME
}
function wait_until_sshable_ms ()
{
        requires_variable MS1_HOSTNAME
        wait_until_sshable $MS1_HOSTNAME
}
function wait_until_sshable_sc1 ()
{
        requires_variable SC1_HOSTNAME
        wait_until_sshable $SC1_HOSTNAME
}
function wait_until_sshable_sc2 ()
{
        requires_variable SC2_HOSTNAME
        wait_until_sshable $SC2_HOSTNAME
}
function wait_oss_online_adm1 ()
{
	wait_oss_online_internal $ADM1_HOSTNAME $ADM1_HOSTNAME
}
function wait_oss_online_adm2 ()
{
	wait_oss_online_internal $ADM2_HOSTNAME $ADM2_HOSTNAME
}
function wait_oss_online_oss2_adm1 ()
{
	wait_oss_online_internal $OSS2_ADM1_HOSTNAME $OSS2_ADM1_HOSTNAME
}
function wait_oss_online_internal ()
{
	local SERVER=$1
	local SERVER_HOSTNAME=$2

	wait_until_sshable $SERVER
	mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/wait_oss_online.sh -s $SERVER_HOSTNAME"
	if [[ $? -ne 0 ]]
	then
		message "ERROR: ha didn't come online on $SERVER\n" ERROR
		exit 1
	fi
}
function wait_smtool_available_adm1 ()
{
	wait_until_sshable_adm1
        mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/wait_smtool_available.sh"
}
function wait_smtool_available_oss2_adm1 ()
{
	wait_until_sshable_oss2_adm1
        mount_scripts_directory $OSS2_ADM1_HOSTNAME
	$SSH -qt $OSS2_ADM1_HOSTNAME "$MOUNTPOINT/bin/wait_smtool_available.sh"
}
function wait_until_sshable ()
{
	local SERVER=$1
	local ATTEMPT=1
	message "INFO: Waiting until $SERVER is sshable\n" INFO

        while [[ $ATTEMPT -le 360 ]]
        do
		#message "INFO: Attempt number $ATTEMPT of 360 to ssh to $SERVER\n" INFO
		mount_scripts_directory $SERVER noexit > /dev/null 2>&1
		if [[ $? -ne 0 ]]
		then
			#message "INFO: $SERVER is not sshable yet, waiting for 5 seconds before trying again\n"
			sleep 5
		else
			message "INFO: SSH working towards $SERVER\n"
			#message "OK\n" INFO
			return 0
		fi
		let ATTEMPT=ATTEMPT+1
	done
	exit 1
}
function wait_until_services_started ()
{
	local SERVER=$1
	wait_until_sshable $SERVER
	mount_scripts_directory $SERVER
	message "INFO: Waiting for smf services to finish starting on $SERVER: " INFO
	$SSH -qt $SERVER "$MOUNTPOINT/bin/wait_until_services_started.sh" 2>/dev/null
	message "OK\n" INFO
}
function wait_until_services_started_nedss ()
{
	wait_until_services_started $NEDSS_HOSTNAME
}
function wait_until_services_started_omsas ()
{
        wait_until_services_started $OMSAS_HOSTNAME
}
function wait_until_services_started_adm1 ()
{
	if [[ "$ADM1_HOSTNAME" != "" ]]
	then
		wait_until_services_started $ADM1_HOSTNAME
	fi
}
function wait_until_services_started_oss2_adm1 ()
{
	wait_until_services_started $OSS2_ADM1_HOSTNAME
}
function wait_until_services_started_adm2 ()
{
        wait_until_services_started $ADM2_HOSTNAME
}
function wait_until_services_started_omservm ()
{
        wait_until_services_started $OMSERVM_HOSTNAME
}
function wait_until_services_started_omservs ()
{
        wait_until_services_started $OMSERVS_HOSTNAME
}
function wait_until_services_started_ebas ()
{
        wait_until_services_started $EBAS_HOSTNAME
}
function wait_until_services_started_mws ()
{
        wait_until_services_started $MWS_HOSTNAME
}
function wait_until_services_started_uas1 ()
{
        wait_until_services_started $UAS1_HOSTNAME
}
function wait_until_services_started_peer1 ()
{
        wait_until_services_started $PEER1_HOSTNAME
}
function wait_until_services_started_eniqe ()
{
        wait_until_services_started $ENIQE_HOSTNAME
}
function wait_until_not_sshable()
{
        local SERVER=$1
        local ATTEMPT=1

	message "INFO: Waiting until $SERVER is down\n" INFO

        while [[ $ATTEMPT -le 1000 ]]
        do
               # message "INFO: Attempt number $ATTEMPT of 1000 to see if $SERVER is down: \n" INFO
                mount_scripts_directory $SERVER noexit > /dev/null 2>&1
                if [[ $? -ne 0 ]]
                then
			message "INFO: OK $SERVER is down\n" INFO
			return 0
                else
                        #message "INFO: $SERVER is still sshable, waiting for 5 seconds before trying again\n"
			sleep 5
                fi
                let ATTEMPT=ATTEMPT+1
        done
        exit 1
}
function wait_until_vm_powered_off ()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

        local VM_NAME="$1"
	local THE_HOSTNAME="$2"

        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
                wait_until_vm_powered_off_vcd "$THE_HOSTNAME"
        else
                wait_until_vm_powered_off_vsphere "$VM_NAME"
        fi
}
function wait_until_vm_powered_off_vcd ()
{
        local VM_NAME="$1"
        local ATTEMPT=1

        message "INFO: Waiting until $VM_NAME is fully powered off: " INFO
	local output=""

        while [[ $ATTEMPT -le 60 ]]
        do
                output=`$VCLOUD_PHP_FUNCTION -f check_power_vm_rest --vmname="$VM_NAME" 2>&1`
                if [[ $? -eq 0 ]] && [[ `echo "$output" | grep "POWERED_OFF"` ]]
                then
                        message "OK\n" INFO
                        return 0
                else
                        sleep 10
                fi
                let ATTEMPT=ATTEMPT+1
        done
	message "ERROR: It hasn't fully powered off even after 10 minutes, is it stuck shutting down? Heres state it was in: $output\n" ERROR
        exit 1
}
function wait_until_vm_powered_off_vsphere ()
{
        local VM_NAME="$1"
        local ATTEMPT=1

        message "INFO: Waiting until $VM_NAME is fully powered off: " INFO
	local output=""

	local check_power_vm_command="$MOUNTPOINT/bin/check_power_vm.pl --vmname '$VM_NAME'"

        while [[ $ATTEMPT -le 60 ]]
        do
		output=`run_vcli_command "$check_power_vm_command" $VCEN_HOSTNAME`
                if [[ $? -eq 0 ]] && [[ `echo "$output" | grep "poweredOff"` ]]
                then
                        message "OK\n" INFO
                        return 0
                else
                        sleep 10
                fi
                let ATTEMPT=ATTEMPT+1
        done
	message "ERROR: It hasn't fully powered off even after 10 minutes, is it stuck shutting down? Heres state it was in: $output\n" ERROR
        exit 1
}
function wait_until_not_pingable()
{
        local SERVER=$1
        local ATTEMPT=1

        message "INFO: Waiting until $SERVER is not pingable: " INFO

        while [[ $ATTEMPT -le 3600 ]]
        do
                #message "INFO: Attempt number $ATTEMPT of 1000 to see if $SERVER is not pingable\n" INFO
                ping -c 1 $SERVER > /dev/null 2>&1
                if [[ $? -ne 0 ]]
                then
                        message "OK\n" INFO
                        return 0
                else
                        #message "INFO: $SERVER is still pingable, waiting for 1 seconds before trying again\n"
                        sleep 1
                fi
                let ATTEMPT=ATTEMPT+1
        done
        exit 1
}
function cleanup_preinirator ()
{
        local PRE_INIRATOR_DIR=$1        
        if [[ "$PRE_INIRATOR_DIR" == "" ]]
	then
		message "ERROR: You can't run this function on its own\n" ERROR
		exit 1
	fi
	message "INFO: Cleaning up the pre inirator directory" INFO
local COMMAND="
rm $PRE_INIRATOR_DIR/*
rmdir $PRE_INIRATOR_DIR
bye"
echo "Command #$COMMAND#"

        $EXPECT - <<EOF
                        set force_conservative 1
                        set timeout 60

                        # autologin variables
                        set prompt ".*(%|#|\\$|>):? $"


                        # set login variables before attempting to login
                        set loggedin "0"
                        set entered_password "0"
                        set exited_unexpectedly "0"
                        set timedout_unexpectedly "0"

                        spawn sftp $DHCP_SERVER_IP
                                expect {
                                        "Are you sure" {
                                                send "yes\r"
                                                exp_continue -continue_timer
                                        }
                                        "assword:" {
                                                send "$DHCP_SERVER_ROOT_PASS\r"
                                                set entered_password "1"
                                                exp_continue -continue_timer
                                        }
                                        -re \$prompt {
                                                set loggedin "1"
                                        }
                                        timeout {
                                                set timedout_unexpectedly "1"
                                        }
                                }
                                if {\$loggedin == "1"} {
                                        send_user "\nLogged in fine, running command\n"
                                        send "$COMMAND\r"
                                        set timeout 10
                                        expect {
                                                "eof" {
                                                        send_user "\nFinished removing preinirator\n"
                                                        exit 0
                                                }
                                        }

                                        expect eof
                                } else {
                                        send_user "\nERROR: Failed to temporary preinirator\n"
                                        exit 1
                              }
EOF
}

function tor_ms_configuration()
{
	# Function used to rollout the configuration onto the MS
	# and to boot the Peer nodes from the Network
	echo "Running command: /proj/lciadm100/cifwk/latest/bin/cicmd torinst_deployment ${runCommand} ${extraCommands}"
	/proj/lciadm100/cifwk/latest/bin/cicmd torinst_deployment ${runCommand} ${extraCommands}
	result=$(echo $?)
	if [[ "$result" != "0" ]]; then
		echo "Error thrown during deployment. Please investigate"
		exit 1
	fi
	# Reboot Peer Nodes from the Nework
	boot_from_network_sc1
	boot_from_network_sc2
	sleep 180
	# Set boot device back to disk
	boot_from_disk_sc1
	boot_from_disk_sc2
}

function tor_peer_node_configuration()
{
	##############################
	# John, apply os patches to scs and start campaign
	##############################
	extraCommands="--reInstallTorinst no --reStartFromStage bootloader_verification"
        echo "Restarting Deployment"
        echo "Running command /proj/lciadm100/cifwk/latest/bin/cicmd torinst_deployment ${runCommand} ${extraCommands}"
	/proj/lciadm100/cifwk/latest/bin/cicmd torinst_deployment ${runCommand} ${extraCommands}
	result=$(echo $?)
	if [[ "$result" != "0" ]]; then
		echo "Error thrown during deployment. Please investigate"
		exit 1
	fi
	# Installing vmware tools on ms, sc's and sfs
        #install_vmware_tools_ms
	#install_vmware_tools_sc1
        #install_vmware_tools_sc2
	#install_vmware_tools_sfs
}

function upgrade_adm ()
{
	requires_variable ADM1_APPL_MEDIA_LOC

	message "INFO: Setting unlimited iops on vms, please wait...: " INFO
	vm_set_iops_all unlimited
	echo "OK"

	update_sentinel_license
	install_usck_and_wranmom
	split_cluster
	system_upgrade
	isolate_and_cutover_system
	remake_cluster
	bmr_install_other_node

	message "INFO: Setting limited iops on vms, please wait...: " INFO
	vm_set_iops_all 300
	echo "OK"
}
function bmr_install_other_node ()
{
	if [[ "$ADM2_HOSTNAME" == "" ]]
        then
                message "INFO: This is a single node deployment, not bmr installing a second node\n" INFO
                return 0
        fi
	ADM1_HASTATUS_OK="no"
        ADM2_HASTATUS_OK="no"

	ADM1_HASTATUS_OUTPUT=`check_hastatus_group Oss $ADM1_HOSTNAME $BACKUP_IP`
        if [[ $? -eq 0 ]]
        then
                ADM1_HASTATUS_OK="yes"
        fi

        ADM2_HASTATUS_OUTPUT=`check_hastatus_group Oss $ADM2_HOSTNAME $ADM2_BACKUP_IP`
        if [[ $? -eq 0 ]]
        then
                ADM2_HASTATUS_OK="yes"
        fi

	if [[ "$ADM1_HASTATUS_OK" == "$ADM2_HASTATUS_OK" ]]
	then
		message "ADM1 hastatus output: $ADM1_HASTATUS_OUTPUT\n" ERROR
		message "ADM2 hastatus output: $ADM2_HASTATUS_OUTPUT\n" ERROR
		message "ERROR: Both sides of the cluster have the Oss group in the same state, only one should be ONLINE, the other not\n" ERROR
		exit 1
	fi
	if [[ $ADM1_HASTATUS_OK == "yes" ]]
	then
		PRIMARY_NODE_PREFIX="ADM1"
		SECONDARY_NODE_PREFIX="ADM2"
	fi
	if [[ $ADM2_HASTATUS_OK == "yes" ]]
        then
		PRIMARY_NODE_PREFIX="ADM2"
		SECONDARY_NODE_PREFIX="ADM1"
        fi

	local PRIMARY_NODE_HOSTNAME=`eval echo \\$${PRIMARY_NODE_PREFIX}_HOSTNAME`

	local SECONDARY_NODE_HOSTNAME=`eval echo \\$${SECONDARY_NODE_PREFIX}_HOSTNAME`
	local SECONDARY_NODE_SERVER_TYPE=`eval echo \\$${SECONDARY_NODE_PREFIX}_SERVER_TYPE`
	local SECONDARY_NODE_ILO_ADDRESS=`eval echo \\$${SECONDARY_NODE_PREFIX}_ILO_ADDRESS`
	local SECONDARY_NODE_ILO_USER=`eval echo \\$${SECONDARY_NODE_PREFIX}_ILO_USER`
	local SECONDARY_NODE_ILO_PASS=`eval echo \\$${SECONDARY_NODE_PREFIX}_ILO_PASS`

	message "INFO: BMR Installing $SECONDARY_NODE_PREFIX $SECONDARY_NODE_HOSTNAME\n" INFO
	create_config_files_adm_bmr_prefix $SECONDARY_NODE_PREFIX
	add_dhcp_client_remote $SECONDARY_NODE_PREFIX
	if [[ "$SECONDARY_NODE_SERVER_TYPE" == "blade" ]]
	then
		boot_from_network_prefix $SECONDARY_NODE_PREFIX
		poweron_server BLADE $SECONDARY_NODE_ILO_ADDRESS $SECONDARY_NODE_ILO_USER $SECONDARY_NODE_ILO_PASS
	else
		boot_from_network_prefix $SECONDARY_NODE_PREFIX
	fi
	install_bmr_prefix $SECONDARY_NODE_PREFIX
	wait_until_sshable $SECONDARY_NODE_HOSTNAME
	set_eeprom_text_prefix $SECONDARY_NODE_PREFIX
	remove_serial_port_prefix $SECONDARY_NODE_PREFIX poweron graceful
	wait_until_sshable $SECONDARY_NODE_HOSTNAME
	add_cluster_node_prefix $SECONDARY_NODE_PREFIX
	wait_for_check_hastatus_group StorLan $PRIMARY_NODE_HOSTNAME
	add_second_root_disk_prefix $SECONDARY_NODE_PREFIX
	switch_sybase_prefix $SECONDARY_NODE_PREFIX $PRIMARY_NODE_PREFIX
	$SSH -qt $UNIQUE_MASTERSERVICE "touch /var/opt/ericsson/sck/log/HA_end_upg_proc_`date +%Y-%m-%d-%H-%M` log"
}
function remake_cluster()
{
	if [[ "$ADM2_HOSTNAME" == "" ]]
        then
                message "INFO: This is a single node deployment, not remaking the cluster\n" INFO
                return 0
        fi
	message "INFO: Going to stop vcs on the non upgraded side, and resync disks on the upgraded side\n" INFO

	# Unmount stale /export/scripts/ mounts after cutover
        setup_passwordless_ssh $BACKUP_IP root shroot12
        $SSH -qt $BACKUP_IP "umount -f /export/scripts/;sleep 5;umount -f /export/scripts/"

        setup_passwordless_ssh $ADM2_BACKUP_IP root shroot12
        $SSH -qt $ADM2_BACKUP_IP "umount -f /export/scripts/;sleep 5;umount -f /export/scripts/"

	local LIVE_BACKUP_IP=""
	LIVE_BACKUP_IP=`get_live_backup_ip`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $LIVE_BACKUP_IP\n" ERROR
                message "ERROR: Something went wrong trying to figure out the live backup ip, see output above\n" ERROR
                exit 1
        fi

	local ISOLATED_BACKUP_IP=""
	ISOLATED_BACKUP_IP=`get_isolated_backup_ip`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_BACKUP_IP\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated backup ip, see output above\n" ERROR
                exit 1
        fi

	mount_scripts_directory $ISOLATED_BACKUP_IP
        $SSH -qt $ISOLATED_BACKUP_IP "bash --login -c \"$MOUNTPOINT/bin/stop_vcs.sh -m $MOUNTPOINT -c '$CONFIG'\""
        if [[ $? -ne 0 ]]
        then
		message "ERROR: Something went wrong stopping vcs, check above\n" ERROR
		exit 1
        fi

	mount_scripts_directory $LIVE_BACKUP_IP
        $SSH -qt $LIVE_BACKUP_IP "$MOUNTPOINT/bin/resync_disks.sh -m $MOUNTPOINT -c '$CONFIG'"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong removing the disk reservations, check above\n" ERROR
                exit 1
        fi
}
function get_live_priv_hostname()
{
        local ISOLATED_PREFIX=""
        ISOLATED_PREFIX=`get_isolated_prefix`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_PREFIX\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated node, see output above\n" ERROR
                exit 1
        fi

        local LIVE_PRIV_HOSTNAME=""
        if [[ "$ISOLATED_PREFIX" == "ADM1" ]]
        then
                LIVE_PRIV_HOSTNAME="${ADM2_HOSTNAME}-priv"
        else
                LIVE_PRIV_HOSTNAME="${ADM1_HOSTNAME}-priv"
        fi
        echo -n "$LIVE_PRIV_HOSTNAME"
}
function get_live_backup_ip ()
{
        local ISOLATED_PREFIX=""
        ISOLATED_PREFIX=`get_isolated_prefix`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_PREFIX\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated node, see output above\n" ERROR
                exit 1
        fi

        local LIVE_BACKUP_IP=""
        if [[ "$ISOLATED_PREFIX" == "ADM1" ]]
        then
		LIVE_BACKUP_IP="$ADM2_BACKUP_IP"
	else
                LIVE_BACKUP_IP="$BACKUP_IP"
        fi
        echo -n "$LIVE_BACKUP_IP"
}
function get_isolated_backup_ip ()
{
	local ISOLATED_PREFIX=""
	ISOLATED_PREFIX=`get_isolated_prefix`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_PREFIX\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated node, see output above\n" ERROR
                exit 1
        fi

	local ISOLATED_BACKUP_IP=""
	if [[ "$ISOLATED_PREFIX" == "ADM1" ]]
        then
                ISOLATED_BACKUP_IP="$BACKUP_IP"
        else
                ISOLATED_BACKUP_IP="$ADM2_BACKUP_IP"
        fi
	echo -n "$ISOLATED_BACKUP_IP"
}
function get_isolated_prefix ()
{
        if [[ "$ADM2_HOSTNAME" == "" ]]
        then
                echo -n "ADM1"
                return 0
        fi

	ADM1_PINGABLE="no"
	ADM2_PINGABLE="no"
	ADM1_HASTATUS_OK="no"
	ADM2_HASTATUS_OK="no"

	ping -c 1 $ADM1_HOSTNAME >> /dev/null 2>&1
	if [[ $? -eq 0 ]]
	then
		ADM1_PINGABLE="yes"
	fi
	ADM1_HASTATUS_OUTPUT=`check_hastatus_group Oss $ADM1_HOSTNAME $BACKUP_IP`
	if [[ $? -eq 0 ]]
	then
		ADM1_HASTATUS_OK="yes"
	fi

	ping -c 1 $ADM2_HOSTNAME >> /dev/null 2>&1
        if [[ $? -eq 0 ]]
        then
                ADM2_PINGABLE="yes"
	fi
	ADM2_HASTATUS_OUTPUT=`check_hastatus_group Oss $ADM2_HOSTNAME $ADM2_BACKUP_IP`
	if [[ $? -eq 0 ]]
	then
		ADM2_HASTATUS_OK="yes"
	fi

	if [[ $ADM1_PINGABLE == "no" ]] && [[ $ADM2_PINGABLE == "yes" ]] && [[ $ADM1_HASTATUS_OK == "yes" ]] && [[ $ADM2_HASTATUS_OK == "yes" ]]
	then
		echo -n "ADM1"
	elif [[ $ADM1_PINGABLE == "yes" ]] && [[ $ADM2_PINGABLE == "no" ]] && [[ $ADM1_HASTATUS_OK == "yes" ]] && [[ $ADM2_HASTATUS_OK == "yes" ]]
	then
		echo -n "ADM2"
	else
		message "ERROR: Couldn't find only one admin server which was pingable, and both admin servers having hastatus looking ok, status below\n" ERROR
		message "ERROR: ADM1 Main IP Pingable: $ADM1_PINGABLE\n" ERROR
		message "ERROR: ADM1 Hastatus OK: $ADM1_HASTATUS_OK\n" ERROR
		message "ERROR: ADM1 Hastatus Output: $ADM1_HASTATUS_OUTPUT\n" ERROR

		message "ERROR: ADM2 Main IP Pingable: $ADM2_PINGABLE\n" ERROR
		message "ERROR: ADM2 Hastatus OK: $ADM2_HASTATUS_OK\n" ERROR
		message "ERROR: ADM2 Hastatus Output: $ADM2_HASTATUS_OUTPUT\n" ERROR
		
		exit 1
	fi
}
function split_cluster ()
{
	if [[ "$ADM2_HOSTNAME" == "" ]]
	then
		message "INFO: This is a single node deployment, not splitting the cluster\n" INFO
		return 0
	fi
	message "INFO: Starting to split the cluster\n" INFO

        mount_scripts_directory $UNIQUE_MASTERSERVICE
        $SSH -qt $UNIQUE_MASTERSERVICE "bash --login -c \"$MOUNTPOINT/bin/split_cluster.sh -m $MOUNTPOINT -c '$CONFIG'\""
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong splitting the cluster, check above\n" ERROR
                exit 1
        fi
	wait_oss_online_internal $BACKUP_IP $ADM1_HOSTNAME
	wait_oss_online_internal $ADM2_BACKUP_IP $ADM2_HOSTNAME
}
function install_usck_and_wranmom ()
{
	requires_variable ADM1_APPL_MEDIA_LOC

	message "INFO: Installing usck and wranmom on ADM1 $ADM1_HOSTNAME\n" INFO

	mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/install_usck_and_wranmom.sh -m $MOUNTPOINT -c '$CONFIG'"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong installing usck and wranmom on $ADM1_HOSTNAME, check above\n" ERROR
                exit 1
        fi

	if [[ "$ADM2_HOSTNAME" != "" ]]
	then

		message "INFO: Installing usck and wranmom on ADM2 $ADM2_HOSTNAME\n" INFO
		mount_scripts_directory $ADM2_HOSTNAME
	        $SSH -qt $ADM2_HOSTNAME "$MOUNTPOINT/bin/install_usck_and_wranmom.sh -m $MOUNTPOINT -c '$CONFIG'"
		if [[ $? -ne 0 ]]
	        then
	                message "ERROR: Something went wrong installing usck and wranmom on $ADM2_HOSTNAME, check above\n" ERROR
	                exit 1
	        fi
	fi
}

function system_upgrade ()
{
	requires_variable MWS_BACKUP_IP
	requires_variable ADM1_APPL_MEDIA_LOC

	message "INFO: Starting the system upgrade\n" INFO

	local ISOLATED_PREFIX=""
        ISOLATED_PREFIX=`get_isolated_prefix`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_PREFIX\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated node, see output above\n" ERROR
                exit 1
        fi

	local ISOLATED_BACKUP_IP=""
	ISOLATED_BACKUP_IP=`get_isolated_backup_ip`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: $ISOLATED_BACKUP_IP\n" ERROR
		message "ERROR: Something went wrong trying to figure out the isolated backup ip, see output above\n" ERROR
		exit 1
	fi

	mount_scripts_directory $ISOLATED_BACKUP_IP
        $SSH -qt $ISOLATED_BACKUP_IP "bash --login -c \"$MOUNTPOINT/bin/system__upgrade.sh -m $MOUNTPOINT -c '$CONFIG'\""
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong running the system upgrade, check above\n" ERROR
                exit 1
        fi
	$SSH -qt $ISOLATED_BACKUP_IP "init 6"
	wait_until_not_pingable $ISOLATED_BACKUP_IP
	wait_until_sshable $ISOLATED_BACKUP_IP

	local ISOLATED_HOSTNAME=`eval echo \\$${ISOLATED_PREFIX}_HOSTNAME`
	wait_oss_online_internal $ISOLATED_BACKUP_IP $ISOLATED_HOSTNAME
}
function isolate_and_cutover_system ()
{
	if [[ "$ADM2_HOSTNAME" == "" ]]
        then
                message "INFO: This is a single node deployment, not isolating and doing cutover\n" INFO
                return 0
        fi

	local LIVE_BACKUP_IP=""
	LIVE_BACKUP_IP=`get_live_backup_ip`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: $LIVE_BACKUP_IP\n" ERROR
                message "ERROR: Something went wrong trying to figure out the live backup ip, see output above\n" ERROR
                exit 1
        fi

	local ISOLATED_BACKUP_IP=""
	ISOLATED_BACKUP_IP=`get_isolated_backup_ip`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $ISOLATED_BACKUP_IP\n" ERROR
                message "ERROR: Something went wrong trying to figure out the isolated backup ip, see output above\n" ERROR
                exit 1
        fi

	local LIVE_PRIV_HOSTNAME=""
	LIVE_PRIV_HOSTNAME=`get_live_priv_hostname`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: $LIVE_PRIV_HOSTNAME\n" ERROR
                message "ERROR: Something went wrong trying to figure out the live priv hostname, see output above\n" ERROR
                exit 1
        fi

	message "INFO: Running the split_cluster isolate_system from $ISOLATED_BACKUP_IP -> $LIVE_PRIV_HOSTNAME\n" INFO
	$SSH -qt $ISOLATED_BACKUP_IP "ssh $LIVE_PRIV_HOSTNAME \"/opt/ericsson/sck/bin/split_cluster isolate_system\""
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong trying to run split_cluster isolate_system, see output above\n" ERROR
                exit 1
        fi

	message "INFO: Running split_cluster rmip_backup from $ISOLATED_BACKUP_IP -> $LIVE_PRIV_HOSTNAME\n" INFO
	$SSH -qt $ISOLATED_BACKUP_IP "ssh $LIVE_PRIV_HOSTNAME \"/opt/ericsson/sck/bin/split_cluster rmip_backup\""
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong trying to run split_cluster rmip_backup, see output above\n" ERROR
                exit 1
        fi

	message "INFO: Running the split_cluster cutover_system from $ISOLATED_BACKUP_IP\n" INFO
	$SSH -qt $ISOLATED_BACKUP_IP "/opt/ericsson/sck/bin/split_cluster cutover_system"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong trying to run split_cluster cutover_system, see output above\n" ERROR
                exit 1
        fi

	message "INFO: Clearing the ldap service on $ISOLATED_BACKUP_IP\n" INFO
	$SSH -qt $ISOLATED_BACKUP_IP "svcadm clear svc:/network/ldap/client:default;svcadm enable -s svc:/network/ldap/client:default"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong trying to clear the ldap/client service, see output above\n" ERROR
                exit 1
        fi

	message "INFO: Running a maintain_ldap on $ISOLATED_BACKUP_IP\n" INFO
	mount_scripts_directory $ISOLATED_BACKUP_IP
	$SSH -qt $ISOLATED_BACKUP_IP "$MOUNTPOINT/bin/maintain_ldap.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong running the maintain ldap command, see above for errors\n" ERROR
                exit 1
        fi
	reboot_ldap_clients
}

function reboot_ldap_clients ()
{
	if [[ "$ADM2_HOSTNAME" == "" ]]
        then
                message "INFO: This is a single node deployment, not rebooting ldap clients\n" INFO
                return 0
        fi

	message "INFO: Rebooting ldap clients\n" INFO
	## Kick off reboots
	if [[ "$PEER1_HOSTNAME" != "" ]]
        then
                $SSH -qt $PEER1_HOSTNAME "init 6"
                wait_until_not_pingable $PEER1_HOSTNAME
        fi
	if [[ "$UAS1_HOSTNAME" != "" ]]
	then
		$SSH -qt $UAS1_HOSTNAME "init 6"
		wait_until_not_pingable $UAS1_HOSTNAME
	fi
	if [[ "$EBAS_HOSTNAME" != "" ]]
        then
                $SSH -qt $EBAS_HOSTNAME "init 6"
                wait_until_not_pingable $EBAS_HOSTNAME
        fi

	## Wait for the clients to boot back up
	if [[ "$PEER1_HOSTNAME" != "" ]]
        then
                wait_until_sshable $PEER1_HOSTNAME
        fi
        if [[ "$UAS1_HOSTNAME" != "" ]]
        then
                wait_until_sshable $UAS1_HOSTNAME
        fi
        if [[ "$EBAS_HOSTNAME" != "" ]]
        then
                wait_until_sshable $EBAS_HOSTNAME
        fi
}

function jumpstart_check ()
{
	local SERIAL_CONNECTION_STRING=$1
	#local TIMEOUT=$2
 message "INFO: SERIAL_CONNECTION is $SERIAL_CONNECTION_STRING" INFO
$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 1800
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
	expect {
		"The highlighted entry will be executed automatically" {
			send "\r"
		}
		"Oracle Solaris 11.2 X86 Automated Install" {
			send_user "\nDetected jumpstart starting\n"
		}
		"Packages completed:" {
			send_user "\nDetected linux kickstarting\n"
			exit 0
		}
		"Automated Installation started" {
			send_user "\nDetected solaris software installation\n"
			exit 0
		}
		"ERROR: core.sh failed" {
			sleep 10
			send_user "\nDetected core.sh failure, exiting automated installation\n"
			exit 1
		}
		"Failed to find any suitable disks for root mirror" {
			sleep 10
			send_user "\nDetected install failure, exiting automated installation\n"
			exit 1
		}
		"What type of terminal are you using" {
			send_user "\nDetected interactive solaris install, this shouldn't appear, exiting\n"
			exit 1
		}
		"Select a Language" {
			send_user "\nDetected interactive solaris install, this shouldn't appear, exiting\n"
			exit 1
		}
		"Could not find matching rule in rules.ok" {
			send_user "\nDetected an issue with getting the rules.ok file, this shouldn't appear\n"
			exit 99
                }
		timeout {
			send_user "\nERROR: Didn't detect the jumpstart starting after 20 minutes, check your network settings on your server\n"
			exit 98
		}
		"Script aborted.." {
			send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
			exit 1
		}
		eof {
			send_user "\nERROR (Auto Installer): Unexpectedly exited from console connection\n"
			exit 97
		}
	}
}
EOF
EXIT_CODE=$?
return $EXIT_CODE

}

function jumpstart_loop()
{
	# While loop checks the returned exit code from the jumpstart_check function if 366 
	# is returned then we need to try again, as it seems to have timed out or iunable to 
	# find the rules.ok
	local SERIAL_CONNECTION_STRING=$1
	local PREFIX=$2
	local i=1
        message "INFO: (JUMPSTART $PREFIX) Will attempt the jumpstart for $PREFIX, try $i of 3\n" INFO
	while [ $i -lt 4 ]; do
		jumpstart_check "$SERIAL_CONNECTION_STRING"
		local EXIT_CODE=$?
		if [ $EXIT_CODE -eq 99 ] || [ $EXIT_CODE -eq 98 ] || [ $EXIT_CODE -eq 97 ]; then
			if [ $EXIT_CODE -eq 99 ]; then
				ERROR="Could not find matching rule in rules.ok"
			elif [ $EXIT_CODE -eq 98 ]; then
				ERROR="Timeout issue, did not detect string \"Automated Installation started\""
			elif [ $EXIT_CODE -eq 97 ]; then
				ERROR="Console Connection closed unexpectedly\""
			fi
			i=$[$i+1]
			if [ $i -ge 4 ]; then
				retry_message "\nERROR: (JUMPSTART $PREFIX) There seems to have been an issue with the jumpstart\n" ERROR
				retry_message "ERROR: (JUMPSTART $PREFIX) $ERROR\n" ERROR
                                retry_message "-------------------------------------------------------------------------\n" ERROR
                                retry_message "ERROR: (JUMPSTART $PREFIX) There are no more retries available. Please investigate the issue\n" ERROR
                                retry_message "ERROR: (JUMPSTART $PREFIX) and retry the installation\n" ERROR
                                retry_message "-------------------------------------------------------------------------\n\n" ERROR
				EXIT_CODE=1
				break
			fi
			retry_message "\nERROR: (JUMPSTART $PREFIX): There seems to have been an issue with the jumpstart\n" ERROR
			retry_message "ERROR: (JUMPSTART $PREFIX) $ERROR\n" ERROR
                        retry_message "-------------------------------------------------------------------------\n" WARNING
                        retry_message "WARNING: (JUMPSTART $PREFIX) Will reattempt the jumpstart, try $i of 3\n" WARNING
                        retry_message "-------------------------------------------------------------------------\n\n" WARNING
			boot_from_network_prefix $PREFIX
		else
			break
		fi
	done
	return $EXIT_CODE
}

function cleanup_dhcp ()
{
        local PREFIX=$1
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
            remove_dhcp_client_remote $X_HOSTNAME
            clear_lock /tmp/${PREFIX}.lock remote $ACTUAL_DHCP_SERVER_IP
        fi
}

function install_adm1 ()
{
        local PREFIX=$1 # can be ADM1 or OSS2_ADM1
        local SMALL_PREFIX=`echo "$1" | tr '[:upper:]' '[:lower:]'`
        local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`

	local PRE_INIRATOR_DIR="/JUMP/preinirators/${PARENT_BASHPID}_${X_HOSTNAME}/"

	### Build up serial connection string
	local SERIAL_CONNECTION_STRING=""
	if [[ "$X_SERVER_TYPE" == "blade" ]]
	then
		SERIAL_CONNECTION_STRING=`create_blade_connection_string $PREFIX`
	else
		SERIAL_CONNECTION_STRING=`create_vsp_connection_string $PREFIX nongraceful`
		if [[ $? -ne 0 ]]
	        then
			message "$SERIAL_CONNECTION_STRING\n" ERROR
	                exit 1
	        fi
	fi
	# loop through the boot sequence to check for certain error if found try the jump again
	jumpstart_loop "$SERIAL_CONNECTION_STRING" $PREFIX
	local EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
	echo "1" > /tmp/$PARENT_BASHPID/status/${SMALL_PREFIX}_initial_jump_complete.status
	cleanup_preinirator $PRE_INIRATOR_DIR
        cleanup_dhcp $PREFIX
        exit 1
fi

boot_from_disk_${SMALL_PREFIX}

# Clean up the preinirator
$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
	"#   inirator successfully executed"
	{
		exit 0
	}
	"ERROR: core.sh failed" {
                sleep 10
                send_user "\nDetected core.sh failure, exiting automated installation\n"
                exit 1
        }
	"Failed to find any suitable disks for root mirror" {
		sleep 10
		send_user "\nDetected install failure, exiting automated installation\n"
		exit 1
	}
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
	eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

if [[ $? -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
	echo "1" > /tmp/$PARENT_BASHPID/status/${SMALL_PREFIX}_initial_jump_complete.status
	cleanup_preinirator $PRE_INIRATOR_DIR
        cleanup_dhcp $PREFIX
        exit 1
fi

cleanup_preinirator $PRE_INIRATOR_DIR
cleanup_dhcp $PREFIX

if [[ "$BEHIND_GATEWAY" == "yes" ]]
then
        update_md_conf $X_HOSTNAME
fi

if [[ "$ADM1_SERVER_TYPE" != "blade" ]]
then
	disable_iofence_clusterini_${SMALL_PREFIX}
fi

sm_bios_workaround $X_HOSTNAME

$SSH -n $X_HOSTNAME "rm /.ssh/authorized_keys" > /dev/null

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "#    root_disk_control started"
        {
                send_user "Detected software installation completed\n"
		exit 0
        }
        "ERROR: core.sh failed" {
                sleep 10
                send_user "\nDetected core.sh failure, exiting automated installation\n"
                exit 1
        }
	"Failed to find any suitable disks for root mirror" {
		sleep 10
		send_user "\nDetected install failure, exiting automated installation\n"
		exit 1
	}
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

if [[ $? -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
	echo "1" > /tmp/$PARENT_BASHPID/status/${SMALL_PREFIX}_initial_jump_complete.status
        exit 1
fi

echo "0" > /tmp/$PARENT_BASHPID/status/${SMALL_PREFIX}_initial_jump_complete.status

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "Completed software installation"
        {
                send_user "Detected software installation completed\n"
        }
	"ERROR: core.sh failed" {
		sleep 10
		send_user "\nDetected core.sh failure, exiting automated installation\n"
		exit 1
	}
	"Failed to find any suitable disks for root mirror" {
		sleep 10
		send_user "\nDetected install failure, exiting automated installation\n"
		exit 1
	}
        "Entering ERIC Bootstrap Stage cleanup"
        {
                set timeout 3600
                expect "console login" {
			send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
                                set timeout 300
                                expect {
                                        "The system is coming down" {
                                                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
                                                set timeout -1
                                                expect "console login:" {
                                                        send_user "Automation: Completed\n"
                                                        exit 0
                                                }
                                        }
                                	timeout {
                                        	send_user "\nDidn't detect extra reboot\n"
						exit 0
                                	}
			}
                }
        }
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF
	if [[ $? -eq 0 ]]
	then
		message "INFO: Installation completed successfully\n" INFO
	else
		message "ERROR: Installation did not complete successfully\n" ERROR
	        exit 1
	fi
}

function check_vsp_port_prefix ()
{
	local SERVER_PREFIX=$1
	local GRACEFUL="$2"
	local X_SERVER_TYPE=`eval echo \\$${SERVER_PREFIX}_SERVER_TYPE`
	
	if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi

	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
	local X_VM_NAME=`eval echo \\$${SERVER_PREFIX}_VM_NAME`
        requires_variable X_VSP_SERVER

	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
        message "INFO: Checking virtual serial port settings on $X_HOSTNAME, please wait....: " INFO
        X_VSP_PORT=`get_vsp_port_prefix $SERVER_PREFIX $GRACEFUL`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the vsp port for $X_HOSTNAME, see further output below\n" ERROR
                message "---------------------------------------------------------\n" ERROR
                message "$X_VSP_PORT" ERROR
                message "---------------------------------------------------------\n" ERROR
                exit 1
        fi
        message "OK\n" INFO
}
function check_vsp_port_omsas ()
{
	check_vsp_port_prefix OMSAS $1
}
function check_vsp_port_omservm ()
{
	check_vsp_port_prefix OMSERVM $1
}
function check_vsp_port_omservs ()
{
	check_vsp_port_prefix OMSERVS $1
}
function check_vsp_port_ebas ()
{
	check_vsp_port_prefix EBAS $1
}
function check_vsp_port_mws ()
{
	check_vsp_port_prefix MWS $1
}
function check_vsp_port_nedss ()
{
	check_vsp_port_prefix NEDSS $1
}
function check_vsp_port_adm1 ()
{
	check_vsp_port_prefix ADM1 $1
}
function check_vsp_port_oss2_adm1 ()
{
	check_vsp_port_prefix OSS2_ADM1 $1
}
function check_vsp_port_adm2 ()
{
	check_vsp_port_prefix ADM2 $1
}
function check_vsp_port_uas1()
{
	check_vsp_port_prefix UAS1 $1
}
function check_vsp_port_peer1()
{
	check_vsp_port_prefix PEER1 $1
}
function check_vsp_port_eniqe ()
{
	check_vsp_port_prefix ENIQE $1
}
function check_vsp_port_cep ()
{
        check_vsp_port_prefix CEP $1
}
function check_vsp_port_eniqs ()
{
	check_vsp_port_prefix ENIQS $1
}
function check_vsp_port_eniqsc ()
{
	check_vsp_port_prefix ENIQSC $1
}
function check_vsp_port_eniqse ()
{
	check_vsp_port_prefix ENIQSE $1
}
function check_vsp_port_eniqsr1 ()
{
	check_vsp_port_prefix ENIQSR1 $1
}
function check_vsp_port_eniqsr2 ()
{
	check_vsp_port_prefix ENIQSR2 $1
}
function check_vsp_port_son_vis ()
{
	check_vsp_port_prefix SON_VIS $1
}
function poweron_sfs ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$SFS_HOSTNAME" "$SFS_VSP_SERVER" "$SFS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the sfs\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$SFS_HOSTNAME"
}
function poweron_adm1 ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
	VM_NAME=`get_unique_vm_name "$ADM1_HOSTNAME" "$ADM1_VSP_SERVER" "$ADM1_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the adm1\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
	poweronvm "$VM_NAME" "$ADM1_HOSTNAME"
}

function poweron_adm2 ()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$ADM2_HOSTNAME" "$ADM2_VSP_SERVER" "$ADM2_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the adm2\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$ADM2_HOSTNAME"
}

function poweron_omsas()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$OMSAS_HOSTNAME" "$OMSAS_VSP_SERVER" "$OMSAS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the omsas\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$OMSAS_HOSTNAME"
}

function poweron_omservm()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$OMSERVM_HOSTNAME" "$OMSERVM_VSP_SERVER" "$OMSERVM_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the omservm\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$OMSERVM_HOSTNAME"
}

function poweron_omservs()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$OMSERVS_HOSTNAME" "$OMSERVS_VSP_SERVER" "$OMSERVS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for omservs\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$OMSERVS_HOSTNAME"
}

function poweron_ebas()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$EBAS_HOSTNAME" "$EBAS_VSP_SERVER" "$EBAS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the ebas\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$EBAS_HOSTNAME"
}
function poweron_mws()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$MWS_HOSTNAME" "$MWS_VSP_SERVER" "$MWS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the mws\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$MWS_HOSTNAME"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't power on mws\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        else
                message "INFO: Powered on mws\n" INFO
                message "$VM_NAME\n" INFO
        fi
}

function poweron_uas1()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$UAS1_HOSTNAME" "$UAS1_VSP_SERVER" "$UAS1_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the uas1\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$UAS1_HOSTNAME"
}
function poweron_peer1()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$PEER1_HOSTNAME" "$PEER1_VSP_SERVER" "$PEER1_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the peer1\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$PEER1_HOSTNAME"
}
function poweron_nedss()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$NEDSS_HOSTNAME" "$NEDSS_VSP_SERVER" "$NEDSS_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the nedss\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$NEDSS_HOSTNAME"
}
function poweron_netsim()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$NETSIM_HOSTNAME" "$NETSIM_VSP_SERVER" "$NETSIM_VM_NAME"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the netsim\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        poweronvm "$VM_NAME" "$NETSIM_HOSTNAME"
}

function install_omsas()
{

        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$OMSAS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string OMSAS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string OMSAS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING\n" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" OMSAS
        local EXIT_CODE=$?

        
if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp OMSAS
        exit 1
fi

boot_from_disk_omsas

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"COMINF SW Distribution found"
		{
                        send_user "\nDetected Automated Installation finished successfully"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF

local EXIT_CODE=$?
cleanup_dhcp OMSAS
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        exit 1
fi

sm_bios_workaround $OMSAS_HOSTNAME

	$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
	"The highlighted entry will be booted automatically"
	{
		send "yes\r"
	}
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
	"INFO Script /ericsson/ocs/bin/conf_cominf_serv.sh started"
        {
		send_user "\nCOMINF inirator started\n"
		while {"1" == "1"} {
			expect {
				"values correct" {
                                        send "y\r"
                                        break
                                }
				"Enter IP address of the NTP Source" {
                                        set timeout 5
                                        expect {
                                                "Enter IP address of the NTP Source" {
                                                        set timeout 23400
                                                        send "$OMSERVM_IP_ADDR\r"
                                                }
                                                timeout {
                                                        set timeout 23400
                                                        send "$OMSERVM_IP_ADDR\r"
                                                }
                                        }
                                }
				-re { DNS Domain Name.*: } {
					send "$DNSDOMAIN\r"
				}
				"LDAP Domain Name" {
					send "$LDAPDOMAIN\r"
				}
				"Enter LDAP Directory Manager DN:" {
					sleep 1
					send "\r"
				}
				"Enter LDAP Replication ID" {
					sleep 1
					send "3\r"
				}
				-re {Enter a unique name.*masterservice} {
					send "$UNIQUE_MASTERSERVICE\r"
				}
				-re {Enter IP address.*masterservice} {
					send "$VIP_OSSFS\r"
				}
				"Manager password:" {
					send "$dm_pass\r"
					expect "Re-enter password:" {
						send "$dm_pass\r"
					}
				}
				"migration password:" {
					send "$ns_data_migration_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_migration_pass\r"
					}
				}
				"maintenence password:" {
					send "$ns_data_maintenence_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_maintenence_pass\r"
					}
				}
				"proxyagent password:" {
					send "$proxyagent_pass\r"
					expect "Re-enter passwor" {
						sleep 1
						send "$proxyagent_pass\r"
					}
				}
			}
		}
		expect "INSTALLATION for infra_omsas COMPLETE"
		expect "console login"
		send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
		set timeout 300
		expect {
	        	"The system is coming down" {
	        	        send_user "\nDetected machine rebooting again, waiting for next boot.\n"
		                set timeout -1
		                expect "console login:" {
					send_user "Automation: Completed\n"
		                        exit 0
		                }
		        }
			timeout {
		        	send_user "\nDidn't detect extra reboot\n"
				exit 0
			}
		}
		exit 0
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

	if [[ $? -eq 0 ]]
	then
		message "INFO: Installation completed successfully\n" INFO
	else
		message "ERROR: Installation did not complete successfully\n" ERROR
	        exit 1
	fi
}
function install_omservs()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$OMSERVS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string OMSERVS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string OMSERVS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING\n" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" OMSERVS
        local EXIT_CODE=$?


if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp OMSERVS
        exit 1
fi


boot_from_disk_omservs


$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"COMINF SW Distribution found"
		{
                        send_user "\nDetected Automated Installation finished successfully"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF

local EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp OMSERVS
        exit 1
fi

sm_bios_workaround $OMSERVS_HOSTNAME



        $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
	exp_internal -f /debug.log 1
        expect {
        "The highlighted entry will be booted automatically"
        {
                send "yes\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
	"INFO Script /ericsson/ocs/bin/conf_cominf_serv.sh started"
        {
                send_user "\n COMINF inirator started \n"
		while {"1" == "1"} {
			expect {
				"values correct" {
                                        send "y\r"
                                        break
                                }
				"Enter Deployment type" {
					set timeout 5
					expect {
						"Enter Deployment type" {
							set timeout 23400
							send "Enhanced\r"
						}
						timeout {
							set timeout 23400
							send "Enhanced\r"
						}
					}
				}
				"Is this a GEO redundant setup" {
                                        send "n\r"
                                }
				"Enter IP address of the NTP Source" {
                                        send "$NTP_SOURCE\r"
                                }
				"DHCP on this Machine" {
					send "n\r"
				}
				-re { DNS Domain Name.*: } {
                                        send "$DNSDOMAIN\r"
                                }
				"Enter O&M Services Primary server Hostname" {
					send "$OMSERVM_HOSTNAME\r"
				}
				"Enter O&M Services Primary server IPV6" {
                                        send "$OMSERVM_IPV6_ADDR\r"
                                }
				"Enter O&M Services Primary server IP" {
					send "$OMSERVM_IP_ADDR\r"
				}
				"Enter IPV6 prefix" {
					sleep 1
					send "$OMSERVS_IPV6_PREFIX\r"
				}
				"LDAP Domain Name" {
					send "$LDAPDOMAIN\r"
				}
				"Enter LDAP Directory Manager DN" {
					sleep 1
					send "\r"
				}
				-re {Enter a unique name.*masterservice} {
                                        send "$UNIQUE_MASTERSERVICE\r"
                                }
                                -re {Enter IP address.*masterservice} {
                                        send "$VIP_OSSFS\r"
                                }
				"Manager password:" {
					send "$dm_pass\r"
					expect "Re-enter password:" {
						send "$dm_pass\r"
					}
				}
				"migration password:" {
					send "$ns_data_migration_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_migration_pass\r"
					}
				}
				"maintenence password:" {
					send "$ns_data_maintenence_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_maintenence_pass\r"
					}
				}
				"proxyagent password:" {
					send "$proxyagent_pass\r"
					expect "Re-enter password:" {
						send "$proxyagent_pass\r"
					}
				}
			}
		}
		expect "INSTALLATION for om_serv_slave COMPLETE"
		expect "console login"
		send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
		set timeout 300
		expect {
			"The system is coming down" {
				send_user "\nDetected machine rebooting again, waiting for next boot.\n"
				set timeout -1
				expect "console login:" {
					send_user "Automation: Completed\n"
					exit 0
				}
			}
			timeout {
				send_user "\nDidn't detect extra reboot\n"
				exit 0
			}
		}
		exit 0
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
                cleanup_dhcp OMSERVS
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                cleanup_dhcp OMSERVS
                exit 1
        fi
}
function install_omservm()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$OMSERVM_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string OMSERVM`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string OMSERVM nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING\n" ERROR
                        exit 1
                fi
        fi
	
	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" OMSERVM
        local EXIT_CODE=$?
	
if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp OMSERVM
        exit 1
fi

boot_from_disk_omservm


$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"COMINF SW Distribution found"
		{
                        send_user "\nAutomated Installation finished successfully"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF


local EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp OMSERVM
        exit 1
fi


sm_bios_workaround $OMSERVM_HOSTNAME



	$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
	"The highlighted entry will be booted automatically"
	{
                send "yes\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
	}
	"INFO Script /ericsson/ocs/bin/conf_cominf_serv.sh started"
	{
		send_user "\n COMINF inirator started \n"
		while {"1" == "1"} {
			expect {
				"values correct" {
                                        send "y\r"
                                        break
                                }
				"Is this a GEO redundant setup" {
					send "n\r"
				}
                                "Enter Deployment type" {
                                        set timeout 5
                                        expect {
                                                "Enter Deployment type" {
                                                        set timeout 23400
                                                        send "Enhanced\r"
                                                }
                                                timeout {
                                                        set timeout 23400
                                                        send "Enhanced\r"
                                                }
                                        }
                                }
				"Enter IP address of the NTP Source" {
                                        send "$NTP_SOURCE\r"
                                }
				"DHCP on this Machine" {
					send "n\r"
				}
				-re { DNS Domain Name.*: } {
                                        send "$DNSDOMAIN\r"
                                }
				"Enter O&M Services Secondary server Hostname" {
					send "$OMSERVS_HOSTNAME\r"
				}
				"Enter O&M Services Secondary server IPV6" {
					send "$OMSERVS_IPV6_ADDR\r"
				}
				"Enter O&M Services Secondary server IP" {
					send "$OMSERVS_IP_ADDR\r"
				}
				"Enter IPV6 prefix" {
                                        sleep 1
                                        send "$OMSERVM_IPV6_PREFIX\r"
                                }
				"LDAP Domain Name" {
					send "$LDAPDOMAIN\r"
				}
				"Enter LDAP Directory Manager DN" {
					sleep 1
					send "\r"
				}
				-re {Enter a unique name.*masterservice} {
                                        send "$UNIQUE_MASTERSERVICE\r"
                                }
                                -re {Enter IP address.*masterservice} {
                                        send "$VIP_OSSFS\r"
                                }
				"Manager password:" {
					send "$dm_pass\r"
					expect "Re-enter password:" {
						send "$dm_pass\r"
					}
				}
				"migration password:" {
					send "$ns_data_migration_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_migration_pass\r"
					}
				}
				"maintenence password:" {
					send "$ns_data_maintenence_pass\r"
					expect "Re-enter password:" {
						send "$ns_data_maintenence_pass\r"
					}
				}
				"proxyagent password:" {
					send "$proxyagent_pass\r"
					expect "Re-enter password:" {
						send "$proxyagent_pass\r"
					}
				}
			}
		}
		expect "INSTALLATION for om_serv_master COMPLETE"
		expect "console login"
		send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
		set timeout 300
		expect {
		        "The system is coming down" {
		                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
		                set timeout -1
		                expect "console login:" {
					send_user "Automation: Completed\n"
					exit 0
		                }
		        }
			timeout {
			        send_user "\nDidn't detect extra reboot\n"
				exit 0
			}
		}
	exit 0
        }
	eof {
		send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
		exit 1
        }
        }
}
EOF

	if [[ $? -eq 0 ]]
	then
		message "INFO: Installation completed successfully\n" INFO
                cleanup_dhcp OMSERVM
	else
		message "ERROR: Installation did not complete successfully\n" ERROR
                cleanup_dhcp OMSERVM
	        exit 1
	fi
}

function install_uas1_initial_only ()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string UAS1`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string UAS1 nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" UAS1
        local EXIT_CODE=$?


if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp UAS1
        exit 1
fi

boot_from_disk_uas1


$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"Started LDAP Client Configuration"
		{
			send_user "\nStarted LDAP Client Configuration on UAS server"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF

local EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp UAS1
        exit 1
fi

sm_bios_workaround $UAS1_HOSTNAME



                $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "The highlighted entry will be booted automatically"
        {
                send "\r"
        }
	"Escape character is"
	{
		send "\r"
	}
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "LDAP DS Server IP address" {
		send "\r"
		send_user "\nExiting now as UAS initial jump is complete\n"
                exit 0
        }
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
	}
}
EOF

        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
                cleanup_dhcp UAS1
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                cleanup_dhcp UAS1
                exit 1
        fi

}

function install_peer1_initial_only ()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string PEER1`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string PEER1 nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" PEER1
        local EXIT_CODE=$?


if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp PEER1
        exit 1
fi

boot_from_disk_peer1

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"Automated Installation finished successfully"
		{
                        send_user "\nDetected Automated Installation finished successfully"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF

local EXIT_CODE=$?
cleanup_dhcp PEER1
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        exit 1
fi

sm_bios_workaround $PEER1_HOSTNAME



                $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "The highlighted entry will be booted automatically"
        {
                send "\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "LDAP DS Server IP address" {
                send_user "\nExiting now as peer initial jump is complete\n"
                exit 0
        }
        "Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
	}
}
EOF

        if [[ $? -eq 0 ]]
        then
                message "INFO: Installation completed successfully\n" INFO
        else
                message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi

}


function install_ebas_initial_only ()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string EBAS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string EBAS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" EBAS
        local EXIT_CODE=$?



if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp EBAS
        exit 1
fi

boot_from_disk_ebas

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "Automated Installation finished successfully"
        {
        send_user "\nDetected Automated Installation finished successfully"
                exit 0
        }
	}               
}
EOF
exit 0

local EXIT_CODE=$?
cleanup_dhcp EBAS
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        exit 1
fi

sm_bios_workaround $EBAS_HOSTNAME



                $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "The highlighted entry will be booted automatically"
        {
                send "\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "Automated Installation finished successfully"
        {
                send_user "\nDetected Automated Installation finished successfully"
                exit 0
        }
        "LDAP DS Server IP address,"{
                send_user "\nExiting now as EBAS initial jump is complete\n"
                exit 0
        }
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
	}
}
EOF

        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi

}


function create_vsp_connection_string ()
{
	local SERVER_PREFIX=$1
	local GRACEFUL=$2

	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	
	X_VSP_PORT=`get_vsp_port_prefix $SERVER_PREFIX $GRACEFUL`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Couldn't get the vsp port for this server\n" ERROR
		message "$X_VSP_PORT" ERROR
		exit 1
	fi

	cat << EOF
spawn telnet $X_VSP_SERVER $X_VSP_PORT
EOF
}


function create_blade_connection_string ()
{
	local SERVER_PREFIX=$1

	local X_ILO_ADDRESS=`eval echo \\$${SERVER_PREFIX}_ILO_ADDRESS`
	local X_ILO_USER=`eval echo \\$${SERVER_PREFIX}_ILO_USER`
	local X_ILO_PASS=`eval echo \\$${SERVER_PREFIX}_ILO_PASS`

	local ILO_PROMPT="->"

	local CONNECT_COMMAND="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l $X_ILO_USER $X_ILO_ADDRESS"

	cat << EOF
spawn $CONNECT_COMMAND
set connected 1
	while { \$connected < 2 } {
		expect {
			"assword:" {
				send "$X_ILO_PASS\r"
			}
			-re $ILO_PROMPT {
				send_user "\nFinished setting infinite timeout on ilo\n"
				send "cd /map1/config1/\r"
				expect -re $ILO_PROMPT {
					send "set oemhp_timeout=0\r"
				}
				expect -re $ILO_PROMPT {
					send_user "\nFinished setting infinite timeout on ilo\n"
				}
				send "stop /system1/oemhp_vsp1\r"
				send_user "Stopping vsp\n"
				sleep 5
				send_user "Connecting to vsp\n"
				send "vsp\r"
				expect {
					"Requested service is unavailable" {
						send_user "VSP is not available\n"
						send "reset /map1\r"
						send_user "Reset ilo after failed stop\n"
						sleep 120
						send_user "Try to reconnect to iLO\n"
						spawn $CONNECT_COMMAND
						expect {
							"assword:" {
							        send "$X_ILO_PASS\r"
						        }
							expect {
								-re $ILO_PROMPT {
									send_user "Try to stop VSP again\n"
									send "stop /system1/oemhp_vsp1\r"
									sleep 5
									send_user "Try to start VSP again\n"
									send "vsp\r"
									expect {
										"Requested service is unavailable" {
											send_user "Problem with VSP even after reset. Exiting and investigate\n"
											exit 1
										}
										"to return to the CLI Session" {
											send_user "VSP connected\n"
											set connected 10
											break
										}
									}
								}
							}
						}
					}
					"Virtual Serial Port is not enabled" {
						send_user "\nCouldn't connect to the vsp, going to retry once more in 60 seconds\n"
						sleep 60
						send_user "Try to start VSP again\n"
						send "vsp\r"
						expect {
							"to return to the CLI Session" {
								send_user "VSP connected\n"
								set connected 10
								break
							}
						}
					}
					"to return to the CLI Session" {
						send_user "VSP connected\n"
						set connected 10
						break
				        }
				}
			}
		}
	}
EOF

}

######

function install_eniqe ()
{
	install_eniq ENIQE
}
function install_cep ()
{
	install_eniq CEP
}
function install_eniqs ()
{
	install_eniq ENIQS
}
function install_eniqsc ()
{
        install_eniq ENIQSC
}
function install_eniqse ()
{
        install_eniq ENIQSE
}
function install_eniqsr1 ()
{
        install_eniq ENIQSR1
}
function install_eniqsr2 ()
{
        install_eniq ENIQSR2
}
function install_son_vis ()
{
        install_eniq SON_VIS
}

function install_eniq()
{
	. $MOUNTPOINT/bin/function_install_eniq
}
#######
function install_uas1 ()
{
	#install_uas1_initial_only
	mount_scripts_directory $UAS1_HOSTNAME
	local output=""
	output=`$SSH -qt $UAS1_HOSTNAME "ls /opt/CTXSmf/sbin/"`
        if [[ `echo "$output" | grep "ctxlsdcfg"` ]]
        then
                message "INFO: UAS Seems to have already been completed, not doing console based steps\n" INFO
                return 0
        fi
	
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string UAS1`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string UAS1 nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi
        ###############################
	wait_until_services_started_uas1
	mount_scripts_directory $UAS1_HOSTNAME
	#$SSH -qt $UAS1_HOSTNAME "$MOUNTPOINT/bin/copy_rootca_to_uas.sh -m $MOUNTPOINT -c '$CONFIG'"
	$SSH -qt $UAS1_HOSTNAME "TERM=xterm; $MOUNTPOINT/bin/sol11_copy_rootca_to_uas_grant.sh -m $MOUNTPOINT -c '$CONFIG'"
	$SSH -qt $UAS1_HOSTNAME "/usr/sbin/eeprom console=ttya"
	$SSH -qt $UAS1_HOSTNAME "reboot"

	$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
         "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
	"Secondary LDAP DS Server IP address" {
		send "$OMSERVS_IP_ADDR\r"
	}
	"Secondary LDAP Fully Qualified Hostname" {
		send "$OMSERVS_FQHN\r"
	}
        "LDAP DS Server IP address" {
                send "$OMSERVM_IP_ADDR\r"
        }
        "LDAP Fully Qualified Hostname" {
                send "$OMSERVM_FQHN\r"
        }
        "LDAP Domain Name" {
                send "$LDAPDOMAIN\r"
        }
        "LDAP proxyagent DN" {
                send "\r"
        }
        "LDAP Proxy Password" {
                send "$proxyagent_pass\r"
        }
        "Certificate Database Password" {
                send "\r"
        }
        "LDAP Client Profile" {
                send "\r"
        }
	"Full path to valid PKS root CA certificate" {
		send "/var/tmp/rootca.cer\r"
	}
	"Do you want to configure a secondary LDAP server now" {
		send "y\r"
	}
	"Is all information correct; YES or NO" {
		send "YES\r"
	}
        "Completed software installation"
        {
                send_user "Detected software installation completed\n"
        }
	"Script aborted.."
	{
		send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
		exit 1
	}
                "INSTALLATION for appserv COMPLETE" {
			send_user "Detected appserv installation completed\n"
			expect "console login:" {
				send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
				set timeout 150
				expect {
				        "The system is coming down" {
				                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
				                set timeout -1
				                expect "console login:" {
				                        send_user "Automation: Completed\n"
							exit 0
				                }
				        }
					timeout {
			        		send_user "\nDidn't detect extra reboot\n"
						exit 0
					}
				}
			}
                }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi
}
function install_peer1 ()
{
        #install_peer1_initial_only
        mount_scripts_directory $PEER1_HOSTNAME
	output=`$SSH -qt $PEER1_HOSTNAME "cat /etc/hosts"`
        if [[ `echo "$output" | grep "$OMSERVM_FQHN"` ]]
        then
                message "INFO: Peer1 Seems to have already been completed, not doing console based steps\n" INFO
                return 0
        fi

        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string PEER1`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string PEER1 nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi
        ###############################
	wait_until_services_started_peer1
        mount_scripts_directory $PEER1_HOSTNAME
        $SSH -qt $PEER1_HOSTNAME "$MOUNTPOINT/bin/copy_rootca_to_uas.sh -m $MOUNTPOINT -c '$CONFIG'"
        $SSH -qt $PEER1_HOSTNAME "/usr/sbin/eeprom console=ttya"
        $SSH -qt $PEER1_HOSTNAME "reboot"

        $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
         "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "Secondary LDAP DS Server IP address" {
                send "$OMSERVS_IP_ADDR\r"
        }
        "Secondary LDAP Fully Qualified Hostname" {
                send "$OMSERVS_FQHN\r"
        }
        "LDAP DS Server IP address" {
                send "$OMSERVM_IP_ADDR\r"
        }
        "LDAP Fully Qualified Hostname" {
                send "$OMSERVM_FQHN\r"
        }
        "LDAP Domain Name" {
                send "$LDAPDOMAIN\r"
        }
        "LDAP proxyagent DN" {
                send "\r"
        }
        "LDAP Proxy Password" {
                send "$proxyagent_pass\r"
        }
        "Certificate Database Password" {
                send "\r"
        }
        "LDAP Client Profile" {
                send "\r"
        }
        "Full path to valid PKS root CA certificate" {
                send "/var/tmp/rootca.cer\r"
        }
        "Do you want to configure a secondary LDAP server now" {
                send "y\r"
        }
        "Is all information correct; YES or NO" {
                send "YES\r"
        }
        "Completed software installation"
        {
                send_user "Detected software installation completed\n"
        }
        "Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
	"Entering ERIC Bootstrap Stage cleanup" {
                        expect "console login:" {
                                send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
                                set timeout 150
                                expect {
                                        "The system is coming down" {
                                                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
                                                set timeout -1
                                                expect "console login:" {
                                                        send_user "Automation: Completed\n"
                                                        exit 0
                                                }
                                        }
                                        timeout {
                                                send_user "\nDidn't detect extra reboot\n"
                                                exit 0
                                        }
                                }
                        }
	}
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

        if [[ $? -eq 0 ]]
        then
                message "INFO: Installation completed successfully\n" INFO
        else
                message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi
}
function set_eeprom_text_adm1 ()
{
	set_eeprom_text_prefix ADM1
}
function set_eeprom_text_oss2_adm1 ()
{
	set_eeprom_text_prefix OSS2_ADM1
}
function set_eeprom_text_adm2 ()
{
	set_eeprom_text_prefix ADM2
}
function set_eeprom_text_uas1 ()
{
	set_eeprom_text_prefix UAS1
}
function set_eeprom_text_peer1 ()
{
	set_eeprom_text_prefix PEER1
}
function set_eeprom_text_omsas ()
{
	set_eeprom_text_prefix OMSAS
}
function set_eeprom_text_omservs ()
{
	set_eeprom_text_prefix OMSERVS
}
function set_eeprom_text_omservm ()
{
	set_eeprom_text_prefix OMSERVM
}
function set_eeprom_text_nedss ()
{
	set_eeprom_text_prefix NEDSS
}
function set_eeprom_text_ebas ()
{
	set_eeprom_text_prefix EBAS
}
function set_eeprom_text_mws ()
{
	set_eeprom_text_prefix MWS
}
function set_eeprom_text_eniqe ()
{
	set_eeprom_text_prefix ENIQE
}
function set_eeprom_text_eniqs ()
{
	set_eeprom_text_prefix ENIQS
}
function set_eeprom_text_eniqsc ()
{
	set_eeprom_text_prefix ENIQSC
}
function set_eeprom_text_eniqse ()
{
	set_eeprom_text_prefix ENIQSE
}
function set_eeprom_text_eniqsr1 ()
{
	set_eeprom_text_prefix ENIQSR1
}
function set_eeprom_text_eniqsr2 ()
{
	set_eeprom_text_prefix ENIQSR2
}
function set_eeprom_text_son_vis ()
{
	set_eeprom_text_prefix SON_VIS
}

function set_eeprom_text_prefix ()
{
	local PREFIX=$1
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
        local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`

	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi

	mount_scripts_directory $X_HOSTNAME
	message "INFO: Setting the eeprom console to text\n" INFO
	$SSH -qt $X_HOSTNAME "$MOUNTPOINT/bin/set_eeprom_text.sh" 2>/dev/null
}
function install_ebas ()
{
    
	mount_scripts_directory $EBAS_HOSTNAME

	local output=""
        output=`$SSH -qt $EBAS_HOSTNAME "cat /etc/hosts"`
        if [[ `echo "$output" | grep "$OMSERVM_FQHN"` ]]
        then
                message "INFO: EBAS Seems to have already been completed, not doing console based steps\n" INFO
                return 0
        fi

        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string EBAS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string EBAS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi
        ###############################
	wait_until_services_started_ebas
	mount_scripts_directory $EBAS_HOSTNAME
	$SSH -qt $EBAS_HOSTNAME "TERM=xterm; $MOUNTPOINT/bin/sol11_copy_rootca_to_uas_grant.sh -m $MOUNTPOINT -c '$CONFIG'"
	#$SSH -qt $EBAS_HOSTNAME "$MOUNTPOINT/bin/copy_rootca_to_uas.sh -m $MOUNTPOINT -c '$CONFIG'"
	$SSH -qt $EBAS_HOSTNAME "eeprom console=ttya;reboot"

	 $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
         "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "Secondary LDAP DS Server IP address" {
                send "$OMSERVS_IP_ADDR\r"
        }
        "Secondary LDAP Fully Qualified Hostname" {
                send "$OMSERVS_FQHN\r"
        }
        "LDAP DS Server IP address" {
                send "$OMSERVM_IP_ADDR\r"
        }
        "LDAP Fully Qualified Hostname" {
                send "$OMSERVM_FQHN\r"
        }
        "LDAP Domain Name" {
                send "$LDAPDOMAIN\r"
        }
        "LDAP proxyagent DN" {
                send "\r"
        }
        "LDAP Proxy Password" {
                send "$proxyagent_pass\r"

        }
        "Certificate Database Password" {
                send "\r"
        }
        "LDAP Client Profile" {
                send "\r"
        }
        "Full path to valid PKS root CA certificate" {
                send "/var/tmp/rootca.cer\r"
        }
        "Do you want to configure a secondary LDAP server now" {
                send "y\r"
        }
        "Is all information correct; YES or NO" {
                send "YES\r"
        }
        "Completed software installation"
        {
                send_user "Detected software installation completed\n"
        }
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
                "Entering ERIC Bootstrap Stage cleanup" {
                        expect "console login:" {
				send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
                                set timeout 300
                                expect {
                                        "The system is coming down" {
                                                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
                                                set timeout -1
                                                expect "console login:" {
                                                        send_user "Automation: Completed\n"
                                                        exit 0
                                                }
                                        }
                                	timeout {
                                       		send_user "\nDidn't detect extra reboot\n"
						exit 0
                                	}
				}
                        }
                }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF
        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi

}
function install_mws ()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$MWS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string MWS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string MWS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" MWS
        local EXIT_CODE=$?



if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp MWS
        exit 1
fi

boot_from_disk_mws

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
        "Automated Installation finished successfully"
        {
        send_user "\nDetected Automated Installation finished successfully"
                exit 0
        }
	"Script aborted.."
        {
                send_user "\nERROR: Detected the installation aborting, exiting automated installation\n"
                exit 1
        }
	}               
}
EOF
        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
                cleanup_dhcp MWS
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                cleanup_dhcp MWS
                exit 1
        fi

}

function install_adm2 ()
{
	install_bmr_prefix ADM2
}

function install_bmr_prefix ()
{
	local PREFIX=$1
	local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`

        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string $PREFIX`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string $PREFIX nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" $PREFIX
        local EXIT_CODE=$?


if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp $PREFIX
        exit 1
fi

boot_from_disk_prefix $PREFIX

	$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
	"The highlighted entry will be booted automatically"
        {
                send "yes\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
        "Completed software installation"
        {
                send_user "\nDetected software installation completed\n"
        }
                "console login" {
                        send_user "Automation: Completed\n"
                        exit 0
                }
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

	if [[ $? -eq 0 ]]
	then
		message "INFO: Installation completed successfully\n" INFO
                cleanup_dhcp $PREFIX
	else
		message "ERROR: Installation did not complete successfully\n" ERROR
                cleanup_dhcp $PREFIX
	        exit 1
	fi
}
function install_nedss ()
{
        ### Build up serial connection string
        local SERIAL_CONNECTION_STRING=""
        if [[ "$NEDSS_SERVER_TYPE" == "blade" ]]
        then
                SERIAL_CONNECTION_STRING=`create_blade_connection_string NEDSS`
        else
                SERIAL_CONNECTION_STRING=`create_vsp_connection_string NEDSS nongraceful`
                if [[ $? -ne 0 ]]
                then
                        message "$SERIAL_CONNECTION_STRING" ERROR
                        exit 1
                fi
        fi

	# loop through the boot sequence to check for certain error if found try the jump again
        jumpstart_loop "$SERIAL_CONNECTION_STRING" NEDSS
        local EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]
then
	message "ERROR: Installation did not complete successfully\n" ERROR
        cleanup_dhcp NEDSS
        exit 1
fi

boot_from_disk_nedss

$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 20000
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
		"Entering ERIC Bootstrap Stage cleanup"
		{
			send_user "\nDetected Entering ERIC Bootstrap Stage cleanup"
			exit 0
		}
		eof {
                	send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                	exit 1
        	}
	}
}
EOF

local EXIT_CODE=$?
cleanup_dhcp NEDSS
if [[ $EXIT_CODE -ne 0 ]]
then
        message "ERROR: Installation did not complete successfully\n" ERROR
        exit 1
fi

sm_bios_workaround $NEDSS_HOSTNAME



        $EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 23400
$SERIAL_CONNECTION_STRING
while {"1" == "1"} {
        expect {
	"The highlighted entry will be booted automatically"
        {
                send "\r"
        }
        "Custom JumpStart"
        {
                send_user "\nDetected jumpstart starting\n"
        }
        "Automated Installation started"
        {
                send_user "\nDetected solaris software installation\n"
        }
	"console login"
	{
		send "\r"
		send_user "Automation: Completed\n"
		exit 0
	}
        "Entering ERIC Bootstrap Stage cleanup"
        {
                send_user "\nDetected software installation completed\n"
                expect "console login" {
			send_user "\nDetected first machine console login prompt, waiting for a while to see if second login prompt appears\n"
                                set timeout 300
                                expect {
                                        "The system is coming down" {
                                                send_user "\nDetected machine rebooting again, waiting for next boot.\n"
                                                set timeout -1
                                                expect "console login:" {
                                                        send_user "Automation: Completed\n"
                                                        exit 0
                                                }
                                        }
                                	timeout {
                                        	send_user "\nDidn't detect extra reboot\n"
						exit 0
                                	}
				}
                }
	}
        eof {
                send_user "ERROR (Auto Installer): Unexpectedly exited from console connection\n"
                exit 1
        }
        }
}
EOF

        if [[ $? -eq 0 ]]
        then
		message "INFO: Installation completed successfully\n" INFO
        else
		message "ERROR: Installation did not complete successfully\n" ERROR
                exit 1
        fi
}
function add_to_cleanup ()
{
        cleanup_file="$1"
	mkdir -p /tmp/$PARENT_BASHPID/cleanup_list > /dev/null 2>&1
	touch /tmp/$PARENT_BASHPID/cleanup_list/cleanup.list > /dev/null 2>&1
        echo "$cleanup_file" >> /tmp/$PARENT_BASHPID/cleanup_list/cleanup.list
}

function get_lock ()
{
	local lockfile=$1
	local lock_type=$2
	local remote_server=$3
	local timeoutvalue=$4
	local removeontimeout=$5

	if [[ "$lock_type" == "local" ]]
	then
		$MOUNTPOINT/bin/get_lock.sh -f $lockfile -p $PARENT_BASHPID -t $timeoutvalue -r $removeontimeout
	elif [[ "$lock_type" == "remote" ]]
	then
		mount_scripts_directory $remote_server
		$SSH -qt $remote_server "$MOUNTPOINT/bin/get_lock.sh -f $lockfile -p $PARENT_BASHPID -t $timeoutvalue -r $removeontimeout"
	fi

	if [[ $? -eq 0 ]]
	then
		add_to_cleanup "$lockfile $lock_type $remote_server"
	else
		return 1
	fi

}
function clear_lock ()
{
	local lockfile=$1
        local lock_type=$2
        local remote_server=$3
	if [[ "$lock_type" == "local" ]]
        then
		$MOUNTPOINT/bin/clear_lock.sh -f $lockfile -p $PARENT_BASHPID
	elif [[ "$lock_type" == "remote" ]]
        then
		mount_scripts_directory $remote_server
                $SSH -qt $remote_server "$MOUNTPOINT/bin/clear_lock.sh -f $lockfile -p $PARENT_BASHPID" 2> /dev/null
        fi
}
function remove_dhcp_client_remote ()
{
	local SERVER=$1
	requires_variable DHCP_SERVER
        requires_variable DHCP_SERVER_IP
        requires_variable DHCP_SERVER_ROOT_PASS
	message "INFO: Removing dhcp config on $DHCP_SERVER\n" INFO
        local ATTEMPT=1
        while [[ $ATTEMPT -le 3 ]]
        do
                ssh $DHCP_SERVER_IP "/ericsson/autoinstall/bin/manage_dhcp_clients.bsh -a remove -c $SERVER -N"
                if [[ $? -ne 0 ]]
                then
                        message "INFO: DHCP profile deletion failed \n" INFO
                        message "INFO: Sleeping for 300 seconds before trying again\n" INFO
                        sleep 300
                else
                        return 0
                fi
                let ATTEMPT=ATTEMPT+1
        done


}
function add_dhcp_client_remote()
{
	local CLIENT_TYPE=$1
	local CLIENT_HOSTNAME=`eval echo \\$${CLIENT_TYPE}_HOSTNAME`
        local CLIENT_IP_ADDR=`eval echo \\$${CLIENT_TYPE}_IP_ADDR`
        local CLIENT_MAC_ADDR=`eval echo \\$${CLIENT_TYPE}_MAC_ADDR`

	local CLIENT_FILE="$LOCAL_CONFIG_DIR/${CLIENT_HOSTNAME}_${PARENT_BASHPID}.txt"

	requires_variable DHCP_SERVER
	requires_variable DHCP_SERVER_IP
	requires_variable DHCP_SERVER_ROOT_PASS
	requires_variable ACTUAL_DHCP_SERVER
        requires_variable ACTUAL_DHCP_SERVER_IP
        requires_variable ACTUAL_DHCP_SERVER_ROOT_PASS

	message "INFO: Setting up dhcp config on $DHCP_SERVER\n" INFO
	setup_passwordless_ssh $DHCP_SERVER_IP root $DHCP_SERVER_ROOT_PASS
	setup_passwordless_ssh $ACTUAL_DHCP_SERVER_IP root $ACTUAL_DHCP_SERVER_ROOT_PASS
	chmod -R 755 $LOCAL_CONFIG_MOUNT
	share_local_filesystem $LOCAL_CONFIG_MOUNT

	## Figure out which ip to mount the config from
	local RUNNING_HOST=""
        RUNNING_HOST=`get_pingable_host $DHCP_SERVER_IP root $DHCP_SERVER_ROOT_PASS "$RUNNING_HOSTS"`
        if [[ $? -ne 0 ]]
        then
                echo "$RUNNING_HOST"

		# Do some cleanup
		rm -rf $CLIENT_FILE

		if [[ "$CLIENT_TYPE" == "ADM1" ]]
		then
                	echo "1" > /tmp/$PARENT_BASHPID/status/adm1_initial_jump_complete.status
		fi

                if [[ "$CLIENT_TYPE" == "OSS2_ADM1" ]]
		then
			echo "1" > /tmp/$PARENT_BASHPID/status/oss2_adm1_initial_jump_complete.status
		fi

                exit 1
        fi

	## Get the general lock to avoid too many adding of clients breaking things
	local DHCP_LOCK="/tmp/$PARENT_BASHPID/locks/dhcp.lock"
	get_lock $DHCP_LOCK local na 7200 yes

	## If its an oss box behind a gateway, we must first get the special lock to avoid conflicts of jumps of eg an ossmaster
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		get_lock /tmp/${CLIENT_TYPE}.lock remote $ACTUAL_DHCP_SERVER_IP 7200 yes
	fi

	## Mount up the config directory on the MWS from the appropriate ip
	ssh $DHCP_SERVER_IP "mkdir -p /tmp/mounted_configs/${PARENT_BASHPID};mount -o vers=3 $RUNNING_HOST:$LOCAL_CONFIG_MOUNT /tmp/mounted_configs/${PARENT_BASHPID}"

	local ATTEMPT=1
	while [[ $ATTEMPT -le 3 ]]
	do
		message "INFO: Attempt number $ATTEMPT to add the server as a dhcp client\n" INFO

		CLIENT_CONFIG_FILE="/tmp/mounted_configs/${PARENT_BASHPID}/${CLIENT_HOSTNAME}_${PARENT_BASHPID}.txt"
		if [[ `ssh $DHCP_SERVER_IP "grep CLIENT_KICK_LOC $CLIENT_CONFIG_FILE"` ]]
		then
			MANAGE_DHCP_SCRIPT="/ericsson/jumpstart/bin/manage_linux_dhcp_clients.bsh"
		else
			MANAGE_DHCP_SCRIPT="/ericsson/autoinstall/bin/manage_dhcp_clients.bsh"
		fi


		local DHCP_OUTPUT=`eval ssh $DHCP_SERVER_IP '$MANAGE_DHCP_SCRIPT -a add -f $CLIENT_CONFIG_FILE -N'`

		if [[ $? -ne 0 ]]
		then
			if [[ `echo $DHCP_OUTPUT | grep -i 'Duplicated profile name' | wc -l ` -ne 0 ]]
			then
				message "INFO: Found Duplicate profile. So deleting it.\n" INFO
				remove_dhcp_client_remote ${CLIENT_HOSTNAME}	
			fi
			message "ERROR: There was an error adding this server as a dhcp client, please check the error above\n" ERROR
		else
			ssh $DHCP_SERVER_IP "umount /tmp/mounted_configs/${PARENT_BASHPID};rm -rf /tmp/mounted_configs/${PARENT_BASHPID}"
                        message "INFO: Listing the DHCP clients that are added on MWS\n" INFO 
                        ssh $DHCP_SERVER_IP '/ericsson/autoinstall/bin/manage_dhcp_clients.bsh -a list -c ${CLIENT_HOSTNAME}' 
			clear_lock $DHCP_LOCK local na
			rm -rf $CLIENT_FILE
			jsbsh $CLIENT_HOSTNAME $CLIENT_IP_ADDR $CLIENT_MAC_ADDR
			return 0
		fi
		if [[ $ATTEMPT -ne 3 ]]
		then
			message "INFO: Sleeping for 300 seconds before trying again\n" INFO
			sleep 300 
		fi

		let ATTEMPT=ATTEMPT+1
	done

	# Something went wrong adding the client, do cleanup
	ssh $DHCP_SERVER_IP "umount /tmp/mounted_configs/${PARENT_BASHPID};rm -rf /tmp/mounted_configs/${PARENT_BASHPID}"
	message "ERROR: Wasn't able to add the server as a dhcp client after 3 attempts\n" ERROR
	clear_lock $DHCP_LOCK local na
	rm -rf $CLIENT_FILE

	if [[ "$CLIENT_TYPE" == "ADM1" ]]
	then
		echo "1" > /tmp/$PARENT_BASHPID/status/adm1_initial_jump_complete.status
	fi

        if [[ "$CLIENT_TYPE" == "OSS2_ADM1" ]]
        then
                echo "1" > /tmp/$PARENT_BASHPID/status/oss2_adm1_initial_jump_complete.status
        fi

	if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
		clear_lock /tmp/${CLIENT_TYPE}.lock remote $ACTUAL_DHCP_SERVER_IP 7200 yes
	fi
	exit 1

}

function jsbsh ()
{
        if [[ "$BEHIND_GATEWAY" != "yes" ]]
        then
                return
        fi

        INPUT_HOSTNAME=$1
        INPUT_IP=$2
        INPUT_MAC=$3
        DHCP_FILE="/etc/dhcp/dhcpd.conf"
        AI_LOCK="/tmp/$PARENT_BASHPID/locks/ai.lock"
        get_lock $AI_LOCK local na 7200 yes

        # Check DHCP on gateway and ensure it is enabled
        /sbin/service dhcpd status | grep running
        if [ `/bin/echo $?` -eq 0 ]
        then
            echo " DHCP running "
        else
            # Just make a backup of dhcpd.conf file if exists
            # Build our own dhcpd.conf file
            # Enable the dhcpd service
            # Start the dhcpd service
            # If dhcp service still not up, bail out.
            echo "DHCP Not running "
            if [ -f $DHCP_FILE ]
            then
                cp $DHCP_FILE $DHCP_FILE`date '+-%H%M%S-%d%m%Y'`
            fi
            DHCP_OUTPUT=`cat <<EOF
allow booting;
ignore unknown-clients;
default-lease-time 1600;
max-lease-time 7200;
use-host-decl-names on;
ddns-update-style none;

option grubmenu code 150 = text;

subnet 192.168.0.0 netmask 255.255.0.0 {
 option routers 192.168.0.1;
 option domain-name "vts.com";
 option domain-name-servers 192.168.0.1;
 option time-servers 192.168.0.1;
}
EOF
`
                echo "$DHCP_OUTPUT" > $DHCP_FILE
                chkconfig dhcpd on
                service dhcpd restart
                if [ `/bin/echo $?` -eq 0 ]
                then
                    echo "DHCP enabled on gateway now"
                else
                    echo "Bail out and message goes here"
                fi
            fi

        # ADD DHCP client on gateway


        if [ ! -d $DHCP_AI ] ; then
            mkdir $DHCP_AI
        fi

        ####    Create the DHCP client file ex : /etc/dhcp_ai/ebas.conf and
        ####    Update the Gateway DHCP conf file : /etc/dhcp/dhcpd.conf

        BOOTFILE=`echo $INPUT_MAC | /bin/sed 's/://g'`
        BOOTFILE="01${BOOTFILE}.bios"
        CLIENT_OUTPUT=`cat <<EOF
host ${INPUT_HOSTNAME} {
    hardware ethernet ${INPUT_MAC};
    fixed-address ${INPUT_IP};
    next-server ${ACTUAL_DHCP_SERVER_IP};
    filename "${BOOTFILE}";
}
EOF
`
        echo "${CLIENT_OUTPUT}" > ${DHCP_AI}/${INPUT_HOSTNAME}.conf

        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.last
        cat /etc/dhcp/dhcpd.conf.last | egrep -v '^include' > /etc/dhcp/dhcpd.conf
        FILE_LIST=`find $DHCP_AI -name '*.conf'`
        for FILE in ${FILE_LIST} ; do
                echo "include \"${FILE}\";" >> /etc/dhcp/dhcpd.conf
        done

        #Restart dhcp
        service dhcpd restart

        clear_lock $AI_LOCK local na
}

function add_dhcp_client_remote_adm1 ()
{
	add_dhcp_client_remote ADM1
}
function add_dhcp_client_remote_oss2_adm1 ()
{
	add_dhcp_client_remote OSS2_ADM1
}
function add_dhcp_client_remote_ebas ()
{
        add_dhcp_client_remote EBAS
}
function add_dhcp_client_remote_mws ()
{
        add_dhcp_client_remote MWS
}
function add_dhcp_client_remote_adm2 ()
{
        add_dhcp_client_remote ADM2
}
function add_dhcp_client_remote_omservm ()
{
	add_dhcp_client_remote OMSERVM
}
function add_dhcp_client_remote_omservs ()
{
        add_dhcp_client_remote OMSERVS
}
function add_dhcp_client_remote_omsas ()
{
	add_dhcp_client_remote OMSAS
}
function add_dhcp_client_remote_nedss ()
{
        add_dhcp_client_remote NEDSS
}
function add_dhcp_client_remote_uas1 ()
{
        add_dhcp_client_remote UAS1
}
function add_dhcp_client_remote_peer1 ()
{
        add_dhcp_client_remote PEER1
}
function add_dhcp_client_remote_eniqe ()
{
	add_dhcp_client_remote ENIQE
}
function add_dhcp_client_remote_cep ()
{
	add_dhcp_client_remote CEP
}
function add_dhcp_client_remote_eniqs ()
{
        add_dhcp_client_remote ENIQS
}
function add_dhcp_client_remote_eniqsc ()
{
        add_dhcp_client_remote ENIQSC
}
function add_dhcp_client_remote_eniqse ()
{
        add_dhcp_client_remote ENIQSE
}
function add_dhcp_client_remote_eniqsr1 ()
{
        add_dhcp_client_remote ENIQSR1
}
function add_dhcp_client_remote_eniqsr2 ()
{
        add_dhcp_client_remote ENIQSR2
}
function add_dhcp_client_remote_son_vis ()
{
        add_dhcp_client_remote SON_VIS
}

function create_config_files_uas1 ()
{
	requires_variable UAS1_JUMP_LOC
	requires_variable UAS1_AI_SERVICE
	requires_variable UAS1_OM_LOC
	requires_variable UAS1_APPL_MEDIA_LOC

	local CLIENT_TYPE="UAS1"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${UAS1_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

	JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$UAS1_HOSTNAME
CLIENT_IP_ADDR@$UAS1_IP_ADDR
CLIENT_NETMASK@$UAS1_NETMASK
CLIENT_MAC_ADDR@$UAS1_MAC_ADDR
IPV6_PARAMETER@$UAS1_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$UAS1_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$UAS1_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$UAS1_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$UAS1_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$UAS1_JUMP_LOC
CLIENT_JUMP_DESC@$UAS1_AI_SERVICE
CLIENT_AI_SERVICE@$UAS1_AI_SERVICE
CLIENT_OM_LOC@$UAS1_OM_LOC
CLIENT_APPL_TYPE@cominf_install
CLIENT_APPL_MEDIA_LOC@$UAS1_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=oss_client config=appserv nowin
EOF
`

	echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "INFO: DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_peer1 ()
{
	requires_variable PEER1_JUMP_LOC
	requires_variable PEER1_AI_SERVICE
	requires_variable PEER1_OM_LOC
	requires_variable PEER1_APPL_MEDIA_LOC

        local CLIENT_TYPE="PEER1"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${PEER1_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""


        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$PEER1_HOSTNAME
CLIENT_IP_ADDR@$PEER1_IP_ADDR
CLIENT_NETMASK@$PEER1_NETMASK
CLIENT_MAC_ADDR@$PEER1_MAC_ADDR
IPV6_PARAMETER@$PEER1_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$PEER1_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$PEER1_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$PEER1_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$PEER1_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$PEER1_JUMP_LOC
CLIENT_JUMP_DESC@$PEER1_AI_SERVICE
CLIENT_AI_SERVICE@$PEER1_AI_SERVICE
CLIENT_OM_LOC@$PEER1_OM_LOC
CLIENT_APPL_TYPE@ossrc
CLIENT_APPL_MEDIA_LOC@$PEER1_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install label_disks inst_type=oss_client config=peer rmirr nowin
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "INFO: DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}


function create_config_files_ebas ()
{
	requires_variable EBAS_JUMP_LOC
	requires_variable EBAS_AI_SERVICE
	requires_variable EBAS_OM_LOC

        local CLIENT_TYPE="EBAS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${EBAS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$EBAS_HOSTNAME
CLIENT_IP_ADDR@$EBAS_IP_ADDR
CLIENT_NETMASK@$EBAS_NETMASK
CLIENT_MAC_ADDR@$EBAS_MAC_ADDR
IPV6_PARAMETER@$EBAS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$EBAS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$EBAS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$EBAS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$EBAS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$EBAS_JUMP_LOC
CLIENT_JUMP_DESC@$EBAS_AI_SERVICE
CLIENT_AI_SERVICE@$EBAS_AI_SERVICE
CLIENT_OM_LOC@$EBAS_OM_LOC
CLIENT_APPL_TYPE@solonly
CLIENT_INSTALL_PARAMS@- install inst_type=oss_client config=ebas nowin
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_mws ()
{
	requires_variable MWS_JUMP_LOC
	requires_variable MWS_AI_SERVICE
	requires_variable MWS_OM_LOC

        local CLIENT_TYPE="MWS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${MWS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$MWS_HOSTNAME
CLIENT_IP_ADDR@$MWS_IP_ADDR
CLIENT_NETMASK@$MWS_NETMASK
CLIENT_MAC_ADDR@$MWS_MAC_ADDR
IPV6_PARAMETER@$MWS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$MWS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$MWS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$MWS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$MWS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$MWS_JUMP_LOC
CLIENT_JUMP_DESC@$MWS_AI_SERVICE
CLIENT_AI_SERVICE@$MWS_AI_SERVICE
CLIENT_OM_LOC@$MWS_OM_LOC
CLIENT_APPL_TYPE@solonly
CLIENT_INSTALL_PARAMS@- install inst_type=solonly config=mws label_disks nowin
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_omsas ()
{
	requires_variable OMSAS_JUMP_LOC
	requires_variable OMSAS_AI_SERVICE
	requires_variable OMSAS_OM_LOC
	#requires_variable OMSAS_APPL_MEDIA_LOC

	local CLIENT_TYPE="OMSAS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${OMSAS_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

	JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$OMSAS_HOSTNAME
CLIENT_IP_ADDR@$OMSAS_IP_ADDR
CLIENT_NETMASK@$OMSAS_NETMASK
CLIENT_MAC_ADDR@$OMSAS_MAC_ADDR
IPV6_PARAMETER@$OMSAS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$OMSAS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$OMSAS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$OMSAS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$OMSAS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$OMSAS_JUMP_LOC
CLIENT_JUMP_DESC@$OMSAS_AI_SERVICE
CLIENT_AI_SERVICE@$OMSAS_AI_SERVICE
CLIENT_OM_LOC@$OMSAS_OM_LOC
CLIENT_APPL_TYPE@cominf_install
CLIENT_APPL_MEDIA_LOC@$OMSAS_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=cominf config=infra_omsas nowin
EOF
`

	echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_nedss ()
{
	requires_variable NEDSS_JUMP_LOC
	requires_variable NEDSS_AI_SERVICE
	requires_variable NEDSS_OM_LOC
	requires_variable NEDSS_APPL_MEDIA_LOC

        local CLIENT_TYPE="NEDSS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${NEDSS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$NEDSS_HOSTNAME
CLIENT_IP_ADDR@$NEDSS_IP_ADDR
CLIENT_NETMASK@$NEDSS_NETMASK
CLIENT_MAC_ADDR@$NEDSS_MAC_ADDR
IPV6_PARAMETER@$NEDSS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$NEDSS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$NEDSS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$NEDSS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$NEDSS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$NEDSS_JUMP_LOC
CLIENT_JUMP_DESC@$NEDSS_AI_SERVICE
CLIENT_AI_SERVICE@$NEDSS_AI_SERVICE
CLIENT_OM_LOC@$NEDSS_OM_LOC
CLIENT_APPL_TYPE@solonly
CLIENT_APPL_MEDIA_LOC@$NEDSS_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=cominf config=smrs_slave nowin
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_omservm ()
{
	requires_variable OMSERVM_JUMP_LOC
	requires_variable OMSERVM_AI_SERVICE
	requires_variable OMSERVM_OM_LOC
	#requires_variable OMSERVM_APPL_MEDIA_LOC

	local CLIENT_TYPE="OMSERVM"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${OMSERVM_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

	JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$OMSERVM_HOSTNAME
CLIENT_IP_ADDR@$OMSERVM_IP_ADDR
CLIENT_NETMASK@$OMSERVM_NETMASK
CLIENT_MAC_ADDR@$OMSERVM_MAC_ADDR
IPV6_PARAMETER@$OMSERVM_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$OMSEVM_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$OMSERVM_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$OMSERVM_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$OMSERVM_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$OMSERVM_JUMP_LOC
CLIENT_JUMP_DESC@$OMSERVM_AI_SERVICE
CLIENT_AI_SERVICE@$OMSERVM_AI_SERVICE
CLIENT_OM_LOC@$OMSERVM_OM_LOC
CLIENT_APPL_TYPE@cominf_install
CLIENT_APPL_MEDIA_LOC@$OMSERVM_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=cominf config=om_serv_master nowin
EOF
`
	echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_omservs ()
{
	requires_variable OMSERVS_JUMP_LOC
	requires_variable OMSERVS_AI_SERVICE
        requires_variable OMSERVS_OM_LOC
        #requires_variable OMSERVS_APPL_MEDIA_LOC

        local CLIENT_TYPE="OMSERVS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${OMSERVS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$OMSERVS_HOSTNAME
CLIENT_IP_ADDR@$OMSERVS_IP_ADDR
CLIENT_NETMASK@$OMSERVS_NETMASK
CLIENT_MAC_ADDR@$OMSERVS_MAC_ADDR
IPV6_PARAMETER@$OMSERVS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$OMSERVS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$OMSERVS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$OMSERVS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$OMSERVS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$OMSERVS_JUMP_LOC
CLIENT_JUMP_DESC@$OMSERVS_AI_SERVICE
CLIENT_AI_SERVICE@$OMSERVS_AI_SERVICE
CLIENT_OM_LOC@$OMSERVS_OM_LOC
CLIENT_APPL_TYPE@cominf_install
CLIENT_APPL_MEDIA_LOC@$OMSERVS_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=cominf config=om_serv_slave nowin
EOF
`
        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_adm2 ()
{
	create_config_files_adm_bmr_prefix ADM2
}

function create_config_files_adm_bmr_prefix()
{
	local PREFIX=$1
	local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
	local X_IP_ADDR=`eval echo \\$${PREFIX}_IP_ADDR`
	local X_NETMASK=`eval echo \\$${PREFIX}_NETMASK`
	local X_MAC_ADDR=`eval echo \\$${PREFIX}_MAC_ADDR`
	local X_IPV6_PARAMETER=`eval echo \\$${PREFIX}_IPV6_PARAMETER`
	local X_CLIENT_HOSTNAME_V6=`eval echo \\$${PREFIX}_CLIENT_HOSTNAME_V6`
	local X_CLIENT_IP_ADDR_V6=`eval echo \\$${PREFIX}_CLIENT_IP_ADDR_V6`
	local X_ROUTER_IP_ADDR_V6=`eval echo \\$${PREFIX}_ROUTER_IP_ADDR_V6`
	local X_ARCH=`eval echo \\$${PREFIX}_ARCH`
	local X_JUMP_LOC=`eval echo \\$${PREFIX}_JUMP_LOC`
	local X_JUMP_DESC=`eval echo \\$${PREFIX}_AI_SERVICE`
	local X_AI_SERVICE=`eval echo \\$${PREFIX}_AI_SERVICE`
	local X_OM_LOC=`eval echo \\$${PREFIX}_OM_LOC`
	local X_EXTRA_BOOTARGS="$ADM2_EXTRA_BOOTARGS"

	requires_variable X_JUMP_LOC
	requires_variable X_AI_SERVICE
	requires_variable X_OM_LOC

        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${X_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""
	JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$X_HOSTNAME
CLIENT_IP_ADDR@$X_IP_ADDR
CLIENT_NETMASK@$X_NETMASK
CLIENT_MAC_ADDR@$X_MAC_ADDR
IPV6_PARAMETER@$X_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$X_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$X_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$X_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$X_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_APPL_TYPE@solonly
CLIENT_JUMP_LOC@$X_JUMP_LOC
CLIENT_JUMP_DESC@$X_AI_SERVICE
CLIENT_AI_SERVICE@$X_AI_SERVICE
CLIENT_OM_LOC@$X_OM_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=ossrc bmr_inst $X_EXTRA_BOOTARGS
EOF
`

	echo "$JUMP_OUTPUT" > $CONFIG_FILE
	message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_adm1()
{
        create_config_files_internal ADM1
}
function create_config_files_oss2_adm1()
{        
        create_config_files_internal OSS2_ADM1
}
function create_config_files_internal()
{
	local PREFIX=$1 # can be ADM1 or OSS2_ADM1
        local SMALL_PREFIX=`echo "$1" | tr '[:upper:]' '[:lower:]'`
        

        local X_JUMP_LOC=`eval echo \\$${PREFIX}_JUMP_LOC`
	local X_JUMP_DESC=`eval echo \\$${PREFIX}_AI_SERVICE`
	local X_AI_SERVICE=`eval echo \\$${PREFIX}_AI_SERVICE`
        local X_OM_LOC=`eval echo \\$${PREFIX}_OM_LOC`
        local X_APPL_MEDIA_LOC=`eval echo \\$${PREFIX}_APPL_MEDIA_LOC`
        local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`
        local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
        local X_EXTRA_BOOTARGS=`eval echo \\$${PREFIX}_EXTRA_BOOTARGS`
        local X_IP_ADDR=`eval echo \\$${PREFIX}_IP_ADDR`
        local X_NETMASK=`eval echo \\$${PREFIX}_NETMASK`
        local X_MAC_ADDR=`eval echo \\$${PREFIX}_MAC_ADDR`
        local X_IPV6_PARAMETER=`eval echo \\$${PREFIX}_IPV6_PARAMETER`
        local X_CLIENT_HOSTNAME_V6=`eval echo \\$${PREFIX}_CLIENT_HOSTNAME_V6`
        local X_CLIENT_IP_ADDR_V6=`eval echo \\$${PREFIX}_CLIENT_IP_ADDR_V6`
        local X_ROUTER_IP_ADDR_V6=`eval echo \\$${PREFIX}_ROUTER_IP_ADDR_V6`
        local X_ARCH=`eval echo \\$${PREFIX}_ARCH`
        local X_IPV6_ADDR=`eval echo \\$${PREFIX}_IPV6_ADDR`
        
        if [[ "$1" == "OSS2_ADM1" ]]
        then
            local PREFIXWADM="OSS2_" 
        fi

        local X_VXVMLIC=`eval echo \\$${PREFIXWADM}VXVMLIC` #OSS2_VXVMLIC or VXVMLIC
        local X_CLUSTER_NAME=`eval echo \\$${PREFIXWADM}CLUSTER_NAME`
        local X_STOR_BASE_IP1=`eval echo \\$${PREFIXWADM}STOR_BASE_IP1`
        local X_STOR_BASE_IP2=`eval echo \\$${PREFIXWADM}STOR_BASE_IP2`
        local X_STOR_BASE_VIP=`eval echo \\$${PREFIXWADM}STOR_BASE_VIP`
        local X_PUB_BASE_IP1=`eval echo \\$${PREFIXWADM}PUB_BASE_IP1`
        local X_PUB_BASE_IP2=`eval echo \\$${PREFIXWADM}PUB_BASE_IP2`
        local X_OSS_ID=`eval echo \\$${PREFIXWADM}OSS_ID`
        local X_BACKUP_IP=`eval echo \\$${PREFIXWADM}BACKUP_IP`
        local X_BACKUP_NETMASK=`eval echo \\$${PREFIXWADM}BACKUP_NETMASK`
        local X_VIP_OSSFS=`eval echo \\$${PREFIXWADM}VIP_OSSFS`
        local X_VIP_IPV6_OSSFS=`eval echo \\$${PREFIXWADM}VIP_IPV6_OSSFS`
        local X_VIP_PMS=`eval echo \\$${PREFIXWADM}VIP_PMS`
        local X_VIP_IPV6_PMS=`eval echo \\$${PREFIXWADM}VIP_IPV6_PMS`
        local X_VIP_CMS=`eval echo \\$${PREFIXWADM}VIP_CMS`
        local X_VIP_IPV6_CMS=`eval echo \\$${PREFIXWADM}VIP_IPV6_CMS`
        local X_VIP_SYBASE=`eval echo \\$${PREFIXWADM}VIP_SYBASE`
        local X_VIP_SNMP=`eval echo \\$${PREFIXWADM}VIP_SNMP`
        local X_VIP_OSS_BKUP=`eval echo \\$${PREFIXWADM}VIP_OSS_BKUP`
        local X_VIP_OSS_SYB_BKUP=`eval echo \\$${PREFIXWADM}VIP_OSS_SYB_BKUP`
        local X_GSMDEF=`eval echo \\$${PREFIXWADM}GSMDEF`
        local X_UTRANDEF=`eval echo \\$${PREFIXWADM}UTRANDEF`
        local X_RNCDEF=`eval echo \\$${PREFIXWADM}RNCDEF`
        local X_LTEDEF=`eval echo \\$${PREFIXWADM}LTEDEF`
        local X_COREDEF=`eval echo \\$${PREFIXWADM}COREDEF`
        local X_AXDnodes=`eval echo \\$${PREFIXWADM}AXDnodes`
        local X_OSSTGR=`eval echo \\$${PREFIXWADM}OSSTGR`
        local X_Tesnodes=`eval echo \\$${PREFIXWADM}Tesnodes`
        local X_Tesnodes=`eval echo \\$${PREFIXWADM}Tesnodes`
        local X_MINUTE_GPEH=`eval echo \\$${PREFIXWADM}MINUTE_GPEH`
        local X_CELL_TRACE=`eval echo \\$${PREFIXWADM}CELL_TRACE`
        local X_Numbsp=`eval echo \\$${PREFIXWADM}Numbsp`
        local X_ADDSGW=`eval echo \\$${PREFIXWADM}ADDSGW`
        local X_ADDPMS=`eval echo \\$${PREFIXWADM}ADDPMS`
        local X_ADDEBSW=`eval echo \\$${PREFIXWADM}ADDEBSW`
        local X_ADDRPMO=`eval echo \\$${PREFIXWADM}ADDRPMO`
        local X_ADDEBS=`eval echo \\$${PREFIXWADM}ADDEBS`
        local X_ADDRTT=`eval echo \\$${PREFIXWADM}ADDRTT`
        local X_ADDRNDBI=`eval echo \\$${PREFIXWADM}ADDRNDBI`
        local X_ADDEBSS=`eval echo \\$${PREFIXWADM}ADDEBSS`
        local X_NumSites=`eval echo \\$${PREFIXWADM}NumSites`
        local X_Nummgw=`eval echo \\$${PREFIXWADM}Nummgw`
        local X_Numepgssr=`eval echo \\$${PREFIXWADM}Numepgssr`
        local X_Numstn=`eval echo \\$${PREFIXWADM}Numstn`
        local X_Numipr=`eval echo \\$${PREFIXWADM}Numipr`
        local X_Numcscf=`eval echo \\$${PREFIXWADM}Numcscf`
        local X_Nummtas=`eval echo \\$${PREFIXWADM}Nummtas`
        local X_Numh2s=`eval echo \\$${PREFIXWADM}Numh2s`
        local X_Numwcg=`eval echo \\$${PREFIXWADM}Numwcg`
        local X_Numpgm=`eval echo \\$${PREFIXWADM}Numpgm`
        local X_Numsgsn=`eval echo \\$${PREFIXWADM}Numsgsn`
        local X_Numsgsnmme=`eval echo \\$${PREFIXWADM}Numsgsnmme`
        local X_Numggsn=`eval echo \\$${PREFIXWADM}Numggsn`
        local X_Num2g3gsaus=`eval echo \\$${PREFIXWADM}Num2g3gsaus`
        local X_Num4gsaus=`eval echo \\$${PREFIXWADM}Num4gsaus`
        local X_Numssr=`eval echo \\$${PREFIXWADM}Numssr`
        local X_Numsdc=`eval echo \\$${PREFIXWADM}Numsdc`
        local X_Numirathomcells=`eval echo \\$${PREFIXWADM}Numirathomcells`
        local X_Numapg43=`eval echo \\$${PREFIXWADM}Numapg43`
        local X_Numredback=`eval echo \\$${PREFIXWADM}Numredback`
        local X_Numegr=`eval echo \\$${PREFIXWADM}Numegr`
        local X_ADD5mROP=`eval echo \\$${PREFIXWADM}ADD5mROP`
        local X_Numsasnsara=`eval echo \\$${PREFIXWADM}Numsasnsara`
        local X_Numpicowcdmacells=`eval echo \\$${PREFIXWADM}Numpicowcdmacells`
        local X_Numpicoltecells=`eval echo \\$${PREFIXWADM}Numpicoltecells`
        local X_Numrnc1min=`eval echo \\$${PREFIXWADM}Numrnc1min`
        local X_Nummp15min=`eval echo \\$${PREFIXWADM}Nummp15min`
        local X_Sizegpehfs=`eval echo \\$${PREFIXWADM}Sizegpehfs`
        local X_Nummp1min=`eval echo \\$${PREFIXWADM}Nummp1min`
        local X_Numdsc=`eval echo \\$${PREFIXWADM}Numdsc`
        local X_Numlanswitch=`eval echo \\$${PREFIXWADM}Numlanswitch`
        local X_Numsbg=`eval echo \\$${PREFIXWADM}Numsbg`
        local X_Numtcu=`eval echo \\$${PREFIXWADM}Numtcu`
        local X_Numduas=`eval echo \\$${PREFIXWADM}Numduas`
        local X_Nummio=`eval echo \\$${PREFIXWADM}Nummio`
	local X_Numradiot=`eval echo \\$${PREFIXWADM}Numradiot`
	local X_Numradio=`eval echo \\$${PREFIXWADM}Numradio`
        local X_Nummsrbsv2=`eval echo \\$${PREFIXWADM}Nummsrbsv2`
        local X_NETGROUPNAME=`eval echo \\$${PREFIXWADM}NETGROUPNAME`
        local X_SQL_DEF_USER_PW=`eval echo \\$${PREFIXWADM}SQL_DEF_USER_PW`
        local X_TIMEZONE=`eval echo \\$${PREFIXWADM}TIMEZONE`
        local X_DEFAULTROUTERS=`eval echo \\$${PREFIXWADM}DEFAULTROUTERS`
        local X_NAMESERVERS=`eval echo \\$${PREFIXWADM}NAMESERVERS`
        local X_DNSDOMAIN=`eval echo \\$${PREFIXWADM}DNSDOMAIN`
        local X_LDAPDOMAIN=`eval echo \\$${PREFIXWADM}LDAPDOMAIN`
        local X_SENTINEL_LICENSE_FILE_PATH=`eval echo \\$${PREFIXWADM}SENTINEL_LICENSE_FILE_PATH`
        local X_SEC_TYPE=`eval echo \\$${PREFIXWADM}SEC_TYPE`
        local X_VXVMLIC=`eval echo \\$${PREFIXWADM}VXVMLIC`
        local X_NETWORK_TYPE=`eval echo \\$${PREFIXWADM}NETWORK_TYPE`
        local X_IM_ROOT=`eval echo \\$${PREFIXWADM}IM_ROOT`
        local X_X29_SUFF=`eval echo \\$${PREFIXWADM}X29_SUFF`
        local X_NT_SERVER_IPADDRESS=`eval echo \\$${PREFIXWADM}NT_SERVER_IPADDRESS`
        local X_WAS_IP_1=`eval echo \\$${PREFIXWADM}WAS_IP_1`
        local X_WAS_IP_2=`eval echo \\$${PREFIXWADM}WAS_IP_2`
        local X_WAS_IP_3=`eval echo \\$${PREFIXWADM}WAS_IP_3`
        local X_WAS_IP_4=`eval echo \\$${PREFIXWADM}WAS_IP_4`
        local X_WAS_IP_5=`eval echo \\$${PREFIXWADM}WAS_IP_5`
        

        requires_variable X_JUMP_LOC
	requires_variable X_AI_SERVICE
	requires_variable X_OM_LOC
	requires_variable X_APPL_MEDIA_LOC

	local CLIENT_TYPE=${PREFIX}
	local CONFIG_FILE="$LOCAL_CONFIG_DIR/${X_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

	local PRE_INIRATOR_SHORT_DIR="/JUMP/preinirators/"
	local PRE_INIRATOR_DIR="/JUMP/preinirators/${PARENT_BASHPID}_${X_HOSTNAME}/"
	#PRE_INIRATOR_DIR="$LOCAL_CONFIG_DIR"
	local PRE_INIRATOR_FILE="preinirate_$X_HOSTNAME"

	# Blank variables
	local JUMP_OUTPUT=""
	local PRE_INIRATOR_OUTPUT=""

	if [[ "$X_VXVMLIC" == "" ]]
	then
		if [[ ! -r /tmp/veritas/LICENSES.txt ]]
		then
			message "INFO: Obtaining veritas license from 159.107.177.94:/export/veritas/LICENCES.txt\n" INFO
			mkdir /tmp/veritas >/dev/null 2>&1
			mount -o vers=3 159.107.177.94:/export/veritas /tmp/veritas >/dev/null 2>&1
		fi

		X_VXVMLIC=`cat /tmp/veritas/LICENSES.txt | egrep 'License1_i386=OSSRC_O11@' | awk -F@ '{print $2}'`
	fi

	if [[ "$X_VXVMLIC" == "" ]]
	then
		message "ERROR: The veritas license wasn't set, please set it in the config file manually or check why it can't be obtained from attemjump220" error
		exit 1
	fi
	message "INFO: Veritas license is $X_VXVMLIC\n" INFO

        # Remove noiofence workaround from bootargs, as we have our own workaround in place
        X_EXTRA_BOOTARGS=`echo $X_EXTRA_BOOTARGS | sed 's/environ=noiofence//g'`

	# Figure out the correct ip to mount the preinirator from
	local MWS_IP=""
	MWS_IP=`find_matching_interface_ip $DHCP_SERVER_IP root $DHCP_SERVER_ROOT_PASS $X_IP_ADDR $X_NETMASK`
	if [[ $? -ne 0 ]]
	then
		MWS_IP="$DHCP_SERVER_IP"
	fi

JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$X_HOSTNAME
CLIENT_IP_ADDR@$X_IP_ADDR
CLIENT_NETMASK@$X_NETMASK
CLIENT_MAC_ADDR@$X_MAC_ADDR
IPV6_PARAMETER@$X_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$X_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$X_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$X_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$X_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$X_JUMP_LOC
CLIENT_JUMP_DESC@$X_JUMP_DESC
CLIENT_AI_SERVICE@$X_AI_SERVICE
CLIENT_OM_LOC@$X_OM_LOC
CLIENT_APPL_TYPE@ossrc
CLIENT_APPL_MEDIA_LOC@$X_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install label_disks inst_type=ossrc config=system nowin $X_EXTRA_BOOTARGS pre_ini=$MWS_IP:$PRE_INIRATOR_DIR/
EOF
`

# Fix some variables
if [[ "$X_IPV6_ADDR" == "" ]]
then
	X_IPV6_ADDR="none"
fi

PRE_INIRATOR_OUTPUT=`cat <<EOF
;#################################################################
;
;  This file is used by the inirator to set variables such that
;  default values from the file are presented for every inirator
;  question.
;
;  Default questions for fencing and data LUNS cannot be set as
;  it is not possible to determine the LUN ids before jumpstart.
;  However, if the correct number and type of LUNs are connected
;  to the server, the the inirator function will figure out the
;  defaults itself. Otherwise the LUNS can be manually changed
;  during inirator execution
;
;  For use by inirator, this file should be stored in /ericsson/config
;  and be named preinerate_<hostname>
;
;#################################################################

[PREINIRATE]
; The autoini variable can be set to yes to complete full automatic installation through
; the inirator phase. Note: Make sure that all default variables are correct before setting
; this value to yes. It is advisable to set the value to no for the first time installation
; to verify that all default values are picked up correctly by the inirator. The value can then
; be set to yes for subsequent installs when default values are verified.
autoini=yes
; The clearscsi3 variable can be set to yes to automatically clear scsi3 registration/reservation
; keys on LUNS. If scsi3 keys are detected on any LUNS connected to the server, core.sh will bail
; out before starting inirator. Setting this variable to yes will prevent bailout of core.sh and
; will automatically clear the scsi3 keys from the LUNs.
clearscsi3=yes
; cluster name
clustername=$X_CLUSTER_NAME
; Test IP Address for first Storage VLAN NIC
storBaseIPP1=$X_STOR_BASE_IP1
; Test IP Address for second Storage VLAN NIC
storBaseIPP2=$X_STOR_BASE_IP2
; Storage VIP address
storVIPP1=$X_STOR_BASE_VIP
; Storage VLAN Netmask
storNETMM=$STOR_NETMASK
; OSS System Identifier
OssIDD=$X_OSS_ID
; NAS master Password
nasMasPWW=$NASMASPWW
; NAS support Password
nasSupPWW=$NASSUPPWW
; IP address for NAS1 server
nasServ1IPP=$NAS1
; IP address for NAS2 server
nasServ2IPP=$NAS2
; IP address for NAS Console
nasServConn=$NASC
; Test IP Address for first Public VLAN NIC
pubBaseIPP1=$X_PUB_BASE_IP1
; Test IP Address for second Public VLAN NIC
pubBaseIPP2=$X_PUB_BASE_IP2
; Public VLAN Default router IP Address
pubDRR=$PUB_ROUTER
; Public VLAN Netmask
pubNETMM=$PUB_NETMASK
; IPv6 address for the host itself
IPv6address_def=$X_IPV6_ADDR
; IPv6 subnet prefix length [default 64]
ipv6_prefix_len_def=64
; Default IPv6 router
ipv6_pub_router_def=$X_ROUTER_IP_ADDR_V6
; IP address for Private LAN NIC
privBaseIPP1=200.200.200.15
; Private LAN Netmask
privNETMM=255.255.255.0
; IP address for Backup LAN NIC
bkupBaseIPP=$X_BACKUP_IP
; Backup LAN Netmask
bkupNETMM=$X_BACKUP_NETMASK
; Virtual IP address for OSSFS
ossfsIPP=$X_VIP_OSSFS
; Virtual IP address for IPv6 OSSFS
ossfsIPv6_def=$X_VIP_IPV6_OSSFS
; Virtual IP address for PMS
pmsIPP=$X_VIP_PMS
; Virtual IP address for IPv6 PMS
pmsIPv6_def=$X_VIP_IPV6_PMS
; Virtual IP address for CMS
cmsIPP=$X_VIP_CMS
; Virtual IP address for IPv6 CMS
cmsIPv6_def=$X_VIP_IPV6_CMS
; Virtual IP address for Sybase
sybaseIPP=$X_VIP_SYBASE
; Virtual IP address for SNMP
snmpIPP=$X_VIP_SNMP
; Virtual IP address for OSS bkup
ossbkupIPP=$X_VIP_OSS_BKUP
; Virtual IP address for Sybase bkup
syb1bkupIPP=$X_VIP_OSS_SYB_BKUP
; Do you want to use Host-Based Mirroring (YES|NO) <YES> >>
ossmirror=YES
; Total number of GSM Cells
GSMDEF=$X_GSMDEF
; Total number of UTRAN Cells
UTRANDEF=$X_UTRANDEF
; Total number of RNCs
RNCDEF=$X_RNCDEF
; Total number of LTE Cells
LTEDEF=$X_LTEDEF
; Total number of Core Nodes
COREDEF=$X_COREDEF
; Number of AXD based nodes
AXDnodes=$X_AXDnodes
; Use TGR application ( YES/NO )
OSSTGR=$X_OSSTGR
; Number of TeS nodes
Tesnodes=$X_Tesnodes
TeSnodes=$X_Tesnodes
; Will the one minute GPEH application be used ( YES/NO )
MINUTE_GPEH=$X_MINUTE_GPEH
; Will the cell trace application be used ( YES/NO )
CELL_TRACE=$X_CELL_TRACE
; Number of BSP nodes in the Core Network
Numbsp=$X_Numbsp
; Allocate space for SGW ( YES/NO )
ADDSGW=$X_ADDSGW
; Allocate space for PMS ( YES/NO )
ADDPMS=$X_ADDPMS
; Allocate space for EBSW ( YES/NO )
ADDEBSW=$X_ADDEBSW
; Allocate space for RPMO ( YES/NO )
ADDRPMO=$X_ADDRPMO
; Allocate space for EBS ( YES/NO )
ADDEBS=$X_ADDEBS
; Allocate space for RTT ( YES/NO )
ADDRTT=$X_ADDRTT
; Setup RNO Database Export Interface ( YES/NO )
ADDRNDBI=$X_ADDRNDBI
; Allocate space for EBS-S ( YES/NO )
ADDEBSS=$X_ADDEBSS
; Number of OSSRC Sites
NumSites=$X_NumSites
; Number of CPP MGW nodes in the Core Network
Nummgw=$X_Nummgw
; Number of EPGSSR nodes in the Core Network
Numepgssr=$X_Numepgssr
; Number of STN nodes OSSRC supports
Numstn=$X_Numstn
; Number of IPROUTER nodes OSSRC supports
Numipr=$X_Numipr
; Number of CSCF nodes in the Core Network
Numcscf=$X_Numcscf
; Number of MTAS nodes in the Core Network
Nummtas=$X_Nummtas
; Number of H2S nodes in the Core Network
Numh2s=$X_Numh2s
; Number of WCG nodes in the Core Network
Numwcg=$X_Numwcg
; Number of CBA_PGM nodes in the Core Network
Numpgm=$X_Numpgm
; Number of SGSN nodes in the Core Network
Numsgsn=$X_Numsgsn
; Number of SGSN MME nodes in the Core Network
Numsgsnmme=$X_Numsgsnmme
; Number of GGSN nodes in the Core Network
Numggsn=$X_Numggsn
; Number of 2G/3G SAUs per OSS-RC
Num2g3gsaus=$X_Num2g3gsaus
; Number of 4G SAUs per OSS-RC
Num4gsaus=$X_Num4gsaus
; Number of SASNSSR nodes in the Core Network
Numssr=$X_Numssr
; Number of SDC nodes in the Core Network
Numsdc=$X_Numsdc
; Combined number of cells on all OSS-RC servers that will be audited by IRATHOM application
Numirathomcells=$X_Numirathomcells
; Number of APG43 equipped nodes in the  Network
Numapg43=$X_Numapg43
; Number of Redback SmartEdge equipped nodes in the  Network
Numredback=$X_Numredback
; Number of HSS nodes in the Core Network
Numhss=$Numhss
; Number of Redback Nodes which are EdgeRouter Nodes
Numegr=$X_Numegr
; Will the 5 minute ROP collection Supported ( YES/NO )
ADD5mROP=$X_ADD5mROP
; Number of SASN nodes with SARA functionality equipped nodes in the  Network
Numsasnsara=$X_Numsasnsara
; Number of PICO WCDMA cells OSSRC supports
Numpicowcdmacells=$X_Numpicowcdmacells
; Number of PICO LTE cells OSSRC supports
Numpicoltecells=$X_Numpicoltecells
; Number of RNCs on 1MIN OSSRC supports
Numrnc1min=$X_Numrnc1min
; Number of MPs on 15MIN OSSRC supports
Nummp15min=$X_Nummp15min
; GPEH File Size on 1MIN OSSRC supports
Sizegpehfs=$X_Sizegpehfs
; Number of MPs on 1MIN OSSRC supports
Nummp1min=$X_Nummp1min
; Number of DSC nodes in the Core Network
Numdsc=$X_Numdsc
; Number of LANSWITCH nodes in the GRAN
Numlanswitch=$X_Numlanswitch
; Number of SBG nodes in the Core Network
Numsbg=$X_Numsbg
; Number of TCU nodes in the WRAN/LTE Network
Numtcu=$X_Numtcu
; Number of DUA_S nodes in the Core Network
Numduas=$X_Numduas
; Number of MIO nodes in the Core Network
Nummio=$X_Nummio
; number of MSRBS_V2 nodes the OSSRC will support
Nummsrbsv2=$X_Nummsrbsv2
; Number of RADIOT nodes in the WRAN/LTE Network 
Numradiot=$X_Numradiot
; Number of RADIO nodes in the LTE Network 
Numradio=$X_Numradio
; Installation type
INS_TYPE=ii
; The hostname of the OSS server
HOSTNAME=$X_HOSTNAME
; Netgroup name
NETGROUPNAME=$X_NETGROUPNAME
; default password for the OSS-RC sybase users. 6 or more characters.
SQL_DEF_USER_PW=$X_SQL_DEF_USER_PW
; timezone for your geographical region or offset from GMT
TIMEZONE=$X_TIMEZONE
; defaultrouter IP address. The address of the gateway to the rest of the network.
DEFAULTROUTERS=$X_DEFAULTROUTERS
; DNS-servers ip-address. Leave empty if not used.
NAMESERVERS=$X_NAMESERVERS
; DNS-domain, e.g company.domain.com
DNSDOMAIN=$X_DNSDOMAIN
; LDAP-domain, e.g company.domain.com
LDAPDOMAIN=$X_LDAPDOMAIN
; SLS server name e.g https://<slsserver>:8443/ericsson/servlet/sls
SLS_SERVER=https://${OMSERVM_HOSTNAME}:8443/ericsson/servlet/sls
; Sentinel license file path. Leave empty if have nothing to give
SENTINEL_LICENSE_FILE_PATH=$X_SENTINEL_LICENSE_FILE_PATH
; Type of xml file installation, server
SEC_TYPE=$X_SEC_TYPE
; The Veritas VM license key.
VXVMLIC=$X_VXVMLIC
; This is either GSM1900 or GSM900/1800, depending on the frequencies used by the GSM network.
NETWORK_TYPE=$X_NETWORK_TYPE
; Name of the network root object in the information model.
IM_ROOT=$X_IM_ROOT
; The X29 suffix to be used.
X29_SUFF=$X_X29_SUFF
; The IP address of the WEBI server. If unknown, accept default and change later in /etc/hosts.
NT_SERVER_IPADDRESS=$X_NT_SERVER_IPADDRESS
; The IP address of the first Windows Application Server. If unknown, press enter and add it later.
WAS_IP_1=$X_WAS_IP_1
; The IP address of the second Windows Application Server. If unknown, press enter and add it later.
WAS_IP_2=$X_WAS_IP_2
; The IP address of the third Windows Application Server. If unknown, press enter and add it later.
WAS_IP_3=$X_WAS_IP_3
; The IP address of the fourth Windows Application Server. If unknown, press enter and add it later.
WAS_IP_4=$X_WAS_IP_4
; The IP address of the fifth Windows Application Server. If unknown, press enter and add it later.
WAS_IP_5=$X_WAS_IP_5
; LDAP DS Server IP address
LDAPSERVERIP=
; LDAP Fully Qualified Hostname
PRIMARYFQHN=
; LDAP Domain Name
LDAPDOMAINNAME=
; LDAP Proxy Password
LDAPPROXYPASSWORD=
; LDAP Clients Certificate Database Password
LDAPCLIENTCERTDBPW=
; LDAP Client Profile
LDAPCLIENTPROFILE=
; Full path to valid PKS root CA certificate
PKSCACERTIFICATE=
; Do you want to configure a secondary LDAP server now? [Y|n]
SECONDARYLDAP=
; Secondary LDAP DS Server IP address
SECONDARYLDAPSERVERIP=
; Secondary LDAP Fully Qualified Hostname
SECONDARYFQHN=
EOF
`

	echo "$JUMP_OUTPUT" > $CONFIG_FILE
	message "INFO: DHCP Client file written for this server at $CONFIG_FILE\n" INFO
	if [[ "$PRE_INIRATOR_OUTPUT" != "" ]]
	then
	        echo "$PRE_INIRATOR_OUTPUT" > /tmp/$PRE_INIRATOR_FILE
	
        	message "INFO: Ftping pre inirator file to $DHCP_SERVER_IP:/JUMP/\n" INFO
COMMAND="
lcd /tmp/
mkdir $PRE_INIRATOR_SHORT_DIR
mkdir $PRE_INIRATOR_DIR
cd $PRE_INIRATOR_DIR
put $PRE_INIRATOR_FILE
bye"

	$EXPECT - <<EOF
                        set force_conservative 1
                        set timeout 60

                        # autologin variables
                        set prompt ".*(%|#|\\$|>):? $"


                        # set login variables before attempting to login
                        set loggedin "0"
                        set entered_password "0"
                        set exited_unexpectedly "0"
                        set timedout_unexpectedly "0"

                        spawn sftp $DHCP_SERVER_IP
                                expect {
                                        "Are you sure" {
                                                send "yes\r"
                                                exp_continue -continue_timer
                                        }
                                        "assword:" {
                                                send "$DHCP_SERVER_ROOT_PASS\r"
                                                set entered_password "1"
                                                exp_continue -continue_timer
                                        }
                                        -re \$prompt {
                                                set loggedin "1"
                                        }
                                        timeout {
                                                set timedout_unexpectedly "1"
                                        }
                                }
                                if {\$loggedin == "1"} {
                                        send_user "\nLogged in fine, running command\n"
                                        send "$COMMAND\r"
                                        set timeout 10
                                        expect {
                                                "eof" {
                                                        send_user "\nFinished sftp of preinirator\n"
                                                        exit 0
                                                }
                                        }

                                        expect eof
                                } else {
                                        send_user "\nERROR: Failed to sftp preinirator\n"
                                        exit 1
                              }
EOF
		rm /tmp/$PRE_INIRATOR_FILE
	fi

}

function create_config_files_eniqe ()
{
	requires_variable ENIQE_JUMP_LOC
	requires_variable ENIQE_AI_SERVICE
        requires_variable ENIQE_OM_LOC
        requires_variable ENIQE_APPL_MEDIA_LOC

	local CLIENT_TYPE="ENIQE"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQE_HOSTNAME}_${PARENT_BASHPID}.txt"
	mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

	JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQE_HOSTNAME
CLIENT_IP_ADDR@$ENIQE_IP_ADDR
CLIENT_NETMASK@$ENIQE_NETMASK
CLIENT_MAC_ADDR@$ENIQE_MAC_ADDR
IPV6_PARAMETER@$ENIQE_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQE_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQE_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQE_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQE_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQE_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQE_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQE_AI_SERVICE
CLIENT_OM_LOC@$ENIQE_OM_LOC
CLIENT_APPL_TYPE@eniq_events
CLIENT_APPL_MEDIA_LOC@$ENIQE_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=events $ENIQE_EXTRA_BOOTARGS
EOF
`

	echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_cep ()
{
        requires_variable CEP_KICK_LOC
        requires_variable CEP_OM_LOC
        requires_variable CEP_APPL_MEDIA_LOC

        local CLIENT_TYPE="CEP"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${CEP_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$CEP_HOSTNAME
CLIENT_IP_ADDR@$CEP_IP_ADDR
CLIENT_NETMASK@$CEP_NETMASK
CLIENT_MAC_ADDR@$CEP_MAC_ADDR
IPV6_PARAMETER@$CEP_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$CEP_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$CEP_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$CEP_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$CEP_ARCH
CLIENT_DISP_TYPE@NON-VGA
CLIENT_TZ@$CEP_CLIENT_TZ
CLIENT_KICK_LOC@$CEP_KICK_LOC
CLIENT_OM_LOC@$CEP_OM_LOC
CLIENT_APPL_TYPE@eniq_events
CLIENT_APPL_MEDIA_LOC@$CEP_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@inst_type=eniq config=cep $CEP_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_eniqs ()
{
	requires_variable ENIQS_JUMP_LOC
	requires_variable ENIQS_AI_SERVICE
        requires_variable ENIQS_OM_LOC
        requires_variable ENIQS_APPL_MEDIA_LOC

        local CLIENT_TYPE="ENIQS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQS_HOSTNAME
CLIENT_IP_ADDR@$ENIQS_IP_ADDR
CLIENT_NETMASK@$ENIQS_NETMASK
CLIENT_MAC_ADDR@$ENIQS_MAC_ADDR
IPV6_PARAMETER@$ENIQS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQS_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQS_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQS_AI_SERVICE
CLIENT_OM_LOC@$ENIQS_OM_LOC
CLIENT_APPL_TYPE@eniq_stats
CLIENT_APPL_MEDIA_LOC@$ENIQS_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=stats $ENIQS_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_eniqsc ()
{
        requires_variable ENIQSC_JUMP_LOC
	requires_variable ENIQSC_AI_SERVICE
        requires_variable ENIQSC_OM_LOC
        requires_variable ENIQSC_APPL_MEDIA_LOC

        local CLIENT_TYPE="ENIQSC"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQSC_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQSC_HOSTNAME
CLIENT_IP_ADDR@$ENIQSC_IP_ADDR
CLIENT_NETMASK@$ENIQSC_NETMASK
CLIENT_MAC_ADDR@$ENIQSC_MAC_ADDR
IPV6_PARAMETER@$ENIQSC_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQSC_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQSC_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQSC_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQSC_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQSC_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQSC_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQSC_AI_SERVICE
CLIENT_OM_LOC@$ENIQSC_OM_LOC
CLIENT_APPL_TYPE@eniq_stats
CLIENT_APPL_MEDIA_LOC@$ENIQSC_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=stats $ENIQSC_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_eniqse ()
{
        requires_variable ENIQSE_JUMP_LOC
	requires_variable ENIQSE_AI_SERVICE
        requires_variable ENIQSE_OM_LOC
        requires_variable ENIQSE_APPL_MEDIA_LOC

        local CLIENT_TYPE="ENIQSE"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQSE_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQSE_HOSTNAME
CLIENT_IP_ADDR@$ENIQSE_IP_ADDR
CLIENT_NETMASK@$ENIQSE_NETMASK
CLIENT_MAC_ADDR@$ENIQSE_MAC_ADDR
IPV6_PARAMETER@$ENIQSE_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQSE_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQSE_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQSE_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQSE_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQSE_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQSE_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQSE_AI_SERVICE
CLIENT_OM_LOC@$ENIQSE_OM_LOC
CLIENT_APPL_TYPE@eniq_stats
CLIENT_APPL_MEDIA_LOC@$ENIQSE_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=stats $ENIQSE_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}
function create_config_files_eniqsr1 ()
{
        requires_variable ENIQSR1_JUMP_LOC
	requires_variable ENIQSR1_AI_SERVICE
        requires_variable ENIQSR1_OM_LOC
        requires_variable ENIQSR1_APPL_MEDIA_LOC

        local CLIENT_TYPE="ENIQSR1"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQSR1_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQSR1_HOSTNAME
CLIENT_IP_ADDR@$ENIQSR1_IP_ADDR
CLIENT_NETMASK@$ENIQSR1_NETMASK
CLIENT_MAC_ADDR@$ENIQSR1_MAC_ADDR
IPV6_PARAMETER@$ENIQSR1_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQSR1_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQSR1_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQSR1_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQSR1_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQSR1_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQSR1_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQSR1_AI_SERVICE
CLIENT_OM_LOC@$ENIQSR1_OM_LOC
CLIENT_APPL_TYPE@eniq_stats
CLIENT_APPL_MEDIA_LOC@$ENIQSR1_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=stats $ENIQSR1_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}
function create_config_files_eniqsr2 ()
{
        requires_variable ENIQSR2_JUMP_LOC
	requires_variable ENIQSR2_AI_SERVICE
        requires_variable ENIQSR2_OM_LOC
        requires_variable ENIQSR2_APPL_MEDIA_LOC

        local CLIENT_TYPE="ENIQSR2"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${ENIQSR2_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$ENIQSR2_HOSTNAME
CLIENT_IP_ADDR@$ENIQSR2_IP_ADDR
CLIENT_NETMASK@$ENIQSR2_NETMASK
CLIENT_MAC_ADDR@$ENIQSR2_MAC_ADDR
IPV6_PARAMETER@$ENIQSR2_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$ENIQSR2_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$ENIQSR2_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$ENIQSR2_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$ENIQSR2_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$ENIQSR2_JUMP_LOC
CLIENT_JUMP_DESC@$ENIQSR2_AI_SERVICE
CLIENT_AI_SERVICE@$ENIQSR2_AI_SERVICE
CLIENT_OM_LOC@$ENIQSR2_OM_LOC
CLIENT_APPL_TYPE@eniq_stats
CLIENT_APPL_MEDIA_LOC@$ENIQSR2_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=stats $ENIQSR2_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
}

function create_config_files_son_vis ()
{
        requires_variable SON_VIS_JUMP_LOC
	requires_variable SON_VIS_AI_SERVICE
        requires_variable SON_VIS_OM_LOC
        requires_variable SON_VIS_APPL_MEDIA_LOC

        local CLIENT_TYPE="SON_VIS"
        local CONFIG_FILE="$LOCAL_CONFIG_DIR/${SON_VIS_HOSTNAME}_${PARENT_BASHPID}.txt"
        mkdir -p $LOCAL_CONFIG_DIR

        # Blank variables
        local JUMP_OUTPUT=""

        JUMP_OUTPUT=`cat <<EOF
CLIENT_HOSTNAME@$SON_VIS_HOSTNAME
CLIENT_IP_ADDR@$SON_VIS_IP_ADDR
CLIENT_NETMASK@$SON_VIS_NETMASK
CLIENT_MAC_ADDR@$SON_VIS_MAC_ADDR
IPV6_PARAMETER@$SON_VIS_IPV6_PARAMETER
CLIENT_HOSTNAME_V6@$SON_VIS_CLIENT_HOSTNAME_V6
CLIENT_IP_ADDR_V6@$SON_VIS_CLIENT_IP_ADDR_V6
ROUTER_IP_ADDR_V6@$SON_VIS_ROUTER_IP_ADDR_V6
CLIENT_ARCH@$SON_VIS_ARCH
CLIENT_DISP_TYPE@NON-VGA
LDAP_SERVER_HOSTNAME@none
LDAP_DOMAIN_NAME@none
LDAP_ROOTCERT@none
CLIENT_JUMP_LOC@$SON_VIS_JUMP_LOC
CLIENT_JUMP_DESC@$SON_VIS_AI_SERVICE
CLIENT_AI_SERVICE@$SON_VIS_AI_SERVICE
CLIENT_OM_LOC@$SON_VIS_OM_LOC
CLIENT_APPL_TYPE@eniq_events
CLIENT_APPL_MEDIA_LOC@$SON_VIS_APPL_MEDIA_LOC
CLIENT_INSTALL_PARAMS@- install inst_type=eniq config=events $SON_VIS_EXTRA_BOOTARGS
EOF
`

        echo "$JUMP_OUTPUT" > $CONFIG_FILE
        message "DHCP Client file written for this server at $CONFIG_FILE\n" INFO
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

function setup_ssh_masterservice()
{
	#wait_oss_online_adm1
	local FROM_SERVER=$1
	mount_scripts_directory $ADM1_HOSTNAME
        mount_scripts_directory $FROM_SERVER
	local SSH_MASTERSERVICE_LOCK="/tmp/$PARENT_BASHPID/locks/setup_ssh_masterservice.lock"
        get_lock $SSH_MASTERSERVICE_LOCK local na 7200 yes
        $SSH -qt $ADM1_HOSTNAME  "su - comnfadm -c \"mkdir -p /home/comnfadm/.ssh\""
        $SSH -qt $FROM_SERVER "$MOUNTPOINT/bin/sol11_setup_ssh_masterservice.sh -m $MOUNTPOINT -c '$CONFIG'"
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/copy_comnfadm_key.sh"
	clear_lock $SSH_MASTERSERVICE_LOCK local na
}
function setup_ssh_masterservice_omsas ()
{
	requires_variable ADM1_HOSTNAME
	requires_variable OMSAS_HOSTNAME
	setup_ssh_masterservice $OMSAS_HOSTNAME
}
function setup_ssh_masterservice_omservm ()
{
	requires_variable ADM1_HOSTNAME
	requires_variable OMSERVM_HOSTNAME
	setup_ssh_masterservice $OMSERVM_HOSTNAME
}
function setup_ssh_masterservice_omservs ()
{
        requires_variable ADM1_HOSTNAME
        requires_variable OMSERVS_HOSTNAME
        setup_ssh_masterservice $OMSERVS_HOSTNAME
}
function configure_smrs_master_service ()
{
	if [[ "$NEDSS_SMRS_OSS_ID" == "" ]]
	then
		return 0
	fi
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_smrs_master_service.sh  -c '$CONFIG' -m $MOUNTPOINT" 2>/dev/null
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong configuring the smrs master service\n" ERROR
                exit 1
        fi
}
function configure_smrs_add_nedss_nedss ()
{
	configure_smrs_add_nedss_prefix NEDSS
}
function configure_smrs_add_nedss_prefix()
{
	local PREFIX="$1"
        if [[ "$NEDSS_SMRS_OSS_ID" == "" ]]
        then
                return 0
        fi
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_smrs_add_nedss.sh  -c '$CONFIG' -m $MOUNTPOINT -p $PREFIX" 2>/dev/null
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong adding the nedss\n" ERROR
                exit 1
        fi
}
function add_aif_nedss ()
{
	configure_smrs_add_aif WRAN aifwran shroot12 $NEDSS_SLAVE_SERV_ID4
	configure_smrs_add_aif LRAN aiflran shroot12 $NEDSS_SLAVE_SERV_ID4
	configure_smrs_add_aif GRAN aifgran shroot12 $NEDSS_SLAVE_SERV_ID4
	configure_smrs_add_aif CORE aifcore shroot12 $NEDSS_SLAVE_SERV_ID4

	if [[ "$ADM1_IPV6_PARAMETER" != "NO" ]]
	then
		configure_smrs_add_aif WRAN aifwranIP6 shroot12 $NEDSS_SLAVE_SERV_ID6
		configure_smrs_add_aif LRAN aiflranIP6 shroot12 $NEDSS_SLAVE_SERV_ID6
		configure_smrs_add_aif GRAN aifgranIP6 shroot12 $NEDSS_SLAVE_SERV_ID6
		configure_smrs_add_aif CORE aifcoreIP6 shroot12 $NEDSS_SLAVE_SERV_ID6
	fi
}
function configure_smrs_add_aif()
{
	local NET_TYPE="$1"
	local AIF_USER="$2"
	local AIF_PASS="$3"
	local SLAVE_SERVICE="$4"
        if [[ "$NEDSS_SMRS_OSS_ID" == "" ]]
        then
                return 0
        fi
	mount_scripts_directory $OMSERVM_HOSTNAME
	local OMSERVM_USERS="`$SSH -qTn $OMSERVM_HOSTNAME 'cat /etc/passwd'`"
	if [[ `echo "$OMSERVM_USERS" | grep "^${AIF_USER}:"` ]]
	then
		message "INFO: This aif user $AIF_USER already exists, not going to add again\n" INFO
		return 0
	fi
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/configure_smrs_add_aif.sh  -c '$CONFIG' -m $MOUNTPOINT -n $NET_TYPE -u $AIF_USER -p $AIF_PASS -s $SLAVE_SERVICE"
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong adding the aif user\n" ERROR
                exit 1
        fi
}

function configure_smrs_add_slave4_service_nedss ()
{
	configure_smrs_add_slave_service_prefix NEDSS "no"
}
function configure_smrs_add_slave6_service_nedss ()
{
	if [[ "$ADM1_IPV6_PARAMETER" != "NO" ]]
	then
	        configure_smrs_add_slave_service_prefix NEDSS "yes"
	fi
}
function configure_smrs_add_slave_service_prefix ()
{
	local PREFIX="$1"
	local IPV6="$2"
	if [[ "$NEDSS_SMRS_OSS_ID" == "" ]]
        then
                return 0
        fi
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_smrs_add_slave_service.sh  -c '$CONFIG' -m $MOUNTPOINT -p $PREFIX -i "$IPV6"" 2>/dev/null
        if [[ $? -ne 0 ]]
        then
		## Remove this retry when fixed
                message "ERROR: Something went wrong adding the smrs slave service, retrying once more due to TR HQ65518\n" ERROR
		$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_smrs_add_slave_service.sh  -c '$CONFIG' -m $MOUNTPOINT -p $PREFIX -i "$IPV6"" 2>/dev/null
	        if [[ $? -ne 0 ]]
        	then
	                message "ERROR: Something went wrong adding the smrs slave service for the second time\n" ERROR
        	        exit 1
	        fi
        fi
}
function create_and_share_smrs_filesystems ()
{
	if [[ "$NEDSS_SMRS_OSS_ID" == "" ]]
        then
                return 0
        fi

	###################################################################################
	# Check fs lengths are not greater than 25 before continuing
	###################################################################################

	# IPV4 fs names
	FS_VAR_IPV4_LIST="$NEDSS_FULL_FS4_NAME_CORE
$NEDSS_FULL_FS4_NAME_GRAN
$NEDSS_FULL_FS4_NAME_WRAN
$NEDSS_FULL_FS4_NAME_LRAN"

	# IPV6 fs names
	if [[ "$ADM1_IPV6_PARAMETER" != "NO" ]]
	then
		FS_VAR_IPV6_LIST="$NEDSS_FULL_FS6_NAME_CORE
$NEDSS_FULL_FS6_NAME_GRAN
$NEDSS_FULL_FS6_NAME_WRAN
$NEDSS_FULL_FS6_NAME_LRAN"
	fi

	# Full list of fs names
	FS_VAR_LIST="$FS_VAR_IPV4_LIST
$FS_VAR_IPV6_LIST"

	echo "$FS_VAR_LIST" | while read FS_VAR
	do
        	if [[ "${#FS_VAR}" -gt 25 ]]
	        then
	                message "ERROR: The smrs fs name ${FS_VAR} is too long. It should be 25 characters or less. Please reduce the length of the id's and try again\n" ERROR
	                exit 1
        	fi
	done
	if [[ $? -ne 0 ]]
	then
		exit 1
	fi

	###################################################################################
	# Cleanup and recreate filesystems using nascli
	###################################################################################

	NASCLI_COMMON_INPUTS="$NEDSS_FSCOMMON_SIZE_CORE $NEDSS_FSCOMMON_NAME_CORE
$NEDSS_FSCOMMON_SIZE_GRAN $NEDSS_FSCOMMON_NAME_GRAN
$NEDSS_FSCOMMON_SIZE_WRAN $NEDSS_FSCOMMON_NAME_WRAN
$NEDSS_FSCOMMON_SIZE_LRAN $NEDSS_FSCOMMON_NAME_LRAN"
	
	NASCLI_IPV4_INPUTS="$NEDSS_FS_SIZE_CORE $NEDSS_FS4_NAME_CORE
$NEDSS_FS_SIZE_GRAN $NEDSS_FS4_NAME_GRAN
$NEDSS_FS_SIZE_WRAN $NEDSS_FS4_NAME_WRAN
$NEDSS_FS_SIZE_LRAN $NEDSS_FS4_NAME_LRAN"

	if [[ "$ADM1_IPV6_PARAMETER" != "NO" ]]
        then
		NASCLI_IPV6_INPUTS="$NEDSS_FS_SIZE_CORE $NEDSS_FS6_NAME_CORE
$NEDSS_FS_SIZE_GRAN $NEDSS_FS6_NAME_GRAN
$NEDSS_FS_SIZE_WRAN $NEDSS_FS6_NAME_WRAN
$NEDSS_FS_SIZE_LRAN $NEDSS_FS6_NAME_LRAN"
	fi

	NASCLI_INPUTS="$NASCLI_COMMON_INPUTS
$NASCLI_IPV4_INPUTS
$NASCLI_IPV6_INPUTS"

	IPS_TO_SHARE="$STOR_BASE_VIP
$ADM2_STOR_BASE_VIP
$OMSERVM_STOR_BASE_VIP
$OMSERVS_STOR_BASE_VIP
$NEDSS_STOR_BASE_VIP"

	NFS_MOUNT_OPTIONS="rw,no_root_squash"

	###################################################################################
	# For loop to create filesystems
        echo "$NASCLI_INPUTS" | while read FS_SIZE FS_NAME
        do
		if [[ "$FS_SIZE" == "" ]]
                then
                        continue
                fi
                run_nascli_command "create_fs $NEDSS_SMRS_SYS_ID ${FS_SIZE}g $NEDSS_POOL_NAME $FS_NAME"
                if [[ $? -ne 0 ]]
                then
                        message "ERROR: There was a problem creating the smrs filesystem on the sfs\n" ERROR
                        exit 1
                fi

		# For loop to share filesystems
		echo "$IPS_TO_SHARE" | grep "\." | while read IP_TO_SHARE
		do
			run_nascli_command "add_client $NEDSS_SMRS_SYS_ID $IP_TO_SHARE $NFS_MOUNT_OPTIONS $FS_NAME"
			if [[ $? -ne 0 ]]
			then
				message "ERROR: There was a problem sharing the smrs filesystem on the sfs\n" ERROR
				exit 1
			fi
		done
        done
	###################################################################################
}
function setup_ntp_client()
{
	local SERVER_IN=$1
	requires_variable NTP_SOURCE
	mount_scripts_directory $SERVER_IN
        $SSH -qTn $SERVER_IN "$MOUNTPOINT/bin/sol11_setup_ntp_client.sh  -c '$CONFIG' -m $MOUNTPOINT"
}
function setup_ntp_client_netsim()
{
        requires_variable NETSIM_HOSTNAME
        setup_ntp_client $NETSIM_HOSTNAME
}
function setup_ntp_client_omsas()
{
	requires_variable OMSAS_HOSTNAME
	setup_ntp_client $OMSAS_HOSTNAME
}
function setup_ntp_client_omservm()
{
	requires_variable OMSERVM_HOSTNAME
        setup_ntp_client $OMSERVM_HOSTNAME
}
function setup_ntp_client_omservs()
{
        requires_variable OMSERVS_HOSTNAME
        setup_ntp_client $OMSERVS_HOSTNAME
}
function setup_ntp_client_adm1()
{
        requires_variable ADM1_HOSTNAME
        setup_ntp_client $ADM1_HOSTNAME
}
function setup_ntp_client_oss2_adm1()
{
        requires_variable OSS2_ADM1_HOSTNAME
        setup_ntp_client $OSS2_ADM1_HOSTNAME
}
function setup_ntp_client_uas1()
{
        requires_variable UAS1_HOSTNAME
        setup_ntp_client $UAS1_HOSTNAME
}
function setup_ntp_client_peer1()
{
        requires_variable PEER1_HOSTNAME
        setup_ntp_client $PEER1_HOSTNAME
}
function setup_ntp_client_ebas()
{
        requires_variable EBAS_HOSTNAME
        setup_ntp_client $EBAS_HOSTNAME
}
function setup_ntp_client_mws()
{
        requires_variable MWS_HOSTNAME
        setup_ntp_client $MWS_HOSTNAME
}
function setup_ntp_client_nedss()
{
        requires_variable NEDSS_HOSTNAME
        setup_ntp_client $NEDSS_HOSTNAME
}
function setup_ntp_client_eniqe()
{
        requires_variable ENIQE_HOSTNAME
        setup_ntp_client $ENIQE_HOSTNAME
}
function setup_ntp_client_eniqs()
{
        requires_variable ENIQS_HOSTNAME
        setup_ntp_client $ENIQS_HOSTNAME
}
function setup_ntp_client_eniqsc()
{
        requires_variable ENIQSC_HOSTNAME
        setup_ntp_client $ENIQSC_HOSTNAME
}
function setup_ntp_client_eniqse()
{
        requires_variable ENIQSE_HOSTNAME
        setup_ntp_client $ENIQSE_HOSTNAME
}
function setup_ntp_client_eniqsr1()
{
        requires_variable ENIQSR1_HOSTNAME
        setup_ntp_client $ENIQSR1_HOSTNAME
}
function setup_ntp_client_eniqsr2()
{
        requires_variable ENIQSR2_HOSTNAME
        setup_ntp_client $ENIQSR2_HOSTNAME
}
function setup_ntp_client_son_vis()
{
        requires_variable SON_VIS_HOSTNAME
        setup_ntp_client $SON_VIS_HOSTNAME
}
function configure_csa_omsas()
{
	if [[ "$CONFIGURE_CSA" != "NO" ]]
        then
		requires_variable OMSAS_HOSTNAME
		mount_scripts_directory $OMSAS_HOSTNAME
		# loop through the configuration script and retry if there are any issues
		exec_configuration_script "bin/sol11_configure_csa_omsas.sh" "2>/dev/null"
		local EXIT_CODE=$?
		if [[ $EXIT_CODE -ne 0 ]]
		then
			message "ERROR: Something went wrong configuring csa on the omsas, please check output above\n" ERROR
			exit 1
		fi
	fi
}

function configure_csa_omservm()
{
	if [[ "$CONFIGURE_CSA" != "NO" ]]
	then
        	requires_variable OMSERVM_HOSTNAME
		requires_variable OMSAS_HOSTNAME
		mount_scripts_directory $OMSERVM_HOSTNAME
		mount_scripts_directory $OMSAS_HOSTNAME
		local ADMIN_SERVER_PRESENT=""
		if [[ "$ADM1_HOSTNAME" == "" ]]
		then
			ADMIN_SERVER_PRESENT="no"
		else
			ADMIN_SERVER_PRESENT="yes"
		fi
		$SSH -qt $OMSERVM_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_csa_omserv.sh  -c '$CONFIG' -m $MOUNTPOINT -a $ADMIN_SERVER_PRESENT" 2>/dev/null
	fi
	if [[ $? -ne 0 ]]
        then
		message "ERROR: Something went wrong configuring csa on the omservm, check output above\n" ERROR
                exit 1
        fi
}
function configure_csa_omservs()
{
	if [[ "$CONFIGURE_CSA" != "NO" ]]
	then
	        requires_variable OMSERVS_HOSTNAME
	        requires_variable OMSAS_HOSTNAME
	        mount_scripts_directory $OMSERVS_HOSTNAME
		mount_scripts_directory $OMSAS_HOSTNAME
		local ADMIN_SERVER_PRESENT=""
                if [[ "$ADM1_HOSTNAME" == "" ]]
		then
			ADMIN_SERVER_PRESENT="no"
		else
			ADMIN_SERVER_PRESENT="yes"
		fi
		$SSH -qt $OMSERVS_HOSTNAME "$MOUNTPOINT/bin/sol11_configure_csa_omserv.sh  -c '$CONFIG' -m $MOUNTPOINT -a $ADMIN_SERVER_PRESENT" 2>/dev/null
	fi
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong configuring csa on the omservs, check output above\n" ERROR
                exit 1
        fi
}
function install_node_hardening_force_adm1 ()
{
        install_node_hardening_prefix ADM1 yes
}
function install_node_hardening_force_adm2 ()
{
        install_node_hardening_prefix ADM2 yes
}
function install_node_hardening_force_uas1 ()
{
	install_node_hardening_prefix UAS1 yes
}
function install_node_hardening_force_ebas ()
{
        install_node_hardening_prefix EBAS yes
}
function install_node_hardening_force_peer1 ()
{
        install_node_hardening_prefix PEER1 yes
}
function install_node_hardening_force_omsas ()
{
        install_node_hardening_prefix OMSAS yes
}
function install_node_hardening_force_omservm ()
{
        install_node_hardening_prefix OMSERVM yes
}
function install_node_hardening_force_omservs ()
{
        install_node_hardening_prefix OMSERVS yes
}
function install_node_hardening_force_nedss ()
{
        install_node_hardening_prefix NEDSS yes
}
function install_node_hardening_prefix ()
{
	local SERVER_PREFIX=$1
	local FORCE=$2
	local SERVER=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
	local SERVER_IP=`eval echo \\$${SERVER_PREFIX}_IP_ADDR`
	local SERVER_NETMASK=`eval echo \\$${SERVER_PREFIX}_NETMASK`

        mount_scripts_directory $SERVER

	local MWS_IP=""
	MWS_IP=`find_matching_interface_ip $DHCP_SERVER_IP root $DHCP_SERVER_ROOT_PASS $SERVER_IP $SERVER_NETMASK`
	if [[ $? -ne 0 ]]
	then
		MWS_IP="$DHCP_SERVER_IP"
	fi
        $SSH -qt $SERVER "$MOUNTPOINT/bin/install_node_hardening.sh -c '$CONFIG' -m $MOUNTPOINT -p $SERVER_PREFIX -o '$MWS_IP' -f $FORCE"
	local EXIT_CODE=$?
	if [[ $EXIT_CODE -ne 0 ]] && [[ $EXIT_CODE -ne 123 ]]
	then
		message "ERROR: Something went wront enabling node hardening, see output above\n"
		exit 1
	fi
	if [[ $EXIT_CODE -ne 123 ]]
        then
		wait_until_not_pingable $SERVER
		wait_until_sshable $SERVER
        fi
}
function install_caas ()
{
	if [[ "$INSTALL_CAAS" != "NO" ]]
	then
		local SERVER_PREFIX=$1
		local SERVER=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
		local SERVER_IP=`eval echo \\$${SERVER_PREFIX}_IP_ADDR`
		local SERVER_NETMASK=`eval echo \\$${SERVER_PREFIX}_NETMASK`
		local INPUT_CHOICE=$2
		local SECOND_CHOICE=$3

		mount_scripts_directory $SERVER
		message "INFO: Installing caas...: " INFO
		local MWS_IP=""
	        MWS_IP=`find_matching_interface_ip $DHCP_SERVER_IP root $DHCP_SERVER_ROOT_PASS $SERVER_IP $SERVER_NETMASK`
		if [[ $? -ne 0 ]]
	        then
	                MWS_IP="$DHCP_SERVER_IP"
	        fi
		$SSH -qt $SERVER "$MOUNTPOINT/bin/install_caas.sh -i $INPUT_CHOICE -s $SECOND_CHOICE -m $MOUNTPOINT -c '$CONFIG' -o '$MWS_IP'"
	fi
}
function install_caas_omsas()
{
	requires_variable OMSAS_HOSTNAME
	install_caas OMSAS 3 2
}
function install_caas_omservm()
{
        requires_variable OMSERVM_HOSTNAME
        install_caas OMSERVM 4 3
}
function install_caas_omservs()
{
        requires_variable OMSERVS_HOSTNAME
        install_caas OMSERVS 4 3
}
function setup_resolver()
{
	local SERVER_IN=$1
	mount_scripts_directory $SERVER_IN
	$SSH -qt $SERVER_IN "$MOUNTPOINT/bin/sol11_setup_resolver.sh -c '$CONFIG' -m $MOUNTPOINT" 2>/dev/null
}
function setup_resolver_omsas()
{
	requires_variable OMSAS_HOSTNAME
		#$SSH -qt $OMSAS_HOSTNAME "echo 'LD_LIBRARY_PATH=/usr/lib/mps:/usr/lib/mps/amd64:$LD_LIBRARY_PATH;export LD_LIBRARY_PATH' >> /root/.profile" 2>/dev/null
	setup_resolver $OMSAS_HOSTNAME
}
function setup_resolver_omservm()
{
        requires_variable OMSERVM_HOSTNAME
        setup_resolver $OMSERVM_HOSTNAME
}
function setup_resolver_omservs()
{
        requires_variable OMSERVS_HOSTNAME
        setup_resolver $OMSERVS_HOSTNAME
}
function setup_resolver_uas1()
{
	requires_variable UAS1_HOSTNAME
	setup_resolver $UAS1_HOSTNAME
}
function setup_resolver_nedss()
{
	requires_variable NEDSS_HOSTNAME
	setup_resolver $NEDSS_HOSTNAME
}
function setup_resolver_adm1()
{
	requires_variable ADM1_HOSTNAME
	setup_resolver $ADM1_HOSTNAME
}
function update_sentinel_license()
{
	requires_variable UNIQUE_MASTERSERVICE
	mount_scripts_directory $UNIQUE_MASTERSERVICE
	$SSH -qt $UNIQUE_MASTERSERVICE "$MOUNTPOINT/bin/update_sentinel_license.sh"
}
function update_sentinel_license_oss2_adm1()
{
	requires_variable OSS2_ADM1_HOSTNAME
	mount_scripts_directory $OSS2_ADM1_HOSTNAME
	$SSH -qt $OSS2_ADM1_HOSTNAME "$MOUNTPOINT/bin/update_sentinel_license.sh"
}
function expand_databases()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME

	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		message "INFO: Skipping database expansion for VApp\n" INFO

		return 0
	fi
		$SSH -qt $ADM1_HOSTNAME "PATH=$PATH:/usr/ucb;export PATH;$MOUNTPOINT/bin/expand_databases.sh"
       
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Something went wrong with database expansion, check output above\n" ERROR
		exit 1
	fi
}
function dmr_config()
{
        requires_variable ADM1_HOSTNAME
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "PATH=$PATH:/usr/ucb;export PATH;$MOUNTPOINT/bin/dmr_config.bsh"

        if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong with defining mirrors, check output above\n" ERROR
                exit 1
        fi

}
function expand_databases_oss2_adm1()
{
	requires_variable OSS2_ADM1_HOSTNAME
	mount_scripts_directory $OSS2_ADM1_HOSTNAME
	#MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        #get_lock $MC_LOCK local na 7200 yes
	$SSH -qt $OSS2_ADM1_HOSTNAME "PATH=$PATH:/usr/ucb;export PATH;$MOUNTPOINT/bin/expand_databases.sh"
	#clear_lock $MC_LOCK local na
}
function create_caas_user_tss_adm1()
{
	requires_variable ADM1_HOSTNAME
	message "INFO: Creating caas user called $CAASADM_USER in tss and adding role Security_Management to it\n" INFO
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        get_lock $MC_LOCK local na 7200 yes
        mount_scripts_directory $ADM1_HOSTNAME
	wait_smtool_available_adm1
        $SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/userAdmin -create $CAASADM_USER;/opt/ericsson/bin/roleAdmin -add Security_Management $CAASADM_USER"
	clear_lock $MC_LOCK local na
}
function create_caas_user_tss_oss2_adm1()
{
	requires_variable OSS2_ADM1_HOSTNAME
	message "INFO: Creating caas user called $CAASADM_USER in tss and adding role Security_Management to it\n" INFO
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        get_lock $MC_LOCK local na 7200 yes
        mount_scripts_directory $OSS2_ADM1_HOSTNAME
	wait_smtool_available_oss2_adm1
        $SSH -qt $OSS2_ADM1_HOSTNAME "/opt/ericsson/bin/userAdmin -create $CAASADM_USER;/opt/ericsson/bin/roleAdmin -add Security_Management $CAASADM_USER"
	clear_lock $MC_LOCK local na
}
function install_vmware_tools_nedss()
{
	if [[ "$NEDSS_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi	
    requires_variable NEDSS_HOSTNAME
    install_vmware_tools $NEDSS_HOSTNAME
}
function install_vmware_tools_gateway()
{
        install_vmware_tools localhost no
}
function install_vmware_tools_sfs()
{
        if [[ "$SFS_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
	if [[ "$NASC" == "" ]]
	then
		return 0
	fi
        requires_variable NASC
	install_vmware_tools $NASC no support $NASSUPPWW
}
function install_vmware_tools_omservm()
{
	if [[ "$OMSERVM_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
	requires_variable OMSERVM_HOSTNAME
    install_vmware_tools $OMSERVM_HOSTNAME
}
function install_vmware_tools_omservs()
{
	if [[ "$OMSERVS_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable OMSERVS_HOSTNAME
    install_vmware_tools $OMSERVS_HOSTNAME
}
function install_vmware_tools_omsas()
{
	if [[ "$OMSAS_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable OMSAS_HOSTNAME
    install_vmware_tools $OMSAS_HOSTNAME
}
function install_vmware_tools_uas1()
{
	if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable UAS1_HOSTNAME
    install_vmware_tools $UAS1_HOSTNAME
}
function install_vmware_tools_peer1()
{
        if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable PEER1_HOSTNAME
    install_vmware_tools $PEER1_HOSTNAME
}
function install_vmware_tools_ebas()
{
	if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable EBAS_HOSTNAME
    install_vmware_tools $EBAS_HOSTNAME
}
function install_vmware_tools_mws()
{
	if [[ "$MWS_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable MWS_HOSTNAME
    install_vmware_tools $MWS_HOSTNAME
}
function install_vmware_tools_adm1()
{
	if [[ "$ADM1_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
	requires_variable ADM1_HOSTNAME
	install_vmware_tools $ADM1_HOSTNAME no
}
function install_vmware_tools_oss2_adm1()
{
	if [[ "$OSS2_ADM1_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
	requires_variable OSS2_ADM1_HOSTNAME
	install_vmware_tools $OSS2_ADM1_HOSTNAME no
}
function install_vmware_tools_adm2()
{
	if [[ "$ADM2_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable ADM2_HOSTNAME
    install_vmware_tools $ADM2_HOSTNAME no
}
function install_vmware_tools_eniqe()
{
	if [[ "$ENIQE_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
    requires_variable ENIQE_HOSTNAME
    install_vmware_tools $ENIQE_HOSTNAME no
}
function install_vmware_tools_cep()
{
	if [[ "$CEP_SERVER_TYPE" == "blade" ]]
	then
		return 0
	fi
	requires_variable CEP_HOSTNAME
	install_vmware_tools $CEP_HOSTNAME no
}
function install_vmware_tools_eniqs()
{
        if [[ "$ENIQS_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable ENIQS_HOSTNAME
    install_vmware_tools $ENIQS_HOSTNAME no
}
function install_vmware_tools_eniqsc()
{
        if [[ "$ENIQSC_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable ENIQSC_HOSTNAME
    install_vmware_tools $ENIQSC_HOSTNAME no
}
function install_vmware_tools_eniqse()
{
        if [[ "$ENIQSE_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable ENIQSE_HOSTNAME
    install_vmware_tools $ENIQSE_HOSTNAME no
}
function install_vmware_tools_eniqsr1()
{
        if [[ "$ENIQSR1_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable ENIQSR1_HOSTNAME
    install_vmware_tools $ENIQSR1_HOSTNAME no
}
function install_vmware_tools_eniqsr2()
{
        if [[ "$ENIQSR2_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable ENIQSR2_HOSTNAME
    install_vmware_tools $ENIQSR2_HOSTNAME no
}
function install_vmware_tools_son_vis()
{
        if [[ "$SON_VIS_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable SON_VIS_HOSTNAME
    install_vmware_tools $SON_VIS_HOSTNAME no
}
function install_vmware_tools_ms1()
{
        if [[ "$MS1_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable MS1_HOSTNAME
    install_vmware_tools $MS1_HOSTNAME no root 12shroot
}
function install_vmware_tools_sc1()
{
        if [[ "$SC1_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable SC1_HOSTNAME
    install_vmware_tools $SC1_HOSTNAME no root litpc0b6lEr
}
function install_vmware_tools_sc2 ()
{
        if [[ "$SC2_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
    requires_variable SC2_HOSTNAME
    install_vmware_tools $SC2_HOSTNAME no root litpc0b6lEr
}
function install_vmware_tools_netsim()
{
        requires_variable NETSIM_HOSTNAME
        install_vmware_tools $NETSIM_HOSTNAME
}
function add_cluster_node_adm1()
{
	add_cluster_node_prefix ADM1
}
function add_cluster_node_adm2()
{
	add_cluster_node_prefix ADM2
}
function add_cluster_node_prefix ()
{
	local SECONDARY_NODE_PREFIX=$1
	local PRIMARY_NODE_PREFIX=""

	if [[ $SECONDARY_NODE_PREFIX == "ADM1" ]]
	then
		PRIMARY_NODE_PREFIX="ADM2"
	else
		PRIMARY_NODE_PREFIX="ADM1"
	fi

	local PRIMARY_HOSTNAME=`eval echo \\$${PRIMARY_NODE_PREFIX}_HOSTNAME`
	local SECONDARY_HOSTNAME=`eval echo \\$${SECONDARY_NODE_PREFIX}_HOSTNAME`

	requires_variable PRIMARY_HOSTNAME
        mount_scripts_directory $PRIMARY_HOSTNAME
        $SSH -qt $PRIMARY_HOSTNAME "$MOUNTPOINT/bin/add_cluster_node.sh -c '$CONFIG' -m $MOUNTPOINT -p $SECONDARY_NODE_PREFIX"
	local EXIT_CODE=$?
	# The script exits 7 if the node is already part of the cluster
	if [[ $EXIT_CODE -ne 0 ]] && [[ $EXIT_CODE -ne 7 ]]
        then
                message "ERROR: There was a problem adding the second node to the cluster, see output above\n" ERROR
                exit 1
	fi
	if [[ $EXIT_CODE -eq 0 ]]
	then
		wait_until_not_pingable $SECONDARY_HOSTNAME
		wait_until_services_started $SECONDARY_HOSTNAME
	fi
	$SSH -qt $PRIMARY_HOSTNAME "$MOUNTPOINT/bin/maintain_ldap.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong running the maintain ldap command, see above for errors\n" ERROR
                exit 1
        fi
}
function install_vmware_tools()
{
	# Its not a vm, dont install vmware tools or update the md conf
	if [[ "$VIRTUAL" == "no" ]]
	then
		return 0
	fi

	local SERVER=$1
	local MD=$2
	local SSHUSER=$3
	local SSHPASS=$4

	if [[ "$SSHUSER" == "" ]]
	then
		SSHUSER="root"
	fi
	if [[ "$SSHPASS" == "" ]]
        then
                SSHPASS="shroot12"
        fi

	local UPDATE_MD_CONF=""

	if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
		#if [[ "$SERVER" == "localhost" ]]
		#then
		#	MOTD="-o no"
		#else
		#	MOTD="-o yes"
		#fi
		if [[ "$MD" == "no" ]]
		then
			UPDATE_MD_CONF="-d no"
		else
			UPDATE_MD_CONF="-d yes"
		fi
	else
		#MOTD="-o no"
		UPDATE_MD_CONF="-d no"
        fi
	
	mount_scripts_directory $SERVER dummy $SSHUSER $SSHPASS
	$SSH -qt $SERVER -l $SSHUSER "$MOUNTPOINT/bin/inst_vmtools.bsh -m $MOUNTPOINT $UPDATE_MD_CONF" 2>/dev/null
	if [[ "$UPDATE_MD_CONF" == "-d yes" ]]
	then
		# It might have come back up before we got here...
                # So might get stuck on not_pingable as already up
                # So just sleep and wait for it to come up
                #wait_until_not_pingable $SERVER
                sleep 300
                wait_until_sshable $SERVER
	fi

}
function update_md_conf ()
{
	local SERVER=$1
        mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/update_md_conf.sh -m $MOUNTPOINT"
}

function disable_iofence_clusterini_adm1 ()
{
	mount_scripts_directory $ADM1_HOSTNAME
	message "INFO: Disabling iofencing\n" INFO
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/disable_iofence_clusterini_adm1.sh -m $MOUNTPOINT"
}
function disable_iofence_clusterini_oss2_adm1 ()
{
	mount_scripts_directory $OSS2_ADM1_HOSTNAME
	message "INFO: Disabling iofencing\n" INFO
	$SSH -qt $OSS2_ADM1_HOSTNAME "$MOUNTPOINT/bin/disable_iofence_clusterini_adm1.sh -m $MOUNTPOINT"
}
function disable_iofence_vxfenmode_adm1 ()
{
        mount_scripts_directory $ADM1_HOSTNAME
        message "INFO: Disabling iofencing\n" INFO
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/disable_iofence_vxfenmode_adm1.sh -m $MOUNTPOINT"
}

function disable_iofence_vxfenmode_oss2_adm1 ()
{
        mount_scripts_directory $OSS2_ADM1_HOSTNAME
        message "INFO: Disabling iofencing\n" INFO
        $SSH -qt $OSS2_ADM1_HOSTNAME "$MOUNTPOINT/bin/disable_iofence_vxfenmode_adm1.sh -m $MOUNTPOINT"
}

function disable_oss_backup_crons_adm1 ()
{
	disable_oss_backup_crons_internal $ADM1_HOSTNAME
}

function disable_oss_backup_crons_oss2_adm1 ()
{
	disable_oss_backup_crons_internal $OSS2_ADM1_HOSTNAME
}

function disable_oss_backup_crons_internal ()
{
	local SERVER=$1
	mount_scripts_directory $SERVER
	message "INFO: Disabling database backup crons\n" INFO
	$SSH -qt $SERVER "$MOUNTPOINT/bin/disable_oss_backup_crons.sh"
}

function ipmp_workaround_adm1 ()
{
        mount_scripts_directory $ADM1_HOSTNAME
        message "INFO: Running ipmp workaround\n" INFO
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/ipmp_workaround.sh"
}

function ipmp_workaround_oss2_adm1 ()
{
        mount_scripts_directory $OSS2_ADM1_HOSTNAME
        message "INFO: Running ipmp workaround\n" INFO
        $SSH -qt $OSS2_ADM1_HOSTNAME "$MOUNTPOINT/bin/ipmp_workaround.sh"
}

function check_args()
{
	if [[ -z "$CONFIG" ]]
	then
		message "ERROR: You must give a config name\n" ERROR
		usage_msg
	else
		. $MOUNTPOINT/bin/load_config
	fi

	if [[ -z "$FUNCTION" ]]
	then
		message "ERROR: You must give a function\n" ERROR
		usage_msg
	fi

	if [[ ! `type $FUNCTION 2>/dev/null | grep "is a function"` ]]
	then
		message "$FUNCTION is not a valid function\n" ERROR
        	usage_msg
	fi

	if [[ "$BEHIND_GATEWAY" != "yes" ]]
	then
		ON_THE_GATEWAY="no"
	fi
}

function get_pingable_host ()
{
	local SERVER=$1
        local SSHUSER=$2
        local SSHPASS=$3
	local HOSTS=$4
	
	## Figure out where to mount the scripts from on this server first
        while read HOSTER
        do
		local output=""
		output=$($EXPECT << EOF
			set force_conservative 1
			set timeout 300
			
			
			spawn ssh -qtn -l $SSHUSER -o StrictHostKeyChecking=no "$SERVER" "ping -c 1 $HOSTER > /dev/null 2>&1"
			
			while 1 {
			expect {
				        "assword:" {
				                send "$SSHPASS\r"
				        }
					eof {
						catch wait result
						exit [lindex \$result 3]
					}
				        timeout {
				                send_user "Timed out\n"
				                exit 1
			        	}
				}
			}
EOF
)
                if [[ $? -eq 0 ]]
                then
			echo "$HOSTER"
			return 0
                fi
        done < <(echo "$HOSTS")

	message "ERROR: Unable to ping any of the host ips from $SERVER, please check why not, list of host ips below\n" ERROR
	message "$HOSTS\n" ERROR
	return 1
}

function find_matching_interface_ip ()
{
        local SERVER=$1
        local SSHUSER=$2
        local SSHPASS=$3
        local DEST_IP=$4
        local DEST_NETMASK=$5

        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
                echo -n "$SERVER"
                return 0
        fi

        setup_passwordless_ssh $SERVER $SSHUSER $SSHPASS

        ## Get the list of networks from the input server
	local NETWORKS="`ssh $SERVER netstat -nr | grep '\.'`"
	if [[ ! `echo "$NETWORKS" | grep '\.'` ]]
        then
                message "ERROR: Couldn't figure out the networks from $SERVER\n" ERROR
                return 1
        fi

        ## Calculate the network for the destination
	local DEST_NETWORK="`ipcalc $DEST_IP $DEST_NETMASK -ns | awk -F= '{print $2}'`"
	if [[ ! `echo "$DEST_NETWORK" | grep '\.'` ]]
	then
		message "ERROR: Couldn't figure out the network for this ip and netmask $DEST_IP $DEST_NETMASK\n" ERROR
		return 1
	fi

	# Loop through the networks and compare
	while read NETWORK_LINE
	do
		local NETWORK=`echo "$NETWORK_LINE" | awk '{print $1}'`
		if [[ "$DEST_NETWORK" == "$NETWORK" ]]
		then
			local NIC=`echo "$NETWORK_LINE" | awk '{print $6}'`
			local NIC_OUTPUT="`ssh $SERVER /usr/sbin/ifconfig $NIC`"
			local NIC_OUTPUT_FORMATTED="`echo \"$NIC_OUTPUT\" | awk '/inet/ {print $2}'`"
			if [[ `echo "$NIC_OUTPUT_FORMATTED" |  grep '\.'` ]]
			then
				echo -n "$NIC_OUTPUT_FORMATTED"
				return 0
			fi
		fi
	done < <(echo "$NETWORKS")

        message "ERROR: Unable to find a nic on $SERVER thats on the same network as $DEST_IP, please fix this and try again, list of networks from $SERVER below\n" ERROR
        message "$NETWORKS\n" ERROR
        return 1
}

function configure_passwordless_ssh_omsrv()
{
	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]]
	then
		setup_remote_passwordless_ssh $OMSERVM_HOSTNAME $OMSERVS_HOSTNAME
		setup_remote_passwordless_ssh $OMSERVS_HOSTNAME $OMSERVM_HOSTNAME
	fi
}

function setup_remote_passwordless_ssh()
{
	FROM_SERVER=$1
	TO_SERVER=$2
	message "INFO: Setting up passwordless ssh between $FROM_SERVER and $TO_SERVER\n" INFO
	mount_scripts_directory $FROM_SERVER
	$SSH -qt $FROM_SERVER "$MOUNTPOINT/bin/sol11_setup_remote_passwordless_ssh.sh -m $MOUNTPOINT -t $TO_SERVER"
	local EXIT_CODE=$?
        if [[ $EXIT_CODE -ne 0 ]]
        then
                message "ERROR: Something went wrong setting up passwordless ssh between $FROM_SERVER and $TO_SERVER\n" ERROR
                exit 1
	else
		message "INFO: Passwordless ssh is now working between $FROM_SERVER and $TO_SERVER\n" INFO
        fi
}

function setup_passwordless_ssh()
{
	local SERVER=$1
	local SSHUSER=$2
	local SSHPASS=$3
	
	if [[ "$SSHUSER" == "" ]]
	then
		SSHUSER="root"
	fi
	if [[ "$SSHPASS" == "" ]]
	then
		SSHPASS="shroot12"
	fi
#echo -n "Checking passwordless ssh to $SERVER: "
ssh -qtn -l $SSHUSER -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 "$SERVER" ls > /dev/null 2>&1
if [ $? -eq 0 ]
then
        #echo "OK"
	return 0
fi
	message "INFO: Setting up passwordless ssh to $SERVER\n" INFO
	KNOWN_HOSTS_LOCK="/tmp/.known_hosts_lock"
	get_lock $KNOWN_HOSTS_LOCK local na 600 yes
	cat $HOME/.ssh/known_hosts | grep -v "^$SERVER," | grep -v "^$SERVER " > $HOME/.ssh/known_hosts.temp
	mv $HOME/.ssh/known_hosts.temp $HOME/.ssh/known_hosts
	clear_lock $KNOWN_HOSTS_LOCK local na

	if [[ ! -f $HOME/.ssh/id_rsa ]]
	then
        	ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" >/dev/null 2>&1
	fi
	local SCRIPTHOST=""
	SCRIPTHOST=`get_pingable_host $SERVER $SSHUSER $SSHPASS "$SCRIPTHOSTS"`
	if [[ $? -ne 0 ]]
	then
		echo "$SCRIPTHOST"
		return 1
	fi
local COMMAND1="umount $SCRIPTMOUNT > /dev/null 2>&1;mkdir -p $MOUNTPOINT > /dev/null 2>&1;mount -o vers=3 $SCRIPTHOST:$SCRIPTMOUNT $SCRIPTMOUNT"
local COMMAND2="$MOUNTPOINT/bin/setup_passwordless_ssh.sh '`cat $HOME/.ssh/id_rsa.pub`'"
local output=$($EXPECT << EOF
set force_conservative 1
set timeout 300


spawn ssh -qtn -l $SSHUSER -o StrictHostKeyChecking=no "$SERVER" "$COMMAND1;$COMMAND2"

while 1 {
expect {
	"ew Password:" {
		send_user "\nCurrently cant handle passwords expiring\n"
		exit 1
	}
        "assword:" {
                send "$SSHPASS\r"
        }
        eof {
                break
        }
        timeout {
                send_user "Timed out\n"
                exit 1
        }
}
}
EOF
)
sleep 2
#ssh -qtn -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 "$SERVER" < /dev/null > /dev/null 2>&1
ssh -qtn -l $SSHUSER -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 "$SERVER" ls > /dev/null 2>&1
if [ $? -eq 0 ]
then
        #echo "Passwordless ssh is working towards $SERVER"
        return 0
else
        message "Failed to setup passwordless ssh towards $SERVER\n" ERROR
	message "$output\n" ERROR
        return 1
fi

}
function setup_adm1_ssh_keys ()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME
	message "INFO: Setting up root and nmsadm ssh keys on adm1\n" INFO
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/sol11_setup_adm1_ssh_keys.sh"
}
function share_local_filesystem()
{
	local FILESYSTEM=$1
	#echo "INFO: Sharing filesystem"
	local OS=`uname`
	if [[ "$OS" == "Linux" ]]
	then
		#echo "INFO: Its a Linux OS"
		exportfs *:$FILESYSTEM
	elif [[ "$OS" == "SunOS" ]]
	then
		#echo "INFO: Its a Sun OS"
		share -F nfs -o rw $FILESYSTEM
	else
		message "ERROR: Unrecognized operating system type $ARCH, exiting as don't know how to share the filesystem\n" ERROR
		exit 1
	fi
	
}
function mount_scripts_directory()
{
	local SSHTEST=""
	local SERVER=$1
	local ACTION=""
	local SSHUSER=$3
	local SSHPASS=$4

	if [[ "$SSHUSER" == "" ]]
        then
                SSHUSER="root"
        fi
        if [[ "$SSHPASS" == "" ]]
        then
                SSHPASS="shroot12"
        fi

	if [[ "$2" == "noexit" ]]
	then
		ACTION="return 1"
	else
		ACTION="exit 1"
	fi
       # echo "INFO: Pinging $SERVER"
        ping -c 2 $SERVER >> /dev/null 2>&1
        if [ $? -eq 0 ]; then
            # echo "INFO: $SERVER is alive"
       	    setup_passwordless_ssh $SERVER $SSHUSER $SSHPASS
            if [ $? -ne 0 ]; then
		$ACTION
            #else
            #    echo "INFO: $SERVER trusts me"
            fi
        else
            echo "ping failed, checking the command again"
	    ping -c 2 $SERVER
	    message "ERROR: $SERVER is not alive\n" ERROR
		$ACTION
        fi

	##########################################################
	#If its already mounted dont do it again
	##########################################################
	SSHTEST=$($EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 300
spawn $SSH -qtn -l $SSHUSER $SERVER "ls $SCRIPTMOUNT/CLOUD/SOLARIS11/bin/" 2>/dev/null

while {"1" == "1"} {
        expect {
        timeout {
                exit 1
        }
        eof {
                catch wait result
                exit [lindex \$result 3]
        }

        }
EOF
)
                #SSHTEST=`$SSH -qtn $SERVER "ls $SCRIPTMOUNT/CLOUD_xlaxain/bin/" 2>/dev/null`
                echo "$SSHTEST" | grep "master.sh" > /dev/null 2>&1
                if [ $? -eq 0 ] ;then
                        return 0
		fi
        #echo "INFO: Checking mountpoints for $SERVER"
        #$SSH -qtn $SERVER "umount $SCRIPTMOUNT" > /dev/null 2>&1
	local ATTEMPT=1
	while [[ $ATTEMPT -le 60 ]]
	do
		local SCRIPTHOST=""
		SCRIPTHOST=`get_pingable_host $SERVER $SSHUSER $SSHPASS "$SCRIPTHOSTS"`
	        if [[ $? -ne 0 ]]
	        then
			echo "$SCRIPTHOST"
	                return 1
        	fi
		$SSH -qtn -l $SSHUSER $SERVER "mkdir -p $SCRIPTMOUNT" > /dev/null 2>&1
		$SSH -qtn -l $SSHUSER $SERVER "mount -o vers=3 $SCRIPTHOST:$SCRIPTMOUNT $SCRIPTMOUNT" > /dev/null 2>&1

		SSHTEST=$($EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 300
spawn $SSH -qtn -l $SSHUSER $SERVER "ls $SCRIPTMOUNT/CLOUD/SOLARIS11/bin/" 2>/dev/null

while {"1" == "1"} {
        expect {
        timeout {
                exit 1
        }
        eof {
                catch wait result
                exit [lindex \$result 3]
        }

        }
EOF
)
		#SSHTEST=`$SSH -qtn $SERVER "ls $SCRIPTMOUNT/CLOUD_xlaxain/bin/" 2>/dev/null`
	        echo "$SSHTEST" | grep "master.sh" > /dev/null 2>&1
	        if [ $? -eq 0 ] ;then
			break
		elif [[ "$2" == "noexit" ]]
		then
			echo "INFO: $SERVER Cannot find scripts on $SCRIPTHOST but not retrying"
			return 0
	        else
			message "ERROR: $SERVER Cannot find scripts on $SCRIPTHOST\n" WARNING
			if [[ $ATTEMPT -ne 60 ]]
			then
				message "ERROR: Trying again in 10 seconds...\n" WARNING
				sleep 10
			else
				$ACTION
				message "ERROR: $SERVER Couldn't find scripts on $SCRIPTHOST\n" ERROR
			fi
	        fi
		let ATTEMPT=ATTEMPT+1
        done
        #$SSH -qtn $SERVER "touch $MOUNTPOINT/touchtest.$$" > /dev/null 2>&1

        #SSHTEST=`$SSH -qtn $SERVER "/bin/ls $MOUNTPOINT | grep touchtest.$$" 2>&1`
        #echo $SSHTEST | grep touchtest.$$ >> /dev/null 2>&1
        #if [ $? -eq 0 ];then
            #echo "INFO: $SERVER has write access to $MOUNTPOINT"
        #    $SSH -qtn $SERVER "rm $MOUNTPOINT/touchtest.$$" > /dev/null
        #else
         #   echo "WARNING: $SERVER cannot write to $MOUNTPOINT"
        #fi
}

function mount_directory ()
{
	local SERVER=$1
	mount_scripts_directory $SERVER
	message "INFO: Mounting $2 from $4 at $3 on $SERVER: " INFO
	local OUTPUT=""
	OUTPUT=`$SSH -qt $SERVER "$MOUNTPOINT/bin/mount_directory.sh $2 $3 $4"`
	if [[ $? -eq 0 ]]
	then
		message "OK\n" INFO
	else
		message "NOK, output below\n" ERROR
		message "-------------------------------------------\n" ERROR
		message "$OUTPUT\n" ERROR
		message "-------------------------------------------\n" ERROR
	fi
}
function validate_onrm_root_mo ()
{
	local DESIRED=$1
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/validate_onrm_root_mo.sh $DESIRED"
}

function verify_timezone ()
{
	local SERVER=$1
	requires_variable TIMEZONE
	mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/verify_timezone.sh $TIMEZONE"
}
function verify_ntp_server ()
{
	local SERVER=$1
	requires_variable NTP_SOURCE
	mount_scripts_directory $SERVER
        $SSH -qt $SERVER "$MOUNTPOINT/bin/verify_ntp_server.sh $NTP_SOURCE"
}
function alter_sybase_db_size ()
{
        local DB_NAME=$1
        local DDEV_SIZE=$2
        if [[ "$3" != "" ]]
        then
                LDEV_SIZE="-l $3"
        fi

        requires_variable ADM1_HOSTNAME
        requires_variable SQL_DEF_USER_PW
        mount_scripts_directory $ADM1_HOSTNAME
        message "INFO: Altering the size of the $DB_NAME sybase database: " INFO
	local OUTPUT=""
        OUTPUT=`$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/alter_sybase_db_size.sh  -c '$CONFIG' -m $MOUNTPOINT -n $DB_NAME -d $DDEV_SIZE $LDEV_SIZE -p $SQL_DEF_USER_PW"`
	if [[ $? -eq 0 ]]
        then
                message "OK\n" INFO
        else
                message "NOK, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
        fi
}
function all_wlr_post_steps ()
{
	disable_password_expiry
        disable_password_lockout
        disable_password_must_change
        remove_password_change_history
        reduce_min_password_length
	create_users_config
	manage_mcs_config
}
function all_rno_post_steps ()
{
	requires_variable ADM1_HOSTNAME
	mount_directory $ADM1_HOSTNAME RELEASES /opt/rational/releases 10.44.80.51:/export/backups2/rational/releases
	mount_directory $ADM1_HOSTNAME CONFIG /opt/rational/config 10.44.80.51:/export/backups2/rational/config
	mount_directory $ADM1_HOSTNAME BASE /opt/rational/base 10.44.80.51:/export/backups2/rational/base

}
function all_eth_post_steps ()
{
	requires_variable ADM1_HOSTNAME
	requires_variable UAS1_HOSTNAME
	echo_line

	# Validate the onrm root mo value
	validate_onrm_root_mo "ONRM_ROOT_MO"
	echo_line

	## Mount squish 
	mount_directory $ADM1_HOSTNAME squish /opt/squish 159.107.177.22:/ETH/app/squish
	mount_directory $UAS1_HOSTNAME squish /opt/squish 159.107.177.22:/ETH/app/squish

	## Mount purify
	mount_directory $ADM1_HOSTNAME base /opt/rational/base 159.107.177.22:/ETH/app/purify/7.0.0.0-010/base   
	mount_directory $ADM1_HOSTNAME releases /opt/rational/releases 159.107.177.22:/ETH/app/purify/7.0.0.0-010/releases
	mount_directory $ADM1_HOSTNAME config /opt/rational/config 159.107.177.22:/ETH/app/purify/7.0.0.0-010/config   

	## Mount clearcase
	mount_directory $ADM1_HOSTNAME clearcase /proj/ccbtcs eieatna002.athtem.eei.ericsson.se:/vol/cctcs
	mount_directory $UAS1_HOSTNAME clearcase /proj/ccbtcs eieatna002.athtem.eei.ericsson.se:/vol/cctcs
        if [[ "$NETSIM_HOSTNAME" != "" ]]
        then
		mount_directory $NETSIM_HOSTNAME clearcase /proj/ccbtcs eieatna002.athtem.eei.ericsson.se:/vol/cctcs
        fi

	## Mount shmprod
	mount_directory $ADM1_HOSTNAME shmprod /proj/shmprod liproj2.lmera.ericsson.se:/vol/volp0621/shmprod
	mount_directory $UAS1_HOSTNAME shmprod /proj/shmprod liproj2.lmera.ericsson.se:/vol/volp0621/shmprod
	
	## Mount ossrc
	mount_directory $ADM1_HOSTNAME ossrc /proj/ossrc liproj2.lmera.ericsson.se:/vol/volp0615/ossrc
	mount_directory $UAS1_HOSTNAME ossrc /proj/ossrc liproj2.lmera.ericsson.se:/vol/volp0615/ossrc
	if [[ "$NETSIM_HOSTNAME" != "" ]]
	then
		mount_directory $NETSIM_HOSTNAME ossrc /proj/ossrc liproj2.lmera.ericsson.se:/vol/volp0615/ossrc
	fi

	mount_directory $ADM1_HOSTNAME athossrc /proj/athossrc eieatna002.athtem.eei.ericsson.se:/vol/seli0230m/ossrc
        mount_directory $UAS1_HOSTNAME athossrc /proj/athossrc eieatna002.athtem.eei.ericsson.se:/vol/seli0230m/ossrc
        if [[ "$NETSIM_HOSTNAME" != "" ]]
        then
                mount_directory $NETSIM_HOSTNAME athossrc /proj/athossrc eieatna002.athtem.eei.ericsson.se:/vol/seli0230m/ossrc
        fi

        mount_directory $ADM1_HOSTNAME ccbeth /proj/ccbeth eieatna0003.ie.eu.ericsson.se:/vol/vol0312/unix-proj/at/ccbeth
        mount_directory $UAS1_HOSTNAME ccbeth /proj/ccbeth eieatna0003.ie.eu.ericsson.se:/vol/vol0312/unix-proj/at/ccbeth
        if [[ "$NETSIM_HOSTNAME" != "" ]]
        then
                mount_directory $NETSIM_HOSTNAME ccbeth /proj/ccbeth eieatna0003.ie.eu.ericsson.se:/vol/vol0312/unix-proj/at/ccbeth
        fi

        mount_directory $ADM1_HOSTNAME nss /proj/nss liproj2.lmera.ericsson.se:/vol/volp0612/nss
        mount_directory $UAS1_HOSTNAME nss /proj/nss liproj2.lmera.ericsson.se:/vol/volp0612/nss
        if [[ "$NETSIM_HOSTNAME" != "" ]]
        then
                mount_directory $NETSIM_HOSTNAME nss /proj/nss liproj2.lmera.ericsson.se:/vol/volp0612/nss
        fi
        echo_line

        if [[ "$NETSIM_HOSTNAME" != "" ]]
        then
                message "INFO: Updating ftp.conf file on netsim\n" INFO
                mount_scripts_directory $NETSIM_HOSTNAME
                $SSH -qTn $NETSIM_HOSTNAME "$MOUNTPOINT/bin/update_netsim_ftp_conf.sh"
                echo_line
        fi
	
	## Enable security no ms
	enable_ms_security
	echo_line
	## Generic ipv4 ipv6 setup - TODO, waiting on feedback from Ray

	## Set swap to 16gb - TODO - waiting on feedback from John Cunningham

	## Disable screensavers
        disable_screensavers
	echo_line

	## User accounts - uses USER_LIST variable in config
	#create_users_config
	#echo_line
	## Clearcase setup on servers - TODO, get clarification from Ray

	## All MCs online/offline, TODO: decide how variables get taken in
	#manage_mcs_config
	#echo_line

	## Verify ntp - TODO
	verify_ntp_server $ADM1_HOSTNAME
	echo_line

	## Verify timezone - TODO, which servers, need to find out from Ray
	verify_timezone $ADM1_HOSTNAME
	echo_line

	## Grow partitions - done - needs testing
	resize_volume ossdg/ericsson 30 GB
	resize_volume ossdg/segment1 5 GB
	resize_volume ossdg/eba_ebsw 4 GB
	resize_volume ossdg/eba_ebss 4 GB
	resize_volume ossdg/eba_rsdm 4 GB
	resize_volume ossdg/eba_rtt 4 GB
	resize_volume ossdg/eba_rede 2 GB
	resize_volume ossdg/sybdata 30 GB
	resize_volume ossdg/syblog 14 GB
	echo_line

	## Change nmsadm password - done - needs testing
	update_nmsadm_password_config
	echo_line

	## Change root password - done - need to know what servers to run on though, Ray?
	update_root_password $ADM1_HOSTNAME "shroot12"
	echo_line

	## DB Changes - done - needs testing and error checking
	#alter_sybase_db_size rnxdb 500M 2G
        alter_sybase_db_size ffaxblrdb 500M
        alter_sybase_db_size cnadb 2G 500M
        #alter_sybase_db_size smlogdb 3G 2G
	echo_line
}
function all_security_post_steps ()
{
	if [[ "$ADM1_HOSTNAME" != "" ]]
	then
		update_root_password $ADM1_HOSTNAME "sec94ft9"
	fi
        if [[ "$OSS2_ADM1_HOSTNAME" != "" ]]
	then
		update_root_password $OSS2_ADM1_HOSTNAME "sec94ft9"
	fi
	if [[ "$UAS1_HOSTNAME" != "" ]]
	then
		update_root_password $UAS1_HOSTNAME "sec94ft9"
	fi
	if [[ "$OMSERVM_HOSTNAME" != "" ]]
	then
		update_root_password $OMSERVM_HOSTNAME "sec94ft9"
	fi
	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]]
	then
		update_root_password $OMSERVS_HOSTNAME "sec94ft9"
	fi
	if [[ "$OMSAS_HOSTNAME" != "" ]]
	then
		update_root_password $OMSAS_HOSTNAME "sec94ft9"
	fi
	if [[ "$NEDSS_HOSTNAME" != "" ]]
	then
		update_root_password $NEDSS_HOSTNAME "sec94ft9"
	fi
	if [[ "$EBAS_HOSTNAME" != "" ]]
	then
		update_root_password $EBAS_HOSTNAME "sec94ft9"
	fi

	message "INFO: Populating the /etc/hosts file on $ADM1_HOSTNAME with node ips\n"
	local IPS='159.107.175.60  RNC54
159.107.181.132 RNC132
159.107.178.78  RBS214
10.64.208.12   lienb0512
10.64.208.11   lienb0511'
	local IP=""
	echo "$IPS" | while read line
	do
		IP=`echo "$line" | awk '{print $1}'`
		$SSH -qtn $ADM1_HOSTNAME "cat /etc/hosts | grep -v '$IP' > /etc/hosts.tmp;echo '$line' >> /etc/hosts.tmp;mv /etc/hosts.tmp /etc/hosts" > /dev/null 2>&1
	done
	#
	message "INFO: Running pwAdmin for scsuser and neuser on $ADM1_HOSTNAME\n"
	$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/pwAdmin -changePw infra SFTP scsuser -pw sec94ft9"
	$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/pwAdmin -changePw infra SFTP neuser -pw sec94ft9"
	$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/bin/pwAdmin -create infra SECURE ipsecsmrs -pw sec94ft9"

	setup_replication_detect

	security_netsim_steps

	# Mount the FT directory and run the health checks
	mount_directory $ADM1_HOSTNAME ft /FT 10.44.80.68:/FTshared
	#$SSH -qt $ADM1_HOSTNAME "cd /FT/test_support_tools/install_checklist/;./serverhealthcheckMU.py $ADM1_HOSTNAME/$UAS1_HOSTNAME"
}
function update_root_password ()
{
	local SERVER=$1
	local NEW_PASS=$2
	mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/update_root_password.sh -m $MOUNTPOINT -n $NEW_PASS"
}
function disable_screensavers()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME
	message "INFO: Disabling screensavers: " INFO
	$SSH -qt $ADM1_HOSTNAME "mv /usr/openwin/lib/xscreensaver/hacks /usr/openwin/lib/xscreensaver/disable_screensaver > /dev/null 2>&1"
	message "OK\n" INFO
}

function config_gateway ()
{
	if [[ "$BEHIND_GATEWAY" != "yes" ]]
        then
		return 0
	fi
	message "INFO: Configuring gateway\n" INFO
	$MOUNTPOINT/bin/config_gateway.bsh
	install_vmware_tools_gateway
}

function parallel_requirements ()
{
	for requirement in $1
        do
		message "INFO: Waiting for required process to complete ($requirement): " INFO
                while [[ "a" != "b" ]]
                do
                        if [[ -f /tmp/$PARENT_BASHPID/status/$requirement.status ]]
                        then
                                if [[ `cat /tmp/$PARENT_BASHPID/status/$requirement.status | wc -l` > 0 ]]
                                then
                                        if [[ "`cat /tmp/$PARENT_BASHPID/status/$requirement.status`" == "0" ]]
                                        then
                                                echo "OK"
                                                break
                                        else
                                                echo "NOK: Required process didn't complete successfully, exiting"
                                                exit 123
                                        fi
                                else
                                        sleep 1
                                fi
                        else
                                sleep 1
                        fi
		done
        done
}

function nightly_dm_sequence ()
{
	. $MOUNTPOINT/bin/nightly_dm_sequence.sh
}

function nightly_assure_sequence ()
{
        . $MOUNTPOINT/bin/nightly_assure_sequence.sh
}

function full_rollout ()
{
	INITIAL_INSTALL_ADM1="yes"
		INITIAL_INSTALL_ADM1_PART1="yes"
		INITIAL_INSTALL_ADM1_PART2="yes"
        INITIAL_INSTALL_OSS2_ADM1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART2="yes"
        INITIAL_INSTALL_ADM2="yes"
		INITIAL_INSTALL_ADM2_PART1="yes"
		INITIAL_INSTALL_ADM2_PART2="yes"
        INITIAL_INSTALL_OMSAS="yes"
		INITIAL_INSTALL_OMSAS_PART1="yes"
		INITIAL_INSTALL_OMSAS_PART2="yes"
        INITIAL_INSTALL_OMSERVM="yes"
		INITIAL_INSTALL_OMSERVM_PART1="yes"
		INITIAL_INSTALL_OMSERVM_PART2="yes"
        INITIAL_INSTALL_OMSERVS="yes"
		INITIAL_INSTALL_OMSERVS_PART1="yes"
		INITIAL_INSTALL_OMSERVS_PART2="yes"
        INITIAL_INSTALL_UAS1="yes"
		INITIAL_INSTALL_UAS1_PART1="yes"
		INITIAL_INSTALL_UAS1_PART2="yes"
	INITIAL_INSTALL_PEER1="yes"
                INITIAL_INSTALL_PEER1_PART1="yes"
                INITIAL_INSTALL_PEER1_PART2="yes"
        INITIAL_INSTALL_NEDSS="yes"
		INITIAL_INSTALL_NEDSS_PART1="yes"
		INITIAL_INSTALL_NEDSS_PART2="yes"
        INITIAL_INSTALL_EBAS="yes"
		INITIAL_INSTALL_EBAS_PART1="yes"
		INITIAL_INSTALL_EBAS_PART2="yes"
		INITIAL_INSTALL_MWS="no"
		INITIAL_INSTALL_MWS_PART1="no"
		INITIAL_INSTALL_MWS_PART2="no"
	INITIAL_INSTALL_ENIQE="yes"
		INITIAL_INSTALL_ENIQE_PART1="yes"
		INITIAL_INSTALL_ENIQE_PART2="yes"
	INITIAL_INSTALL_CEP="yes"
		INITIAL_INSTALL_CEP_PART1="yes"
		INITIAL_INSTALL_CEP_PART2="yes"
	INITIAL_INSTALL_ENIQS="yes"
                INITIAL_INSTALL_ENIQS_PART1="yes"
                INITIAL_INSTALL_ENIQS_PART2="yes"
	INITIAL_INSTALL_ENIQSC="yes"
                INITIAL_INSTALL_ENIQSC_PART1="yes"
                INITIAL_INSTALL_ENIQSC_PART2="yes"
	INITIAL_INSTALL_ENIQSE="yes"
                INITIAL_INSTALL_ENIQSE_PART1="yes"
                INITIAL_INSTALL_ENIQSE_PART2="yes"
	INITIAL_INSTALL_ENIQSR1="yes"
                INITIAL_INSTALL_ENIQSR1_PART1="yes"
                INITIAL_INSTALL_ENIQSR1_PART2="yes"
	INITIAL_INSTALL_ENIQSR2="yes"
                INITIAL_INSTALL_ENIQSR2_PART1="yes"
                INITIAL_INSTALL_ENIQSR2_PART2="yes"
	INITIAL_INSTALL_SON_VIS="yes"
		INITIAL_INSTALL_SON_VIS_PART1="yes"
		INITIAL_INSTALL_SON_VIS_PART2="yes"
	INITIAL_INSTALL_NETSIM="no"
		INITIAL_INSTALL_NETSIM_PART2="no"
		INITIAL_INSTALL_NETSIM_PART2="no"
	INITIAL_INSTALL_TOR="yes"
		INITIAL_INSTALL_TOR_PART1="yes"

	POST_INSTALL_ADM1="yes"
        POST_INSTALL_ADM2="yes"
	#POST_INSTALL_OMSAS="yes"
	POST_INSTALL_OMSAS="no"
	POST_INSTALL_OMSERVM="yes"
	POST_INSTALL_OMSERVS="yes"
	POST_INSTALL_UAS1="yes"
	POST_INSTALL_PEER1="yes"
	POST_INSTALL_NEDSS="yes"
	POST_INSTALL_EBAS="yes"
	POST_INSTALL_MWS="no"
	POST_INSTALL_NETSIM="no"

	rollout_config
}

function initial_rollout ()
{
	INITIAL_INSTALL_ADM1="yes"
                INITIAL_INSTALL_ADM1_PART1="yes"
                INITIAL_INSTALL_ADM1_PART2="yes"
        INITIAL_INSTALL_OSS2_ADM1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART2="yes"
        INITIAL_INSTALL_ADM2="yes"
                INITIAL_INSTALL_ADM2_PART1="yes"
                INITIAL_INSTALL_ADM2_PART2="yes"
        INITIAL_INSTALL_OMSAS="yes"
                INITIAL_INSTALL_OMSAS_PART1="yes"
                INITIAL_INSTALL_OMSAS_PART2="yes"
        INITIAL_INSTALL_OMSERVM="yes"
                INITIAL_INSTALL_OMSERVM_PART1="yes"
                INITIAL_INSTALL_OMSERVM_PART2="yes"
        INITIAL_INSTALL_OMSERVS="yes"
                INITIAL_INSTALL_OMSERVS_PART1="yes"
                INITIAL_INSTALL_OMSERVS_PART2="yes"
        INITIAL_INSTALL_UAS1="yes"
                INITIAL_INSTALL_UAS1_PART1="yes"
                INITIAL_INSTALL_UAS1_PART2="yes"
        INITIAL_INSTALL_PEER1="yes"
                INITIAL_INSTALL_PEER1_PART1="yes"
                INITIAL_INSTALL_PEER1_PART2="yes"
        INITIAL_INSTALL_NEDSS="yes"
                INITIAL_INSTALL_NEDSS_PART1="yes"
                INITIAL_INSTALL_NEDSS_PART2="yes"
        INITIAL_INSTALL_EBAS="yes"
                INITIAL_INSTALL_EBAS_PART1="yes"
                INITIAL_INSTALL_EBAS_PART2="yes"
        INITIAL_INSTALL_MWS="no"
                INITIAL_INSTALL_MWS_PART1="no"
                INITIAL_INSTALL_MWS_PART2="no"
        INITIAL_INSTALL_ENIQE="yes"
                INITIAL_INSTALL_ENIQE_PART1="yes"
                INITIAL_INSTALL_ENIQE_PART2="yes"
	INITIAL_INSTALL_CEP="yes"
		INITIAL_INSTALL_CEP_PART1="yes"
		INITIAL_INSTALL_CEP_PART2="yes"
	INITIAL_INSTALL_ENIQS="yes"
                INITIAL_INSTALL_ENIQS_PART1="yes"
                INITIAL_INSTALL_ENIQS_PART2="yes"
	INITIAL_INSTALL_ENIQSC="yes"
                INITIAL_INSTALL_ENIQSC_PART1="yes"
                INITIAL_INSTALL_ENIQSC_PART2="yes"
        INITIAL_INSTALL_ENIQSE="yes"
                INITIAL_INSTALL_ENIQSE_PART1="yes"
                INITIAL_INSTALL_ENIQSE_PART2="yes"
        INITIAL_INSTALL_ENIQSR1="yes"
                INITIAL_INSTALL_ENIQSR1_PART1="yes"
                INITIAL_INSTALL_ENIQSR1_PART2="yes"
        INITIAL_INSTALL_ENIQSR2="yes"
                INITIAL_INSTALL_ENIQSR2_PART1="yes"
                INITIAL_INSTALL_ENIQSR2_PART2="yes"
	INITIAL_INSTALL_SON_VIS="yes"
		INITIAL_INSTALL_SON_VIS_PART1="yes"
		INITIAL_INSTALL_SON_VIS_PART2="yes"
	INITIAL_INSTALL_NETSIM="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
	INITIAL_INSTALL_TOR="yes"
                INITIAL_INSTALL_TOR_PART1="yes"

        POST_INSTALL_ADM1="no"
        POST_INSTALL_ADM2="no"
        POST_INSTALL_OMSAS="no"
        POST_INSTALL_OMSERVM="no"
        POST_INSTALL_OMSERVS="no"
        POST_INSTALL_UAS1="no"
		POST_INSTALL_MWS="no"
	POST_INSTALL_PEER1="no"
        POST_INSTALL_NEDSS="no"
        POST_INSTALL_EBAS="no"
	POST_INSTALL_NETSIM="no"

	rollout_config
}

function initial_rollout_part1 ()
{
	
	INITIAL_INSTALL_ADM1="yes"
		INITIAL_INSTALL_ADM1_PART1="yes"
		INITIAL_INSTALL_ADM1_PART2="no"
        INITIAL_INSTALL_OSS2_ADM1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART2="no"
        INITIAL_INSTALL_ADM2="yes"
		INITIAL_INSTALL_ADM2_PART1="yes"
		INITIAL_INSTALL_ADM2_PART2="no"
        INITIAL_INSTALL_OMSAS="yes"
		INITIAL_INSTALL_OMSAS_PART1="yes"
		INITIAL_INSTALL_OMSAS_PART2="yes"
        INITIAL_INSTALL_OMSERVM="yes"
		INITIAL_INSTALL_OMSERVM_PART1="yes"
		INITIAL_INSTALL_OMSERVM_PART2="no"
        INITIAL_INSTALL_OMSERVS="yes"
		INITIAL_INSTALL_OMSERVS_PART1="yes"
		INITIAL_INSTALL_OMSERVS_PART2="no"
        INITIAL_INSTALL_UAS1="yes"
		INITIAL_INSTALL_UAS1_PART1="yes"
		INITIAL_INSTALL_UAS1_PART2="no"
	INITIAL_INSTALL_PEER1="yes"
                INITIAL_INSTALL_PEER1_PART1="yes"
                INITIAL_INSTALL_PEER1_PART2="no"
        INITIAL_INSTALL_NEDSS="yes"
		INITIAL_INSTALL_NEDSS_PART1="yes"
		INITIAL_INSTALL_NEDSS_PART2="no"
        INITIAL_INSTALL_EBAS="yes"
		INITIAL_INSTALL_EBAS_PART1="yes"
		INITIAL_INSTALL_EBAS_PART2="no"
        INITIAL_INSTALL_MWS="no"
		INITIAL_INSTALL_MWS_PART1="no"
		INITIAL_INSTALL_MWS_PART2="no"
	INITIAL_INSTALL_ENIQE="yes"
		INITIAL_INSTALL_ENIQE_PART1="yes"
		INITIAL_INSTALL_ENIQE_PART2="no"
	INITIAL_INSTALL_CEP="yes"
		INITIAL_INSTALL_CEP_PART1="yes"
		INITIAL_INSTALL_CEP_PART2="no"
	INITIAL_INSTALL_ENIQS="yes"
                INITIAL_INSTALL_ENIQS_PART1="yes"
                INITIAL_INSTALL_ENIQS_PART2="no"
	INITIAL_INSTALL_ENIQSC="yes"
                INITIAL_INSTALL_ENIQSC_PART1="yes"
                INITIAL_INSTALL_ENIQSC_PART2="no"
        INITIAL_INSTALL_ENIQSE="yes"
                INITIAL_INSTALL_ENIQSE_PART1="yes"
                INITIAL_INSTALL_ENIQSE_PART2="no"
        INITIAL_INSTALL_ENIQSR1="yes"
                INITIAL_INSTALL_ENIQSR1_PART1="yes"
                INITIAL_INSTALL_ENIQSR1_PART2="no"
        INITIAL_INSTALL_ENIQSR2="yes"
                INITIAL_INSTALL_ENIQSR2_PART1="yes"
                INITIAL_INSTALL_ENIQSR2_PART2="no"
	INITIAL_INSTALL_SON_VIS="yes"
		INITIAL_INSTALL_SON_VIS_PART1="yes"
		INITIAL_INSTALL_SON_VIS_PART2="no"
	INITIAL_INSTALL_NETSIM="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
	INITIAL_INSTALL_TOR="yes"
                INITIAL_INSTALL_TOR_PART1="yes"

	POST_INSTALL_ADM1="no"
        POST_INSTALL_ADM2="no"
        POST_INSTALL_OMSAS="no"
        POST_INSTALL_OMSERVM="no"
        POST_INSTALL_OMSERVS="no"
        POST_INSTALL_UAS1="no"
	POST_INSTALL_PEER1="no"
        POST_INSTALL_NEDSS="no"
        POST_INSTALL_EBAS="no"
		POST_INSTALL_MWS="no"
	POST_INSTALL_NETSIM="no"

	rollout_config
}

function initial_rollout_part2 ()
{

        INITIAL_INSTALL_ADM1="yes"
                INITIAL_INSTALL_ADM1_PART1="no"
                INITIAL_INSTALL_ADM1_PART2="yes"
        INITIAL_INSTALL_OSS2_ADM1="yes"
		INITIAL_INSTALL_OSS2_ADM1_PART1="no"
		INITIAL_INSTALL_OSS2_ADM1_PART2="yes"
        INITIAL_INSTALL_ADM2="yes"
                INITIAL_INSTALL_ADM2_PART1="no"
                INITIAL_INSTALL_ADM2_PART2="yes"
        INITIAL_INSTALL_OMSAS="yes"
                INITIAL_INSTALL_OMSAS_PART1="no"
                INITIAL_INSTALL_OMSAS_PART2="yes"
        INITIAL_INSTALL_OMSERVM="yes"
                INITIAL_INSTALL_OMSERVM_PART1="no"
                INITIAL_INSTALL_OMSERVM_PART2="yes"
        INITIAL_INSTALL_OMSERVS="yes"
                INITIAL_INSTALL_OMSERVS_PART1="no"
                INITIAL_INSTALL_OMSERVS_PART2="yes"
        INITIAL_INSTALL_UAS1="yes"
                INITIAL_INSTALL_UAS1_PART1="no"
                INITIAL_INSTALL_UAS1_PART2="yes"
	INITIAL_INSTALL_PEER1="yes"
                INITIAL_INSTALL_PEER1_PART1="no"
                INITIAL_INSTALL_PEER1_PART2="yes"
        INITIAL_INSTALL_NEDSS="yes"
                INITIAL_INSTALL_NEDSS_PART1="no"
                INITIAL_INSTALL_NEDSS_PART2="yes"
        INITIAL_INSTALL_EBAS="yes"
                INITIAL_INSTALL_EBAS_PART1="no"
                INITIAL_INSTALL_EBAS_PART2="yes"
        INITIAL_INSTALL_MWS="no"
                INITIAL_INSTALL_MWS_PART1="no"
                INITIAL_INSTALL_MWS_PART2="no"
	INITIAL_INSTALL_ENIQE="yes"
		INITIAL_INSTALL_ENIQE_PART1="no"
		INITIAL_INSTALL_ENIQE_PART2="yes"
	INITIAL_INSTALL_CEP="yes"
		INITIAL_INSTALL_CEP_PART1="no"
		INITIAL_INSTALL_CEP_PART2="yes"
	INITIAL_INSTALL_ENIQS="yes"
                INITIAL_INSTALL_ENIQS_PART1="no"
                INITIAL_INSTALL_ENIQS_PART2="yes"
	INITIAL_INSTALL_ENIQSC="yes"
                INITIAL_INSTALL_ENIQSC_PART1="no"
                INITIAL_INSTALL_ENIQSC_PART2="yes"
        INITIAL_INSTALL_ENIQSE="yes"
                INITIAL_INSTALL_ENIQSE_PART1="no"
                INITIAL_INSTALL_ENIQSE_PART2="yes"
        INITIAL_INSTALL_ENIQSR1="yes"
                INITIAL_INSTALL_ENIQSR1_PART1="no"
                INITIAL_INSTALL_ENIQSR1_PART2="yes"
        INITIAL_INSTALL_ENIQSR2="yes"
                INITIAL_INSTALL_ENIQSR2_PART1="no"
                INITIAL_INSTALL_ENIQSR2_PART2="yes"
	INITIAL_INSTALL_SON_VIS="yes"
		INITIAL_INSTALL_SON_VIS_PART1="no"
		INITIAL_INSTALL_SON_VIS_PART2="yes"
	INITIAL_INSTALL_NETSIM="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
	INITIAL_INSTALL_TOR="yes"
                INITIAL_INSTALL_TOR_PART1="no"

        POST_INSTALL_ADM1="no"
        POST_INSTALL_ADM2="no"
        POST_INSTALL_OMSAS="no"
        POST_INSTALL_OMSERVM="no"
        POST_INSTALL_OMSERVS="no"
        POST_INSTALL_UAS1="no"
	POST_INSTALL_PEER1="no"
        POST_INSTALL_NEDSS="no"
        POST_INSTALL_EBAS="no"
		POST_INSTALL_MWS="no"
	POST_INSTALL_NETSIM="no"

        rollout_config
}

function common_post_steps ()
{
	INITIAL_INSTALL_ADM1="no"
                INITIAL_INSTALL_ADM1_PART1="no"
                INITIAL_INSTALL_ADM1_PART2="no"
        INITIAL_INSTALL_OSS2_ADM1="no"
		INITIAL_INSTALL_OSS2_ADM1_PART1="no"
		INITIAL_INSTALL_OSS2_ADM1_PART2="no"
        INITIAL_INSTALL_ADM2="no"
                INITIAL_INSTALL_ADM2_PART1="no"
                INITIAL_INSTALL_ADM2_PART2="no"
        INITIAL_INSTALL_OMSAS="no"
                INITIAL_INSTALL_OMSAS_PART1="no"
                INITIAL_INSTALL_OMSAS_PART2="no"
        INITIAL_INSTALL_OMSERVM="no"
                INITIAL_INSTALL_OMSERVM_PART1="no"
                INITIAL_INSTALL_OMSERVM_PART2="no"
        INITIAL_INSTALL_OMSERVS="no"
                INITIAL_INSTALL_OMSERVS_PART1="no"
                INITIAL_INSTALL_OMSERVS_PART2="no"
        INITIAL_INSTALL_UAS1="no"
                INITIAL_INSTALL_UAS1_PART1="no"
                INITIAL_INSTALL_UAS1_PART2="no"
        INITIAL_INSTALL_PEER1="no"
                INITIAL_INSTALL_PEER1_PART1="no"
                INITIAL_INSTALL_PEER1_PART2="no"
        INITIAL_INSTALL_NEDSS="no"
                INITIAL_INSTALL_NEDSS_PART1="no"
                INITIAL_INSTALL_NEDSS_PART2="no"
        INITIAL_INSTALL_MWS="no"
                INITIAL_INSTALL_MWS_PART1="no"
                INITIAL_INSTALL_MWS_PART2="no"
        INITIAL_INSTALL_ENIQE="no"
                INITIAL_INSTALL_ENIQE_PART1="no"
                INITIAL_INSTALL_ENIQE_PART2="no"
	INITIAL_INSTALL_CEP="no"
		INITIAL_INSTALL_CEP_PART1="no"
		INITIAL_INSTALL_CEP_PART2="no"
	INITIAL_INSTALL_ENIQS="no"
                INITIAL_INSTALL_ENIQS_PART1="no"
                INITIAL_INSTALL_ENIQS_PART2="no"
	INITIAL_INSTALL_ENIQSC="no"
                INITIAL_INSTALL_ENIQSC_PART1="no"
                INITIAL_INSTALL_ENIQSC_PART2="no"
        INITIAL_INSTALL_ENIQSE="no"
                INITIAL_INSTALL_ENIQSE_PART1="no"
                INITIAL_INSTALL_ENIQSE_PART2="no"
        INITIAL_INSTALL_ENIQSR1="no"
                INITIAL_INSTALL_ENIQSR1_PART1="no"
                INITIAL_INSTALL_ENIQSR1_PART2="no"
        INITIAL_INSTALL_ENIQSR2="no"
                INITIAL_INSTALL_ENIQSR2_PART1="no"
                INITIAL_INSTALL_ENIQSR2_PART2="no"
	INITIAL_INSTALL_SON_VIS="no"
		INITIAL_INSTALL_SON_VIS_PART1="no"
		INITIAL_INSTALL_SON_VIS_PART2="no"
	INITIAL_INSTALL_NETSIM="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
                INITIAL_INSTALL_NETSIM_PART2="no"
	INITIAL_INSTALL_TOR="no"
                INITIAL_INSTALL_TOR_PART1="no"

        POST_INSTALL_ADM1="yes"
        POST_INSTALL_ADM2="yes"
  #        POST_INSTALL_OMSAS="yes"
        POST_INSTALL_OMSAS="no"
        POST_INSTALL_OMSERVM="yes"
        POST_INSTALL_OMSERVS="yes"
        POST_INSTALL_UAS1="yes"
	POST_INSTALL_PEER1="yes"
        POST_INSTALL_NEDSS="yes"
        POST_INSTALL_EBAS="yes"
		POST_INSTALL_MWS="no"
	POST_INSTALL_NETSIM="no"
        # Set variables
        rollout_config
}

function create_deployment_directory_adm1 ()
{
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		mount_scripts_directory $ADM1_HOSTNAME
		$SSH $ADM1_HOSTNAME "mkdir -p /etc/deployment/ > /dev/null 2>&1;chmod 777 /etc/deployment/"
	fi
}
function create_deployment_directory_oss2_adm1 ()
{
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		mount_scripts_directory $OSS2_ADM1_HOSTNAME
		$SSH $OSS2_ADM1_HOSTNAME "mkdir -p /etc/deployment/ > /dev/null 2>&1;chmod 777 /etc/deployment/"
	fi
}
function populate_mc_start_list_internal ()
{
	local SERVER=$1
	local MC_LIST_TYPE=$2
	local FIX=$3

	if [[ "$FIX" == "no" ]]
	then
		message "INFO: Not populating the mc_start_list file\n" INFO
	else
		wait_until_sshable $SERVER
		message "INFO: Populating the mc_start_list file\n" INFO
	        mount_scripts_directory $SERVER
        	$SSH -qt $SERVER "$MOUNTPOINT/bin/populate_mc_start_list_adm1.sh"
	fi
}
function populate_mc_start_list_adm1 ()
{
	if [[ "$INITIAL_INSTALL_MCS" != "" ]]
        then
                populate_mc_start_list_internal $ADM1_HOSTNAME $INITIAL_INSTALL_MCS
	else
		populate_mc_start_list_internal $ADM1_HOSTNAME CRITICAL_5
        #elif [[ "$ON_THE_GATEWAY" == "yes" ]]
        #then
        #        populate_mc_start_list_internal $ADM1_HOSTNAME CRITICAL_5
        #else
        #        populate_mc_start_list_internal $ADM1_HOSTNAME INITIAL
        fi
}
function populate_mc_start_list_oss2_adm1 ()
{
	if [[ "$OSS2_INITIAL_INSTALL_MCS" != "" ]]
        then
                populate_mc_start_list_internal $OSS2_ADM1_HOSTNAME $OSS2_INITIAL_INSTALL_MCS
	else
		populate_mc_start_list_internal $OSS2_ADM1_HOSTNAME CRITICAL_5
        #elif [[ "$ON_THE_GATEWAY" == "yes" ]]
        #then
        #        populate_mc_start_list_internal $ADM1_HOSTNAME CRITICAL_5
        #else
        #        populate_mc_start_list_internal $ADM1_HOSTNAME INITIAL
        fi
}

function run_nascli_command ()
{
	local COMMAND="$1"
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qTn $ADM1_HOSTNAME "$MOUNTPOINT/bin/run_nascli_command.sh -c $CONFIG -m $MOUNTPOINT -r \"$COMMAND\""
}
function run_sfs_command ()
{
	local COMMAND="$1"
	requires_variable NASC
        requires_variable NASSUPPWW

	#setup_passwordless_ssh $NASC support $NASSUPPWW
	#ssh -qTn -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "support@$NASC" "su - master -c '$COMMAND'"

	#requires_variable NASMASPWW

        $EXPECT << EOF
                set force_conservative 1
                set timeout -1

                spawn ssh -qTn -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "support@$NASC" "su - master -c '$COMMAND'"
                while 1 {
                        expect {
                                "assword:" {
                                        send "$NASSUPPWW\r"
                                }
                                eof {
                                        catch wait result
                                        exit [lindex \$result 3]
                                }
                        }
                }
EOF
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Something went wront running the sfs command\n" ERROR
		return 1
	fi
}
function cleanup_sfs_eniqe ()
{
        if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$ENIQE_ID" != "" ]]
        then
                cleanup_sfs_internal "${ENIQE_ID}"
		if [[ $? -ne 0 ]]
                then
                        exit 1
                fi
        fi
}
function cleanup_sfs_eniqs ()
{
        if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$ENIQS_ID" != "" ]]
        then
                cleanup_sfs_internal "${ENIQS_ID}"
		if [[ $? -ne 0 ]]
                then
                        exit 1
                fi
        fi
}
function cleanup_sfs_eniqsc ()
{
        if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$ENIQSC_ID" != "" ]]
        then
                cleanup_sfs_internal "${ENIQSC_ID}"
                if [[ $? -ne 0 ]]
                then
                        exit 1
                fi
        fi
}
function cleanup_sfs_son_vis ()
{
        if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$SON_VIS_ID" != "" ]]
        then
                cleanup_sfs_internal "${SON_VIS_ID}"
                if [[ $? -ne 0 ]]
                then
                        exit 1
                fi
        fi
}
function cleanup_sfs_smrs ()
{
	if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$NEDSS_SMRS_OSS_ID" != "" ]]
	then
		# Take this line out in a few months. Only there to remove fs created with old naming convention
		cleanup_sfs_internal "${NEDSS_SMRS_SYS_ID_OLD}"
		cleanup_sfs_internal "${NEDSS_SMRS_SYS_ID}"
		if [[ $? -ne 0 ]]
		then
			exit 1
		fi
	fi
}
function cleanup_sfs_oss ()
{
	if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$OSS_ID" != "" ]]
        then
                cleanup_sfs_internal "${OSS_ID}a"
                if [[ $? -ne 0 ]]
                then
                        echo "1" > /tmp/$PARENT_BASHPID/status/adm1_initial_jump_complete.status
                        exit 1
                fi
        fi
}
function wait_until_sfs_ready ()
{
	local CHECK_OUTPUT=""
        local ATTEMPT=1
        message "INFO: Waiting for sfs to become ready." INFO
        while [[ $ATTEMPT -le 120 ]]
        do
                CHECK_OUTPUT=`run_sfs_command 'storage pool list'`
                if [[ $? -ne 0 ]]
                then
                        echo -n "."
                        sleep 10
                else
                        echo "OK"
                        break
                fi
                if [[ $ATTEMPT -eq 120 ]]
                then
                        message "ERROR: The sfs didn't seem to be ready after 20 minutes, see output below\n" ERROR
                        message "-------------------------------------------\n" ERROR
                        message "$CHECK_OUTPUT\n" ERROR
                        message "-------------------------------------------\n" ERROR
                        exit 1
                fi
                let ATTEMPT=ATTEMPT+1
        done
}
function cleanup_sfs_oss2 ()
{
	if [[ "$NASC" != "" ]] && [[ "$NASMASPWW" != "" ]] && [[ "$OSS2_OSS_ID" != "" ]]
        then
                cleanup_sfs_internal "${OSS2_OSS_ID}a"
                if [[ $? -ne 0 ]]
                then
                        echo "1" > /tmp/$PARENT_BASHPID/status/oss2_adm1_initial_jump_complete.status
                        exit 1
                fi
        fi
}
function cleanup_sfs_internal ()
{
	local IDENTIFIER="$1"

	message "INFO: Cleaning up the sfs shares, rollbacks, snapshots and filesystems for identifier $IDENTIFIER\n" INFO

	wait_until_sfs_ready

	###################################
	# Find and delete each share
	###################################
	local SHARE_SHOW_OUTPUT=""
	SHARE_SHOW_OUTPUT=`run_sfs_command 'nfs share show'`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of nfs shares from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SHARE_SHOW_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
		return 1
        fi
	SHARE_LIST=`echo "$SHARE_SHOW_OUTPUT" | awk '{print $1, $2}' | grep "/vx/${IDENTIFIER}-"`
	SHARE_COUNT=`echo "$SHARE_LIST" | grep vx | wc -l`
	message "INFO: There are $SHARE_COUNT shares to be deleted, list below\n" INFO
	echo "---------------------------------------------"
	echo "$SHARE_LIST"
	echo "---------------------------------------------"
	echo "$SHARE_LIST" | grep vx | while read SHARE
	do
		message "INFO: Running this command on the sfs, nfs share delete $SHARE\n" INFO
		run_sfs_command "nfs share delete $SHARE"
	done

	###################################
	# Check if share count is 0
	###################################
	SHARE_SHOW_OUTPUT=`run_sfs_command 'nfs share show'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of nfs shares from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SHARE_SHOW_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
        SHARE_LIST=`echo "$SHARE_SHOW_OUTPUT" | awk '{print $1, $2}' | grep "/vx/${IDENTIFIER}-"`
        SHARE_COUNT=`echo "$SHARE_LIST" | grep vx | wc -l`
	if [[ "$SHARE_COUNT" -ne 0 ]]
	then
		message "ERROR: There still seems to be $SHARE_COUNT shares left on the sfs, please check for errors in the output above. Remaining shares are below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SHARE_LIST\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
	fi

	###################################
        # Find and delete each snapshot
        ###################################
        local SNAPSHOT_LIST_OUTPUT=""
        SNAPSHOT_LIST_OUTPUT==`run_sfs_command 'storage snapshot list'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of snapshots from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SNAPSHOT_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
        SNAPSHOT_LIST=$(run_sfs_command 'storage snapshot list' | while read snapshotline
	do
		if [[ `echo "$snapshotline" | awk '{print $2}' | grep "^${IDENTIFIER}-"` ]]
		then
			echo "$snapshotline" | awk '{print $1, $2}'
		fi
	done)
        SNAPSHOT_COUNT=`echo "$SNAPSHOT_LIST" | grep "-" | wc -l`
        message "INFO: There are $SNAPSHOT_COUNT snapshots to be deleted, list below\n" INFO
        echo "---------------------------------------------"
        echo "$SNAPSHOT_LIST"
        echo "---------------------------------------------"
        echo "$SNAPSHOT_LIST" | grep "-" | while read SNAPSHOT FS
        do
                message "INFO: Running this command on the sfs, storage snapshot destroy $SNAPSHOT $FS\n" INFO
		run_sfs_command "storage snapshot destroy $SNAPSHOT $FS"
        done


        ###################################
        # Check if snapshot count is 0
        ###################################
	SNAPSHOT_LIST_OUTPUT==`run_sfs_command 'storage snapshot list'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of snapshots from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SNAPSHOT_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
	SNAPSHOT_LIST=$(run_sfs_command 'storage snapshot list' | while read snapshotline
        do
                if [[ `echo "$snapshotline" | awk '{print $2}' | grep "^${IDENTIFIER}-"` ]]
                then
                        echo "$snapshotline" | awk '{print $1, $2}'
                fi
        done)
        SNAPSHOT_COUNT=`echo "$SNAPSHOT_LIST" | grep "-" | wc -l`
        if [[ "$SNAPSHOT_COUNT" -ne 0 ]]
        then
                message "ERROR: There still seems to be $SNAPSHOT_COUNT snapshots left on the sfs, please check for errors in the output above. Remaining snapshots are below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$SNAPSHOT_LIST\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi


	###################################
        # Find and delete each rollback
        ###################################
        local ROLLBACK_LIST_OUTPUT=""
        ROLLBACK_LIST_OUTPUT==`run_sfs_command 'storage rollback list'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of rollbacks from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$ROLLBACK_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
        ROLLBACK_LIST=$(run_sfs_command 'storage rollback list' | while read rollbackline
        do
                if [[ `echo "$rollbackline" | awk '{print $3}' | grep "^${IDENTIFIER}-"` ]]
                then
                        echo "$rollbackline" | awk '{print $1, $3}'
                fi
        done)
        ROLLBACK_COUNT=`echo "$ROLLBACK_LIST" | grep "-" | wc -l`
        message "INFO: There are $ROLLBACK_COUNT rollbacks to be deleted, list below\n" INFO
        echo "---------------------------------------------"
        echo "$ROLLBACK_LIST"
        echo "---------------------------------------------"
        echo "$ROLLBACK_LIST" | grep "-" | while read ROLLBACK FS
        do
                message "INFO: Running this command on the sfs, storage rollback destroy $ROLLBACK $FS\n" INFO
                run_sfs_command "storage rollback destroy $ROLLBACK $FS"
        done


        ###################################
        # Check if rollback count is 0
        ###################################
        ROLLBACK_LIST_OUTPUT==`run_sfs_command 'storage rollback list'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of rollbacks from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$ROLLBACK_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
        ROLLBACK_LIST=$(run_sfs_command 'storage rollback list' | while read rollbackline
        do
                if [[ `echo "$rollbackline" | awk '{print $3}' | grep "^${IDENTIFIER}-"` ]]
                then
                        echo "$rollbackline" | awk '{print $1, $3}'
                fi
        done)
        ROLLBACK_COUNT=`echo "$ROLLBACK_LIST" | grep "-" | wc -l`
        if [[ "$ROLLBACK_COUNT" -ne 0 ]]
        then
                message "ERROR: There still seems to be $ROLLBACK_COUNT rollbacks left on the sfs, please check for errors in the output above. Remaining rollbacks are below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$ROLLBACK_LIST\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi


	###################################
	# Find and delete each filesystem
	###################################
	local FS_LIST_OUTPUT=""
	FS_LIST_OUTPUT==`run_sfs_command 'storage fs list'`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of filesystems from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$FS_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
	FS_LIST=`echo "$FS_LIST_OUTPUT" | awk '{print $1}' | grep "^${IDENTIFIER}-"`
	FS_COUNT=`echo "$FS_LIST" | grep "-" | wc -l`
        message "INFO: There are $FS_COUNT filesystems to be deleted, list below\n" INFO
        echo "---------------------------------------------"
        echo "$FS_LIST"
        echo "---------------------------------------------"
        echo "$FS_LIST" | grep "-" | while read FS
        do
		message "INFO: Running this command on the sfs, storage fs destroy $FS\n" INFO
		run_sfs_command "storage fs destroy $FS"
        done

	###################################
        # Check if filesystem count is 0
        ###################################
        FS_LIST_OUTPUT=`run_sfs_command 'storage fs list'`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: There was a problem getting the list of filesystems from the sfs, output below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$FS_LIST_OUTPUT\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
	FS_LIST=`echo "$FS_LIST_OUTPUT" | awk '{print $1}' | grep "^${IDENTIFIER}-"`
        FS_COUNT=`echo "$FS_LIST" | grep "-" | wc -l`
        if [[ "$FS_COUNT" -ne 0 ]]
        then
                message "ERROR: There still seems to be $FS_COUNT filesystems left on the sfs, please check for errors in the output above. Remaining filesystems are below\n" ERROR
                message "-------------------------------------------\n" ERROR
                message "$FS_LIST\n" ERROR
                message "-------------------------------------------\n" ERROR
                return 1
        fi
}

function rollout_config ()
{
	config_gateway
	message "INFO: Started Pre Checks\n" INFO

	# Set the iops to unlimited before rollout
        message "INFO: Setting unlimited iops on vms, please wait...: " INFO
	vm_set_iops_all unlimited
        echo "OK"


	# Do some prechecks to catch problems early

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]]
        then
		if [[ "$INITIAL_INSTALL_ADM1_PART1" != "no" ]]
		then
			requires_variable ADM1_JUMP_LOC
			requires_variable ADM1_AI_SERVICE
			requires_variable ADM1_OM_LOC
			requires_variable ADM1_APPL_MEDIA_LOC

			if [[ "$SFS_HOSTNAME" != "" ]]
			then
				NEED_TO_POWERON_SFS="yes"
			fi
        		if [[ "$ADM1_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_adm1
			else
				set_cpu_count_adm1
				set_memory_mb_adm1
				check_vsp_port_adm1 nongraceful
				boot_from_floppy_adm1
			fi
			
			REQUIREMENT_ADM1_PART1="adm1_part1"
			REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE="adm1_initial_jump_complete"
		fi

		if [[ "$INITIAL_INSTALL_ADM1_PART2" != "no" ]]
		then
			REQUIREMENT_MANAGE_MCS_INITIAL="manage_mcs_initial"
			REQUIREMENT_EXPAND_DATABASES="expand_databases"
			REQUIREMENT_ADM1_PART2="adm1_part2"
		fi
	fi
	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_ADM1" == "yes" ]]
	then
		REQUIREMENT_SETUP_ADM1_LDAP_CLIENT="setup_adm1_ldap_client"
		if [[ "$ADM1_SECURITY" == "yes" ]]
		then
			requires_variable OMSAS_HOSTNAME
			REQUIREMENT_ENABLE_MS_SECURITY="enable_ms_security"
		fi
	fi

        if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]]
        then
		if [[ "$INITIAL_INSTALL_OSS2_ADM1_PART1" != "no" ]]
		then
			requires_variable OSS2_ADM1_JUMP_LOC
			requires_variable OSS2_ADM1_AI_SERVICE
			requires_variable OSS2_ADM1_OM_LOC
			requires_variable OSS2_ADM1_APPL_MEDIA_LOC

			if [[ "$SFS_HOSTNAME" != "" ]]
			then
				NEED_TO_POWERON_SFS="yes"
			fi
        		if [[ "$OSS2_ADM1_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_oss2_adm1 
			else
				set_cpu_count_oss2_adm1
				set_memory_mb_oss2_adm1
				check_vsp_port_oss2_adm1 nongraceful
				boot_from_floppy_oss2_adm1
			fi
			
			REQUIREMENT_OSS2_ADM1_PART1="oss2_adm1_part1"
			REQUIREMENT_OSS2_ADM1_INITIAL_JUMP_COMPLETE="oss2_adm1_initial_jump_complete"
		fi

		if [[ "$INITIAL_INSTALL_OSS2_ADM1_PART2" != "no" ]]
		then
			REQUIREMENT_OSS2_MANAGE_MCS_INITIAL="manage_mcs_initial_oss2_adm1"
			REQUIREMENT_OSS2_EXPAND_DATABASES="expand_databases_oss2_adm1"
			REQUIREMENT_OSS2_ADM1_PART2="oss2_adm1_part2"
		fi
	fi
	if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OSS2_ADM1" == "yes" ]]
	then
		REQUIREMENT_SETUP_OSS2_ADM1_LDAP_CLIENT="setup_oss2_adm1_ldap_client"
		if [[ "$OSS2_ADM1_SECURITY" == "yes" ]]
		then
			requires_variable OMSAS_HOSTNAME
			REQUIREMENT_ENABLE_MS_SECURITY="enable_ms_security"#needs change
		fi
	fi

	if [[ "$ADM2_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_ADM2" == "yes" ]]
	then
		REQUIREMENT_ADM2_ADD_TO_CLUSTER="adm2_add_to_cluster"
	fi
	
	if [[ "$ADM2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM2" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_ADM2_PART1" != "no" ]]
		then
			requires_variable ADM2_JUMP_LOC
			requires_variable ADM2_AI_SERVICE
			requires_variable ADM2_OM_LOC

			if [[ "$ADM2_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_adm2
			else
				set_cpu_count_adm2
				set_memory_mb_adm2
				check_vsp_port_adm2 nongraceful
				boot_from_floppy_adm2
			fi
			REQUIREMENT_ADM2_PART1="adm2_part1"
		fi
		if [[ "$INITIAL_INSTALL_ADM2_PART2" != "no" ]]
                then
                	REQUIREMENT_ADM2_PART2="adm2_part2"
                fi
	fi

	if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSAS" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_OMSAS_PART1" != "no" ]]
	        then
			requires_variable OMSAS_JUMP_LOC
			requires_variable OMSAS_AI_SERVICE
			requires_variable OMSAS_OM_LOC
			#requires_variable OMSAS_APPL_MEDIA_LOC

			if [[ "$OMSAS_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_omsas
			else
				set_cpu_count_omsas
                                set_memory_mb_omsas
				check_vsp_port_omsas nongraceful
				boot_from_floppy_omsas
			fi
			REQUIREMENT_OMSAS_PART1="omsas_part1"
		fi
		if [[ "$INITIAL_INSTALL_OMSAS_PART2" != "no" ]]
                then
			requires_variable OMSAS_MEDIA
			REQUIREMENT_OMSAS_PART2="omsas_part2"
			
		fi
	fi
	if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSAS" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
	then
		REQUIREMENT_OMSAS_POST_STEPS="omsas_post_steps"
	fi

	# Netsim related requirements
	if [[ "$NETSIM_SERVERS" != "" ]] && [[ "$INITIAL_INSTALL_NETSIM" == "yes" ]] && [[ "$INITIAL_INSTALL_NETSIM_PART1" != "no" ]]
        then
		REQUIREMENT_NETSIM_ROLLOUT_PART1="netsim_rollout_part1"
	fi
	if [[ "$NETSIM_SERVERS" != "" ]] && [[ "$INITIAL_INSTALL_NETSIM" == "yes" ]] && [[ "$INITIAL_INSTALL_NETSIM_PART2" != "no" ]]
        then
		REQUIREMENT_NETSIM_ROLLOUT_PART2="netsim_rollout_part2"
	fi
	if [[ "$POST_INSTALL_NETSIM" == "yes" ]]
        then
		REQUIREMENT_NETSIM_POST_STEPS="netsim_post_steps"
	fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSERVM" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_OMSERVM_PART1" != "no" ]]
		then
			requires_variable OMSERVM_JUMP_LOC
			requires_variable OMSERVM_AI_SERVICE
			requires_variable OMSERVM_OM_LOC
			#requires_variable OMSERVM_APPL_MEDIA_LOC

			if [[ "$OMSERVM_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_omservm
			else
				set_cpu_count_omservm
				set_memory_mb_omservm
				check_vsp_port_omservm nongraceful
				boot_from_floppy_omservm
			fi
			REQUIREMENT_OMSERVM_PART1="omservm_part1"
		fi

		if [[ "$INITIAL_INSTALL_OMSERVM_PART2" != "no" ]]
		then
			requires_variable OMSAS_MEDIA
			REQUIREMENT_OMSERVM_PART2="omservm_part2"
		fi
	fi
		
	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]]
	then
		REQUIREMENT_OMSERVM_POST_STEPS="omservm_post_steps"
		REQUIREMENT_SETUP_REPLICATION="setup_replication_detect"
	fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then
		REQUIREMENT_OMSERVM_SCS="omservm_scs"
		REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVM="setup_ssh_masterservice_omservm"
        fi
	
	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$INITIAL_INSTALL_OMSERVS" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_OMSERVS_PART1" != "no" ]]
		then
			requires_variable OMSERVS_JUMP_LOC
			requires_variable OMSERVS_AI_SERVICE
			requires_variable OMSERVS_OM_LOC
			#requires_variable OMSERVS_APPL_MEDIA_LOC

			if [[ "$OMSERVS_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_omservs
			else
				set_cpu_count_omservs
				set_memory_mb_omservs
				check_vsp_port_omservs nongraceful
				boot_from_floppy_omservs
			fi
			REQUIREMENT_OMSERVS_PART1="omservs_part1"
		fi
		if [[ "$INITIAL_INSTALL_OMSERVS_PART2" != "no" ]]
		then
			requires_variable OMSAS_MEDIA
			REQUIREMENT_OMSERVS_PART2="omservs_part2"
		fi
	fi
	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]]
	then
		REQUIREMENT_OMSERVS_POST_STEPS="omservs_post_steps"
	fi

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
	then
		REQUIREMENT_ADD_OMSERVS_SLS_URL_ADM1="add_omservs_sls_url_adm1"
		REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVS="setup_ssh_masterservice_omservs"
	fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_NEDSS" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_NEDSS_PART1" != "no" ]]
	        then
			requires_variable NEDSS_JUMP_LOC
			requires_variable NEDSS_AI_SERVICE
			requires_variable NEDSS_OM_LOC
			requires_variable NEDSS_APPL_MEDIA_LOC

			if [[ "$NEDSS_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_nedss
			else
				set_cpu_count_nedss
				set_memory_mb_nedss
				check_vsp_port_nedss nongraceful
				boot_from_floppy_nedss
			fi
			REQUIREMENT_NEDSS_PART1="nedss_part1"
			REQUIREMENT_CLEANUP_SFS_SMRS="cleanup_sfs_smrs"
		fi
		if [[ "$INITIAL_INSTALL_NEDSS_PART2" != "no" ]]
		then
			REQUIREMENT_NEDSS_PART2="nedss_part2"
		fi
	fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_NEDSS" == "yes" ]] && [[ "$NEDSS_SMRS_OSS_ID" != "" ]]
	then
		REQUIREMENT_CREATE_AND_SHARE_SMRS_FILESYSTEMS="create_and_share_smrs_filesystems"
		REQUIREMENT_NEDSS_POST_STEPS="nedss_post_steps"
	fi

	if [[ "$UAS1_HOSTNAME" != "" ]]
	then
		if [[ "$INITIAL_INSTALL_UAS1" == "yes" ]]
		then
			if [[ "$INITIAL_INSTALL_UAS1_PART1" != "no" ]]
			then
				requires_variable UAS1_JUMP_LOC
				requires_variable UAS1_AI_SERVICE
				requires_variable UAS1_OM_LOC
				requires_variable UAS1_APPL_MEDIA_LOC

				if [[ "$UAS1_SERVER_TYPE" = "blade" ]]
				then
					boot_from_floppy_uas1
				else
					set_cpu_count_uas1
	                                set_memory_mb_uas1
					check_vsp_port_uas1 nongraceful
					boot_from_floppy_uas1
				fi
				REQUIREMENT_UAS1_PART1="uas1_part1"
			fi
			if [[ "$INITIAL_INSTALL_UAS1_PART2" != "no" ]]
			then
				REQUIREMENT_UAS1_PART2="uas1_part2"
			fi
		elif [[ "$POST_INSTALL_UAS1" == "yes" ]]
		then
			if [[ "$UAS1_SERVER_TYPE" = "blade" ]]
			then
				:
			else
				check_vsp_port_uas1 nongraceful
			fi
		fi
		
	fi


	if [[ "$PEER1_HOSTNAME" != "" ]]
	then
		if [[ "$INITIAL_INSTALL_PEER1" == "yes" ]]
		then
                        if [[ "$INITIAL_INSTALL_PEER1_PART1" != "no" ]]
			then
				requires_variable PEER1_JUMP_LOC
				requires_variable PEER1_AI_SERVICE
				requires_variable PEER1_OM_LOC
				requires_variable PEER1_APPL_MEDIA_LOC

                                if [[ "$PEER1_SERVER_TYPE" = "blade" ]]
                                then
                                        boot_from_floppy_peer1
                                else
					set_cpu_count_peer1
					set_memory_mb_peer1
					check_vsp_port_peer1 nongraceful
					boot_from_floppy_peer1
                                fi
                                REQUIREMENT_PEER1_PART1="peer1_part1"
                        fi
                        if [[ "$INITIAL_INSTALL_PEER1_PART2" != "no" ]]
			then
                                REQUIREMENT_PEER1_PART2="peer1_part2"
			fi
                elif [[ "$POST_INSTALL_PEER1" == "yes" ]]
                then
                        if [[ "$PEER1_SERVER_TYPE" = "blade" ]]
                        then
                                :
                        else
                                check_vsp_port_peer1 nongraceful
                        fi
		fi
	fi

	if [[ "$UAS1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_UAS1" == "yes" ]]
        then
                REQUIREMENT_UAS_POST_STEPS="uas_post_steps"
	fi

	if [[ "$PEER1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_PEER1" == "yes" ]]
        then
                REQUIREMENT_PEER_POST_STEPS="peer1_post_steps"
	fi

	if [[ "$EBAS_HOSTNAME" != "" ]] 
	then
		if [[ "$INITIAL_INSTALL_EBAS" == "yes" ]]
		then
			if [[ "$INITIAL_INSTALL_EBAS_PART1" != "no" ]]
			then
				requires_variable EBAS_JUMP_LOC
				requires_variable EBAS_AI_SERVICE
				requires_variable EBAS_OM_LOC

				if [[ "$EBAS_SERVER_TYPE" = "blade" ]]
				then
					boot_from_floppy_ebas
				else
					set_cpu_count_ebas
					set_memory_mb_ebas
					check_vsp_port_ebas nongraceful
					boot_from_floppy_ebas
				fi
				REQUIREMENT_EBAS_PART1="ebas_part1"
			fi
			if [[ "$INITIAL_INSTALL_EBAS_PART2" != "no" ]]
			then
				REQUIREMENT_EBAS_PART2="ebas_part2"
			fi
		elif [[ "$POST_INSTALL_EBAS" == "yes" ]]
		then
			if [[ "$EBAS_SERVER_TYPE" = "blade" ]]
			then
				:
			else
				check_vsp_port_ebas nongraceful
			fi
		fi
	fi
	if [[ "$EBAS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_EBAS" == "yes" ]]
        then
		REQUIREMENT_EBAS_POST_STEPS="ebas_post_steps"
	fi

	if [[ "$MWS_HOSTNAME" != "" ]] 
	then
		if [[ "$INITIAL_INSTALL_MWS" == "yes" ]]
		then
			if [[ "$INITIAL_INSTALL_MWS_PART1" != "no" ]]
			then
				requires_variable MWS_JUMP_LOC
				requires_variable MWS_AI_SERVICE
				requires_variable MWS_OM_LOC

				if [[ "$MWS_SERVER_TYPE" = "blade" ]]
				then
					boot_from_floppy_mws
				else
					set_cpu_count_mws
					set_memory_mb_mws
					check_vsp_port_mws nongraceful
					boot_from_floppy_mws
				fi
				REQUIREMENT_MWS_PART1="mws_part1"
			fi
			if [[ "$INITIAL_INSTALL_MWS_PART2" != "no" ]]
			then
				REQUIREMENT_MWS_PART2="mws_part2"
			fi
		elif [[ "$POST_INSTALL_MWS" == "yes" ]]
		then
			if [[ "$MWS_SERVER_TYPE" = "blade" ]]
			then
				:
			else
				check_vsp_port_mws nongraceful
			fi
		fi
	fi
	if [[ "$MWS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_MWS" == "yes" ]]
        then
		REQUIREMENT_MWS_POST_STEPS="mws_post_steps"
	fi
	if [[ "$ENIQE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQE" == "yes" ]]
        then
		if [[ "$INITIAL_INSTALL_ENIQE_PART1" != "no" ]]
		then
			requires_variable ENIQE_JUMP_LOC
			requires_variable ENIQE_AI_SERVICE
			requires_variable ENIQE_OM_LOC
			requires_variable ENIQE_APPL_MEDIA_LOC

			if [[ "$SFS_HOSTNAME" != "" ]]
			then
				NEED_TO_POWERON_SFS="yes"
		        fi
			if [[ "$ENIQE_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_eniqe
			else
				set_cpu_count_eniqe
				set_memory_mb_eniqe
				check_vsp_port_eniqe nongraceful
				boot_from_floppy_eniqe
			fi
			REQUIREMENT_ENIQE_PART1="eniqe_part1"
		fi
		if [[ "$INITIAL_INSTALL_ENIQE_PART2" != "no" ]]
		then
			REQUIREMENT_ENIQE_PART2="eniqe_part2"
		fi
	fi

	if [[ "$CEP_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_CEP" == "yes" ]]
	then
		if [[ "$INITIAL_INSTALL_CEP_PART1" != "no" ]]
		then
			requires_variable CEP_KICK_LOC
			requires_variable CEP_OM_LOC
			requires_variable CEP_APPL_MEDIA_LOC

			if [[ "$SFS_HOSTNAME" != "" ]]
			then
				NEED_TO_POWERON_SFS="yes"
			fi
			if [[ "$CEP_SERVER_TYPE" = "blade" ]]
			then
				boot_from_floppy_cep
			else
				set_cpu_count_cep
				set_memory_mb_cep
				check_vsp_port_cep nongraceful
				boot_from_floppy_cep
			fi
			REQUIREMENT_CEP_PART1="cep_part1"
		fi
	fi

	if [[ "$ENIQS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQS" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_ENIQS_PART1" != "no" ]]
                then
			requires_variable ENIQS_JUMP_LOC
			requires_variable ENIQS_AI_SERVICE
			requires_variable ENIQS_OM_LOC
			requires_variable ENIQS_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
			then
				NEED_TO_POWERON_SFS="yes"
			fi
	                if [[ "$ENIQS_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_eniqs
                        else
                                set_cpu_count_eniqs
                                set_memory_mb_eniqs
                                check_vsp_port_eniqs nongraceful
                                boot_from_floppy_eniqs
                        fi

                        REQUIREMENT_ENIQS_PART1="eniqs_part1"
		fi
	fi

	if [[ "$ENIQSC_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSC" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_ENIQSC_PART1" != "no" ]]
                then
                        requires_variable ENIQSC_JUMP_LOC
                        requires_variable ENIQSC_AI_SERVICE
                        requires_variable ENIQSC_OM_LOC
                        requires_variable ENIQSC_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
                        then
				NEED_TO_POWERON_SFS="yes"
                        fi
                        if [[ "$ENIQSC_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_eniqsc
                        else
                                set_cpu_count_eniqsc
                                set_memory_mb_eniqsc
                                check_vsp_port_eniqsc nongraceful
                                boot_from_floppy_eniqsc
                        fi

                        REQUIREMENT_ENIQSC_PART1="eniqsc_part1"
                fi

		if [[ "$INITIAL_INSTALL_ENIQSC_PART1" != "no" ]]
		then
			REQUIREMENT_ENIQSC_PART2="eniqsc_part2"
		fi
        fi

	if [[ "$ENIQSE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSE" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_ENIQSE_PART1" != "no" ]]
                then
                        requires_variable ENIQSE_JUMP_LOC
                        requires_variable ENIQSE_AI_SERVICE
                        requires_variable ENIQSE_OM_LOC
                        requires_variable ENIQSE_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
                        then
				NEED_TO_POWERON_SFS="yes"
                        fi
                        if [[ "$ENIQSE_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_eniqse
                        else
                                set_cpu_count_eniqse
                                set_memory_mb_eniqse
                                check_vsp_port_eniqse nongraceful
                                boot_from_floppy_eniqse
                        fi

                        REQUIREMENT_ENIQSE_PART1="eniqse_part1"
                fi
        fi

	if [[ "$ENIQSR1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR1" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_ENIQSR1_PART1" != "no" ]]
                then
                        requires_variable ENIQSR1_JUMP_LOC
                        requires_variable ENIQSR1_AI_SERVICE
                        requires_variable ENIQSR1_OM_LOC
                        requires_variable ENIQSR1_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
                        then
				NEED_TO_POWERON_SFS="yes"
                        fi
                        if [[ "$ENIQSR1_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_eniqsr1
                        else
                                set_cpu_count_eniqsr1
                                set_memory_mb_eniqsr1
                                check_vsp_port_eniqsr1 nongraceful
                                boot_from_floppy_eniqsr1
                        fi

                        REQUIREMENT_ENIQSR1_PART1="eniqsr1_part1"
                fi
        fi

	if [[ "$ENIQSR2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR2" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_ENIQSR2_PART1" != "no" ]]
                then
                        requires_variable ENIQSR2_JUMP_LOC
                        requires_variable ENIQSR2_AI_SERVICE
                        requires_variable ENIQSR2_OM_LOC
                        requires_variable ENIQSR2_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
                        then
				NEED_TO_POWERON_SFS="yes"
                        fi
                        if [[ "$ENIQSR2_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_eniqsr2
                        else
                                set_cpu_count_eniqsr2
                                set_memory_mb_eniqsr2
                                check_vsp_port_eniqsr2 nongraceful
                                boot_from_floppy_eniqsr2
                        fi

                        REQUIREMENT_ENIQSR2_PART1="eniqsr2_part1"
                fi
        fi

	if [[ "$SON_VIS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_SON_VIS" == "yes" ]]
        then
                if [[ "$INITIAL_INSTALL_SON_VIS_PART1" != "no" ]]
                then
                        requires_variable SON_VIS_JUMP_LOC
                        requires_variable SON_VIS_AI_SERVICE
                        requires_variable SON_VIS_OM_LOC
                        requires_variable SON_VIS_APPL_MEDIA_LOC

                        if [[ "$SFS_HOSTNAME" != "" ]]
                        then
				NEED_TO_POWERON_SFS="yes"
                        fi
                        if [[ "$SON_VIS_SERVER_TYPE" = "blade" ]]
                        then
                                boot_from_floppy_son_vis
                        else
                                set_cpu_count_son_vis
                                set_memory_mb_son_vis
                                check_vsp_port_son_vis nongraceful
                                boot_from_floppy_son_vis
                        fi

                        REQUIREMENT_SON_VIS_PART1="son_vis_part1"
                fi
        fi

	# If we need to power on the sfs, do it now
	if [[ "$NEED_TO_POWERON_SFS" == "yes" ]]
	then
		message "INFO: Powering on the sfs $SFS_HOSTNAME\n" INFO
		poweron_sfs
	fi

	################
	message "INFO: Completed Pre Checks\n" INFO

	
	# Install them all now
	FORMATTED_DATE="`date | awk '{print $2 "_" $3 "_" $NF}'`"
	FORMATTED_TIME="`date | awk '{print $4}'`"
	PARALLEL_STATUS_HEADER="Running processes since $FORMATTED_DATE - $FORMATTED_TIME"

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM1_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="adm1_part1"
		PART_OF_STAGE="INITIAL_INSTALL_ADM1_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing adm1 $ADM1_HOSTNAME"
		###################################
		(
		(
			cleanup_sfs_oss
			create_config_files_adm1
			add_dhcp_client_remote_adm1
			if [[ "$ADM1_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_adm1
				poweron_server BLADE $ADM1_ILO_ADDRESS $ADM1_ILO_USER $ADM1_ILO_PASS
			else
				boot_from_network_adm1
			fi
			install_adm1 ADM1
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables

	fi

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="adm1_part2"
		PART_OF_STAGE="INITIAL_INSTALL_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on adm1 $ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_PART1"
			wait_until_sshable_adm1
			if [[ "$ADM1_SERVER_TYPE" != "blade" ]]
			then
			        disable_iofence_vxfenmode_adm1
			fi
			if [[ "$BEHIND_GATEWAY" == "yes" ]]
			then
				ipmp_workaround_adm1
			fi
			set_eeprom_text_adm1
                        remove_serial_port_adm1
                        populate_mc_start_list_adm1
                        wait_oss_online_adm1
			wait_until_services_started_adm1
                        update_sentinel_license
			if [[ "$BEHIND_GATEWAY" == "yes" ]]
			then
				disable_oss_backup_crons_adm1
			fi
                        create_deployment_directory_adm1
                        update_nmsadm_password_initial
                        set_external_gateway_adm1
                        set_prompt_adm1
                        setup_ntp_client_adm1
                        install_vmware_tools_adm1
			install_vmware_tools_sfs
                        #wait_oss_online_adm1
                        message "INFO: Completed adm1 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="expand_databases"
		PART_OF_STAGE="INITIAL_INSTALL_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Database expansion on adm1 $ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_ENABLE_MS_SECURITY"
                        expand_databases
			dmr_config
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="manage_mcs_initial"
		PART_OF_STAGE="INITIAL_INSTALL_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Manage mcs on adm1 $ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_ENABLE_MS_SECURITY"
                        manage_mcs_initial
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="create_caas_user_tss"
		PART_OF_STAGE="INITIAL_INSTALL_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Creating caas user in tss"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_ENABLE_MS_SECURITY $REQUIREMENT_MANAGE_MCS_INITIAL"
                        create_caas_user_tss_adm1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

        if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="oss2_adm1_part1"
		PART_OF_STAGE="INITIAL_INSTALL_OSS2_ADM1_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing oss2_adm1 $OSS2_ADM1_HOSTNAME"
		###################################
		(
		(
			cleanup_sfs_oss2
			create_config_files_oss2_adm1
			add_dhcp_client_remote_oss2_adm1
			if [[ "$OSS2_ADM1_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_oss2_adm1
				poweron_server BLADE $OSS2_ADM1_ILO_ADDRESS $OSS2_ADM1_ILO_USER $OSS2_ADM1_ILO_PASS
			else
				boot_from_network_oss2_adm1
			fi
			install_adm1 OSS2_ADM1
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables

	fi

	if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="oss2_adm1_part2"
		PART_OF_STAGE="INITIAL_INSTALL_OSS2_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on oss2_adm1 $OSS2_ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_OSS2_ADM1_PART1"
			wait_until_sshable_oss2_adm1
			if [[ "$OSS2_ADM1_SERVER_TYPE" != "blade" ]]
			then
			        disable_iofence_vxfenmode_oss2_adm1
			fi
			if [[ "$BEHIND_GATEWAY" == "yes" ]]
			then
				ipmp_workaround_oss2_adm1
			fi
			set_eeprom_text_oss2_adm1
                        remove_serial_port_oss2_adm1
                        populate_mc_start_list_oss2_adm1
                        wait_oss_online_oss2_adm1
			wait_until_services_started_oss2_adm1
                        update_sentinel_license_oss2_adm1
			if [[ "$BEHIND_GATEWAY" == "yes" ]]
			then
				disable_oss_backup_crons_oss2_adm1
			fi
                        create_deployment_directory_oss2_adm1
                        update_nmsadm_password_initial_oss2_adm1
                        set_external_gateway_oss2_adm1
                        set_prompt_oss2_adm1
                        setup_ntp_client_oss2_adm1
                        install_vmware_tools_oss2_adm1
			install_vmware_tools_sfs
                        #wait_oss_online_oss2_adm1
                        message "INFO: Completed oss2_adm1 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="expand_databases_oss2_adm1"
		PART_OF_STAGE="INITIAL_INSTALL_OSS2_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Database expansion on oss2_adm1 $OSS2_ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_OSS2_ADM1_PART2"
                        expand_databases_oss2_adm1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="manage_mcs_initial_oss2_adm1"
		PART_OF_STAGE="INITIAL_INSTALL_OSS2_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Manage mcs on oss2_adm1 $OSS2_ADM1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_OSS2_ADM1_PART2"
                        manage_mcs_initial_oss2_adm1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1" == "yes" ]] && [[ "$INITIAL_INSTALL_OSS2_ADM1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="create_caas_user_tss_oss2_adm1"
		PART_OF_STAGE="INITIAL_INSTALL_OSS2_ADM1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="--> Creating caas user in tss"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_OSS2_ADM1_PART2 $REQUIREMENT_OSS2_MANAGE_MCS_INITIAL"
                        create_caas_user_tss_oss2_adm1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$ADM2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM2" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM2_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="adm2_part1"
		PART_OF_STAGE="INITIAL_INSTALL_ADM2_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing adm2 $ADM2_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_adm2
			add_dhcp_client_remote_adm2
			if [[ "$ADM2_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_adm2
				poweron_server BLADE $ADM2_ILO_ADDRESS $ADM2_ILO_USER $ADM2_ILO_PASS
			else
				boot_from_network_adm2
			fi
			install_adm2
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$ADM2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ADM2" == "yes" ]] && [[ "$INITIAL_INSTALL_ADM2_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="adm2_part2"
		PART_OF_STAGE="INITIAL_INSTALL_ADM2_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on adm2 $ADM2_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM2_PART1"
                        wait_until_sshable_adm2
                        set_eeprom_text_adm2
                        remove_serial_port_adm2
			wait_until_sshable_adm2
			#install_vmware_tools_adm2
                        message "INFO: Completed adm2 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSAS" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSAS_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="omsas_part1"
		PART_OF_STAGE="INITIAL_INSTALL_OMSAS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing omsas $OMSAS_HOSTNAME"
		###################################
		(
		(
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_omsas
			add_dhcp_client_remote_omsas
			if [[ "$OMSAS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_omsas
				poweron_server BLADE $OMSAS_ILO_ADDRESS $OMSAS_ILO_USER $OMSAS_ILO_PASS
			else
				boot_from_network_omsas
			fi
			install_omsas
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables

	fi

	if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSAS" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSAS_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omsas_part2"
		PART_OF_STAGE="INITIAL_INSTALL_OMSAS_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on omsas $OMSAS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_OMSAS_PART1"
                        remove_serial_port_omsas
                        wait_until_sshable_omsas
                        setup_resolver_omsas
                        set_external_gateway_omsas
                        set_prompt_omsas
                        install_caas_omsas
			#parallel_requirements "$REQUIREMENT_ADM1_PART2"
			#swap space workaround
			$SSH -qt $OMSAS_HOSTNAME "zfs set volsize=10g rpool/swap; zfs get volsize rpool/swap " > /dev/null 2>&1
                        configure_csa_omsas
                        set_eeprom_text_omsas
                        install_vmware_tools_omsas
                        message "INFO: Completed omsas install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSERVM" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSERVM_PART1" != "no" ]]
	then
		###################################
	        # Parallel variable initialization
	        ###################################
		PARALLEL_ID="omservm_part1"
		PART_OF_STAGE="INITIAL_INSTALL_OMSERVM_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
	        PARALLEL_STATUS_STRING="Installing omservm $OMSERVM_HOSTNAME"
	        ###################################
	        (
	        (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_omservm
			add_dhcp_client_remote_omservm
			if [[ "$OMSERVM_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_omservm
				poweron_server BLADE $OMSERVM_ILO_ADDRESS $OMSERVM_ILO_USER $OMSERVM_ILO_PASS
			else
				boot_from_network_omservm
			fi
			install_omservm
	        ) > $LOG_FILE 2>&1;parallel_finish
	        ) & set_parallel_variables
	fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_OMSERVM" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSERVM_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omservm_part2"
		PART_OF_STAGE="INITIAL_INSTALL_OMSERVM_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on omservm $OMSERVM_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_OMSERVM_PART1"
                        remove_serial_port_omservm
                        wait_until_sshable_omservm
                        setup_resolver_omservm
                        set_external_gateway_omservm
                        set_prompt_omservm
			#swap space workaround	
			$SSH -qt $OMSERVM_HOSTNAME "zfs set volsize=10g rpool/swap; zfs get volsize rpool/swap " > /dev/null 2>&1
                        install_caas_omservm
                        set_eeprom_text_omservm
                        install_vmware_tools_omservm
                        message "INFO: Completed omservm install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$INITIAL_INSTALL_OMSERVS" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSERVS_PART1" != "no" ]]
        then

		###################################
	        # Parallel variable initialization
	        ###################################
		PARALLEL_ID="omservs_part1"
		PART_OF_STAGE="INITIAL_INSTALL_OMSERVS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
	        PARALLEL_STATUS_STRING="Installing omservs $OMSERVS_HOSTNAME"
	        ###################################
	        (
	        (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_omservs
			add_dhcp_client_remote_omservs
			if [[ "$OMSERVS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_omservs
				poweron_server BLADE $OMSERVS_ILO_ADDRESS $OMSERVS_ILO_USER $OMSERVS_ILO_PASS
			else
				boot_from_network_omservs
			fi
			install_omservs
		) > $LOG_FILE 2>&1;parallel_finish
	        ) & set_parallel_variables
	fi

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$INITIAL_INSTALL_OMSERVS" == "yes" ]] && [[ "$INITIAL_INSTALL_OMSERVS_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omservs_part2"
		PART_OF_STAGE="INITIAL_INSTALL_OMSERVS_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on omservs $OMSERVS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_OMSERVS_PART1"
                        remove_serial_port_omservs
                        wait_until_sshable_omservs
                        setup_resolver_omservs
                        set_external_gateway_omservs
                        set_prompt_omservs
			#swap space workaround
                        $SSH -qt $OMSERVS_HOSTNAME "zfs set volsize=10g rpool/swap; zfs get volsize rpool/swap " > /dev/null 2>&1
                        install_caas_omservs
                        set_eeprom_text_omservs
                        install_vmware_tools_omservs
                        message "INFO: Completed omservs install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_NEDSS" == "yes" ]] && [[ "$INITIAL_INSTALL_NEDSS_PART1" != "no" ]]
        then
		###################################
                # Parallel variable initialization
                ###################################
		PARALLEL_ID="nedss_part1"
		PART_OF_STAGE="INITIAL_INSTALL_NEDSS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing nedss $NEDSS_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_nedss
		        add_dhcp_client_remote_nedss
			if [[ "$NEDSS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_nedss
				poweron_server BLADE $NEDSS_ILO_ADDRESS $NEDSS_ILO_USER $NEDSS_ILO_PASS
			else
				boot_from_network_nedss
			fi
			install_nedss
		) > $LOG_FILE 2>&1;parallel_finish
	        ) & set_parallel_variables
        fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_NEDSS" == "yes" ]] && [[ "$INITIAL_INSTALL_NEDSS_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="nedss_part2"
		PART_OF_STAGE="INITIAL_INSTALL_NEDSS_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on nedss $NEDSS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_NEDSS_PART1 $REQUIREMENT_CLEANUP_SFS_SMRS"
                        wait_until_sshable_nedss
                        set_eeprom_text_nedss
                        remove_serial_port_nedss
                        wait_until_sshable_nedss
			setup_resolver_nedss
                        set_external_gateway_nedss
                        set_prompt_nedss
                        install_vmware_tools_nedss
                        message "INFO: Completed nedss install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$UAS1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_UAS1" == "yes" ]] && [[ "$INITIAL_INSTALL_UAS1_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
		PARALLEL_ID="uas1_part1"
		PART_OF_STAGE="INITIAL_INSTALL_UAS1_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing uas1 $UAS1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_uas1
			add_dhcp_client_remote_uas1
			if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_uas1
				poweron_server BLADE $UAS1_ILO_ADDRESS $UAS1_ILO_USER $UAS1_ILO_PASS
			else
				boot_from_network_uas1
			fi
			install_uas1_initial_only
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$UAS1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_UAS1" == "yes" ]] && [[ "$INITIAL_INSTALL_UAS1_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="uas1_part2"
		PART_OF_STAGE="INITIAL_INSTALL_UAS1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on uas1 $UAS1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_UAS1_PART1"
			remove_serial_port_uas1
			wait_until_sshable_uas1
			set_external_gateway_uas1
			set_prompt_uas1
			set_eeprom_text_uas1
			install_vmware_tools_uas1

                        $SSH -qt $UAS1_HOSTNAME "cd /usr/lib; ln -s ../../lib/libssl.so.1.0.0 /usr/lib/libssl.so.0.9.7; ln -s ../../lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.0.9.7" > /dev/null 2>&1

			
                         #swap space workaround
                        $SSH -qt $UAS1_HOSTNAME "zfs set volsize=10g rpool/swap; zfs get volsize rpool/swap " > /dev/null 2>&1


		
			if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
			then
				:	
			else
				$SSH -qt $UAS1_HOSTNAME "poweroff" > /dev/null 2>&1
				wait_until_not_pingable $UAS1_HOSTNAME
			fi			
			message "INFO: Completed uas1 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi


	if [[ "$PEER1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_PEER1" == "yes" ]] && [[ "$INITIAL_INSTALL_PEER1_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="peer1_part1"
		PART_OF_STAGE="INITIAL_INSTALL_PEER1_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing peer1 $PEER1_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
                        create_config_files_peer1
	                add_dhcp_client_remote_peer1
                        if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_peer1
                                poweron_server BLADE $PEER1_ILO_ADDRESS $PEER1_ILO_USER $PEER1_ILO_PASS
                        else
                                boot_from_network_peer1
                        fi
                        install_peer1_initial_only
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

        if [[ "$PEER1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_PEER1" == "yes" ]] && [[ "$INITIAL_INSTALL_PEER1_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="peer1_part2"
		PART_OF_STAGE="INITIAL_INSTALL_PEER1_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on peer1 $PEER1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_PEER1_PART1"
			remove_serial_port_peer1
			wait_until_sshable_peer1
			set_external_gateway_peer1
			set_prompt_peer1
			set_eeprom_text_peer1
			install_vmware_tools_peer1
			if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
			then
				:
			else
				$SSH -qt $PEER1_HOSTNAME "poweroff" > /dev/null 2>&1
				wait_until_not_pingable $PEER1_HOSTNAME
			fi

			message "INFO: Completed peer1 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$EBAS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_EBAS" == "yes" ]] && [[ "$INITIAL_INSTALL_EBAS_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
		PARALLEL_ID="ebas_part1"
		PART_OF_STAGE="INITIAL_INSTALL_EBAS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing ebas $EBAS_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			create_config_files_ebas
			add_dhcp_client_remote_ebas
			if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_ebas
				poweron_server BLADE $EBAS_ILO_ADDRESS $EBAS_ILO_USER $EBAS_ILO_PASS
			else
				boot_from_network_ebas
			fi
			install_ebas_initial_only
                     
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

       
	if [[ "$EBAS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_EBAS" == "yes" ]] && [[ "$INITIAL_INSTALL_EBAS_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="ebas_part2"
		PART_OF_STAGE="INITIAL_INSTALL_EBAS_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ebas $EBAS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_EBAS_PART1"
                        remove_serial_port_ebas
                        wait_until_sshable_ebas
                        set_external_gateway_ebas
                        set_prompt_ebas
                        set_eeprom_text_ebas
                        install_vmware_tools_ebas
			if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
			then
				:
			else
				$SSH -qt $EBAS_HOSTNAME "poweroff" > /dev/null 2>&1
				wait_until_not_pingable $EBAS_HOSTNAME
			fi
			
			message "INFO: Completed ebas install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

		if [[ "$MWS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_MWS" == "yes" ]] && [[ "$INITIAL_INSTALL_MWS_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
		PARALLEL_ID="mws_part1"
		PART_OF_STAGE="INITIAL_INSTALL_MWS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing mws $MWS_HOSTNAME"
                ###################################
                (
                (
			#parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
			
			create_config_files_mws
			add_dhcp_client_remote_mws
			if [[ "$MWS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_mws
				poweron_server BLADE $MWS_ILO_ADDRESS $MWS_ILO_USER $MWS_ILO_PASS
			else
				boot_from_network_mws
			fi
			install_mws
                     
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

       
	if [[ "$MWS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_MWS" == "yes" ]] && [[ "$INITIAL_INSTALL_MWS_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="mws_part2"
		PART_OF_STAGE="INITIAL_INSTALL_MWS_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on mws $MWS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_MWS_PART1"
                        wait_until_sshable_mws
                        remove_serial_port_mws
                        wait_until_sshable_mws
                        set_external_gateway_mws
                        set_prompt_mws
                        set_eeprom_text_mws
                        install_vmware_tools_mws
			if [[ "$MWS_SERVER_TYPE" == "blade" ]]
			then
				:
			else
                                # Wait for power off to finish
		                poweroffgracefully_prefix "MWS" graceful
				#$SSH -qt $MWS_HOSTNAME "poweroff" > /dev/null 2>&1
				wait_until_not_pingable $MWS_HOSTNAME
			fi
			
			message "INFO: Completed mws install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$MS1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_TOR" == "yes" ]] && [[ "$INITIAL_INSTALL_TOR_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="tor_part1"
                PART_OF_STAGE="INITIAL_INSTALL_TOR_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing tor part 1"
                ###################################
                (
                (
			tor_ms_configuration
			tor_peer_node_configuration
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi



	# Post steps early
	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]]
        then
		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omservm_post_steps"
		PART_OF_STAGE="POST_INSTALL_OMSERVM"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Omservm Post Steps"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSAS_PART2 $REQUIREMENT_OMSERVM_PART2"
			wait_until_services_started_adm1
			wait_until_services_started_omsas
			wait_until_services_started_omservm
			#setup_ntp_client_omservm
			configure_csa_omservm
			plumb_storage_nic_omservm
		) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
	fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="setup_ssh_masterservice_omservm"
		PART_OF_STAGE="POST_INSTALL_OMSERVM"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="SSH setup from omservm to master"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVM_POST_STEPS"
			wait_until_services_started_adm1
			wait_until_services_started_omservm
                        setup_ssh_masterservice_omservm
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi


	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omservs_post_steps"
		PART_OF_STAGE="POST_INSTALL_OMSERVS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Omservs Post Steps"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSAS_PART2 $REQUIREMENT_OMSERVS_PART2"
			wait_until_services_started_adm1
			wait_until_services_started_omsas
			wait_until_services_started_omservs
			#setup_ntp_client_omservs
                        configure_csa_omservs
			plumb_storage_nic_omservs
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="setup_ssh_masterservice_omservs"
		PART_OF_STAGE="POST_INSTALL_OMSERVS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="SSH setup from omservs to master"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVS_POST_STEPS"
			wait_until_services_started_adm1
			wait_until_services_started_omservs
                        setup_ssh_masterservice_omservs
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="add_omservs_sls_url_adm1"
		PART_OF_STAGE="POST_INSTALL_OMSERVS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Adding 2nd sls url to $ADM1_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVS_POST_STEPS"
			wait_oss_online_adm1
			wait_until_services_started_adm1
                        add_omservs_sls_url_adm1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omservm_scs"
		PART_OF_STAGE="POST_INSTALL_OMSERVM"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Populate scs properties for omservm $OMSERVM_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_ENABLE_MS_SECURITY $REQUIREMENT_MANAGE_MCS_INITIAL"
			wait_until_services_started_adm1
			wait_until_services_started_omservm
			update_scs_properties
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSAS" == "yes" ]] && [[ "$ADM1_HOSTNAME" != "" ]]
        then

		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="omsas_post_steps"
		PART_OF_STAGE="POST_INSTALL_OMSAS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="OMSAS Post Steps"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSAS_PART2 $REQUIREMENT_OMSERVM_PART2"
			wait_until_services_started_adm1
			wait_until_services_started_omsas
			wait_until_services_started_omservm
			#setup_ntp_client_omsas
                        setup_ssh_masterservice_omsas
			generate_p12_omsas
	                copy_ms_certs_omsas
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_OMSERVM" == "yes" ]]
	then
		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="setup_replication_detect"
		PART_OF_STAGE="POST_INSTALL_OMSERVM"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Setting up cominf replication"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSERVS_POST_STEPS $REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVM $REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVS "
			configure_passwordless_ssh_omsrv
			setup_replication_detect
		) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
	fi


	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_ADM1" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="setup_adm1_ldap_client"
		PART_OF_STAGE="POST_INSTALL_ADM1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Setup adm1 $ADM1_HOSTNAME as an ldap client"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_SETUP_REPLICATION"
			wait_oss_online_adm1
			wait_until_services_started_adm1
			wait_until_services_started_omservm
			setup_resolver_adm1
                        setup_adm1_ldap_client
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$ADM1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_ADM1" == "yes" ]] && [[ "$ADM1_SECURITY" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="enable_ms_security"
		PART_OF_STAGE="POST_INSTALL_ADM1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Enabling security on $ADM1_HOSTNAME"
                ###################################
                (
                (
                        if [[ "$INITIAL_INSTALL_OMSERVS_PART2" == "yes" ]] && [[ "$POST_INSTALL_OMSERVS" == "yes" ]]
                        then
                                parallel_requirements "$REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSERVS_POST_STEPS $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT"
                                wait_oss_online_adm1
                                wait_until_services_started_adm1
                                wait_until_services_started_omsas
                                wait_until_services_started_omservm
                                wait_until_services_started_omservs
                        else
                                parallel_requirements "$REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT"
                                wait_oss_online_adm1
                                wait_until_services_started_adm1
                                wait_until_services_started_omsas
                                wait_until_services_started_omservm
                        fi
			enable_ms_security
			pwadmin_commands
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi


	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_NEDSS" == "yes" ]] && [[ "$INITIAL_INSTALL_NEDSS_PART1" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="cleanup_sfs_smrs"
                PART_OF_STAGE="INITIAL_INSTALL_NEDSS_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Cleaning up old smrs shares, rollbacks, snapshots and filesystems" 
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE"
                        cleanup_sfs_smrs
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_NEDSS" == "yes" ]] && [[ "$NEDSS_SMRS_OSS_ID" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="create_and_share_smrs_filesystems"
		PART_OF_STAGE="POST_INSTALL_NEDSS"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Creating and sharing smrs filesystems"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ADM1_PART2 $REQUIREMENT_CLEANUP_SFS_SMRS $REQUIREMENT_ENABLE_MS_SECURITY"
			wait_until_services_started_adm1
			create_and_share_smrs_filesystems
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_NEDSS" == "yes" ]] && [[ "$NEDSS_SMRS_OSS_ID" != "" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="nedss_post_steps"
		PART_OF_STAGE="POST_INSTALL_NEDSS"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="NEDSS Post Steps"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSERVS_POST_STEPS $REQUIREMENT_CLEANUP_SFS_SMRS $REQUIREMENT_CREATE_AND_SHARE_SMRS_FILESYSTEMS $REQUIREMENT_MANAGE_MCS_INITIAL $REQUIREMENT_NEDSS_PART1 $REQUIREMENT_NEDSS_PART2 $REQUIREMENT_ADM2_ADD_TO_CLUSTER"
			plumb_storage_nic_nedss
			setup_adm1_ssh_keys

			#nfs domainmap id update workaround
			#$SSH -qt $OSSMASTER_HOSTNAME "sharectl set -p nfsmapid_domain=vts.com nfs" > /dev/null 2>&1

			configure_smrs_master_service
			configure_smrs_add_nedss_nedss
			configure_smrs_add_slave4_service_nedss
			configure_smrs_add_slave6_service_nedss
			setup_ntp_client_nedss
			add_aif_nedss
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$UAS1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_UAS1" == "yes" ]]
        then
		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="uas_post_steps"
		PART_OF_STAGE="POST_INSTALL_UAS1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="UAS Post Steps"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE $REQUIREMENT_ADM1_PART1 $REQUIREMENT_ADM1_PART2 $REQUIREMENT_UAS1_PART2 $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT $REQUIREMENT_NEDSS_POST_STEPS"
			if [[ "$UAS1_SERVER_TYPE" == "blade" ]]
			then
				:	
			else
				poweron_uas1
			fi
			wait_oss_online_adm1
			wait_until_services_started_adm1
			activate_uas_uas1
			wait_until_sshable_uas1
			wait_until_services_started_uas1
			install_uas1
			wait_until_sshable_uas1
			set_eeprom_text_uas1
			remove_serial_port_uas1
			wait_until_services_started_uas1
			setup_ntp_client_uas1
			plumb_storage_nic_uas1
			setup_resolver_uas1
			uas_post_steps_uas1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$PEER1_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_PEER1" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="peer1_post_steps"
		PART_OF_STAGE="POST_INSTALL_PEER1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Peer Post Steps"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_PEER1_PART2 $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT $REQUIREMENT_ADM1_PART2 $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_NEDSS_POST_STEPS"
			if [[ "$PEER1_SERVER_TYPE" == "blade" ]]
			then
				:
			else
				poweron_peer1
			fi
			wait_oss_online_adm1
			wait_until_services_started_adm1
			#activate_peer_peer1
			#wait_until_sshable_peer1
			wait_until_services_started_peer1
			install_peer1
			wait_until_sshable_peer1
			set_eeprom_text_peer1
			remove_serial_port_peer1
			wait_until_services_started_peer1
			setup_ntp_client_peer1
			configure_peer_peer1
			activate_peer_peer1
			copy_p12_to_server_peer1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ADM2_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_ADM2" == "yes" ]]
        then
		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="adm2_add_to_cluster"
		PART_OF_STAGE="POST_INSTALL_ADM2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Adding adm2 to the cluster"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ADD_OMSERVS_SLS_URL_ADM1 $REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE $REQUIREMENT_ADM1_PART1 $REQUIREMENT_ADM1_PART2 $REQUIREMENT_ADM2_PART1 $REQUIREMENT_ADM2_PART2 $REQUIREMENT_EBAS_PART1 $REQUIREMENT_EBAS_PART2 $REQUIREMENT_EBAS_POST_STEPS $REQUIREMENT_ENABLE_MS_SECURITY $REQUIREMENT_ENIQE_PART1 $REQUIREMENT_ENIQS_PART1 $REQUIREMENT_EXPAND_DATABASES $REQUIREMENT_MANAGE_MCS_INITIAL $REQUIREMENT_CLEANUP_SFS_SMRS $REQUIREMENT_CREATE_AND_SHARE_SMRS_FILESYSTEMS $REQUIREMENT_NEDSS_PART1 $REQUIREMENT_NEDSS_PART2 $REQUIREMENT_OMSAS_PART1 $REQUIREMENT_OMSAS_PART2 $REQUIREMENT_OMSAS_POST_STEPS $REQUIREMENT_OMSERVM_PART1 $REQUIREMENT_OMSERVM_PART2 $REQUIREMENT_OMSERVM_POST_STEPS $REQUIREMENT_OMSERVM_SCS $REQUIREMENT_OMSERVS_PART1 $REQUIREMENT_OMSERVS_PART2 $REQUIREMENT_OMSERVS_POST_STEPS $REQUIREMENT_PEER1_PART1 $REQUIREMENT_PEER1_PART2 $REQUIREMENT_PEER_POST_STEPS $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT $REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVM $REQUIREMENT_SETUP_SSH_MASTERSERVICE_OMSERVS $REQUIREMENT_UAS1_PART1 $REQUIREMENT_UAS1_PART2 $REQUIREMENT_UAS_POST_STEPS $REQUIREMENT_SETUP_REPLICATION"
			add_cluster_node_adm2
			wait_for_check_hastatus_group StorLan $ADM1_HOSTNAME
			add_second_root_disk_adm2
			switch_sybase_adm2
		) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$EBAS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_EBAS" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="ebas_post_steps"
		PART_OF_STAGE="POST_INSTALL_EBAS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="EBAS Post Steps"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_EBAS_PART2 $REQUIREMENT_SETUP_ADM1_LDAP_CLIENT $REQUIREMENT_NEDSS_POST_STEPS"
			if [[ "$EBAS_SERVER_TYPE" == "blade" ]]
			then
				:
			else
				poweron_ebas
			fi
			wait_oss_online_adm1
			wait_until_services_started_adm1
		        activate_uas_ebas
			#wait_until_sshable_ebas
			wait_until_services_started_ebas
		        install_ebas
			wait_until_sshable_ebas
			set_eeprom_text_ebas
			remove_serial_port_ebas
			wait_until_services_started_ebas
			plumb_storage_nic_ebas
	        	post_steps_ebas
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi
######
	if [[ "$MWS_HOSTNAME" != "" ]] && [[ "$POST_INSTALL_MWS" == "yes" ]]
		then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="mws_post_steps"
		PART_OF_STAGE="POST_INSTALL_MWS"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="MWS Post Steps"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_MWS_PART2"
			
			if [[ "$MWS_SERVER_TYPE" == "blade" ]]
			then
				:
			else
				poweron_mws
			fi
			wait_until_services_started_mws
			set_eeprom_text_mws
			remove_serial_port_mws
			wait_until_services_started_mws
			plumb_storage_nic_mws
	        	post_steps_mws
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

    fi
#####
	if [[ "$ENIQE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQE" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQE_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="eniqe_part1"
		PART_OF_STAGE="INITIAL_INSTALL_ENIQE_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing ENIQ Events $ENIQE_HOSTNAME"
		###################################
		(
		(
			cleanup_sfs_eniqe
			create_config_files_eniqe
			add_dhcp_client_remote_eniqe
			if [[ "$ENIQE_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_eniqe
				poweron_server BLADE $ENIQE_ILO_ADDRESS $ENIQE_ILO_USER $ENIQE_ILO_PASS
			else
				boot_from_network_eniqe
			fi
			install_eniqe
			#wait_until_not_pingable $ENIQE_HOSTNAME
            ) > $LOG_FILE 2>&1;parallel_finish
            ) & set_parallel_variables

	fi

	if [[ "$ENIQE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQE" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQE_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqe_part2"
		PART_OF_STAGE="INITIAL_INSTALL_ENIQE_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Events $ENIQE_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ENIQE_PART1"
			wait_until_sshable_eniqe
			set_eeprom_text_eniqe
			remove_serial_port_eniqe
			wait_until_sshable_eniqe
			set_external_gateway_eniqe
			set_prompt_eniqe
			setup_ntp_client_eniqe
			disable_cde_login_eniqe
			install_vmware_tools_eniqe
			install_vmware_tools_sfs
			#wait_oss_online_eniqe
			message "INFO: Completed eniqe install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$CEP_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_CEP" == "yes" ]] && [[ "$INITIAL_INSTALL_CEP_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="cep_part1"
		PART_OF_STAGE="INITIAL_INSTALL_CEP_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing CEP $CEP_HOSTNAME"
		###################################
		(
		(
			create_config_files_cep
			add_dhcp_client_remote_cep
			if [[ "$CEP_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_cep
				poweron_server BLADE $CEP_ILO_ADDRESS $CEP_ILO_USER $CEP_ILO_PASS
			else
				boot_from_network_cep
			fi
			install_cep
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables
	fi

	if [[ "$CEP_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_CEP" == "yes" ]] && [[ "$INITIAL_INSTALL_CEP_PART2" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="cep_part2"
		PART_OF_STAGE="INITIAL_INSTALL_CEP_PART2"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="-> Final install steps on CEP $CEP_HOSTNAME"
		###################################
		(
		(
			parallel_requirements "$REQUIREMENT_CEP_PART1"
			wait_until_sshable_cep
			remove_serial_port_cep
			wait_until_sshable_cep
			install_vmware_tools_cep
			install_vmware_tools_sfs
			parallel_requirements "$REQUIREMENT_ENIQE_PART2"
			cep_post_steps
			message "INFO: Completed cep install\n" INFO
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables
	fi

	if [[ "$ENIQS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQS" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQS_PART1" != "no" ]]
	then

		###################################
		# Parallel variable initialization
		###################################
		PARALLEL_ID="eniqs_part1"
		PART_OF_STAGE="INITIAL_INSTALL_ENIQS_PART1"
		LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
		PARALLEL_STATUS_STRING="Installing ENIQ Stats $ENIQS_HOSTNAME"
		###################################
		(
		(
			cleanup_sfs_eniqs
			create_config_files_eniqs
			add_dhcp_client_remote_eniqs
			if [[ "$ENIQS_SERVER_TYPE" == "blade" ]]
			then
				boot_from_network_eniqs
				poweron_server BLADE $ENIQS_ILO_ADDRESS $ENIQS_ILO_USER $ENIQS_ILO_PASS
			else
				boot_from_network_eniqs
			fi
			install_eniqs
			#wait_until_not_pingable $ENIQS_HOSTNAME
		) > $LOG_FILE 2>&1;parallel_finish
		) & set_parallel_variables

	fi

	if [[ "$ENIQS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQS" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQS_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqs_part2"
		PART_OF_STAGE="INITIAL_INSTALL_ENIQS_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Stats $ENIQS_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ENIQS_PART1"
			wait_until_sshable_eniqs
			set_eeprom_text_eniqs
			remove_serial_port_eniqs
			wait_until_sshable_eniqs
			set_external_gateway_eniqs
			set_prompt_eniqs
			setup_ntp_client_eniqs
			disable_cde_login_eniqs
			install_vmware_tools_eniqs
			install_vmware_tools_sfs
			#wait_oss_online_eniqs
			message "INFO: Completed eniqs install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ENIQSC_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSC" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSC_PART1" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsc_part1"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSC_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing ENIQ Stats Coordinator $ENIQSC_HOSTNAME"
                ###################################
                (
                (
                        cleanup_sfs_eniqsc
                        create_config_files_eniqsc
                        add_dhcp_client_remote_eniqsc
                        if [[ "$ENIQSC_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_eniqsc
                                poweron_server BLADE $ENIQSC_ILO_ADDRESS $ENIQSC_ILO_USER $ENIQSC_ILO_PASS
                        else
                                boot_from_network_eniqsc
                        fi
                        install_eniqsc
                        #wait_until_not_pingable $ENIQSC_HOSTNAME
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

        if [[ "$ENIQSC_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSC" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSC_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsc_part2"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSC_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Stats Coordinator $ENIQSC_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ENIQSC_PART1"
                        wait_until_sshable_eniqsc
                        set_eeprom_text_eniqsc
                        remove_serial_port_eniqsc
                        wait_until_sshable_eniqsc
                        set_external_gateway_eniqsc
                        set_prompt_eniqsc
                        setup_ntp_client_eniqsc
			disable_cde_login_eniqsc
                        install_vmware_tools_eniqsc
                        install_vmware_tools_sfs
                        #wait_oss_online_eniqsc
                        message "INFO: Completed eniqsc install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ENIQSE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSE" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSE_PART1" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqse_part1"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSE_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing ENIQ Stats Engine $ENIQSE_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2"
                        create_config_files_eniqse
                        add_dhcp_client_remote_eniqse
                        if [[ "$ENIQSE_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_eniqse
                                poweron_server BLADE $ENIQSE_ILO_ADDRESS $ENIQSE_ILO_USER $ENIQSE_ILO_PASS
                        else
                                boot_from_network_eniqse
                        fi
                        install_eniqse
                        #wait_until_not_pingable $ENIQSE_HOSTNAME
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

        if [[ "$ENIQSE_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSE" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSE_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqse_part2"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSE_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Stats Engine $ENIQSE_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2 $REQUIREMENT_ENIQSE_PART1"
                        wait_until_sshable_eniqse
                        set_eeprom_text_eniqse
                        remove_serial_port_eniqse
                        wait_until_sshable_eniqse
                        set_external_gateway_eniqse
                        set_prompt_eniqse
                        setup_ntp_client_eniqse
			disable_cde_login_eniqse
                        install_vmware_tools_eniqse
                        install_vmware_tools_sfs
                        #wait_oss_online_eniqse
                        message "INFO: Completed eniqse install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ENIQSR1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR1" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSR1_PART1" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsr1_part1"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSR1_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing ENIQ Stats Reader 1 $ENIQSR1_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2"
                        create_config_files_eniqsr1
                        add_dhcp_client_remote_eniqsr1
                        if [[ "$ENIQSR1_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_eniqsr1
                                poweron_server BLADE $ENIQSR1_ILO_ADDRESS $ENIQSR1_ILO_USER $ENIQSR1_ILO_PASS
                        else
                                boot_from_network_eniqsr1
                        fi
                        install_eniqsr1
                        #wait_until_not_pingable $ENIQSR1_HOSTNAME
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

        if [[ "$ENIQSR1_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR1" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSR1_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsr1_part2"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSR1_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Stats Reader 1 $ENIQSR1_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2 $REQUIREMENT_ENIQSR1_PART1"
                        wait_until_sshable_eniqsr1
                        set_eeprom_text_eniqsr1
                        remove_serial_port_eniqsr1
                        wait_until_sshable_eniqsr1
                        set_external_gateway_eniqsr1
                        set_prompt_eniqsr1
                        setup_ntp_client_eniqsr1
			disable_cde_login_eniqsr1
                        install_vmware_tools_eniqsr1
                        install_vmware_tools_sfs
                        #wait_oss_online_eniqsr1
                        message "INFO: Completed eniqsr1 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$ENIQSR2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR2" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSR2_PART1" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsr2_part1"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSR2_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing ENIQ Stats Reader 2 $ENIQSR2_HOSTNAME"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2 $REQUIREMENT_ENIQSC_PART2"
                        create_config_files_eniqsr2
                        add_dhcp_client_remote_eniqsr2
                        if [[ "$ENIQSR2_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_eniqsr2
                                poweron_server BLADE $ENIQSR2_ILO_ADDRESS $ENIQSR2_ILO_USER $ENIQSR2_ILO_PASS
                        else
                                boot_from_network_eniqsr2
                        fi
                        install_eniqsr2
                        #wait_until_not_pingable $ENIQSR2_HOSTNAME
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

        if [[ "$ENIQSR2_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_ENIQSR2" == "yes" ]] && [[ "$INITIAL_INSTALL_ENIQSR2_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="eniqsr2_part2"
                PART_OF_STAGE="INITIAL_INSTALL_ENIQSR2_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on ENIQ Stats Reader 2 $ENIQSR2_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_ENIQSC_PART1 $REQUIREMENT_ENIQSC_PART2 $REQUIREMENT_ENIQSR2_PART1"
                        wait_until_sshable_eniqsr2
                        set_eeprom_text_eniqsr2
                        remove_serial_port_eniqsr2
                        wait_until_sshable_eniqsr2
                        set_external_gateway_eniqsr2
                        set_prompt_eniqsr2
                        setup_ntp_client_eniqsr2
			disable_cde_login_eniqsr2
                        install_vmware_tools_eniqsr2
                        install_vmware_tools_sfs
                        #wait_oss_online_eniqsr2
                        message "INFO: Completed eniqsr2 install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$SON_VIS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_SON_VIS" == "yes" ]] && [[ "$INITIAL_INSTALL_SON_VIS_PART1" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="son_vis_part1"
                PART_OF_STAGE="INITIAL_INSTALL_SON_VIS_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Installing SON VIS $SON_VIS_HOSTNAME"
                ###################################
                (
                (
                        cleanup_sfs_son_vis
                        create_config_files_son_vis
                        add_dhcp_client_remote_son_vis
                        if [[ "$SON_VIS_SERVER_TYPE" == "blade" ]]
                        then
                                boot_from_network_son_vis
                                poweron_server BLADE $SON_VIS_ILO_ADDRESS $SON_VIS_ILO_USER $SON_VIS_ILO_PASS
                        else
                                boot_from_network_son_vis
                        fi
                        install_son_vis
                        #wait_until_not_pingable $SON_VIS_HOSTNAME
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

        if [[ "$SON_VIS_HOSTNAME" != "" ]] && [[ "$INITIAL_INSTALL_SON_VIS" == "yes" ]] && [[ "$INITIAL_INSTALL_SON_VIS_PART2" != "no" ]]
        then

                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="son_vis_part2"
                PART_OF_STAGE="INITIAL_INSTALL_SON_VIS_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="-> Final install steps on SON VIS $SON_VIS_HOSTNAME"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_SON_VIS_PART1"
                        wait_until_sshable_son_vis
                        set_eeprom_text_son_vis
                        remove_serial_port_son_vis
                        wait_until_sshable_son_vis
                        set_external_gateway_son_vis
                        set_prompt_son_vis
                        setup_ntp_client_son_vis
			disable_cde_login_son_vis
                        install_vmware_tools_son_vis
                        install_vmware_tools_sfs
                        message "INFO: Completed son_vis install\n" INFO
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	if [[ "$NETSIM_SERVERS" != "" ]] && [[ "$INITIAL_INSTALL_NETSIM" == "yes" ]] && [[ "$INITIAL_INSTALL_NETSIM_PART1" != "no" ]]
        then
		###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="netsim_rollout_part1"
                PART_OF_STAGE="INITIAL_INSTALL_NETSIM_PART1"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Netsim rollout part 1"
                ###################################
                (
                (
			netsim_rollout_part1
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
	fi

	if [[ "$NETSIM_SERVERS" != "" ]] && [[ "$INITIAL_INSTALL_NETSIM" == "yes" ]] && [[ "$INITIAL_INSTALL_NETSIM_PART2" != "no" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="netsim_rollout_part2"
                PART_OF_STAGE="INITIAL_INSTALL_NETSIM_PART2"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Netsim rollout part 2"
                ###################################
                (
                (
                        parallel_requirements "$REQUIREMENT_NETSIM_ROLLOUT_PART1 $REQUIREMENT_ADM1_INITIAL_JUMP_COMPLETE $REQUIREMENT_OMSAS_POST_STEPS"
                        netsim_rollout_part2
                ) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables
        fi

	if [[ "$NETSIM_SERVERS" != "" ]] && [[ "$POST_INSTALL_NETSIM" == "yes" ]]
        then
                ###################################
                # Parallel variable initialization
                ###################################
                PARALLEL_ID="netsim_post_steps"
                PART_OF_STAGE="POST_INSTALL_NETSIM"
                LOG_FILE=$RUNNING_LOG_DIR/$PARALLEL_ID.log
                PARALLEL_STATUS_STRING="Netsim Post Steps"
                ###################################
                (
                (
			parallel_requirements "$REQUIREMENT_NETSIM_ROLLOUT_PART1 $REQUIREMENT_NETSIM_ROLLOUT_PART2 $REQUIREMENT_NEDSS_POST_STEPS $REQUIREMENT_MANAGE_MCS_INITIAL $REQUIREMENT_ADM2_ADD_TO_CLUSTER"
			netsim_post_steps
		) > $LOG_FILE 2>&1;parallel_finish
                ) & set_parallel_variables

        fi

	parallel_wait

	if [[ "$POST_INSTALL_FUNCTION" != "" ]]
	then
		message "INFO: Running post install function $POST_INSTALL_FUNCTION now\n" INFO
		$POST_INSTALL_FUNCTION
	fi

	# Set the iops to unlimited before rollout
        message "INFO: Setting limited iops on vms, please wait...: " INFO
	vm_set_iops_all 300
	echo "OK"
}

function run_smoke_test ()
{
	local TEST_NAME="$1"
	local COMMAND="$2"
	local RESULT=""
	echo_equals
	message "Running Smoke Test: $TEST_NAME\n" INFO
	echo_line
	$COMMAND
	echo_line
	EXIT_CODE=$?
	message "Smoke Test Result:  " INFO
	smoke_test_summary="$smoke_test_summary\n$TEST_NAME:"
	if [[ $EXIT_CODE -eq 0 ]]
	then
		message "PASS\n" SUMMARY
		let smoke_test_passes=smoke_test_passes+1
		smoke_test_summary="$smoke_test_summary `message PASS SUMMARY`"
	else
		message "FAIL\n" ERROR
		let smoke_test_failures=smoke_test_failures+1
		smoke_test_summary="$smoke_test_summary `message FAIL ERROR`"
	fi
}
function check_core_completed ()
{
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "cat /ericsson/config/next_stage | grep cleanup"
}
function check_oss_completed ()
{
        requires_variable ADM1_HOSTNAME
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "cat /ericsson/config/.iistage | grep done"
}
function manifest_check ()
{
	requires_variable ADM1_HOSTNAME
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/manifest_check.sh -c $CONFIG -m $MOUNTPOINT"
}
function check_package_installed ()
{
	local SERVER=$1
	local PACKAGE_NAME=$2
	mount_scripts_directory $SERVER
	$SSH -qt $SERVER "$MOUNTPOINT/bin/check_package_installed.sh -c $CONFIG -m $MOUNTPOINT -p $PACKAGE_NAME"
}
function reset_smoke_test_variables ()
{
	smoke_test_failures=0
	smoke_test_passes=0
	smoke_test_summary=""
}
function smoke_test_summary()
{
	echo_line
	message "$smoke_test_summary\n" INFO
	echo_line
	message "Total Number of Tests: $(( $smoke_test_passes + $smoke_test_failures ))\n" INFO
	message "$smoke_test_passes passes\n" INFO
	message "$smoke_test_failures failures\n" INFO
	echo_line
	if [[ $smoke_test_failures -gt 0 ]]
	then
		exit 1
	else
		exit 0
	fi
}
function check_hastatus_group ()
{
	local GROUP=$1
	local SYSTEM=$2
	local SSH_SYSTEM=$3
	if [[ "$SSH_SYSTEM" == "" ]]
	then
		SSH_SYSTEM="$SYSTEM"
	fi
	mount_scripts_directory $SSH_SYSTEM
	$SSH -qTn $SSH_SYSTEM "$MOUNTPOINT/bin/check_hastatus_group.sh -c $CONFIG -m $MOUNTPOINT -g $GROUP -s $SYSTEM"
}

function basic_smoke_test ()
{
	requires_variable ADM1_HOSTNAME
        reset_smoke_test_variables
        local OUTPUT=""
        message "INFO: Starting Basic Smoke Tests\n" INFO
        smoke_test_summary="-- Basic Smoke Test Summary --"

        run_smoke_test "Check core installation completed" "check_core_completed"
        run_smoke_test "Check oss installation completed" "check_oss_completed"
        run_smoke_test "hastatus check of group DDCMon" "check_hastatus_group DDCMon $ADM1_HOSTNAME"
        run_smoke_test "hastatus check of group Oss" "check_hastatus_group Oss $ADM1_HOSTNAME"
        run_smoke_test "hastatus check of group Ossfs" "check_hastatus_group Ossfs $ADM1_HOSTNAME"
        run_smoke_test "hastatus check of group Sybase1" "check_hastatus_group Sybase1 $ADM1_HOSTNAME"
        run_smoke_test "Package installation check of ERICsck" "check_package_installed $ADM1_HOSTNAME ERICsck"
        run_smoke_test "Package installation check of ERICcore" "check_package_installed $ADM1_HOSTNAME ERICcore"
        run_smoke_test "Package installation check of ERICsol" "check_package_installed $ADM1_HOSTNAME ERICsol"
        run_smoke_test "Package installation check of ERICaxe" "check_package_installed $ADM1_HOSTNAME ERICaxe"
        run_smoke_test "Package installation check of ECONFsystem" "check_package_installed $ADM1_HOSTNAME ECONFsystem"
        run_smoke_test "Online mcs check" "manage_mcs_internal INITIAL no yes"
        run_smoke_test "Manifest Check" "manifest_check"

	echo_equals
        smoke_test_summary
}

function enhanced_smoke_test ()
{
	reset_smoke_test_variables
        local OUTPUT=""
	message "INFO: Starting Enhanced Smoke Tests\n" INFO
	smoke_test_summary="-- Enhanced Smoke Test Summary --"

	run_smoke_test "Check nodes are synced" "netsim_rollout_dm_smoke_test"

	message "INFO: Completed Enhanced Smoke Tests\n" INFO
	smoke_test_summary
}
function get_unique_vm_name ()
{
	local THE_HOSTNAME=$1
	local VSP_SERVER=$2
	local VM_NAME_CONFIG=$3
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		get_unique_vm_name_vcd_api $1
	elif [[ "$VM_NAME_CONFIG" != "" ]]
	then
		echo "$VM_NAME_CONFIG"
	else
		get_unique_vm_name_vsp $1 $VSP_SERVER
	fi
}
function get_unique_vm_name_vsp ()
{
	local THE_HOSTNAME=$1
	local VSP_SERVER=$2
	get_vm_name_from_spc $THE_HOSTNAME $VSP_SERVER
}
function get_unique_vm_name_vcd_api ()
{
	local SEARCH="$1"
	echo "$VCD_API_OUTPUT" | grep "$SEARCH"
}

function remove_serial_port_adm1 ()
{
	remove_serial_port_prefix ADM1 poweron verygraceful
}
function remove_serial_port_oss2_adm1 ()
{
	remove_serial_port_prefix OSS2_ADM1 poweron verygraceful
}
function remove_serial_port_adm2 ()
{
	remove_serial_port_prefix ADM2 poweron graceful
}
function remove_serial_port_omservm()
{
	remove_serial_port_prefix OMSERVM poweron graceful
}
function remove_serial_port_omservs()
{
	remove_serial_port_prefix OMSERVS poweron graceful
}
function remove_serial_port_omsas()
{
	remove_serial_port_prefix OMSAS poweron graceful
}
function remove_serial_port_nedss()
{
	remove_serial_port_prefix NEDSS poweron graceful
}
function remove_serial_port_ebas()
{
	remove_serial_port_prefix EBAS poweron graceful
}
function remove_serial_port_mws()
{
	remove_serial_port_prefix MWS poweron graceful
}
function remove_serial_port_uas1 ()
{
	remove_serial_port_prefix UAS1 poweron graceful
}
function remove_serial_port_peer1 ()
{
        remove_serial_port_prefix PEER1 poweron graceful
}
function remove_serial_port_eniqe ()
{
	remove_serial_port_prefix ENIQE poweron graceful
}
function remove_serial_port_cep ()
{
	remove_serial_port_prefix CEP poweron graceful
}
function remove_serial_port_eniqs ()
{
        remove_serial_port_prefix ENIQS poweron graceful
}
function remove_serial_port_eniqsc ()
{
        remove_serial_port_prefix ENIQSC poweron graceful
}
function remove_serial_port_eniqse ()
{
        remove_serial_port_prefix ENIQSE poweron graceful
}
function remove_serial_port_eniqsr1 ()
{
        remove_serial_port_prefix ENIQSR1 poweron graceful
}
function remove_serial_port_eniqsr2 ()
{
        remove_serial_port_prefix ENIQSR2 poweron graceful
}
function remove_serial_port_son_vis ()
{
	remove_serial_port_prefix SON_VIS poweron graceful
}
function remove_serial_port_prefix ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local PREFIX="$1"
	local poweron="$2"
        local GRACEFUL="$3"

	local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`
	if [[ "$X_SERVER_TYPE" == "blade" ]]
        then
                return 0
        fi
        local THE_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
	local VSP_SERVER=`eval echo \\$${PREFIX}_VSP_SERVER`
	local VM_NAME_CONFIG=`eval echo \\$${PREFIX}_VM_NAME`
	local X_SERVER_TYPE=`eval echo \\$${PREFIX}_SERVER_TYPE`
	local VM_NAME=""

	requires_variable VSP_SERVER

	VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi

	# Do the serial activities on vcli server

	message "INFO: Removing the virtual serial port from this VM $VM_NAME\n"
	local check_serial_vcli_command="$MOUNTPOINT/bin/serial.pl --op check --vmname '$VM_NAME'"
	local output=""
	output=`run_vcli_command "$check_serial_vcli_command" $VCEN_HOSTNAME`
	if [[ $? -ne 0 ]]
        then
                message "$output\n" ERROR
                exit 1
        fi
	if [[ `echo "$output" | grep "This VM already has not got serial port"` ]]
	then
	        message "INFO: It already seems to have no serial port\n" INFO
	        return 0
	fi

	# Shut down properly
	if [[ "$GRACEFUL" == "graceful" ]]
	then
		poweroffgracefully "$THE_HOSTNAME" "$VM_NAME" graceful
	elif [[ "$GRACEFUL" == "verygraceful" ]]
	then
		poweroffgracefully "$THE_HOSTNAME" "$VM_NAME" verygraceful
	else
		poweroffvm "$VM_NAME" "$THE_HOSTNAME"
	fi

	#message "INFO: Removing old vSPC for vm $VM_NAME\n" INFO
	local remove_serial_vcli_command="$MOUNTPOINT/bin/serial.pl --op remove --vmname '$VM_NAME'"
	local output=""
	output=`run_vcli_command "$remove_serial_vcli_command" $VCEN_HOSTNAME`
	if [[ $? -ne 0 ]]
        then
		message "$output\n" ERROR
		exit 1
	fi
	if [[ "$poweron" != "nopoweron" ]]
        then
                message "INFO: Powering back on vm $VM_NAME\n" INFO
                poweronvm "$VM_NAME" "$THE_HOSTNAME"
        fi
}
function run_vcli_command ()
{
	local COMMAND="$1"
	local VCEN_HOSTNAME="$2"
	OUTPUT=`$MOUNTPOINT/bin/run_vcli_command.sh -r "$COMMAND" -v $VCEN_HOSTNAME 2>&1`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: $OUTPUT\n" ERROR
		message "ERROR: Something went wrong running the vm command, see output above\n" ERROR
		exit 1
	fi
	echo -n "$OUTPUT"
	message "INFO: OUTPUT= $OUTPUT" INFO
}
function testiops()
{
	vm_set_iops_adm1 100
}
function vm_set_iops_all ()
{
	local SETTING="$1"
	vm_set_iops_sfs $SETTING
        vm_set_iops_adm1 $SETTING
        vm_set_iops_oss2_adm1 $SETTING
        vm_set_iops_adm2 $SETTING
        vm_set_iops_omsas $SETTING
        vm_set_iops_omservm $SETTING
        vm_set_iops_omservs $SETTING
        vm_set_iops_ebas $SETTING
        vm_set_iops_uas1 $SETTING
        vm_set_iops_peer1 $SETTING
        vm_set_iops_nedss $SETTING
        vm_set_iops_eniqe $SETTING
	vm_set_iops_cep $SETTING
        vm_set_iops_eniqs $SETTING
	vm_set_iops_eniqsc $SETTING
	vm_set_iops_eniqse $SETTING
	vm_set_iops_eniqsr1 $SETTING
	vm_set_iops_eniqsr2 $SETTING
	vm_set_iops_son_vis $SETTING
        vm_set_iops_netsim $SETTING
	vm_set_iops_ms $SETTING
	vm_set_iops_sc1 $SETTING
	vm_set_iops_sc2 $SETTING
}
function vm_set_iops_prefix ()
{
	local SERVER_PREFIX=$1
	local IOPS_VALUE="$2"
	local X_SERVER_TYPE=`eval echo \\$${SERVER_PREFIX}_SERVER_TYPE`
	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local X_VM_NAME=`eval echo \\$${SERVER_PREFIX}_VM_NAME`
	local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`

	if [[ "$X_SERVER_TYPE" != "blade" ]] && [[ "$X_HOSTNAME" != "" ]]
        then
                vm_set_iops $X_HOSTNAME "$X_VSP_SERVER" "$X_VM_NAME" $IOPS_VALUE
        fi
}
function vm_set_iops_sfs ()
{
	vm_set_iops_prefix SFS $1
}
function vm_set_iops_adm1 ()
{
	vm_set_iops_prefix ADM1 $1
}
function vm_set_iops_oss2_adm1 ()
{
	vm_set_iops_prefix OSS2_ADM1 $1
}
function vm_set_iops_adm2 ()
{
	vm_set_iops_prefix ADM2 $1
}
function vm_set_iops_omservm ()
{
	vm_set_iops_prefix OMSERVM $1
}
function vm_set_iops_omservs ()
{
	if [[ "$OMSERVS_HOSTNAME" != "dummy" ]]
	then
		vm_set_iops_prefix OMSERVS $1
	fi
}
function vm_set_iops_omsas ()
{
	vm_set_iops_prefix OMSAS $1
}
function vm_set_iops_nedss ()
{
	vm_set_iops_prefix NEDSS $1
}
function vm_set_iops_eniqe ()
{
	vm_set_iops_prefix ENIQE $1
}
function vm_set_iops_cep ()
{
        vm_set_iops_prefix CEP $1
}
function vm_set_iops_eniqs ()
{
	vm_set_iops_prefix ENIQS $1
}
function vm_set_iops_eniqsc ()
{
	vm_set_iops_prefix ENIQSC $1
}
function vm_set_iops_eniqse ()
{
	vm_set_iops_prefix ENIQSE $1
}
function vm_set_iops_eniqsr1 ()
{
	vm_set_iops_prefix ENIQSR1 $1
}
function vm_set_iops_eniqsr2 ()
{
	vm_set_iops_prefix ENIQSR2 $1
}
function vm_set_iops_son_vis ()
{
	vm_set_iops_prefix SON_VIS $1
}
function vm_set_iops_netsim ()
{
	vm_set_iops_prefix NETSIM $1
}
function vm_set_iops_ms ()
{
        vm_set_iops_prefix MS $1
}
function vm_set_iops_sc1 ()
{
        vm_set_iops_prefix SC1 $1
}
function vm_set_iops_sc2 ()
{
        vm_set_iops_prefix SC2 $1
}
function vm_set_iops_uas1 ()
{
	vm_set_iops_prefix UAS1 $1
}
function vm_set_iops_peer1 ()
{
	vm_set_iops_prefix PEER1 $1
}
function vm_set_iops_ebas ()
{
	vm_set_iops_prefix EBAS $1
}
function vm_set_iops ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

        local THE_HOSTNAME="$1"
	local VSP_SERVER="$2"
	local VM_NAME_CONFIG="$3"
	local IOPS_VALUE="$4"
	local VM_NAME=""
	VM_NAME=`get_unique_vm_name $THE_HOSTNAME "$VSP_SERVER" "$VM_NAME_CONFIG"`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
		message "$VM_NAME\n" ERROR
		exit 1
	fi

	if [[ "$IOPS_VALUE" == "unlimited" ]]
	then
		IOPS_VALUE="-1"
	fi

	#message "INFO: Setting iops to $VALUE for this VM\n" INFO
	local iops_vcli_command="$MOUNTPOINT/bin/vmware-vsphere-cli-distrib/apps/vm/vm_set_iops.pl --vmname '$VM_NAME' --iops $IOPS_VALUE"
	run_vcli_command "$iops_vcli_command" $VCEN_HOSTNAME
}
function create_serial_port_prefix()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
	local PREFIX=$1
	local GRACEFUL="$2"

	local VM_NAME_CONFIG=`eval echo \\$${SERVER_PREFIX}_VM_NAME`
	local VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local THE_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`

	VM_NAME=`get_unique_vm_name $THE_HOSTNAME $VSP_SERVER "$VM_NAME_CONFIG"`
	if [[ $? -ne 0 ]]
	then
		message "ERROR: Couldn't get the unique vm name for $THE_HOSTNAME\n" ERROR
		message "$VM_NAME\n" ERROR
		exit 1
	fi

	message "INFO: Checking current vSPC settings\n" INFO
	local check_serial_vcli_command="$MOUNTPOINT/bin/serial.pl --op check --vmname '$VM_NAME'"
	local output=""
	output=`run_vcli_command "$check_serial_vcli_command" $VCEN_HOSTNAME`
	if [[ $? -ne 0 ]]
	then
		message "$output\n" ERROR
		exit 1
	fi
	if [[ `echo "$output" | grep "^telnet://$VSP_SERVER:13370$"` ]]
	then
		message "INFO: Serial port already set to $VSP_SERVER\n" INFO
		message "INFO: Powering back on vm $VM_NAME\n" INFO
		poweronvm "$VM_NAME" "$THE_HOSTNAME"
	else
		remove_serial_port_prefix $PREFIX "nopoweron" "$GRACEFUL"

		# Make sure VM is off, incase didn't have to remove any serial ports and poweroff that way
		if [[ "$GRACEFUL" == "graceful" ]]
	        then
	                poweroffgracefully "$THE_HOSTNAME" "$VM_NAME" graceful
		elif [[ "$GRACEFUL" == "verygraceful" ]]
		then
			poweroffgracefully "$THE_HOSTNAME" "$VM_NAME" verygraceful
	        else
			poweroffvm "$VM_NAME" "$THE_HOSTNAME"
	        fi
		message "INFO: Setting vSPC for vm $VM_NAME\n" INFO

		local add_serial_vcli_command="$MOUNTPOINT/bin/serial.pl --op add --vmname '$VM_NAME' --vspc '$VSP_SERVER'"
		run_vcli_command "$add_serial_vcli_command" $VCEN_HOSTNAME

		message "INFO: Powering back on vm $VM_NAME\n" INFO
		poweronvm "$VM_NAME" "$THE_HOSTNAME"

		#message "INFO: Sleeping for 30 seconds to allow vSPC to kick in\n" INFO
		#sleep 30
	fi

}
function plumb_storage_nic_omservm () 
{
	plumb_storage_nic_prefix OMSERVM
}
function plumb_storage_nic_omservs () 
{
	plumb_storage_nic_prefix OMSERVS
}
function plumb_storage_nic_uas1 () 
{
	plumb_storage_nic_prefix UAS1
}
function plumb_storage_nic_ebas () 
{
	plumb_storage_nic_prefix EBAS
}
function plumb_storage_nic_mws () 
{
	plumb_storage_nic_prefix MWS
}
function plumb_storage_nic_nedss () 
{
	plumb_storage_nic_prefix NEDSS
}
function plumb_storage_nic_prefix () 
{
        local SERVER_PREFIX=$1
        local SERVER=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
        mount_scripts_directory $SERVER

        $SSH -qt $SERVER "$MOUNTPOINT/bin/sol11_plumb_storage_nic.sh -m $MOUNTPOINT -c '$CONFIG' -p $SERVER_PREFIX"
}

function set_cpu_count_prefix ()
{
	local PREFIX=$1
	local X_CPU_COUNT=`eval echo \\$${PREFIX}_CPU_COUNT`
	local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
	local X_VSP_SERVER=`eval echo \\$${PREFIX}_VSP_SERVER`
	local X_VM_NAME=`eval echo \\$${PREFIX}_VM_NAME`

	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi
        if [[ "$X_CPU_COUNT" == "" ]]
        then
                return 0
        fi

        local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$X_HOSTNAME" "$X_VSP_SERVER" "$X_VM_NAME"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the $PREFIX\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        set_cpu_count "$VM_NAME" "$X_CPU_COUNT" "$X_HOSTNAME"
}
function set_cpu_count_adm1 ()
{
	set_cpu_count_prefix ADM1
}
function set_cpu_count_oss2_adm1 ()
{
	set_cpu_count_prefix OSS2_ADM1
}
function set_cpu_count_adm2 ()
{
        set_cpu_count_prefix ADM2
}
function set_cpu_count_ebas ()
{
        set_cpu_count_prefix EBAS
}
function set_cpu_count_mws ()
{
        set_cpu_count_prefix MWS
}
function set_cpu_count_nedss ()
{
        set_cpu_count_prefix NEDSS
}
function set_cpu_count_omsas ()
{
        set_cpu_count_prefix OMSAS
}
function set_cpu_count_omservm ()
{
        set_cpu_count_prefix OMSERVM
}
function set_cpu_count_omservs ()
{
        set_cpu_count_prefix OMSERVS
}
function set_cpu_count_sfs ()
{
        set_cpu_count_prefix SFS1
}
function set_cpu_count_uas1 ()
{
        set_cpu_count_prefix UAS1
}
function set_cpu_count_peer1 ()
{
        set_cpu_count_prefix PEER1
}
function set_cpu_count_eniqe ()
{
        set_cpu_count_prefix ENIQE
}
function set_cpu_count_cep ()
{
	set_cpu_count_prefix CEP
}
function set_cpu_count_eniqs ()
{
        set_cpu_count_prefix ENIQS
}
function set_cpu_count_eniqsc ()
{
        set_cpu_count_prefix ENIQSC
}
function set_cpu_count_eniqse ()
{
        set_cpu_count_prefix ENIQSE
}
function set_cpu_count_eniqsr1 ()
{
        set_cpu_count_prefix ENIQSR1
}
function set_cpu_count_eniqsr2 ()
{
        set_cpu_count_prefix ENIQSR2
}
function set_cpu_count_son_vis ()
{
        set_cpu_count_prefix SON_VIS
}


function set_memory_mb_prefix ()
{
	local PREFIX=$1
        local X_MEMORY_MB=`eval echo \\$${PREFIX}_MEMORY_MB`
	local X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
        local X_VSP_SERVER=`eval echo \\$${PREFIX}_VSP_SERVER`
        local X_VM_NAME=`eval echo \\$${PREFIX}_VM_NAME`

        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

	if [[ "$X_MEMORY_MB" == "" ]]
        then
                return 0
        fi

        local VM_NAME=""
        VM_NAME=`get_unique_vm_name "$X_HOSTNAME" "$X_VSP_SERVER" "$X_VM_NAME"`
        if [[ $? -ne 0 ]]
        then
                message "ERROR: Couldn't get the unique vm name for the $PREFIX\n" ERROR
                message "$VM_NAME\n" ERROR
                exit 1
        fi
        set_memory_mb "$VM_NAME" "$X_MEMORY_MB"
}

function set_memory_mb_adm1 ()
{
        set_memory_mb_prefix ADM1
}
function set_memory_mb_oss2_adm1 ()
{
        set_memory_mb_prefix OSS2_ADM1
}
function set_memory_mb_adm2 ()
{
        set_memory_mb_prefix ADM2
}
function set_memory_mb_ebas ()
{
        set_memory_mb_prefix EBAS
}
function set_memory_mb_mws ()
{
        set_memory_mb_prefix MWS
}
function set_memory_mb_nedss ()
{
        set_memory_mb_prefix NEDSS
}
function set_memory_mb_omsas ()
{
        set_memory_mb_prefix OMSAS
}
function set_memory_mb_omservm ()
{
        set_memory_mb_prefix OMSERVM
}
function set_memory_mb_omservs ()
{
        set_memory_mb_prefix OMSERVS
}
function set_memory_mb_sfs ()
{
        set_memory_mb_prefix SFS1
}
function set_memory_mb_uas1 ()
{
        set_memory_mb_prefix UAS1
}
function set_memory_mb_peer1 ()
{
        set_memory_mb_prefix PEER1
}
function set_memory_mb_eniqe ()
{
        set_memory_mb_prefix ENIQE
}
function set_memory_mb_cep ()
{
	set_memory_mb_prefix CEP
}
function set_memory_mb_eniqs ()
{
        set_memory_mb_prefix ENIQS
}
function set_memory_mb_eniqsc ()
{
        set_memory_mb_prefix ENIQSC
}
function set_memory_mb_eniqse ()
{
        set_memory_mb_prefix ENIQSE
}
function set_memory_mb_eniqsr1 ()
{
        set_memory_mb_prefix ENIQSR1
}
function set_memory_mb_eniqsr2 ()
{
        set_memory_mb_prefix ENIQSR2
}
function set_memory_mb_son_vis ()
{
        set_memory_mb_prefix SON_VIS
}
function set_cpu_count ()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

        local VM_NAME="$1"
	local CPU_COUNT="$2"
	local THE_HOSTNAME="$3"
        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
		message "INFO: Setting the cpu count on $VM_NAME to $CPU_COUNT\n" INFO
		poweroffvm "$VM_NAME" "$THE_HOSTNAME"
                set_cpu_count_vcd "$VM_NAME" "$CPU_COUNT" "$THE_HOSTNAME"
        #else
        #        poweronvm_vsphere "$VM_NAME"
        fi
}
function set_memory_mb()
{
        if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

        local VM_NAME="$1"
	local MEMORY_SIZE="$2"
	local THE_HOSTNAME="$3"
        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
		message "INFO: Setting the memory on $VM_NAME to ${MEMORY_SIZE}mb\n" INFO
		poweroffvm "$VM_NAME" "$THE_HOSTNAME"
                set_memory_mb_vcd "$VM_NAME" "$MEMORY_SIZE" "$THE_HOSTNAME"
	#else
        #        poweronvm_vsphere "$VM_NAME"
        fi
}

function poweronvm ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

	local VM_NAME="$1"
	local THE_HOSTNAME="$2"

	if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
                poweronvm_vcd "$THE_HOSTNAME"
        else
                poweronvm_vsphere "$VM_NAME"
        fi
}

function poweroffgracefully_prefix () {
	local SERVER_PREFIX=$1
        local GRACEFUL=$2

	local X_HOSTNAME=`eval echo \\$${SERVER_PREFIX}_HOSTNAME`
	local X_VSP_SERVER=`eval echo \\$${SERVER_PREFIX}_VSP_SERVER`
	local VM_NAME_CONFIG=`eval echo \\$${SERVER_PREFIX}_VM_NAME`

	local VM_NAME=`get_unique_vm_name $X_HOSTNAME $X_VSP_SERVER "$VM_NAME_CONFIG"`
        poweroffgracefully "$X_HOSTNAME" "$VM_NAME" "$GRACEFUL"
}

function poweroffgracefully ()
{
        local THE_HOSTNAME="$1"
	local VM_NAME="$2"
	local GRACEFUL="$3"
	message "INFO: Powering off $THE_HOSTNAME gracefully\n" INFO
        mount_scripts_directory "$THE_HOSTNAME" "noexit" >/dev/null 2>&1
        if [[ $? -ne 0 ]]
        then
                message "INFO: $THE_HOSTNAME is not sshable, can't power off gracefully\n" INFO
                poweroffvm "$VM_NAME" "$THE_HOSTNAME"
        else
		if [[ "$GRACEFUL" == "graceful" ]]
		then
			# Semi graceful
			$SSH $THE_HOSTNAME "poweroff" > /dev/null 2>&1
		else
			# Very graceful
			$SSH $THE_HOSTNAME "init 5" > /dev/null 2>&1
		fi
                #wait_until_not_sshable $THE_HOSTNAME
		wait_until_not_pingable $THE_HOSTNAME
		wait_until_vm_powered_off "$VM_NAME" "$THE_HOSTNAME"
                return 0
        fi
}

function poweroffvm ()
{
	if [[ "$VIRTUAL" == "no" ]]
        then
                return 0
        fi

        local VM_NAME="$1"
	local THE_HOSTNAME="$2"

        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
                poweroffvm_vcd "$THE_HOSTNAME"
        else
                poweroffvm_vsphere "$VM_NAME"
        fi
}
function resetvm ()
{
        local VM_NAME="$1"
	local THE_HOSTNAME="$2"
        if [[ "$BEHIND_GATEWAY" == "yes" ]]
        then
                resetvm_vcd "$THE_HOSTNAME"
        else
                resetvm_vsphere "$VM_NAME"
        fi
}
function get_vapp_lock ()
{
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		local VAPP_LOCK="/tmp/$PARENT_BASHPID/locks/vapp.lock"
		get_lock $VAPP_LOCK local na 7200 yes > /dev/null 2>&1
	fi
}
function clear_vapp_lock ()
{
	if [[ "$BEHIND_GATEWAY" == "yes" ]]
	then
		local VAPP_LOCK="/tmp/$PARENT_BASHPID/locks/vapp.lock"
		clear_lock $VAPP_LOCK local na > /dev/null 2>&1
	fi
}
function set_memory_mb_vcd ()
{
        local VM_NAME="$1"
	local MEMORY_SIZE="$2"

        output=`$VCLOUD_PHP_FUNCTION -f set_memory_vm --vmid="$VM_NAME" --memorymb="$MEMORY_SIZE" 2>&1`
	local EXIT_CODE=$?

	# Free up vapp lock
	clear_vapp_lock

	if [[ $EXIT_CODE -ne 0 ]]
        then
                message "ERROR: There was a problem setting the memory size on the vm, see output below\n" ERROR
                message "$output\n" ERROR
                exit 1
        #else
        #       message "INFO: Memory size updated on $VM_NAME successfully\n" INFO
        fi
}
function set_cpu_count_vcd ()
{
        local VM_NAME="$1"
        local CPU_COUNT="$2"

        output=`$VCLOUD_PHP_FUNCTION -f set_cpus_vm --vmid="$VM_NAME" --cpucount="$CPU_COUNT" 2>&1`
	local EXIT_CODE=$?

	# Free up vapp lock
        clear_vapp_lock

        if [[ $EXIT_CODE -ne 0 ]]
        then
                message "ERROR: There was a problem setting the cpu count on the vm, see output below\n" ERROR
                message "$output\n" ERROR
                exit 1
        #else
        #       message "INFO: Cpu count updated on $VM_NAME successfully\n" INFO
        fi
}
function poweronvm_vcd ()
{
	local VM_NAME="$1"

	output=`$VCLOUD_PHP_FUNCTION -f poweron_vm_rest --vmname="$VM_NAME" 2>&1`
	local EXIT_CODE=$?

	# Free up vapp lock
	clear_vapp_lock

	if [[ $EXIT_CODE -ne 0 ]]
	then
		message "ERROR: There was a problem powering on the vm, see output below\n" ERROR
		message "$output\n" ERROR
		exit 1
	#else
	#	message "INFO: Powered on $VM_NAME successfully\n" INFO
	fi
}



function poweroffvm_vcd ()
{
        local VM_NAME="$1"

	output=`$VCLOUD_PHP_FUNCTION -f poweroff_vm_rest --vmname="$VM_NAME" 2>&1`
	local EXIT_CODE=$?

	# Free up vapp lock
        clear_vapp_lock

	if [[ $EXIT_CODE -ne 0 ]]
        then
		if [[ ! `echo "$output" | grep "The requested operation could not be executed since VM" |  grep "is not running"` ]] && [[ ! `echo "$output" | grep "The requested operation could not be executed since VM" |  grep "is not powered on"` ]] && [[ ! `echo "$output" |  grep "Current state of the the VM is VMOff"` ]]
		then
	                message "ERROR: There was a problem powering off the vm, see output below\n" ERROR
	                message "$output\n" ERROR
	                return 1
		fi
        fi
}

function resetvm_vcd ()
{
        local VM_NAME="$1"

	output=`$VCLOUD_PHP_FUNCTION -f reset_vm_rest --vmname="$VM_NAME" 2>&1`
	local EXIT_CODE=$?

	# Free up vapp lock
        clear_vapp_lock

	if [[ $EXIT_CODE -ne 0 ]]
        then
                message "ERROR: There was a problem resetting the vm, see output below\n" ERROR
                message "$output\n" ERROR
                exit 1
        fi
}

function poweronvm_vsphere ()
{
	local VM_NAME="$1"

	local poweron_vcli_command="$MOUNTPOINT/bin/vApp_power.pl --op poweronvm --vm '$VM_NAME'"
	run_vcli_command "$poweron_vcli_command" $VCEN_HOSTNAME
}

function poweroffvm_vsphere ()
{
	local VM_NAME="$1"

	local poweroff_vcli_command="$MOUNTPOINT/bin/vApp_power.pl --op poweroffvm --vm '$VM_NAME'"
	run_vcli_command "$poweroff_vcli_command" $VCEN_HOSTNAME
}

function resetvm_vsphere ()
{
	local VM_NAME="$1"

	local reset_vcli_command="$MOUNTPOINT/bin/vApp_power.pl --op resetvm --vm '$VM_NAME'"
	run_vcli_command "$reset_vcli_command" $VCEN_HOSTNAME
}

function add_omservs_sls_url_adm1 ()
{
	requires_variable ADM1_HOSTNAME
	wait_oss_online_adm1
        mount_scripts_directory $ADM1_HOSTNAME
        $SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/add_omservs_sls_url_adm1.sh -c '$CONFIG' -m $MOUNTPOINT"
}
function switch_sybase_adm1 ()
{
	switch_sybase_prefix ADM1 ADM2
}
function switch_sybase_adm2 ()
{
	switch_sybase_prefix ADM2 ADM1
}
function switch_sybase_prefix ()
{
	local TO_NODE_PREFIX=$1
	local FROM_NODE_PREFIX=$2

	local TO_NODE_HOSTNAME=`eval echo \\$${TO_NODE_PREFIX}_HOSTNAME`
	local FROM_NODE_HOSTNAME=`eval echo \\$${FROM_NODE_PREFIX}_HOSTNAME`

	mount_scripts_directory $FROM_NODE_HOSTNAME
	check_hastatus_group Sybase1 $TO_NODE_HOSTNAME
	if [[ "$?" = "0" ]]
	then
		echo "INFO: Sybase already running on $TO_NODE_HOSTNAME"
		return 0
	fi
	wait_for_check_hastatus_group Sybase1 $FROM_NODE_HOSTNAME
	echo "INFO: Switching Sybase1 to $TO_NODE_HOSTNAME"
	local ATTEMPT=1
	while [[ $ATTEMPT -le 10 ]]
	do
		local OUTPUT=`$SSH -qt $FROM_NODE_HOSTNAME "/opt/VRTS/bin/hagrp -switch Sybase1 -to $TO_NODE_HOSTNAME" 2>&1`
		if [[ `echo "$OUTPUT" | grep "VCS WARNING"` ]]
		then
			if [[ $ATTEMPT -eq 10 ]]
                        then
                                echo "$OUTPUT"
                                message "ERROR: Couldn't switch sybase after 10 attempts, see output above\n" ERROR
                                exit 1
                        else
                                message "INFO: Cannot switch sybase yet, waiting 60 secs\n" INFO
                                sleep 60
                                let ATTEMPT=ATTEMPT+1
                        fi
		else
			echo "INFO: Sybase switched to $TO_NODE_HOSTNAME"
			ATTEMPT=11
		fi
	done
	wait_for_check_hastatus_group Sybase1 $TO_NODE_HOSTNAME
}
function wait_for_check_hastatus_group ()
{
	local GROUP=$1
	local SYSTEM=$2
	local ATTEMPT=1
	while [[ $ATTEMPT -le 20 ]]
	do
		echo "INFO: Checking if $GROUP is ONLINE, attempt $ATTEMPT of 20"
		check_hastatus_group $GROUP $SYSTEM
		if [[ "$?" != "0" ]]
		then
			echo "INFO: $GROUP not ONLINE yet, waiting for 60 seconds for $GROUP to come online on $SYSTEM"
			sleep 60
			let ATTEMPT=ATTEMPT+1
		else
			echo "INFO: $GROUP ONLINE"
			ATTEMPT=21
		fi	
	done
}
function add_second_root_disk_adm1 ()
{
        add_second_root_disk_prefix ADM1
}
function add_second_root_disk_adm2 ()
{
	add_second_root_disk_prefix ADM2
}
function add_second_root_disk_prefix ()
{
	local SECONDARY_NODE_PREFIX=$1
	local PRIMARY_NODE_PREFIX=""

	if [[ "$SECONDARY_NODE_PREFIX" == "ADM1" ]]
	then
		PRIMARY_NODE_PREFIX="ADM2"
	else
		PRIMARY_NODE_PREFIX="ADM1"
	fi

	local SECONDARY_NODE_HOSTNAME=`eval echo \\$${SECONDARY_NODE_PREFIX}_HOSTNAME`
        mount_scripts_directory $SECONDARY_NODE_HOSTNAME

	# Sanity check to make sure sybase switched to the primary node
        switch_sybase_prefix $PRIMARY_NODE_PREFIX $SECONDARY_NODE_PREFIX

	# Add the second root disk on the secondary node
        $SSH -qt $SECONDARY_NODE_HOSTNAME "$MOUNTPOINT/bin/add_second_root_disk.sh -c '$CONFIG' -m $MOUNTPOINT -p $SECONDARY_NODE_PREFIX"
}
function update_scs_properties ()
{
	requires_variable OMSERVM_HOSTNAME
	requires_variable ADM1_HOSTNAME
	#wait_oss_online_adm1
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
	get_lock $MC_LOCK local na 7200 yes
	wait_smtool_available_adm1
	mount_scripts_directory $ADM1_HOSTNAME
	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/update_scs_properties.sh -c '$CONFIG' -m $MOUNTPOINT"
	clear_lock $MC_LOCK local na
	message "INFO: Setting omsas expire_logs_days value to 0\n" INFO
	$SSH $OMSAS_HOSTNAME "su caudb -c \"/usr/bin/sed 's/expire_logs_days = 3/expire_logs_days = 0/' /opt/mysql/my.cnf >/var/tmp/my.cnf\""
	$SSH $OMSAS_HOSTNAME "cp /var/tmp/my.cnf /opt/mysql/my.cnf; rm /var/tmp/my.cnf"
	message "INFO: Restarting csa on the omsas\n" INFO
        $SSH $OMSAS_HOSTNAME "svcadm disable -s csa;svcadm enable -s csa"
        message "INFO: csa restart completed\n" INFO
}

function fetch_ior_files ()
{
	requires_variable OMSAS_HOSTNAME
	requires_variable ADM1_HOSTNAME
	mount_scripts_directory $OMSAS_HOSTNAME
	mount_scripts_directory $ADM1_HOSTNAME

	# SCS MC needs to be on, lets check if its on or not
	local CURRENT_SCS_STATUS="`$SSH -qt $ADM1_HOSTNAME \"/opt/ericsson/nms_cif_sm/bin/smtool list\" | grep '^scs ' | awk '{print $2}'`"
	if [[ ! `echo "$CURRENT_SCS_STATUS" | grep "started"` ]]
	then
		message "INFO: Onlining scs mc temporarily\n" INFO
		$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/nms_cif_sm/bin/smtool online scs;/opt/ericsson/nms_cif_sm/bin/smtool prog;/opt/ericsson/nms_cif_sm/bin/smtool prog"
	fi

	# loop through the configuration script and retry if there are any issues
	exec_configuration_script "bin/sol11_fetch_ior_files.sh"
	local EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]
	then
	      message "ERROR: Something went wrong configuring fetch ior files, please check output above\n" ERROR
	      exit 1
	fi

	if [[ ! `echo "$CURRENT_SCS_STATUS" | grep "started"` ]]
        then
                message "INFO: Re-offlining scs mc\n" INFO
                $SSH -qt $ADM1_HOSTNAME "/opt/ericsson/nms_cif_sm/bin/smtool offline scs -reason=other -reasontext=other;/opt/ericsson/nms_cif_sm/bin/smtool prog;/opt/ericsson/nms_cif_sm/bin/smtool prog"
        fi
	
}

function omsas_config_aiws ()
{
        requires_variable OMSAS_HOSTNAME
        requires_variable ADM1_HOSTNAME
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        get_lock $MC_LOCK local na 7200 yes
        wait_smtool_available_adm1

        mount_scripts_directory $OMSAS_HOSTNAME
        mount_scripts_directory $ADM1_HOSTNAME

	message "INFO: Running config.sh for aiws manually post install\n" INFO

	# loop through the configuration script and retry if there are any issues
	exec_configuration_script "bin/sol11_omsas_config_aiws.sh"
	local EXIT_CODE=$?

	clear_lock $MC_LOCK local na
	if [[ $EXIT_CODE -ne 0 ]]
	then
	       message "ERROR: Something went wrong configuring sol11_omsas_config_aiws, please check output above\n" ERROR
	       exit 1
	fi
}

function eba_netsim_steps ()
{
	requires_variable NETSIM_HOSTNAME
	mount_scripts_directory $NETSIM_HOSTNAME
	$SSH -qt $NETSIM_HOSTNAME "$MOUNTPOINT/bin/eba_netsim_steps.sh"
}


# Blank out hostnames of servers that don't exist in vcd vapp any more
function negate_server ()
{
        local SERVER_TYPE=$1
        NEGATE_FILE="/export/scripts/CLOUD/configs/templates/negate/$SERVER_TYPE"
        cd $MOUNTPOINT/bin
        if [[ ! -f $NEGATE_FILE ]]
        then
                message "ERROR: Couldn't find the config file $NEGATE_FILE needed, please check why\n" ERROR
                exit 1
        fi
        #. $NEGATE_FILE
        CONFIG="$CONFIG:$NEGATE_FILE"
        message "INFO: There was no $SERVER_TYPE found in the vapp, so not going to use it in any steps\n" INFO
}

function post_steps_ebas ()
{
	mount_scripts_directory $ADM1_HOSTNAME
	$EXPECT - <<EOF
set force_conservative 1
set prompt ".*(%|#|\\$|>):? $"
set timeout 120
spawn $SSH -qt $ADM1_HOSTNAME "su - nmsadm -c \"/opt/ericsson/eba_common/bin/prepare_ssh.sh $EBAS_HOSTNAME\""

while {"1" == "1"} {
        expect {
	"assword:" {
		send "$ADM1_NMSADM_PASS\r"
	}
	timeout {
                send_user "\nERROR: Timed out trying to setup passwordless ssh from $ADM1_HOSTNAME to ebas\n"
                exit 1
        }
        eof {
		catch wait result
		exit [lindex \$result 3]
        }

        }
EOF

	if [[ $? -ne 0 ]]
	then
		message "ERROR: Failed to setup passwordless ssh from master to ebas, please check output above\n" ERROR
		exit 1
	fi
	setup_ntp_client_ebas

	mount_scripts_directory $EBAS_HOSTNAME
	$SSH -qt $EBAS_HOSTNAME "TERM=xterm; $MOUNTPOINT/bin/sol11_copy_p12_to_ebas.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
	then
		message "ERROR: ebas install failed, couldn't copy the p12 from the master server\n" ERROR
		exit 1
	fi
	NMSADM_PASSWD="`$SSH -qt $ADM1_HOSTNAME \"grep nmsadm /etc/passwd\"`"
	NMSADM_SHADOW="`$SSH -qt $ADM1_HOSTNAME \"grep nmsadm /etc/shadow\"`"

	$SSH -qt $EBAS_HOSTNAME "cat /etc/passwd | grep -v nmsadm > /etc/passwd.tmp;echo \"$NMSADM_PASSWD\" >> /etc/passwd.tmp;mv /etc/passwd.tmp /etc/passwd;dos2unix /etc/passwd > /etc/passwd.tmp;mv /etc/passwd.tmp /etc/passwd"
	$SSH -qt $EBAS_HOSTNAME "cat /etc/shadow | grep -v nmsadm > /etc/shadow.tmp;echo \"$NMSADM_SHADOW\" >> /etc/shadow.tmp;mv /etc/shadow.tmp /etc/shadow;dos2unix /etc/shadow > /etc/shadow.tmp;mv /etc/shadow.tmp /etc/shadow"

	EBAS_SERVICES="rpmoservice ebswservice ebssservice"
	for service in $EBAS_SERVICES
	do
		echo "Setting up $service service in /etc/hosts on $ADM1_HOSTNAME"
		$SSH -qt $ADM1_HOSTNAME "cat /etc/hosts | sed 's/ $service//g' > /etc/hosts.tmp;cat /etc/hosts.tmp | sed 's/^$EBAS_IP_ADDR[ \t][ \t]*/$EBAS_IP_ADDR $service /g' > /etc/hosts"
	done

	$SSH -qt $ADM1_HOSTNAME "$MOUNTPOINT/bin/maintain_ldap.sh  -c '$CONFIG' -m $MOUNTPOINT"
	if [[ $? -ne 0 ]]
        then
                message "ERROR: Something went wrong running the maintain ldap command, see above for errors\n" ERROR
                exit 1
        fi
	
	MC_LOCK="/tmp/$PARENT_BASHPID/locks/mc.lock"
        get_lock $MC_LOCK local na 7200 yes
	wait_smtool_available_adm1
	for service in $EBAS_SERVICES
        do
		if [[ "$service" == "rpmoservice" ]]
		then
			the_mc="EBA_RPMO"
		elif [[ "$service" == "ebswservice" ]]
		then
			the_mc="EBA_EBSW"
		elif [[ "$service" == "ebssservice" ]]
                then
                        the_mc="EBA_EBSS"
		else
			the_mc=""
		fi

		if [[ "$the_mc" != "" ]]
		then
			message "INFO: Restarting the mc $the_mc\n" INFO
			local MC_STATUS=`$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/nms_cif_sm/bin/smtool list | grep $the_mc" 2>/dev/null`
			if [[ ! `echo "$MC_STATUS" | grep offline` ]]
			then
				$SSH -qt $ADM1_HOSTNAME "/opt/ericsson/nms_cif_sm/bin/smtool coldrestart $the_mc -reason=other -reasontext=ebas;/opt/ericsson/nms_cif_sm/bin/smtool prog;/opt/ericsson/nms_cif_sm/bin/smtool prog" 2>/dev/null
			else
				message "INFO: Not coldrestarting $the_mc as its offline\n" INFO
			fi
		else
			message "ERROR: I don't know what the relevant mc is for the service $service\n" ERROR
		fi
        done
	clear_lock $MC_LOCK local na
}

function post_steps_mws ()
{
	
	setup_ntp_client_mws

	mount_scripts_directory $MWS_HOSTNAME
	
}


function exec_configuration_script()
{
	local SCRIPT=$1
	local REDIRECT=$2
	local i=0
	local TIMEOUT=30
	while [ $i -lt 4 ]; do
		$SSH -qt $OMSAS_HOSTNAME "$MOUNTPOINT/$SCRIPT  -c '$CONFIG' -m $MOUNTPOINT" $REDIRECT
		local EXIT_CODE=$?
		if [ $EXIT_CODE -ne 0 ]; then
			i=$[$i+1]
			if [ $i -ge 4 ]; then
				retry_message "ERROR: There seems to have been an issue with the configuration of $SCRIPT\n" ERROR
				retry_message "-------------------------------------------------------------------------\n" ERROR
				retry_message "ERROR: There are no more retries available. Please investigate the issue\n" ERROR
				retry_message "ERROR: and retry the installation\n" ERROR
				retry_message "-------------------------------------------------------------------------\n" ERROR
				EXIT_CODE=1
				break
			fi
			retry_message "ERROR: There seems to have been an issue with the configuration of $SCRIPT\n" ERROR
			retry_message "-------------------------------------------------------------------------\n" WARNING
			retry_message "WARNING: Reattempting the configuration for $SCRIPT, try $i of 3\n" WARNING
			retry_message "-------------------------------------------------------------------------\n" WARNING
			sleep $TIMEOUT
		else
			break
		fi
	done
	return $EXIT_CODE
}

trap "cleanup INT" INT
trap "cleanup EXIT" EXIT
trap "cleanup TERM" TERM
trap "cleanup INT" KILL
trap "cleanup HUP" HUP

while getopts "c:f:g:v:o:e:l:" arg
do
    case $arg in
	c) CONFIG="$OPTARG"
	;;
	f) FUNCTION="$OPTARG"
	;;
	g) GATEWAY="$OPTARG"
	;;
	o) ON_THE_GATEWAY="$OPTARG"
	;;
	e) EMAIL_ADDRESSES="$OPTARG"
	;;
	l) LOG_DIRECTORY="$OPTARG"
	;;
	\?) usage_msg
	exit 1
	;;
    esac
done

check_args

message "INFO: Running script on host $HOSTNAME\n" SCRIPT
## Figure out the ip address of the server running the function
HOST_OUTPUT=`hostname`
RUNNING_HOSTS="`ifconfig -a | grep "inet addr" | grep -v "127.0.0.1" | awk '{print $2}' | awk -F: '{print $2}'`"
if [[ ! `echo "$RUNNING_HOSTS" | grep "\."` ]]
then
        message "ERROR: Couldn't figure out the ip address of the server I'm running scripts from\n" ERROR
        exit 1
fi

FIRST_RUNNING_HOST="`echo \"$RUNNING_HOSTS\" | head -1`"
#message "INFO: Running host IP is $RUNNING_HOST\n" SCRIPT

# Setup timing variables
STARTED_FORMATTED_DATE="`date | awk '{print $2 "_" $3 "_" $NF}'`"
STARTED_TIME="`date | awk '{print $4}'`"
STARTED_SECONDS=$(perl -e 'print int(time)')
STARTED_FORMATTED_TIME="`echo "$STARTED_TIME" | sed 's/:/_/g'`"


if [[ "$BEHIND_GATEWAY" == "yes" ]] && [[ ! -z $GATEWAY ]]
then
	if [[ ! -z $GATEWAY ]]
	then
		if [[ "$ON_THE_GATEWAY" != "yes" ]]
		then
			#share_local_filesystem
			mount_scripts_directory $GATEWAY
			message "INFO: Running the script from the gateway $GATEWAY now\n" SCRIPT
			$SSH -qt $GATEWAY "$MOUNTPOINT/bin/$MASTER_SCRIPT $@ -o yes"
			exit $?
		else
			message "INFO: Retrieving spp hostname to use: " INFO
			GATEWAY_SHORT_NAME=`hostname`
			VCLOUD_PHP_HOSTNAME=`curl -s --insecure "${CIPORTAL_URL}/getSpp/?gateway=${GATEWAY_SHORT_NAME}" 2>&1`
			if [[ `echo "$VCLOUD_PHP_HOSTNAME" | grep "does not exist"` ]] || [[ "$VCLOUD_PHP_HOSTNAME" == "" ]]
			then
				message "ERROR: Couldn't retrieve the spp hostname belonging to this vApp, see output below for output from curl to the CI Portal\n" ERROR
				message "ERROR: $VCLOUD_PHP_HOSTNAME\n" ERROR
				exit 1
			else
				message "$VCLOUD_PHP_HOSTNAME\n" INFO
			fi
			VCLOUD_PHP_HOSTNAME=`echo "$VCLOUD_PHP_HOSTNAME" | sed 's/https\?:\/\///' | sed 's/\///'`
			VCLOUD_PHP_FUNCTION="$MOUNTPOINT/bin/vCloudFunctions_php.sh --username=script --vcloudphphostname=$VCLOUD_PHP_HOSTNAME"

			message "INFO: Retrieving vm names from vcd: " INFO
			VCD_API_OUTPUT=`$VCLOUD_PHP_FUNCTION -f list_vms_in_vapp_rest 2>&1`
			if [[ $? -ne 0 ]] || [[ ! `echo "$VCD_API_OUTPUT" | grep gateway` ]]
			then
				message "$VCD_API_OUTPUT\n" ERROR
				message "ERROR: Something went wrong getting vm names from vcd\n" ERROR
				exit 1
			fi
			message "OK\n" INFO
			message "INFO: This environment is a vApp environment so only running commands towards existing servers, vm list below\n" INFO
			echo_line
			VCD_API_OUTPUT=`echo "$VCD_API_OUTPUT" | awk -F\; '{print $2}'`
			message "$VCD_API_OUTPUT\n" INFO
			echo_line

			# Figure out what vcenter the vms are on
			VCEN_HOSTNAME_FULL=`$VCLOUD_PHP_FUNCTION -f get_vcenter_of_vm_rest --vmname="gateway" 2>&1`
			if [[ $? -ne 0 ]]
			then
				message "$VCEN_HOSTNAME_FULL\n" ERROR
				message "ERROR: Something went wrong getting vcenter the vms are on\n" ERROR
			exit 1
			fi
			VCEN_HOSTNAME=`echo "$VCEN_HOSTNAME_FULL" | awk '{print $2}'`
			#############################################

			if [[ "$ADM1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$ADM1_HOSTNAME"` ]]
			then
				negate_server adm1
			fi
			if [[ "$OSS2_ADM1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$OSS2_ADM1_HOSTNAME"` ]]
			then
				negate_server oss2_adm1
			fi
			if [[ "$ADM2_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$ADM2_HOSTNAME"` ]]
			then
				negate_server adm2
			fi
			if [[ "$UAS1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$UAS1_HOSTNAME"` ]]
			then
				negate_server uas1
			fi
			if [[ "$PEER1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$PEER1_HOSTNAME"` ]]
			then
				negate_server peer1
			fi
			if [[ "$OMSERVM_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$OMSERVM_HOSTNAME"` ]]
			then
				negate_server omservm
			fi
			if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$OMSERVS_HOSTNAME"` ]]
			then
				negate_server omservs
			fi
			if [[ "$OMSAS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$OMSAS_HOSTNAME"` ]]
			then
				negate_server omsas
			fi
			if [[ "$EBAS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$EBAS_HOSTNAME"` ]]
			then
				negate_server ebas
			fi
			if [[ "$MWS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$MWS_HOSTNAME"` ]]
			then
				negate_server mws
			fi
			if [[ "$NEDSS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$NEDSS_HOSTNAME"` ]]
			then
				negate_server nedss
			fi
			if [[ "$NETSIM_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$NETSIM_HOSTNAME"` ]]
			then
				negate_server netsim
			fi
			if [[ "$ENIQE_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$ENIQE_HOSTNAME"` ]]
			then
				negate_server eniqe
			fi
			if [[ "$CEP_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$CEP_HOSTNAME"` ]]
			then
				negate_server cep
			fi
			if [[ "$ENIQS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$ENIQS_HOSTNAME"` ]]
			then
				negate_server eniqs
			fi
			if [[ "$SON_VIS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$SON_VIS_HOSTNAME"` ]]
			then
				negate_server son_vis
			fi
			if [[ "$SFS_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$SFS_HOSTNAME"` ]]
			then
				negate_server sfs
			fi
			if [[ "$MS1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$MS1_HOSTNAME"` ]]
			then
				negate_server ms1
			fi
			if [[ "$SC1_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$SC1_HOSTNAME"` ]]
			then
				negate_server sc1
			fi
			if [[ "$SC2_HOSTNAME" != "" ]] && [[ ! `echo "$VCD_API_OUTPUT" | grep "$SC2_HOSTNAME"` ]]
			then
				negate_server sc2
			fi

			# read the configs again
			. $MOUNTPOINT/bin/load_config
			echo_line

			# Force certain values for when behind gateways
			# Set vsps to gateway
			ADM1_VSP_SERVER=$GATEWAY
                        OSS2_ADM1_VSP_SERVER=$GATEWAY
			ADM2_VSP_SERVER=$GATEWAY
			OMSERVM_VSP_SERVER=$GATEWAY
			OMSERVS_VSP_SERVER=$GATEWAY
			OMSAS_VSP_SERVER=$GATEWAY
			NEDSS_VSP_SERVER=$GATEWAY
			UAS1_VSP_SERVER=$GATEWAY
			PEER1_VSP_SERVER=$GATEWAY
			EBAS_VSP_SERVER=$GATEWAY
			MWS_VSP_SERVER=$GATEWAY
			SFS_VSP_SERVER=$GATEWAY
			NETSIM_VSP_SERVER=$GATEWAY
			ENIQE_VSP_SERVER=$GATEWAY
			CEP_VSP_SERVER=$GATEWAY
			ENIQS_VSP_SERVER=$GATEWAY
			SON_VIS_VSP_SERVER=$GATEWAY
			MS1_VSP_SERVER=$GATEWAY
			SC1_VSP_SERVER=$GATEWAY
			SC2_VSP_SERVER=$GATEWAY
		fi
	else
		message "ERROR: This configuration requires a gateway, but one wasn't specified using -g <GATEWAY>\n" ERROR
		exit 1
	fi
else
	VCEN_HOSTNAME="atvcen1.athtem.eei.ericsson.se"
	#share_local_filesystem
fi

############################################################################
# Setting up logging

if [[ "$BEHIND_GATEWAY" == "yes" ]] && [[ "$GATEWAY" != "" ]]
then
	IDENTIFIER="${GATEWAY}_"
elif [[ "$ADM1_HOSTNAME" != "" ]]
then
	IDENTIFIER="${ADM1_HOSTNAME}_"
else
	IDENTIFIER=""
fi

FULL_LOG_DIR=$LOG_DIRECTORY/${STARTED_FORMATTED_DATE}_${STARTED_FORMATTED_TIME}_${IDENTIFIER}${FUNCTION}
SCRIPT_LOGFILE=$FULL_LOG_DIR/full_output.log
RUNNING_STATUS_FILE=$FULL_LOG_DIR/.running
COMPLETED_STATUS_FILE=$FULL_LOG_DIR/.completed

INDIVIDUAL_LOG_DIR=$FULL_LOG_DIR/logs

RUNNING_LOG_DIR=$INDIVIDUAL_LOG_DIR/running
FAILED_LOG_DIR=$INDIVIDUAL_LOG_DIR/failed
COMPLETED_LOG_DIR=$INDIVIDUAL_LOG_DIR/completed
UNCOMPLETED_LOG_DIR=$INDIVIDUAL_LOG_DIR/uncompleted
RETRY_LOG_DIR=$INDIVIDUAL_LOG_DIR/retry

mkdir -p $RUNNING_LOG_DIR > /dev/null 2>&1
mkdir -p $FAILED_LOG_DIR > /dev/null 2>&1
mkdir -p $COMPLETED_LOG_DIR > /dev/null 2>&1
mkdir -p $RETRY_LOG_DIR > /dev/null 2>&1

message "INFO: Logging output to $SCRIPT_LOGFILE on `hostname`\n" SCRIPT
npipe=/tmp/$PARENT_BASHPID.tmp
mknod $npipe p
tee -a <$npipe $SCRIPT_LOGFILE &
exec 1>&- 2>&-
exec 1>$npipe 2>$npipe
disown %-

# Status running
touch $RUNNING_STATUS_FILE
echo -n "`hostname` $PARENT_BASHPID" > $RUNNING_STATUS_FILE
############################################################################

# Start the function
COMMAND_RUN="$0 $@"
COMMAND_RUN=`echo "$COMMAND_RUN" | sed 's/ -o yes//g'`
message "INFO: Command Run was $COMMAND_RUN\n" SCRIPT

# Make temp directories
rm -rf /tmp/$PARENT_BASHPID/ > /dev/null 2>&1
mkdir -p /tmp/$PARENT_BASHPID/status
mkdir -p /tmp/$PARENT_BASHPID/logs
mkdir -p /tmp/$PARENT_BASHPID/locks
message "INFO: Starting function $FUNCTION\n" SCRIPT
$FUNCTION
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]
then
	message "INFO: Completed function $FUNCTION, with exit code $EXIT_CODE\n" SCRIPT
	exit $EXIT_CODE
else
	message "INFO: Completed function $FUNCTION\n" SCRIPT
fi
