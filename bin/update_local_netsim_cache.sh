#!/bin/bash
NETSIM_SITE="http://netsim.lmera.ericsson.se/tssweb/"
LOCAL_PATH=/export/scripts/CLOUD/files/netsim/versions/
LICENCES_PATH=/export/scripts/CLOUD/files/netsim/licences/
NETSIM_MAJORS=`wget -O - -q $NETSIM_SITE | grep ">netsim" | awk -F\> '{print $7}' | awk -F/ '{print $1}' | grep netsim | tail -2`
output=$(for MAJOR in $NETSIM_MAJORS
do
	#echo "Checking $MAJOR"
	NETSIM_MINORS=`wget -O - -q $NETSIM_SITE/$MAJOR/released/ | grep "NETSim_UMTS" | awk -F\> '{print $3}' | awk -F\< '{print $1}'`
	for MINOR in $NETSIM_MINORS
	do
		MINOR_LINK="$NETSIM_SITE/$MAJOR/released/NETSim_UMTS.$MINOR/"
		
		ZIP_FILE_NAME=`wget -O - -q $MINOR_LINK | grep zip | awk -F\> '{print $3}' | awk -F\< '{print $1}'`
		echo "$MINOR $ZIP_FILE_NAME $MINOR_LINK/$ZIP_FILE_NAME $MINOR_LINK/Unbundle.sh $MAJOR"
	done
done)
NETSIM_LIST=`echo "$output" | sort -r | head -6`

if [[ ! `echo "$NETSIM_LIST" | grep "^R"` ]]
then
	echo "ERROR: This doesn't look like a valid netsim version, did something go wrong downloading details from the netsim webpage"
	echo "$NETSIM_LIST"
	exit 1
fi

echo "$NETSIM_LIST" | while read line
do
	VERSION=`echo "$line" | awk '{print $1}'`
	ZIP_FILE_NAME=`echo "$line" | awk '{print $2}'`
	REMOTE_ZIP_FILE=`echo "$line" | awk '{print $3}'`
	REMOTE_SHELL_FILE=`echo "$line" | awk '{print $4}'`
	MAJOR=`echo "$line" | awk '{print $5}'`

	if [[ ! -f $LOCAL_PATH/$VERSION/installer/$ZIP_FILE_NAME ]]
	then
		echo "Downloading new netsim version $VERSION"
		mkdir -p $LOCAL_PATH/$VERSION/installer/
		mkdir -p $LOCAL_PATH/$VERSION/license/
		rm -rf $LOCAL_PATH/$VERSION/installer/*
		rm -rf $LOCAL_PATH/$VERSION/license/*
		cd $LOCAL_PATH/$VERSION/installer/
		wget -q $REMOTE_ZIP_FILE
		wget -q $REMOTE_SHELL_FILE
		chmod +x Unbundle.sh
		# Copy in the license
		if [[ `ls $LICENCES_PATH/$MAJOR/*.zip` ]]
		then
			cp $LICENCES_PATH/$MAJOR/*.zip $LOCAL_PATH/$VERSION/license/
		else
			echo "ERROR: Couldn't find a licence in $LICENCES_PATH/$MAJOR/, put on there manually"
		fi
	else
		echo "$VERSION already exists"
	fi
done

# Remove old versions
NETSIM_VERSIONS=`echo "$NETSIM_LIST" | awk '{print $1}'`

ls $LOCAL_PATH | while read version
do
	if [[ ! `echo "$NETSIM_VERSIONS" | grep "^$version$"` ]]
	then
		echo "This version of netsim is old, deleting $version's installer directory"
		rm -rf $LOCAL_PATH/$version/installer/
	fi
done
