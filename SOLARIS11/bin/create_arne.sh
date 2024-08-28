#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -n SIMNAME -s SIMNODES"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$SIMNAME" ]]
        then
                echo "ERROR: You must say what simname to match"
                exit 1
        fi
	if [[ -z "$SIMNODES" ]]
        then
                echo "ERROR: You must say what nodes to create the xml for"
                exit 1
        fi
	if [[ -z "$IPV6" ]]
        then
                echo "ERROR: You must say whether its ipv6 or not"
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

while getopts "c:m:s:n:i:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	s) SIMNODES="$OPTARG"
	;;
	n) SIMNAME="$OPTARG"
	;;
        i) IPV6="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

MML=".open $SIMNAME
.show simnes"
NODE_LIST_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi

NODE_LIST=`echo "$NODE_LIST_FULL" | grep -v "In Address" | grep -v "OK" | grep -v ">>" | awk '{print $1, $3, $6}'`

for entry in $SIMNODES
do
	let COUNTER=COUNTER+1
	SEARCH_NODE_TYPE=`echo $entry | awk -F, '{print $1}'`
	SPECIFIC_NODE_LIST_UNFILTERED="`echo \"$NODE_LIST\" | egrep \" $SEARCH_NODE_TYPE\"`"
	SEARCH_NODE_RANGE_START=`echo $entry | awk -F, '{print $2}'`
	SEARCH_NODE_RANGE_END=`echo $entry | awk -F, '{print $3}'`
	if [[ "$SEARCH_NODE_RANGE_END" == "end" ]]
	then
	        SEARCH_NODE_RANGE_END="`echo \"$SPECIFIC_NODE_LIST_UNFILTERED\" | wc -l`"
	fi
	SEARCH_NODE_SUBNETWORK=`echo $entry | awk -F, '{print $4}'`
	SEARCH_NODE_SIZE=$((SEARCH_NODE_RANGE_END-SEARCH_NODE_RANGE_START+1))
	SPECIFIC_NODE_LIST="`echo \"$SPECIFIC_NODE_LIST_UNFILTERED\" | head -$SEARCH_NODE_RANGE_END | tail -$SEARCH_NODE_SIZE`"
	# Filter by ipv4 / ipv6

	if [[ "$IPV6" == "yes" ]]
	then
		# Filter out ipv6 nodes only
		SPECIFIC_NODE_LIST="`echo \"$SPECIFIC_NODE_LIST\" | grep :`"
		XML_IP_TYPE="ipv6"
		SLAVE_SERVICE_NAME="${NEDSS_SLAVE_SERV_ID6}"
		AIF_POSTFIX="IP6"
	else
		# Filter out ipv4 nodes only
		SPECIFIC_NODE_LIST="`echo \"$SPECIFIC_NODE_LIST\" | grep -v :`"
		XML_IP_TYPE="ipv4"
		SLAVE_SERVICE_NAME="${NEDSS_SLAVE_SERV_ID4}"
		AIF_POSTFIX=""
	fi

	# If theres no xml to create here, move on
	if [[ "$SPECIFIC_NODE_LIST" == "" ]]
	then
		continue
	fi

	LINED_NODE_LIST=$(echo "$SPECIFIC_NODE_LIST" | awk '{print $1}' | while read line
	do
		echo -n "$line|"
	done)

	if [[ "$SEARCH_NODE_SUBNETWORK" != "" ]]
	then
		SUBNETWORK_LIST="$LINED_NODE_LIST"
		XML_FILENAME="${COUNTER}_${SIMNAME}_${SEARCH_NODE_TYPE}_${SEARCH_NODE_RANGE_START}_${SEARCH_NODE_RANGE_END}_${SEARCH_NODE_SUBNETWORK}_${XML_IP_TYPE}"
	else
		SUBNETWORK_LIST=""
		XML_FILENAME="${COUNTER}_${SIMNAME}_${SEARCH_NODE_TYPE}_${SEARCH_NODE_RANGE_START}_${SEARCH_NODE_RANGE_END}_NoSubNet_${XML_IP_TYPE}"
	fi

	# Populate the dat text file with the relevant details
	ARNEVERSION="R12.2"
	DATFILE=/netsim/inst/dat/ftp${ARNEVERSION}.txt

	FTP_TYPE="no_value"
	## Figure out what type of nodes we are dealing with for ftp services
	node_type=`echo "$SPECIFIC_NODE_LIST" | head -1 | awk '{print $2}'`
	if [[ "$node_type" == "RNC" ]] || [[ "$node_type" == "RBS" ]] || [[ "$node_type" == "RXI" ]]
	then
		XML_NODE_TYPE="wran"
	elif [[ "$node_type" == "ERBS" ]]
	then
		XML_NODE_TYPE="lran"
	elif [[ "$node_type" == "STN" ]]
	then
		XML_NODE_TYPE="gran"
		FTP_TYPE="ftp"
	else
		echo "ERROR: This is an unknown node type, '$node_type' so I can't accurately create xmls for it"
		echo "ERROR: Please update this script to handle this node type"
		exit 1
	fi


	if [[ "$NEDSS_SMRS_OSS_ID" == "" ]] || [[ "$NEDSS_HOSTNAME" == "" ]]
	then
		echo "INFO: No smrs slave / nedss configuration details found, skipping manipulation of $DATFILE"
	else
		if [[ "$IPV6" == "yes" ]]
		then
			SLAVE_SERVICE_NAME="${NEDSS_SLAVE_SERV_ID6}"
			AIF_POSTFIX="IP6"
		else
			SLAVE_SERVICE_NAME="${NEDSS_SLAVE_SERV_ID4}"
			AIF_POSTFIX=""
		fi

		if [[ "$XML_NODE_TYPE" == "wran" ]]
                then
                        SMRS_SLAVE_PREFIX="SMRSSLAVE-WRAN"
                        AIF_NAME="aifwran${AIF_POSTFIX}"
                elif [[ "$XML_NODE_TYPE" == "lte" ]]
                then
                        SMRS_SLAVE_PREFIX="SMRSSLAVE-LRAN"
                        AIF_NAME="aiflran${AIF_POSTFIX}"
                else
                        SMRS_SLAVE_PREFIX="SMRSSLAVE"
                        AIF_NAME="aifgran${AIF_POSTFIX}"
                fi

		# Set the variable names used later
                SLAVE_SERVER_NAME="${SMRS_SLAVE_PREFIX}-${SLAVE_SERVICE_NAME}"

		# Backup the dat file if the backup isn't already there
		if [[ ! -f ${DATFILE}.backup ]]
		then
			cp ${DATFILE} ${DATFILE}.backup
		fi
		# Copy in the backup file
		cp ${DATFILE}.backup ${DATFILE}
	
		# Replace the server name
		sed "s/server SMRSSLAVE-kloker/server $SLAVE_SERVER_NAME/g" $DATFILE > ${DATFILE}.tmp
		mv ${DATFILE}.tmp $DATFILE
		
		# Remove the aistore entry, and don't add the special case for autoIntegration names yet
		cat $DATFILE | grep -v autoIntegration > ${DATFILE}.tmp
		#echo "service $AIF_NAME autoIntegration 0.0.0.0 ON $AIF_NAME toker" >> ${DATFILE}.tmp
		mv ${DATFILE}.tmp ${DATFILE}
	
		# Replace the service names
		#sed "s/\(service [^.]*\)-kloker/\1-${SLAVE_SERVICE_NAME}/g" $DATFILE > ${DATFILE}.tmp
		sed "s/kloker/${SLAVE_SERVICE_NAME}/g" $DATFILE > ${DATFILE}.tmp
	        mv ${DATFILE}.tmp $DATFILE
	fi

	# Create the xml
	MML=".open $SIMNAME
.select $LINED_NODE_LIST
.arneconfig site %nename
.arneconfig rootmo $IM_ROOT
.createarne $ARNEVERSION ${XML_FILENAME} NETSim %nename secret IP secure sites no_external_associations $FTP_TYPE $SEARCH_NODE_SUBNETWORK $SUBNETWORK_LIST"
	su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
	EXIT_CODE=$?
	cp ${DATFILE}.backup ${DATFILE}
	if [[ $EXIT_CODE -ne 0 ]]
	then
	        echo "ERROR: Something went wrong running the mml commands"
	        exit 1
	fi
done
