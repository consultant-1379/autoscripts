#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -v VERSION -f yes/no"
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

while getopts "c:m:v:f:" arg
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
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
NETSIMDIRECTORY=/netsim/$VERSION/
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
	echo "INFO: Copying the zip file to /netsim/$VERSION/"
	cp $MOUNTPOINT/files/netsim/versions/$VERSION/installer/* $NETSIMDIRECTORY
	echo "INFO: Downloading the specified patches to /netsim/$VERSION/"
	cd $NETSIMDIRECTORY

	# Download patches
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

