#!/bin/bash

MOUNTPOINT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOUNTPOINT=`echo "$MOUNTPOINT" | sed 's/bin$//g'`

VCEN1_CLUSTERS="Compute Cluster 1 - WFT
Compute Cluster 2 - ETH
Test Hotel PoC
COMINF
NMI
Compute Cluster-ENIQ
GTEC Athlone -  HA
GTEC-Athlone
Compute 5-NFD
Compute Cluster-Optimi
Misc-Cluster
Netsim-vyatta-cluster"
#VCEN1_CLUSTERS=""


VCEN3_CLUSTERS="Build
CI1
DM1
ETH1
ETH2
MISC
Platform1
PM1
WLRCM_CN1"

VCEN1_CLUSTERS=""
VCEN3_CLUSTERS="ETH2
WLRCM_CN1"

echo "$VCEN1_CLUSTERS" | while read cluster
do
	echo "INFO: Working on cluster $cluster"
	$MOUNTPOINT/bin/list_vms_in_cluster.sh --vcenter atvcen1.athtem.eei.ericsson.se --cluster "$cluster" | while read VM_NAME
	do
		echo "Setting iops on $VM_NAME"
		$MOUNTPOINT/bin/vm_set_iops.sh --vcenter atvcen1.athtem.eei.ericsson.se --vmname "$VM_NAME" --iops 300
	done
done

echo "$VCEN3_CLUSTERS" | while read cluster
do
        echo "INFO: Working on cluster $cluster"
        $MOUNTPOINT/bin/list_vms_in_cluster.sh --vcenter atvcen3.athtem.eei.ericsson.se --cluster "$cluster" | while read VM_NAME
        do
                echo "Setting iops on $VM_NAME"
                $MOUNTPOINT/bin/vm_set_iops.sh --vcenter atvcen3.athtem.eei.ericsson.se --vmname "$VM_NAME" --iops 300
        done
done
