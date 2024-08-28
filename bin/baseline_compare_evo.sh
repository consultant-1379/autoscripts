#!/bin/sh
#-----------------------------------------------------------
# COPYRIGHT Ericsson Radio Systems  AB 2009
#
# The copyright to the computer program(s) herein is the 
# property of ERICSSON RADIO SYSTEMS AB, Sweden. The 
# programs may be usedand/or copied only with the written 
# permission from ERICSSON RADIO SYSTEMS AB or in accordance 
# with the terms and conditions stipulated in the agreement
# contract under which the program(s)have been supplied.
#-----------------------------------------------------------
#
#   PRODUCT      : Delivery Management
#   CRA NUMBER  For R7: CRA 119 0247
#   CRA NUMBER  For O10: CRA 119 1021
#   PRODUCT REV  :
#   Document REV :
#   RESP         : DM Build Team
#   DATE         :
#
#   REV          :
#
#
#--------------------------------------------------------------
#
#   File: 
#   Revision History:
#   
#  
#set -xv
###############################
#VARIABLE DECLARATION
###############################
bld_srv=159.107.173.47
jump_reldir=/net/$bld_srv/export/jumpstart

###############################
# FUNCTIONS
###############################
usage() {
        echo "Usage: [-lcsh] Initial Install vs Build Manifest File Comparison tool." 1>&2
        printf " -i\t\t\tlists valid releases for OSSRC \n"
        printf " -l\t\t\tlists valid shipments for the OSSRC release \n"
       	printf " -c\t\t\tCreates a baseline for the server.Please specify a baseline filename\t\t\n"
       	printf " -b\t\t\tBaseline for ug or ii\t\t\n"
	printf " -r\t\t\tSpecify the release name in which to compare the ugrade baseline\t\t\n"
	printf " -s\t\t\tSpecify the shipment name in which to compare the ugrade baseline\t\t\n"
	printf " -u\t\t\tSpecify the shipment type (CU/LLSV)\t\t\n"
	printf " -n\t\t\tSpecify the LLSV increment\t\t\n"
        printf " -h\t\t\tprint this help, then exit\n"
        exit 1
}

ls_release() {
	bld_srv=159.107.173.47
	list_curr_releases=`ls /net/$bld_srv/export/jumpstart/OSS*`
	echo $list_curr_releases
}

ls_shipments() {
        bld_srv=159.107.173.47
        list_curr_shipments=`ls /net/$bld_srv/export/jumpstart/$ship_rel/`
        echo $list_curr_shipments
}

ug_baseline() {

if [ -f $ug_bl ]; then
	rm $ug_bl
fi

echo "Creating a baseline called "$ug_bl" for server $hostname"
echo "This may take a few minutes..."
 
pkginfo -l | nawk '{
    if (($1 == "PKGINST:") && ($2 ~ /(ERIC)|(EXTR)|(ECONF)/)) { pkginst=$2; found="yes"; continue }
    if ( found != "yes" ) next
    if ($1 == "VERSION:") { printf("%-25s%-15s\n",pkginst,toupper($2)); found="no" }
}' >> /$ug_bl

if [ -f $ug_bl ]; then
	echo "Baseline created"
else
	echo "Could not create baseline"
fi
}

bl_compare() {

echo ""
echo "Comparing $build_type server baseline $ug_bl with the $ship_rel $ship_rev (`uname -p`) baseline\n"
sleep 3 

if [ $build_type = ug ] ; then
	#build_dir=`ls $jump_reldir/$ship_rel/$ship_rev.daily | grep LLSV | sort -n | tail -1`
	arch_type=`uname -p`
	if [ $arch_type = i386 ] ; then
		if [ -d /var/tmp/manifest ] ; then
			umount /var/tmp/manifest
			rm -rf /var/tmp/manifest
		fi
		mkdir /var/tmp/manifest
		mount $bld_srv:/export/jumpstart/$ship_rel/$ship_rev.daily/$upgrade_type$llsv_inc/ossrc_base_sw/eric_app/ /var/tmp/manifest
		manifest_dir=/var/tmp/manifest/full_manifest_$arch_type
	else
		manifest_dir=/net/$bld_srv/export/jumpstart/$ship_rel/$ship_rev.daily/$upgrade_type$llsv_inc/ossrc_base_sw/eric_app/full_manifest_$arch_type
	fi
else 
        arch_type=`uname -p`
        if [ $arch_type = i386 ] ; then
                if [ -d /var/tmp/manifest ] ; then
                        umount /var/tmp/manifest
                        rm -rf /var/tmp/manifest
                fi
                mkdir /var/tmp/manifest
                mount $bld_srv:/export/jumpstart/$ship_rel/$ship_rev.daily/$upgrade_type$llsv_inc/ossrc_base_sw/eric_app/ /var/tmp/manifest
                manifest_dir=/var/tmp/manifest/manifest_$arch_type
        else
		manifest_dir=/net/$bld_srv/export/jumpstart/$ship_rel/$ship_rev.daily/ossrc_base_sw/eric_app/manifest_$arch_type
	fi
fi
if [ ! -f $manifest_dir ] ; then
	echo "$manifest_dir does not exists..."
	exit 1
fi
nawk -v ug_srvr=/$ug_bl -v manifest=$manifest_dir '
BEGIN {
		misses=0
       		while( (getline < ug_srvr ) > 0) pkg_RSTATE[$1]=$2
       		while( (getline < manifest) > 0) bl_RSTATE[$1]=$2 
			printf("%-45s\n","=============================================================================================")
        		printf("\t%-15s \t%-15s \t\t%-15s\n","Package Name","manifest_'$hostname'","manifest_'`uname -p`' (atrcx1089)")
			printf("%-45s\n","=============================================================================================")
        		for ( pkg in bl_RSTATE ) {
				if ( substr(pkg,1,4) != "ERIC" && substr(pkg,1,4) != "EXTR" && substr(pkg,1,4) != "ECON" ) {
					continue
				}	
				if ( pkg_RSTATE[pkg] != bl_RSTATE[pkg] && pkg != "ERICusck" && pkg != "ERICsct" && pkg != "ERICmvc" ) {
					if ( pkg_RSTATE[pkg] == "") {
					 	pkg_RSTATE[pkg] = "- Not Installed -"
					}
                			printf("\t%-20s \t%-20s \t\t%-20s\n", pkg, pkg_RSTATE[pkg], bl_RSTATE[pkg])
                			misses++
				}
            		else hits++
        		}
			printf("%-45s\n","=============================================================================================")
        		print "No. of Packages missing:" misses
        		print "No. of Co-related Packages:" hits
}'

}

########## MAIN ###############

hostname=`uname -n`

while getopts r:s:c:b:u:n:ilh opt; do
        case $opt in
                r)      ship_rel=$OPTARG
                        ;;
                s)      ship_rev=$OPTARG
                        ;;
               	c)	ug_bl=$OPTARG
			;; 
		b)	build_type=$OPTARG
			;;
		u)	upgrade_type=$OPTARG
			;;
		n)	llsv_inc=$OPTARG
			;;
		i)      list_releases=1
                        ;;
		l)      list_shipments=1
                        ;;
                h|\?)   usage
                        ;;
        esac
done
shift `expr $OPTIND - 1`
if [ "$build_type" = "" ] ; then
	build_type=ii
fi
if [ "$upgrade_type" = "LLSV" ]; then
	if [ "$llsv_inc" = "" ] ; then
		usage
	fi
fi
#[ $list_releases ] && ls_release
#[ $list_shipments ] && ls_shipments
[ $ug_bl ] && ug_baseline 
[ $ship_rev ] && bl_compare 

