#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PREFIX -i IPV6(yes or no)"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$PREFIX" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
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

while getopts "m:c:p:i:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	p) PREFIX="$OPTARG"
	;;
	i) IPV6="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

X_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
X_IP_ADDR=`eval echo \\$${PREFIX}_IP_ADDR`
X_IPV6_ADDR_PREFIX=`eval echo \\$${PREFIX}_CLIENT_IP_ADDR_V6`
X_IPV6_IP_ADDR=`echo "$X_IPV6_ADDR_PREFIX" | awk -F/ '{print $1}'`
X_SLAVE_SERV_ID4=`eval echo \\$${PREFIX}_SLAVE_SERV_ID4`
X_SLAVE_SERV_ID6=`eval echo \\$${PREFIX}_SLAVE_SERV_ID6`
X_SLAVE_ENABLE_GRAN=`eval echo \\$${PREFIX}_SLAVE_ENABLE_GRAN`
X_SLAVE_ENABLE_CORE=`eval echo \\$${PREFIX}_SLAVE_ENABLE_CORE`
X_SLAVE_ENABLE_WRAN=`eval echo \\$${PREFIX}_SLAVE_ENABLE_WRAN`
X_SLAVE_ENABLE_LRAN=`eval echo \\$${PREFIX}_SLAVE_ENABLE_LRAN`

if [[ "$X_IPV6_IP_ADDR" == "" ]] && [[ "$IPV6" == "yes" ]]
then
	exit 0
fi

if [[ "$IPV6" == "yes" ]]
then
	FILEEND="$X_SLAVE_SERV_ID6"
else
	FILEEND="$X_SLAVE_SERV_ID4"
fi
ORIG_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/smrs_slave_config.template
TEMP_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/smrs_slave_config.${FILEEND}
cp $ORIG_TEMPLATE_FILENAME $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_SERVICE_NAME=.*/SMRS_SLAVE_SERVICE_NAME=${FILEEND}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_NEDSS_IP=.*/SMRS_SLAVE_NEDSS_IP=${X_IP_ADDR}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

if [[ "$IPV6" == "yes" ]]
then
        cat $TEMP_TEMPLATE_FILENAME | sed "s/.*SMRS_SLAVE_NEDSS_IPV6=.*/SMRS_SLAVE_NEDSS_IPV6=${X_IPV6_IP_ADDR}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
        mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME
fi

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_ENABLE_GRAN=.*/SMRS_SLAVE_ENABLE_GRAN=${X_SLAVE_ENABLE_GRAN}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_ENABLE_CORE=.*/SMRS_SLAVE_ENABLE_CORE=${X_SLAVE_ENABLE_CORE}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_ENABLE_WRAN=.*/SMRS_SLAVE_ENABLE_WRAN=${X_SLAVE_ENABLE_WRAN}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/SMRS_SLAVE_ENABLE_LRAN=.*/SMRS_SLAVE_ENABLE_LRAN=${X_SLAVE_ENABLE_LRAN}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cd /opt/ericsson/nms_bismrs_mc/bin

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ./configure_smrs.sh add slave_service -f $TEMP_TEMPLATE_FILENAME
while {"1" == "1"} {
expect {
        "What is the root account password of" {send "shroot\r"}
	"What is the password for the local accounts" {send "$NEDSS_FTPSERVICES_PASS\r"}
        "Please confirm the password for the local accounts" {send "$NEDSS_FTPSERVICES_PASS\r"}
        eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
}
EOF
