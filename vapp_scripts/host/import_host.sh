#!/bin/bash

ROOT_DIR=`dirname $0`
ROOT_DIR=`cd ${ROOT_DIR} ; cd .. ; pwd`

while getopts  "c:h:d:" flag
do
    case "$flag" in
	c) CLUST="${OPTARG}";;
	h) ESXI_SRV="${OPTARG}";;
	d) DVS_INFO="${OPTARG}";;

        *) 
           echo "ERROR: Unknown option $flag"
	   exit 1
	   ;;

    esac
done

if [ "${DVS_INFO}" ] ; then
    DVS=`echo ${DVS_INFO} | awk -F: '{print $1}'`
    NIC1=`echo ${DVS_INFO} | awk -F: '{print $2}'`
    NIC2=`echo ${DVS_INFO} | awk -F: '{print $3}'`
    if [ -z "${NIC2}" ] ; then 
	echo "ERROR: dvs switch info format is dvSwitchName:vmnicx:vmnicy"
	exit 1
    fi
fi

if [ ! -r /usr/lib/vmware-vcli/apps/host/hostops-lamw.pl ] ; then
    echo "ERROR: Cannot find /usr/lib/vmware-vcli/apps/host/hostops-lamw.pl"
    exit 1
fi

vifs --server ${ESXI_SRV} --username root --password shr00t12 --get "/host/ssl_cert" /tmp/ssl_cert.${ESXI_SRV}
if [ $? -ne 0 ] ; then
    echo "ERROR: Failed to get SSL cert from ${ESXI_SRV}"
    exit 1
fi

FINGERPRINT=`openssl x509 -sha1 -in /tmp/ssl_cert.${ESXI_SRV} -noout -fingerprint | awk -F= '{print $2}'`
/usr/lib/vmware-vcli/apps/host/hostops-lamw.pl --operation addhost --cluster "${CLUST}" --target_host ${ESXI_SRV} --target_username root --target_password shr00t12  --sslthumbprint "${FINGERPRINT}" 
if [ $? -ne 0 ] ; then
    echo "ERROR: Failed to add host ${ESXI_SRV}"
    exit 1
fi

vicfg-ntp --vihost ${ESXI_SRV} --add 159.107.173.12
vicfg-ntp --vihost ${ESXI_SRV} --stop
vicfg-ntp --vihost ${ESXI_SRV} --start

vicfg-dns --vihost ${ESXI_SRV} --dns 159.107.173.12
vicfg-dns --vihost ${ESXI_SRV} --domain athtem.eei.ericsson.se
vicfg-dns --vihost ${ESXI_SRV} --refresh

vicfg-vswitch --vihost ${ESXI_SRV} --link vmnic1 vSwitch0
vicfg-vswitch --vihost ${ESXI_SRV} --add-pg-uplink vmnic1 --pg "Management Network" vSwitch0
vicfg-vmknic --vihost ${ESXI_SRV} --enable-vmotion "Management Network"
${ROOT_DIR}/host/reconfigHA.pl --host ${ESXI_SRV}

if [ ! -z "${DVS}" ] ; then
    ${ROOT_DIR}/dvs.pl --op addhost --dvs ${DVS} --host ${ESXI_SRV} --nic ${NIC1}
    if [ $? -ne 0 ] ; then
	echo "ERROR: Failed to add nic ${NIC1} to ${DVS}"
	exit 1
    fi
    ${ROOT_DIR}/host/dvs.pl --op addhost --dvs ${DVS} --host ${ESXI_SRV} --nic ${NIC2}
    if [ $? -ne 0 ] ; then
	echo "ERROR: Failed to add nic ${NIC2} to to ${DVS}"
	exit 1
    fi
fi
