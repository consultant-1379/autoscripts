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
	if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
		. $MOUNTPOINT/bin/load_config
        fi

}

while getopts "m:c:i:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	i) INPUT_CHOICE="$OPTARG"
	;;
	c) CONFIG="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

OMSERV_ADDRESSES="$OMSERVM_IP_ADDR"
if [[ "$OMSERVS_HOSTNAME" != "" ]] && [[ "$OMSERVS_HOSTNAME" != "dummy" ]]
then
	OMSERV_ADDRESSES="$OMSERV_ADDRESSES,$OMSERVS_IP_ADDR"
fi
/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs

cat /opt/ericsson/scs/conf/scs.properties |sed "s/^sftp_server_names=.*/sftp_server_names=$OMSERV_ADDRESSES/g" > /opt/ericsson/scs/conf/scs.properties.tmp
mv /opt/ericsson/scs/conf/scs.properties.tmp /opt/ericsson/scs/conf/scs.properties

cat /opt/ericsson/scs/conf/scs.properties |sed "s/^caas_servlet_names=.*/caas_servlet_names=$OMSERV_ADDRESSES/g" > /opt/ericsson/scs/conf/scs.properties.tmp
mv /opt/ericsson/scs/conf/scs.properties.tmp /opt/ericsson/scs/conf/scs.properties

/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs
/opt/ericsson/nms_cif_sm/bin/smtool -coldrestart scs -reason="other" -reasontext="Updated scs.properties"
/opt/ericsson/nms_cif_sm/bin/smtool prog
/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs
