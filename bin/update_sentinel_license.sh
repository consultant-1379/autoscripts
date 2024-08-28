#!/bin/bash

echo "Installing Temporary License"

#mkdir -p /mounts/attemjump220/;mount 159.107.220.94:/export/tep/ /mounts/attemjump220/ 2>/dev/null

full_oss_version=`grep CP_STATUS /var/opt/ericsson/sck/data/cp.status | awk '{print $2}' | sed 's/OSSRC_//g' | sed 's/_Shipment_/ /g'`
oss_release=`echo -n $full_oss_version | awk '{print $1}'`

dir=""
case $oss_release in

        R5_*)
                dir="r53"
                ;;
        R6_*)
                dir="r6"
                ;;
        R7_*)
                dir="r7"
                ;;
        O10_*)
                dir="o10"
                ;;
        O11_*)
                dir="O11"
                ;;
        O12_*)
                dir="O12"
                ;;
	O13_*)
		dir="O13"
		;;
	O14_*)
		dir="O14"
		;;
	O15_*)
		dir="O15"
		;;
	O16_*)
		dir="O16"
		;;
esac
echo "Sentinel directory is /sentinel/$dir"
ftp -inv attemfs1.athtem.eei.ericsson.se<<ENDFTP
user ossread ossread
bin
lcd /
prompt
cd /sentinel/$dir/
mget sentinel_license_*
bye
ENDFTP

export LSFORCEHOST=masterservice
core="`cat /ericsson/config/.network_size | grep core_net_size | awk -F= '{print $2}'`"
gran="`cat /ericsson/config/.network_size | grep gsm_net_size | awk -F= '{print $2}'`"
wran="`cat /ericsson/config/.network_size | grep wran_net_size | awk -F= '{print $2}'`"
lte="`cat /ericsson/config/.network_size | grep lte_net_size | awk -F= '{print $2}'`"
tdran="`cat /ericsson/config/.network_size | grep tdran_net_size | awk -F= '{print $2}'`"

if [[ "$core" != "" ]] && [[ "$core" != "0" ]]
then
        echo "Detected core cells greater than 0, $core"
	/opt/Sentinel/bin/lslic -F /sentinel_license_core
fi
if [[ "$gran" != "" ]] && [[ "$gran" != "0" ]]
then
        echo "Detected gran cells greater than 0, installing gran sentinel license, $gran"
        /opt/Sentinel/bin/lslic -F /sentinel_license_gran
fi
if [[ "$wran" != "" ]] && [[ "$wran" != "0" ]]
then
        echo "Detected wran cells greater than 0, installing wran sentinel license, $wran"
        /opt/Sentinel/bin/lslic -F /sentinel_license_wran
fi
if [[ "$lte" != "" ]] && [[ "$lte" != "0" ]]
then
        echo "Detected lte cells greater than 0, installing lte sentinel license, $lte"
        /opt/Sentinel/bin/lslic -F /sentinel_license_lte
fi
if [[ "$tdran" != "" ]] && [[ "$tdran" != "0" ]]
then
        echo "Detected tdran cells greater than 0, installing tdran sentinel license, $tdran"
        /opt/Sentinel/bin/lslic -F /sentinel_license_td_scdma
fi

#if [[ -f /mounts/attemjump220/Sentinel/permanent/`hostname` ]]
#then
#        echo "Found a permanent license, installing now"
#        /opt/Sentinel/bin/lslic -F /mounts/attemjump220/Sentinel/permanent/`hostname`
#else
#        echo "No permanent license found for this server"
#fi

echo "Sentinel License Update Completed"
