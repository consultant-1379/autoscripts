#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -t MC_LIST_TYPE -f FIX yes/no"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi

        if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
		. $MOUNTPOINT/bin/load_config
        fi

	if [[ -z "$MC_LIST_TYPE" ]]
	then
		echo "ERROR: you must give an mc list type to this script using -t"
		exit 1
	fi
}

while getopts "c:m:t:f:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	t) MC_LIST_TYPE="$OPTARG"
	;;
	f) FIX="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

function work_on_mcs
{
if [[ -f /etc/opt/ericsson/nms_cif_smssr/mc_start_list ]]
then
	echo "INFO: Removing the mc_start_list file /etc/opt/ericsson/nms_cif_smssr/mc_start_list"
	rm /etc/opt/ericsson/nms_cif_smssr/mc_start_list
fi

rm  /tmp/mcoutput.$$ > /dev/null 2>&1
SMTOOL=/opt/ericsson/nms_cif_sm/bin/smtool
SMTOOL_TIMEOUT=60
SMTOOL_ATTEMPTS=10

# Check is OSS up by doing smtool prog and checking return code
echo -n "INFO: Checking smtool is working first..."

SMTOOL_WORKING=0
while [[ $SMTOOL_WORKING -ne 1 && $TRY_NO -lt $SMTOOL_ATTEMPTS ]]
do

        smout="`$SMTOOL list`"
        if [[ $? -ne 0 ]]
        then
                sleep $SMTOOL_TIMEOUT
                TRY_NO=$(( $TRY_NO+1 ))
        else
                SMTOOL_WORKING=1
        fi
done

if [[ "$SMTOOL_WORKING" -ne 1 ]]
then
        echo "ERROR: Smtool didn't respond after $SMTOOL_ATTEMPTS attempts with $SMTOOL_TIMEOUT between each attempt.."
        exit 1
else
	echo "OK"
fi

#echo "INFO: Cancelling any ongoing smtool activities..."
echo "INFO: Waiting for any existing smtool progress to finish..."
#smout="`$SMTOOL prog`"
#$SMTOOL prog
#$SMTOOL -cancel
$SMTOOL prog
$SMTOOL prog
echo "OK"

echo -n "INFO: Getting the start order of the mc's..."
SMTOOL_START_ORDER_UNEDITED="`$SMTOOL config start`"
SMTOOL_START_ORDER="`echo \"$SMTOOL_START_ORDER_UNEDITED\" | egrep -v '\.' | awk '{print $1}' | grep -v startOrder`"
echo "OK"

if [[ "$MC_LIST_TYPE" == "CRITICAL_5" ]]
then
	MC_LIST="`echo \"$SMTOOL_START_ORDER_UNEDITED\" | egrep -v '\.' | awk '{ if ( $2 < 6 ) printf "%s\n", $1}' | grep -v startOrder`"
	MC_LIST="$MC_LIST
ONRM_CS
ARNEServer
Region_CS
Seg_masterservice_CS
MAF"

elif [[ "$MC_LIST_TYPE" == "CONFIG" ]]
then
	MC_LIST="$MC_ONLINE_LIST"
	if [[ "$MC_LIST" == "all" ]]
	then
		MC_LIST="`$SMTOOL list | awk '{print $1}'`"
	fi
elif [[ "$MC_LIST_TYPE" == "ALL" ]]
then
	MC_LIST="`$SMTOOL list | awk '{print $1}'`"
elif [[ "$MC_LIST_TYPE" == "INITIAL" ]]
then
        MC_LIST="`$SMTOOL list | awk '{print $1}' | grep -v "BI_SMRS_MC" | grep -v "netop_ems"`"
fi

# Take spaces out of the mc list
MC_LIST="`echo \"$MC_LIST\" | sed 's/ //g'`"

# Set phases
if [[ "$FIX" == "no" ]]
then
	PHASES="analysis"
else
	PHASES="offline online analysis"
	echo -n "INFO: Getting the stop order of the mc's..."
	SMTOOL_STOP_ORDER="`$SMTOOL config stop | egrep -v '\.' | awk '{print $1}' | grep -v stopOrder`"
	echo "OK"
fi
# Now offline, online and analyse the mcs

touch /tmp/mcoutput.$$

TYPICAL_REASONS='-reason=other -reasontext=Cloud'

for phase in $PHASES
do
        echo "INFO: In phase $phase"
	SMTOOL_OUTPUT="`$SMTOOL list`"
	if [[ "$phase" == "offline" ]]
	then
		SMTOOL_ORDER="$SMTOOL_STOP_ORDER"
	else
		SMTOOL_ORDER="$SMTOOL_START_ORDER"
	fi

	ACTION_ONLINE=""
	ACTION_OFFLINE=""
	ACTION_COLDRESTART=""

	for MC_NAME in $SMTOOL_ORDER
	do
		ACTION=""
	        #MC_NAME=`echo "$SMTOOL_OUTPUT" | grep "^$line" | awk '{print $1}'`
	        MC_STATUS=`echo "$SMTOOL_OUTPUT" | grep "^$MC_NAME " | awk '{print $2}'`
	
	        #echo "Working on $MC_NAME..which is in state $MC_STATUS..."
		SHOULD_BE_ONLINE=`echo "$MC_LIST" | grep "^$MC_NAME$"`
	
	        if [[ "$SHOULD_BE_ONLINE" != "" ]]
	        then
	                #echo "It should be online.."
	                if [[ "$phase" == "online" ]] || [[ "$phase" == "analysis" ]]
	                then
	                        if [[ "$MC_STATUS" == "started" ]]
	                        then
	                                ACTION=""
	                        elif [[ "$MC_STATUS" == "offline" ]] || [[ "$MC_STATUS" == "unlicensed" ]] || [[ "$MC_STATUS" == "stopped" ]]
	                        then
					ACTION="online"
        	                else
					ACTION="coldrestart"
	                        fi
	                fi
	        else
	                #echo "It should be offline.."
	                if [[ "$phase" == "offline" ]] || [[ "$phase" == "analysis" ]]
	                then
	                        if [[ "$MC_STATUS" != "offline" ]]
	                        then
					ACTION="offline"
	                        fi
	                fi
	        fi

	        if [[ "$ACTION" != "" ]]
	        then
	                if [[ "$phase" == "analysis" ]]
	                then
				echo "$MC_NAME $MC_STATUS" >> /tmp/mcoutput.$$
	                else
				if [[ "$ACTION" == "online" ]]
	                        then
					ACTION_ONLINE="$ACTION_ONLINE $MC_NAME"
	                        elif [[ "$ACTION" == "offline" ]]
	                        then
					ACTION_OFFLINE="$ACTION_OFFLINE $MC_NAME"
				elif [[ "$ACTION" == "coldrestart" ]]
				then
					ACTION_COLDRESTART="$ACTION_COLDRESTART $MC_NAME"
				fi
        	        fi
	        fi
	done

	# Now work on the mcs
	if [[ "$phase" == "offline" ]]
        then
                if [[ "$ACTION_OFFLINE" != "" ]]
                then
                        $SMTOOL offline $ACTION_OFFLINE $TYPICAL_REASONS
			$SMTOOL prog
			$SMTOOL prog
                fi
	elif [[ "$phase" == "online" ]]
	then
		if [[ "$ACTION_ONLINE" != "" ]]
                then
                        $SMTOOL online $ACTION_ONLINE
			$SMTOOL prog
			$SMTOOL prog
                fi
		if [[ "$ACTION_COLDRESTART" != "" ]]
                then
                        $SMTOOL coldrestart $ACTION_COLDRESTART $TYPICAL_REASONS
			$SMTOOL prog
			$SMTOOL prog
                fi
	# Print out the anlysis when completed
	elif [[ "$phase" == "analysis" ]]
	then
		output="`cat /tmp/mcoutput.$$`"
	        if [[ "$output" != "" ]]
	        then
	                PROBLEM_COUNT=`echo "$output" | wc -l | awk '{print $1}'`
	                echo "INFO: $PROBLEM_COUNT problem mcs, see list below"
			echo "------------------------------------------------"
	                echo "$output"
			echo "------------------------------------------------"
			exit 1
	        else
			exit 0
	        fi
		rm /tmp/mcoutput.$$
	fi

done
}
work_on_mcs
