#!/bin/bash

function usage_msg ()
{
	echo "Usage: $0 -i <ericsson id> -s <Source MWS> -d <Destination MWS> -r <OSSRC Media Path on Source MWS> -c <COMInf Media Path on Source MWS> -o <OMSAS Media Path on Source MWS> -f <Local File to output media list to, ie the media.txt> -l <Version label used in self provisioning tools>"
	exit 1
}
function check_args ()
{
	if [[ -z "$OUTPUT_FILE" ]]
        then
                echo "ERROR: You must specify an output file using -f <Local File to output media list to, ie the media.txt>"
                usage_msg
        fi
	if [[ -f $OUTPUT_FILE ]]
	then
		echo "ERROR: This output file $OUTPUT_FILE already exists, please rename / delete the old one if you need to update it"
		exit 1
	fi
	if [[ -z $VERSION_LABEL ]]
        then
                echo "ERROR: You must specify a version label using -l <label> for use in self provisioning tools, eg 13.0.5.l2"
                exit 1
        fi
	if [[ `echo "$VERSION_LABEL" | grep "_"` ]]
	then
		echo "ERROR: The version label must not contain any underscores"
	fi

	if [[ -z "$USERNAME" ]]
	then
		echo "ERROR: You must specify a username using -i <ericsson id>"
		usage_msg
	fi
	if [[ -z "$SOURCE" ]]
        then
                echo "ERROR: You must specify a Source MWS using -s <Source MWS>"
                usage_msg
        fi
	if [[ -z "$DESTINATION" ]]
        then
                echo "ERROR: You must specify a Destination MWS using -d <Destination MWS>"
                usage_msg
        fi
	if [[ -z "$OSSRC_PATH" ]]
        then
                echo "ERROR: You must specify an OSSRC Path using -o <OSSRC Media Path on Source MWS>"
                usage_msg
        fi
	if [[ -z "$COMINF_PATH" ]]
        then
                echo "ERROR: You must specify a COMINF Path using -c <COMInf Media Path on Source MWS>"
                usage_msg
        fi
	if [[ -z "$OMSAS_PATH" ]]
        then
                echo "ERROR: You must specify an OMSAS Path using -o <OMSAS Media Path on Source MWS>"
                usage_msg
        fi
}
while getopts "i:s:d:f:l:r:c:o:" arg
do
    case $arg in
        i) USERNAME="$OPTARG"
        ;;
        s) SOURCE="$OPTARG"
        ;;
        d) DESTINATION="$OPTARG"
        ;;
        f) OUTPUT_FILE="$OPTARG"
        ;;
	l) VERSION_LABEL="$OPTARG"
	;;
        r) OSSRC_PATH="$OPTARG"
        ;;
        c) COMINF_PATH="$OPTARG"
        ;;
        o) OMSAS_PATH="$OPTARG"
        ;;
        \?) usage_msg
        ;;
    esac
done

check_args

ssh $DESTINATION "mkdir -p /export/scripts/" > /dev/null 2>&1
ssh $DESTINATION "mount -o vers=3 atmgtvm3.athtem.eei.ericsson.se:/export/scripts/ /export/scripts/" > /dev/null 2>&1

ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $OSSRC_PATH -t ossrc -m dir -s $SOURCE
ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $OMSAS_PATH -t OMSAS -m dir -s $SOURCE
ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $COMINF_PATH -t COMINF -m dir -s $SOURCE

echo "INFO: Please wait while the software paths on the destination MWS are found..."

OUTPUT="`ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $OSSRC_PATH -t ossrc -m dir -s $SOURCE 2>&1`"
MEDIA_LOCATION_i386_SOL_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_i386_SOL_MEDIA | awk '{print $2}' | head -1`
MEDIA_LOCATION_SPARC_SOL_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_SPARC_SOL_MEDIA | awk '{print $2}' | head -1`
MEDIA_LOCATION_SPARC_OSSRC_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_SPARC_OSSRC_MEDIA | awk '{print $2}' | head -1`
MEDIA_LOCATION_i386_OSSRC_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_i386_OSSRC_MEDIA | awk '{print $2}' | head -1`
MEDIA_LOCATION_OM_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_OM_MEDIA | awk '{print $2}' | head -1`

OUTPUT="`ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $OMSAS_PATH -t OMSAS -m dir -s $SOURCE 2>&1`"
MEDIA_LOCATION_OMSAS_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_OMSAS_MEDIA | awk '{print $2}' | head -1`

OUTPUT="`ssh $DESTINATION /export/scripts/CLOUD/bin/manage_mws_sw_sync.sh -i $USERNAME -l $COMINF_PATH -t COMINF -m dir -s $SOURCE 2>&1`"
MEDIA_LOCATION_COMINF_MEDIA=`echo "$OUTPUT" | grep MEDIA_LOCATION_COMINF_MEDIA | awk '{print $2}' | head -1`

if [[ "$MEDIA_LOCATION_i386_SOL_MEDIA" == "" ]]
then
	echo "ERROR: Couldn't get the i386 solaris media location, check script output above"
	exit 1
fi

if [[ "$MEDIA_LOCATION_SPARC_SOL_MEDIA" == "" ]]
then
	echo "ERROR: Couldn't get the sparc solaris media location, check script output above"
        exit 1
fi

if [[ "$MEDIA_LOCATION_OM_MEDIA" == "" ]]
then
        echo "ERROR: Couldn't get the om media location, check script output above"
        exit 1
fi

if [[ "$MEDIA_LOCATION_SPARC_OSSRC_MEDIA" == "" ]]
then
	echo "ERROR: Couldn't get the ossrc media location, check script output above"
        exit 1
fi

if [[ "$MEDIA_LOCATION_i386_OSSRC_MEDIA" == "" ]]
then
        echo "ERROR: Couldn't get the ossrc media location, check script output above"
        exit 1
fi

if [[ "$MEDIA_LOCATION_COMINF_MEDIA" == "" ]]
then
	echo "ERROR: Couldn't get the cominf location, check script output above"
        exit 1
fi

if [[ "$MEDIA_LOCATION_OMSAS_MEDIA" == "" ]]
then
	echo "ERROR: Couldn't get the omsas media location, check script output above"
        exit 1
fi

#echo "$MEDIA_LOCATION_i386_SOL_MEDIA"
#echo "$MEDIA_LOCATION_SPARC_SOL_MEDIA"
#echo "$MEDIA_LOCATION_OM_MEDIA"
#echo "$MEDIA_LOCATION_SPARC_OSSRC_MEDIA"
#echo "$MEDIA_LOCATION_i386_OSSRC_MEDIA"
#echo "$MEDIA_LOCATION_COMINF_MEDIA"
#echo "$MEDIA_LOCATION_OMSAS_MEDIA"
OUTPUT_STRING="# This file was generated automatically by $USERNAME when caching media from $SOURCE to $DESTINATION on `date`
# Media synced using command below
# $0 $@
############################################################################################

VERSION_LABEL='$VERSION_LABEL'

ADM1_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
ADM1_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
ADM1_APPL_MEDIA_LOC='$MEDIA_LOCATION_i386_OSSRC_MEDIA'

ADM2_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
ADM2_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'

OMSERVM_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
OMSERVM_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
OMSERVM_APPL_MEDIA_LOC='$MEDIA_LOCATION_COMINF_MEDIA'

OMSERVS_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
OMSERVS_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
OMSERVS_APPL_MEDIA_LOC='$MEDIA_LOCATION_COMINF_MEDIA'

OMSAS_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
OMSAS_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
OMSAS_APPL_MEDIA_LOC='$MEDIA_LOCATION_COMINF_MEDIA'
OMSAS_MEDIA='$MEDIA_LOCATION_OMSAS_MEDIA'

NEDSS_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
NEDSS_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
NEDSS_APPL_MEDIA_LOC='$MEDIA_LOCATION_COMINF_MEDIA'

UAS1_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
UAS1_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'
UAS1_APPL_MEDIA_LOC='$MEDIA_LOCATION_COMINF_MEDIA'

EBAS_JUMP_LOC='$MEDIA_LOCATION_i386_SOL_MEDIA'
EBAS_OM_LOC='$MEDIA_LOCATION_OM_MEDIA'"

OUTPUT_DIR="`dirname $OUTPUT_FILE`"
if [[ ! -d $OUTPUT_DIR ]]
then
	mkdir -p $OUTPUT_DIR
fi

echo "$OUTPUT_STRING" > "$OUTPUT_FILE"

if [[ -f $OUTPUT_FILE ]]
then
	echo "INFO: Output the following to $OUTPUT_FILE successfully"
	cat $OUTPUT_FILE
	exit 0
else
	echo "ERROR: Couldn't seem to write output to the output file $OUTPUT_FILE"
	exit 1
fi
