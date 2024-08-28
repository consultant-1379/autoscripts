#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -v VERSION -f yes/no -p FETCH_FROM_NEXUS -d NETSIMDROP"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$VERSION" ]]
        then
                echo "ERROR: You must say what version to install"
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

while getopts "c:m:v:f:p:d" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
        v) VERSION="$OPTARG"
        ;;
        f) FORCE="$OPTARG"
        ;;
        p) FETCH_FROM_NEXUS="$OPTARG"
        ;;
        d) NETSIMDROP="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
NETSIMDIRECTORY=/netsim/$VERSION/
PORTAL_NETSIM_LIST=/netsim/simdepContents/netsimList.txt
PORTAL_PATCH_LIST=/netsim/simdepContents/patchList.txt
NETSIM_STORAGE_PATH=$MOUNTPOINT/files/netsim/versions/
NETSIM_INSTALLER_PATH=$MOUNTPOINT/files/netsim/versions/$VERSION/installer
NETSIM_ZIP=1_19089-FAB760956Ux.$VERSION.zip
UNBUNDLE_FILE_LINK="http://eselivm2v214l.lmera.ericsson.se:8081/nexus/content/repositories/releases/com/ericsson/oss/common/Unbundle/1.0.1/Unbundle-1.0.1.sh"
# Removing versions other than this one

if [[ -d $NETSIMDIRECTORY ]] && [[ "$FORCE" != "yes" ]]
then
	echo "INFO: Netsim version $VERSION already installed"
	rm /netsim/inst > /dev/null 2>&1
	su - netsim -c "ln -s $NETSIMDIRECTORY /netsim/inst"
	$MOUNTPOINT/bin/start_netsim.sh -c $CONFIG -m $MOUNTPOINT
else
	$MOUNTPOINT/bin/stop_netsim.sh -c $CONFIG -m $MOUNTPOINT
	ls -1dr /netsim/R??? | grep -v $VERSION | while read otherversion
	do
		echo "INFO: Removing old version $otherversion"
		rm -rf $otherversion
	done
	if [[ -d $NETSIMDIRECTORY ]]
	then
		echo "INFO: Forcibly reinstalling into $NETSIMDIRECTORY"
		rm -rf $NETSIMDIRECTORY
	fi
	mkdir -p $NETSIMDIRECTORY > /dev/null 2>&1
	chown netsim:netsim $NETSIMDIRECTORY
	if [[ "$FETCH_FROM_NEXUS" == "YES" ]]
        then
                rm -rf $PORTAL_NETSIM_LIST
                rm -rf $PORTAL_PATCH_LIST
                PRODUCT=NETSimPatches_CDB
                $MOUNTPOINT/bin/getNetsimNexusPatchList.pl -d $NETSIMDROP -p $PRODUCT -v $VERSION
        fi
        if [[ -s $NETSIM_INSTALLER_PATH/$NETSIM_ZIP && -s $NETSIM_INSTALLER_PATH/Unbundle.sh ]]
        then
                echo "INFO: Copying the zip file to /netsim/$VERSION/"
                cp $NETSIM_INSTALLER_PATH/* $NETSIMDIRECTORY
        else
                #Download netsim from ci portal
                if [[ "$FETCH_FROM_NEXUS" == "YES" ]]
                then
                        cd $NETSIM_STORAGE_PATH
                        mkdir -p $VERSION/installer
                        if [[ -s $PORTAL_NETSIM_LIST ]]
                        then
                                NETSIM_RELEASE_LINK=`cat $PORTAL_NETSIM_LIST`
                                wget -O $NETSIM_INSTALLER_PATH/$NETSIM_ZIP $NETSIM_RELEASE_LINK
                                if [[ $? -ne 0 ]]
                                then
                                        echo "ERROR: Something went wrong getting the netsim, check output above"
                                        exit 1
                                fi
                                wget -O $NETSIM_INSTALLER_PATH/Unbundle.sh $UNBUNDLE_FILE_LINK
                                if [[ $? -ne 0 ]]
                                then
                                        echo "ERROR: Something went wrong getting the Unbundle script"
                                        exit 1
                                fi
                                cp $NETSIM_INSTALLER_PATH/* $NETSIMDIRECTORY
                        else
                                echo "ERROR: Unable to fetch the NETSim link from the ci portal"
                                exit 1
                        fi
                fi
        fi
        echo "INFO: Downloading the specified patches to /netsim/$VERSION/"
        cd $NETSIMDIRECTORY

        # Download patches from ci portal
        if [[ "$FETCH_FROM_NEXUS" == "YES" ]]
        then
                if [[ -s $PORTAL_PATCH_LIST ]]
                then
                        while read patchlink; do
                                IFS='/' read -ra ADDR <<< "$patchlink"
                                wget -O ${ADDR[11]}.zip $patchlink
                                if [[ $? -ne 0 ]]
                                then
                                        echo "ERROR: Something went wrong getting this patch, check output above"
                                        exit 1
                                fi
                        done <$PORTAL_PATCH_LIST
                elif [[ -e $PORTAL_PATCH_LIST ]]
                then
                        echo "INFO: No patches for netsim version $VERSION, installing without patches"
                else
                        echo "ERROR: Something went wrong getting the patchlist from ci portal for drop - $NETSIMDROP"
                        exit 1
                fi
        else
                #Download verified patches from NETSim ftp link
                NETSIM_PATCHES=`$MOUNTPOINT/bin/getNetsimVerifiedPatchList.pl -v $VERSION`
                echo "NETSIM_PATCHES=$NETSIM_PATCHES"
                echo "****************************************"
                echo "$NETSIM_PATCHES" | grep zip | while read patchlink
                do
                        wget $patchlink
                        if [[ $? -ne 0 ]]
                        then
                                echo "ERROR: Something went wrong getting this patch, check output above"
                                exit 1
                        fi
                done
                # Exit if some patches didn't get downloaded
                if [[ $? -ne 0 ]]
                then
                        exit 1
                fi
        fi

        # Install netsim
        echo "INFO: Installing netsim $VERSION now"
        su - netsim -c "cd $NETSIMDIRECTORY;sh ./Unbundle.sh quick AUTO"

        # Wait for the install to finish, parts of it still run in the background
        while [[ `pgrep "Install"` ]]
        do
            sleep 1
        done
        sleep 2
        echo "INFO: Netsim install finished, running setup_fd_server.sh"
        /netsim/inst/bin/setup_fd_server.sh
        echo "INFO: Creating NETSim init Script"
        /netsim/inst/bin/create_init.sh -a
        $MOUNTPOINT/bin/restart_netsim.sh -c $CONFIG -m $MOUNTPOINT
fi
