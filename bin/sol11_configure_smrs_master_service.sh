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

while getopts "m:c:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
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


ORIG_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/smrs_master_config.template
TEMP_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/smrs_master_config.${OMSERVM_HOSTNAME}
cp $ORIG_TEMPLATE_FILENAME $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/DEPLOYMENT_TYPE=.*/DEPLOYMENT_TYPE=blade/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_MASTER_IP=/SMRS_MASTER_IP=$OMSERVM_IP_ADDR/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_ALIAS=.*/OSS_ALIAS=${NEDSS_SMRS_OSS_ID}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME


if [[ "$ADM2_HOSTNAME" != "" ]]
then
	cat $TEMP_TEMPLATE_FILENAME | sed "s/.*OSS_NODE2=.*/OSS_NODE2=$ADM2_HOSTNAME/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
	mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

	cat $TEMP_TEMPLATE_FILENAME | sed "s/.*OSS_NODE2_IP=.*/OSS_NODE2_IP=$ADM2_IP_ADDR/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
	mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

fi

cat $TEMP_TEMPLATE_FILENAME | sed "s/.*SMRS_NAS_SYSID=.*/SMRS_NAS_SYSID=$NEDSS_SMRS_SYS_ID/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_SUPPORT_GRAN=.*/OSS_SUPPORT_GRAN=$NEDSS_OSS_SUPPORT_GRAN/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_SUPPORT_CORE=.*/OSS_SUPPORT_CORE=$NEDSS_OSS_SUPPORT_CORE/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_SUPPORT_WRAN=.*/OSS_SUPPORT_WRAN=$NEDSS_OSS_SUPPORT_WRAN/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_SUPPORT_LRAN=.*/OSS_SUPPORT_LRAN=$NEDSS_OSS_SUPPORT_LRAN/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_GRAN_SMO_FTPSERVICE=.*/OSS_GRAN_SMO_FTPSERVICE=smoftpgran/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/OSS_CORE_SMO_FTPSERVICE=.*/OSS_CORE_SMO_FTPSERVICE=smoftpcore/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cd /opt/ericsson/nms_bismrs_mc/bin

# Workaround for TR HQ63843, ERROR Failed to set ACL permissions to nmsrole
# Remove when fixed
touch /var/opt/ericsson/log/bismrs_events.log

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ./configure_smrs.sh add smrs_master -f $TEMP_TEMPLATE_FILENAME
while {"1" == "1"} {
expect {
        "What is the root account password of" {send "shroot12\r"}
        "What is the password for the local accounts" {send "$NEDSS_FTPSERVICES_PASS\r"}
        "Please confirm the password for the local accounts" {send "$NEDSS_FTPSERVICES_PASS\r"}
        eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
}
EOF
