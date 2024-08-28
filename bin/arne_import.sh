#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$OPTIONAL" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$TRACING" ]]
        then
                echo "ERROR: You must say if you want tracing or not"
                exit 1
        fi
	
	if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
		. $MOUNTPOINT/bin/load_config
        fi

}

while getopts "m:c:o:t:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	o) OPTIONAL="$OPTARG"
	;;
	t) TRACING="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

IMPORT="/opt/ericsson/arne/bin/import.sh"
ARNE_REPORT="/tmp/arne_report"
if [[ -f "$ARNE_REPORT" ]]
then
	echo "WARNING: file "$ARNE_REPORT" already exists on server. The following was the contents"
        cat $ARNE_REPORT | while read line
	do
        	echo "WARNING: $line"
	done
	rm "$ARNE_REPORT"
fi

ls /cloud_network_xmls/*_create.xml | while read xml
do
	ATTEMPT=0
	while true
	do
		ATTEMPT=$(($ATTEMPT + 1))
		if [[ "$TRACING" == "yes" ]]
		then

			#Setup Tracing on OSS
			echo "INFO: Stopping any existing Tracing"
			/opt/ericsson/nms_cif_sm/bin/smtool trace stop


			date=`date`
			formated_date=`echo $date  | awk '{print $2 "_" $3 "_" $NF}'`
		
			echo "INFO: Setting up tracing"
			echo "INFO: Increasing max trace log file to 600mb"
			/opt/ericsson/nms_cif_sm/bin/smtool -set SelfManagement TraceFileLength 600000000
		
			/opt/ericsson/nms_cif_sm/bin/smtool -trace ARNEServer 0-199 arne_trace_tep.${formated_date}
			/opt/ericsson/nms_cif_sm/bin/smtool -trace MAF 0-199 arne_trace_tep.${formated_date}
			#/opt/ericsson/nms_cif_sm/bin/smtool -trace ONRM_CS 8 arne_trace_tep.${formated_date}
			echo "INFO: Tracing log file /var/opt/ericsson/log/trace/arne_trace_tep.${formated_date}"
		
			echo "INFO: Verifying that trace is turned on"
			echo "INFO: Trace Current status "
			/opt/ericsson/nms_cif_sm/bin/smtool trace


		fi


		echo "INFO: Running command $IMPORT -$OPTIONAL -f $xml -i_nau"
		OUTPUT="`$IMPORT -$OPTIONAL -f $xml -i_nau 2>&1`"
		echo "$OUTPUT"


		if [[ "$TRACING" == "yes" ]]
		then
			echo "INFO: Stopping any existing Tracing"
			/opt/ericsson/nms_cif_sm/bin/smtool trace stop

			date=`date`
	                formatted_date=`echo $date  | awk '{print  $2 "_" $3 "_" $NF "_" $4}'`

	                echo "INFO: Backing up the trace file if it exists"

	                trace_file="`/opt/ericsson/nms_cif_sm/bin/smtool -trace | grep -i traceFileName | awk '{print $2}'`"
	                trace_file_full="/var/opt/ericsson/log/trace/$trace_file"
	                trace_file_backup="/var/opt/ericsson/log/trace/$trace_file.backup_$formatted_date"

	                if [[ -f $trace_file_full ]]
	                then
	                        echo "INFO: Backing up trace file $trace_file_full as $trace_file_backup"
	                        cp $trace_file_full $trace_file_backup
	                        echo "INFO: Trace file backed up to $trace_file_backup"
	                else
	                        echo "INFO: No arne trace file exists so nothing to backup"
	                fi

			echo "INFO: Reverting max trace log file to 50mb"
			/opt/ericsson/nms_cif_sm/bin/smtool -set SelfManagement TraceFileLength 50000000
		fi

		if [[ `echo "$OUTPUT" | grep "Configuration locked"` ]] && [[ $ATTEMPT -lt 10 ]]
		then
			echo "WARNING: Detected configuration locked error, sleeping for 60 seconds before retrying import"
			sleep 60
			continue
		fi

		if [[ ! `echo "$OUTPUT" | egrep "There were 0 errors reported during validation|No Errors Reported"` ]]
		then
			echo "ERROR: Script Error ARNE importing $xml. Continuing to import."
			echo "$xml had an import problem" >> $ARNE_REPORT
		fi
		break
	done
done
if [[ -f "$ARNE_REPORT" ]]
then 
	echo "ERROR: ARNE Import failures"
        cat $ARNE_REPORT | while read line
        do
                echo "ERROR: $line"
        done
        rm "$ARNE_REPORT"
	exit 1
fi	
