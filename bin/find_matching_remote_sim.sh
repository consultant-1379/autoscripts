#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -s SIMDIR -n SIMNAME"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$SIMDIR" ]]
        then
                echo "ERROR: You must say what simdir to use"
                exit 1
        fi
	if [[ -z "$SIMNAME" ]]
        then
                echo "ERROR: You must say what simname to match"
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

while getopts "c:m:s:n:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	s) SIMDIR="$OPTARG"
	;;
	n) SIMNAME="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

SIMSERVER=ftp.athtem.eei.ericsson.se
SIMSERVER_USER=simguest
SIMSERVER_PASS=simguest

SIM_LIST="`ftp -n -i $SIMSERVER <<ENDFTP
user ${SIMSERVER_USER} ${SIMSERVER_PASS}
cd $SIMDIR
ls -t1
bye
ENDFTP
`"

SIM_FOUND=`echo "$SIM_LIST" | grep "${SIMNAME}.*.zip" | head -1`
if [[ "$SIM_FOUND" == "" ]]
then
	echo "ERROR: Couldn't find a sim matching ${SIMNAME} in directory $SIMDIR, see list below"
	echo "$SIM_LIST"
	exit 1
fi

echo "$SIM_FOUND"
