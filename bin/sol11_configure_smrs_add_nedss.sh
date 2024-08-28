#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PREFIX"
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
	if [[ -z "$CONFIG" ]]
        then
                echo "ERROR: You must give a config name"
                exit 1
        else
		. $MOUNTPOINT/bin/load_config
        fi

}

while getopts "m:c:p:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	p) PREFIX="$OPTARG"
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

ORIG_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/nedss_config.template
TEMP_TEMPLATE_FILENAME=/etc/opt/ericsson/nms_bismrs_mc/nedss_config.${X_HOSTNAME}
cp $ORIG_TEMPLATE_FILENAME $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/NEDSS_TRAFFIC_HOSTNAME=.*/NEDSS_TRAFFIC_HOSTNAME=${X_HOSTNAME}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cat $TEMP_TEMPLATE_FILENAME | sed "s/NEDSS_TRAFFIC_IP=.*/NEDSS_TRAFFIC_IP=${X_IP_ADDR}/g" > ${TEMP_TEMPLATE_FILENAME}.tmp
mv ${TEMP_TEMPLATE_FILENAME}.tmp $TEMP_TEMPLATE_FILENAME

cd /opt/ericsson/nms_bismrs_mc/bin

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ./configure_smrs.sh add nedss -f $TEMP_TEMPLATE_FILENAME
while {"1" == "1"} {
expect {
        "What is the root account password of" {send "shroot12\r"}
        eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
}
EOF
