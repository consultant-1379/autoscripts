#!/bin/bash

MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

usage_msg()
{
    echo "Usage: $0 -v VCEN_HOSTNAME"
    exit 1
}
check_args()
{
    if [[ -z "$VCEN_HOSTNAME" ]]
    then
        echo "ERROR: You must say what the vcenter server hostname is"
        exit 1
    fi
}

while getopts "v:" arg
do
    case $arg in
        v) VCEN_HOSTNAME="$OPTARG"
        ;;
        \?) usage_msg
        exit 1
        ;;
    esac
done

check_args

# Figure out the fully qualified hostname incase we don't already have it
VCENTER_DETAILS=`grep ${VCEN_HOSTNAME} /vcenter_details.txt 2>&1`
if [[ $? -ne 0 ]]
then
    echo "ERROR: Couldn't find the vcenter specified, in the /vcenter_details.txt file"
    exit 1
fi
VCEN_FQHN=`echo "$VCENTER_DETAILS" | head -1 | awk '{print $2}'`
USERNAME=`echo "$VCENTER_DETAILS" | head -1 | awk '{print $3}'`
PASSWORD=`echo "$VCENTER_DETAILS" | head -1 | awk '{print $4}'`

export VI_SESSIONFILE=/tmp/vma_session_${VCEN_FQHN}
CHECK_OUTPUT=`${MOUNTPOINT}/bin/vmware-vsphere-cli-distrib/check_is_vma_session_valid.pl 2>&1`
if [[ $? -ne 0 ]]
then
    CREATE_SESSION_OUTPUT=`/usr/share/doc/vmware-vcli/samples/session/save_session.pl --server $VCEN_FQHN --username ${USERNAME} --password ${PASSWORD} -savesessionfile ${VI_SESSIONFILE} 2>&1`
    if [[ $? -ne 0 ]]
    then
        echo "ERROR: Couldn't create a session towards this vcenter $VCEN_FQHN, check the error output below for the reason why"
        echo "$CREATE_SESSION_OUTPUT"
        exit 1
    fi
fi
