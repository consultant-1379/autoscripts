#!/bin/bash
# Name    : manage_mws_sw.sh
# Written : Shane Kelly
# Date    : 08/12/10
# Purpose : The purpose of the script is to manage software on the 
#           releases for test MWS
#
# Usage   : manage_mws_sw.sh -u <ericsson id> -s <software path>
#
# ********************************************************************
#
#       ERROR CODE DEFINITION
#
# ********************************************************************
# ERROR
# CODE  EXPLANATION
#

# ********************************************************************
#
#       Command Section
#
# ********************************************************************
AWK=/usr/bin/awk
BASENAME=/usr/bin/basename
CAT=/usr/bin/cat
CHMOD=/usr/bin/chmod
CLEAR=/usr/bin/clear
CP=/usr/bin/cp
CUT=/usr/bin/cut
DATE=/usr/bin/date
DFSHARES=/usr/sbin/dfshares
DIRNAME=/usr/bin/dirname
DOMAINNAME=/usr/bin/domainname
EGREP=/usr/bin/egrep
EXPR=/usr/bin/expr
FILE=/usr/bin/file
FIND=/usr/bin/find
GREP=/usr/bin/grep
HEAD=/usr/bin/head
HOSTNAME=/usr/bin/hostname
ID=/usr/bin/id
LDAPSEARCH=/usr/bin/ldapsearch
LOFIADM=/usr/sbin/lofiadm
LS=/usr/bin/ls
MANAGE_NFS_MEDIA=/ericsson/jumpstart/bin/manage_nfs_media.bsh
MANAGE_JUMPSTART=/ericsson/jumpstart/bin/manage_jumpstart.bsh
MKDIR=/usr/bin/mkdir
MORE=/usr/bin/more
MOUNT=/usr/sbin/mount
MV=/usr/bin/mv
NAWK=/usr/bin/nawk
PING=/usr/sbin/ping
PWD=/usr/bin/pwd
RCP=/usr/bin/rcp
RM=/usr/bin/rm
RMDIR=/usr/bin/rmdir
SED=/usr/bin/sed
SLEEP=/usr/bin/sleep
SORT=/usr/bin/sort
TAIL=/usr/bin/tail
TELNET=/usr/bin/telnet
TOUCH=/usr/bin/touch
TR=/usr/bin/tr
UMOUNT=/usr/sbin/umount
UNAME=/usr/bin/uname
WC=/usr/bin/wc
LDAPFUNCID=/jumpstart/scripts/console/LDAP_functid_pass

LDAP_SERVER=ecd.ericsson.se

# ********************************************************************
#
#       Configuration Section
#
# ********************************************************************
# These are files I expect to find under the directory where this
# script is called from. Must be seperated by at least a space
CHECK_FILES=""
# ********************************************************************
#
#       Pre-execution Operations
#
# ********************************************************************

# ********************************************************************
#
#       functions
#
# ********************************************************************

### Function: check_files ###
#
# Check for files that I need. They should be relative
# to the directory where this script exists
#
# Arguments:
#       none
# Return Values:
check_files()
{
for file in $CHECK_FILES; do
    if [ ! -f "$SCRIPTHOME/$file" ]; then
        echo "Cannot locate file $SCRIPTHOME/$file"
        exit 1
    fi
done

}

### Function: get_absolute_path ###
#
# Determine absolute path to software
#
# Arguments:
#       none
# Return Values:
#       none
get_absolute_path()
{
cd `$DIRNAME $0`
_b_=`$BASENAME $0`
if [ ! -f ./$_b_ ]; then
        echo "Script can only be executed from directory"
        echo "where it resides. eg. ./`$BASENAME $0`\n"
        exit 1
fi
SCRIPTHOME=`pwd`

}

### Function: usage_msg ###
#
#   Print out the usage message
#
# Arguments:
#       none
# Return Values:
#       none

usage_msg()
{
echo "USAGE: `$BASENAME $0` -i <ericsson id> -l <software location> -t <software type> -m <media> -s <server>
USAGE: software location : Path to location of software to be imported
USAGE: ericsson id       : This is your id i.e. eeishky
USAGE: software type     : COMINF, OMBS-NBU, OAM, OMBS-Sol, OMSAS, ossrc, SOL
USAGE: media             : iso or dir - depending on which media you are going to add
USAGE: server            : server hostname data will be accessed over network from "
exit 1
}

### Function: check_ldap ###
#
#   Print out the usage message
#
# Arguments:
#       none
# Return Values:
#       none

check_ldap()
{
ID_NAME_CAP=`echo $ID_NAME | $TR '[a-z]' '[A-Z]'`
echo "INFO: Pinging LDAP server"
if $PING $LDAP_SERVER 3 > /dev/null 2>&1
then
   echo "INFO: LDAP Server alive"
   LDAP_OUTPUT=`$LDAPSEARCH -h $LDAP_SERVER -b "o=ericsson" -D uid=LDAPKBEN,ou=Users,ou=Internal,o=ericsson -j /net/159.107.173.12/jumpstart/scripts/console/LDAP_functid_pass uid=$ID_NAME | $EGREP "^uid" | $EGREP ${ID_NAME_CAP}$ | $NAWK -F[:=] '{print $2}'| $SED -e 's/^[ ]*//' -e 's/[ ]*$//'`
else
   echo "WARNING: LDAP Server not alive, assuming ID ok..."
   LDAP_OUTPUT=$ID_NAME_CAP
fi

if [ "$LDAP_OUTPUT" != "$ID_NAME_CAP" ]
then
    $CLEAR
    echo "ERROR: You must use a valid ericsson id"
    exit 2
else
    echo "INFO: ID $ID_NAME OK"	
fi
}

### Function: check_params ###
#
# Check the Input Parameters.
#
# Arguments:
#       $1 : User ID name
# Return Values:
#       none
check_params()
{
if [ ! "${SW_TYPE}" ]; then
    usage_msg
else
    case "${SW_TYPE}" in
       COMINF)  	;;
       OMBS-NBU)	;;
       OAM)		;;
       OMBS-Sol)	;;
       OMSAS)		;;
       ossrc)		;;
       SOL)		;;
       *)       echo "ERROR: unsupported Software Type"
		usage_msg
                ;;
    esac
    echo "INFO: Using Software Type $SW_TYPE"
fi


if [ ! "${SERVER}" ]; then
    usage_msg
else
    if $PING $SERVER 3 > /dev/null 2>&1; then
        echo "INFO: Server $SERVER alive"
        NET_TEST=`$DFSHARES $SERVER 2>&1 | $GREP ": RPC:"`
        if [ -n "$NET_TEST" ]; then
            echo "ERROR: $SERVER does not seem to be sharing any file systems"
            exit 10
        else
            echo "INFO: Can access $SERVER shares over network"
            if [ ! "${SW_LOC}" ]; then
                usage_msg
                exit 11
            else
                FULL_SW_LOC=/net/${SERVER}${SW_LOC}
                if [ ! -r $FULL_SW_LOC ]; then
                    echo "ERROR: $FULL_SW_LOC cannot be accessed, please check."
                    exit 12
                else
                echo "INFO: Using Software Location $FULL_SW_LOC" 
		fi
            fi
        fi
    else
        echo "ERROR: $SERVER no alive"
        exit 10
    fi
fi

if [ ! "${MEDIA}" ]; then
    usage_msg
else
    case "${MEDIA}" in
       dir)     if [ ! -d $FULL_SW_LOC ]; then
	            echo "ERROR: $FULL_SW_LOC does not seem to be a directory"
                    exit 3
		else
		    echo "INFO: $FULL_SW_LOC seems to be a directory"
	        fi
                ;;
       iso)     if [ ! -f $FULL_SW_LOC ]; then
                    echo "ERROR: $FULL_SW_LOC does not seem to be a file"
                    exit 3
		else
		    echo "INFO: $FULL_SW_LOC seems to be a file"
                fi
		;;
       *)       echo "ERROR: unsupported Media"
                usage_msg
                ;;
    esac
fi
if [ ! "${ID_NAME}" ]; then
    usage_msg
else
    check_ldap
fi
}

### Function: check_yorn ###
#
#   Check y/n
#
# Arguments:
#       none
# Return Values:
#       none

check_yorn()
{
read ANS
if [ "$ANS" = "y" ] || [ "$ANS" = "Y" ]; then
    ANS=y
elif [ "$ANS" = "n" ] || [ "$ANS" = "N" ]; then
    ANS=n
else
    echo -e "ERROR: please enter y or n : \c"
    check_yorn
fi
}

### Function: check_loc_files ###
#
#   Check if loc file exist in media
#
# Arguments:
#       none
# Return Values:
#       none

check_loc_files()
{
if [ "$SW_TYPE" = "ossrc" ]; then
    echo "INFO: Software Type is ossrc"
    R_OSS_LOC=$FULL_SW_LOC
    L_OSS_LOC=${R_OSS_LOC}
    echo "INFO: OSSRC installation at $L_OSS_LOC"
    if [ -s $L_OSS_LOC/om_sw.loc ]; then
        echo "INFO: om_sw.loc found"
        R_OM_LOC=`$CAT $L_OSS_LOC/om_sw.loc`
        echo "INFO: O&M loc - $R_OM_LOC"
    else
        echo "ERROR: om_sw.loc not found, please correct and restart"
        exit 5
    fi

    if [ -s $L_OSS_LOC/sol_i86pc.loc ]; then
        echo "INFO: sol_i86pc.loc found"
        R_SUN_i386_LOC=`$CAT $L_OSS_LOC/sol_i86pc.loc`
        echo "INFO: i386 loc - $R_SUN_i386_LOC"
    else
        echo "WARNING: sol_i86pc.loc not found"
        echo -e "INPUT: Do you require Solaris i386 location file? y/n: \c"
        check_yorn
        if [ "$ANS" = "y" ]; then
             echo "ERROR: sol_i86pc.loc not found, please correct and restart"
             exit 5
        elif [ "$ANS" = "n" ]; then
             echo "INFO: sol_i86pc.loc not required. Continuing"
        fi
    fi

    if [ -s $L_OSS_LOC/sol_sun4u.loc ]; then
        echo "INFO: sol_sun4u.loc found"
        R_SUN_SUN4U_LOC=`$CAT $L_OSS_LOC/sol_sun4u.loc`
        echo "INFO: sun4u loc - $R_SUN_SUN4U_LOC"
    else
        echo "WARNING: sol_sun4u.loc not found"
        echo -e "INPUT: Do you require Solaris sun4u location file? (y/n): \c"
        check_yorn
        if [ "$ANS" = "y" ]; then
             echo "ERROR: sol_sun4u.loc not found, please correct and restart"
             exit 5
        elif [ "$ANS" = "n" ]; then
             echo "INFO: sol_sun4u.loc not required. Continuing"
        fi
    fi
    if [ -z "$R_SUN_SUN4U_LOC" ] && [ -z "$R_SUN_i386_LOC" ]; then
        echo "ERROR: Either i386 or sun4u loc file required, please check and restart"
        exit 7
    fi
elif [ "$SW_TYPE" = "OMSAS" ]; then
	echo "INFO: Software Type is OMSAS"
	L_OMSAS_LOC=/net/${SERVER}${SW_LOC}
elif [ "$SW_TYPE" = "COMINF" ]; then
    if [ "$SERVER" != "`$HOSTNAME`" ]; then
	L_COMINF_LOC=/net/${SERVER}${SW_LOC}
    else
	L_COMINF_LOC=${SW_LOC}
        echo "ERROR: COMINF Software can only be located locally. Exiting"
       # exit 31
    fi
    echo "INFO: Software Type is COMINF"
    echo "INFO: COMINF installation at $L_COMINF_LOC"
    if [ -s $L_COMINF_LOC/om_sw.loc ]; then
        echo "INFO: om_sw.loc found"
        R_OM_LOC=`$CAT $L_COMINF_LOC/om_sw.loc`
        echo "INFO: O&M loc - $R_OM_LOC"
    else
        get_om_path
        if [ ! -f $L_OM_LOC/om/.om_identity ]; then
            echo "ERROR: OM Path is invalid"
            echo "INFO: Advisable to add relevant OSSRC media first and then choose the appropriate OM media when adding COMINF"
            echo "ERROR: Exiting"
            exit 32
        fi
    fi
    if [ -s $L_COMINF_LOC/sol_i86pc.loc ]; then
        echo "INFO: sol_i86pc.loc found"
        L_i386_LOC=`$CAT $L_COMINF_LOC/sol_i86pc.loc`
        echo "INFO: i386 loc - $L_i386_LOC"
    else
        echo "WARNING: sol_i86pc.loc not found. Either Solaris x86 or SUN4U is required"
        echo -e "INPUT: Do you require Solaris i386 location file? y/n: \c"
        check_yorn
        if [ "$ANS" = "y" ]; then
            echo "INFO: Looking for OSS release that uses $L_OM_LOC to get its Solaris i836 media"
		MEDIA_AREA=`cat /ericsson/jumpstart/etc/nfs_media_config/ossrc | grep MEDIA_AREA= | awk -F= '{print $2}'`
		MEDIA_DIRECTORY=`cat /ericsson/jumpstart/etc/nfs_media_config/ossrc | grep MEDIA_DIRECTORY= | awk -F= '{print $2}'`
            for oss_media in `find ${MEDIA_AREA}${MEDIA_DIRECTORY} -type d |egrep -e "${MEDIA_AREA}${MEDIA_DIRECTORY}/OSSRC_O[0-9A-Za-z]*_[^/]*/[0-9A-Za-z]*\.[0-9A-Za-z].[^/]*$"`
            do
                if [ -f $oss_media/om_sw.loc ]; then
                    if [ "`$CAT $oss_media/om_sw.loc`" = "$L_OM_LOC" ]; then
                        L_i386_LOC=`$CAT $oss_media/sol_i86pc.loc`
                        echo "INFO: Found $oss_media using $L_OM_LOC and its Solaris i386 is $L_i386_LOC"
                    fi
                fi
            done
            if [ -z "$L_i386_LOC" ]; then
                echo "ERROR: Solaris i386 matching OM $L_OM_LOC not found..exiting"
                exit 30
            fi
        elif [ "$ANS" = "n" ]; then
            echo "INFO: sol_i86pc.loc not required. Remember you need either i386 or SUN4U Solaris media..."
        fi
    fi
    if [ -s $L_COMINF_LOC/sol_sun4u.loc ]; then
        echo "INFO: sol_sun4u.loc found"
        L_SUN4U_LOC=`$CAT $L_COMINF_LOC/sol_sun4u.loc`
        echo "INFO: sun4u loc - $L_SUN4U_LOC"
    else
        echo "WARNING: sol_sun4u.loc not found"
        echo -e "INPUT: Do you require Solaris sun4u location file? (y/n): \c"
        check_yorn
        if [ "$ANS" = "y" ]; then
           echo "INFO: Looking for OSS release that uses $L_OM_LOC to get its Solaris sun4u media"
	MEDIA_AREA=`cat /ericsson/jumpstart/etc/nfs_media_config/ossrc | grep MEDIA_AREA= | awk -F= '{print $2}'`
                MEDIA_DIRECTORY=`cat /ericsson/jumpstart/etc/nfs_media_config/ossrc | grep MEDIA_DIRECTORY= | awk -F= '{print $2}'`
           for oss_media in `find ${MEDIA_AREA}${MEDIA_DIRECTORY} -type d |egrep -e "${MEDIA_AREA}${MEDIA_DIRECTORY}/OSSRC_O[0-9A-Za-z]*_[^/]*/[0-9A-Za-z]*\.[0-9A-Za-z].[^/]*$"`
           do
                if [ -f $oss_media/om_sw.loc ]; then
                    if [ "`$CAT $oss_media/om_sw.loc`" = "$L_OM_LOC" ]; then
                        L_SUN4U_LOC=`$CAT $oss_media/sol_sun4u.loc`
                        echo "INFO: Found $oss_media using $L_OM_LOC and its Solaris SUN4U is $L_SUN4U_LOC"
                    fi
                fi
           done
           if [ -z "$L_SUN4U_LOC" ]; then
               echo "ERROR: Solaris SUN4U matching OM $L_OM_LOC not found..exiting"
               exit 30
           fi
        elif [ "$ANS" = "n" ]; then
             echo "INFO: sol_sun4u.loc not required. Continuing"
        fi
    fi
    if [ -z "$L_SUN4U_LOC" ] && [ -z "$L_i386_LOC" ]; then
        echo "ERROR: Either i386 or sun4u loc file required, please check and restart"
        exit 7
    fi
fi

}

### Function: get_revs ###
#
#   Print out the usage message
#
# Arguments:
#       none
# Return Values:
#       none

get_revs()
{
L_SUN_SUN4U_LOC=/net/${SERVER}${R_SUN_SUN4U_LOC}
L_SUN_i386_LOC=/net/${SERVER}${R_SUN_i386_LOC}
if  [ -n "$R_OSS_LOC" ]; then
    L_OM_LOC=/net/${SERVER}${R_OM_LOC}
    echo "INFO: i386 OSS Media Identity file to read : $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_i386" 
    R_i386_OSS_REV_PREFIX=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_i386 | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_i386_OSS_REV_NUMBER=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_i386 | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_i386_OSS_REV_REV=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_i386 | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_i386_OSS_REV="${R_i386_OSS_REV_PREFIX}-${R_i386_OSS_REV_NUMBER}-${R_i386_OSS_REV_REV}"
    if [ "$R_i386_OSS_REV" = "--" ]; then
        echo "ERROR: Problem with OSS i386 Media Identity file. Exiting."
	exit 11
    else
        echo "INFO: OSS i386 Rev on $SERVER is $R_i386_OSS_REV"    
    fi 
    echo "INFO: sparc OSS Media Identity file to read : $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_sparc" 
    R_SUN4U_OSS_REV_PREFIX=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_sparc | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_SUN4U_OSS_REV_NUMBER=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_sparc | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_SUN4U_OSS_REV_REV=`$CAT $L_OSS_LOC/ossrc_base_sw/.ossrc_base_sw_sparc | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_SUN4U_OSS_REV="${R_SUN4U_OSS_REV_PREFIX}-${R_SUN4U_OSS_REV_NUMBER}-${R_SUN4U_OSS_REV_REV}"
    if [ "$R__OSS_REV" = "--" ]; then
        echo "ERROR: Problem with OSS sparc Media Identity file. Exiting."
        exit 11
    else
        echo "INFO: OSS sparc Rev on $SERVER is $R_SUN4U_OSS_REV"
    fi
fi
if  [ -n "$R_OM_LOC" ]; then
    L_OM_LOC=/net/${SERVER}${R_OM_LOC}
    echo "INFO: OM Media Identity file to read : $L_OM_LOC/om/.om" 
    R_OM_REV_PREFIX=`$CAT $L_OM_LOC/om/.om | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_OM_REV_NUMBER=`$CAT $L_OM_LOC/om/.om | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_OM_REV_REV=`$CAT $L_OM_LOC/om/.om | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_OM_REV="${R_OM_REV_PREFIX}-${R_OM_REV_NUMBER}-${R_OM_REV_REV}"
    echo "INFO: OM Rev on $SERVER is $R_OM_REV"    
fi
if  [ -n "$R_SUN_SUN4U_LOC" ]; then
    L_OM_LOC=/net/${SERVER}${R_OM_LOC}
    echo "INFO: sun4u Solaris Media Identity file to read : $L_SUN_SUN4U_LOC/../.consolidated_boot_media"
    R_SUN4U_REV_PREFIX=`$CAT $L_SUN_SUN4U_LOC/../.consolidated_boot_media | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_SUN4U_REV_NUMBER=`$CAT $L_SUN_SUN4U_LOC/../.consolidated_boot_media | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_SUN4U_REV_REV=`$CAT $L_SUN_SUN4U_LOC/../.consolidated_boot_media | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_SUN4U_REV="${R_SUN4U_REV_PREFIX}-${R_SUN4U_REV_NUMBER}-${R_SUN4U_REV_REV}"
    if [[ "$R_SUN4U_REV" == "--" ]]
    then
	echo "ERROR: The .consolidated_boot_media file doesn't seem correct"
	exit 11
    else
    	echo "INFO: sun4u Rev on $SERVER is $R_SUN4U_REV"    
    fi
fi
if  [ -n "$R_SUN_i386_LOC" ]; then
    L_OM_LOC=/net/${SERVER}${R_OM_LOC}
    echo "INFO: i386 Solaris Media Identity file to read : $L_SUN_i386_LOC/../.consolidated_boot_media"
    R_i386_REV_PREFIX=`$CAT $L_SUN_i386_LOC/../.consolidated_boot_media | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_i386_REV_NUMBER=`$CAT $L_SUN_i386_LOC/../.consolidated_boot_media | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_i386_REV_REV=`$CAT $L_SUN_i386_LOC/../.consolidated_boot_media | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_i386_REV="${R_i386_REV_PREFIX}-${R_i386_REV_NUMBER}-${R_i386_REV_REV}"
    if [[ "$R_i386_REV" == "--" ]]
    then
        echo "ERROR: The .consolidated_boot_media file doesn't seem correct"
        exit 11
    else
	echo "INFO: i386 Rev on $SERVER is $R_i386_REV"    
    fi
fi

if [ -n "$L_COMINF_LOC" ]; then
    if [[ -f $L_COMINF_LOC/cominf_install/.cominf_install ]]
    then
	IDENTITY_PATH=$L_COMINF_LOC/cominf_install/.cominf_install
    else
	IDENTITY_PATH=$L_COMINF_LOC/.cominf_install
    fi
    echo "INFO: COMINF Media Identity file to read : $IDENTITY_PATH"
    R_COMINF_REV_PREFIX=`$CAT $IDENTITY_PATH | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_COMINF_REV_NUMBER=`$CAT $IDENTITY_PATH | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_COMINF_REV_REV=`$CAT $IDENTITY_PATH | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_COMINF_REV="${R_COMINF_REV_PREFIX}-${R_COMINF_REV_NUMBER}-${R_COMINF_REV_REV}"
    echo "INFO: COMINF Rev to be imported is $R_COMINF_REV"    
fi

if [ -n "$L_OMSAS_LOC" ]; then
    echo "INFO: OMSAS Media Identity file to read : $L_OMSAS_LOC/omsas_base_sw/.omsas_base_sw"
    R_OMSAS_REV_PREFIX=`$CAT $L_OMSAS_LOC/omsas_base_sw/.omsas_base_sw | $EGREP "^media_prefix=" | $AWK -F\= '{print $2}'`
    R_OMSAS_REV_NUMBER=`$CAT $L_OMSAS_LOC/omsas_base_sw/.omsas_base_sw | $EGREP "^media_number=" | $AWK -F\= '{print $2}'`
    R_OMSAS_REV_REV=`$CAT $L_OMSAS_LOC/omsas_base_sw/.omsas_base_sw | $EGREP "^media_rev=" | $AWK -F\= '{print $2}'`
    R_OMSAS_REV="${R_OMSAS_REV_PREFIX}-${R_OMSAS_REV_NUMBER}-${R_OMSAS_REV_REV}"
    echo "INFO: OMSAS Rev to be imported is $R_OMSAS_REV"
fi
}

### Function: get_revs_mws ###
#
#   Print out the usage message
#
# Arguments:
#       none
# Return Values:
#       none

get_revs_mws()
{
if  [ -n "$R_i386_OSS_REV" ]; then
    echo "INFO: Checking if I already manage OSSRC $R_i386_OSS_REV"
    L_i386_OSS_REV=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_i386_OSS_REV`
    if [ -n "`echo $L_i386_OSS_REV |  $EGREP -i \"ERROR|No jumpstart\"`"  ]; then
        echo "INFO: i386 OSSRC rev $R_i386_OSS_REV not yet managed"
        UPDATE_i386_OSS_REV=YES
    elif [ -n "`echo $L_i386_OSS_REV | $GREP $R_i386_OSS_REV`" ]; then
        echo "INFO: i386 OSSRC rev $R_i386_OSS_REV is already managed"
	echo -n "MEDIA_LOCATION_i386_OSSRC_MEDIA "
        echo "$L_i386_OSS_REV" | grep Path | awk '{print $2}'
        UPDATE_i386_OSS_REV=NO
    else
	echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
	exit 12
    fi
fi
if  [ -n "$R_SUN4U_OSS_REV" ]; then
    echo "INFO: Checking if I already manage OSSRC $R_SUN4U_OSS_REV"
    L_SUN4U_OSS_REV=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_SUN4U_OSS_REV`
    if [ -n "`echo $L_SUN4U_OSS_REV | $EGREP -i \"ERROR|No jumpstart\"`"  ]; then
        echo "INFO: Sparc OSSRC rev $R_SUN4U_OSS_REV not yet managed"
        UPDATE_SUN4U_OSS_REV=YES
    elif [ -n "`echo $L_SUN4U_OSS_REV | $GREP $R_SUN4U_OSS_REV`" ]; then
        echo "INFO: Sparc OSSRC rev $R_SUN4U_OSS_REV is already managed"
	echo -n "MEDIA_LOCATION_SPARC_OSSRC_MEDIA "
        echo "$L_SUN4U_OSS_REV" | grep Path | awk '{print $2}'
        UPDATE_SUN4U_OSS_REV=NO
    else
	echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
	exit 12
    fi
fi
if  [ -n "$R_OM_REV" ]; then
    echo "INFO: Checking if I already manage OM $R_OM_REV"
    L_OM_REV=`$MANAGE_NFS_MEDIA -a list -m om -v $R_OM_REV`
    if [ -n "`echo $L_OM_REV | $EGREP -i \"ERROR|No jumpstart\"`"  ]; then
        echo "INFO: OM rev $R_OM_REV not yet managed"
        UPDATE_OM_REV=YES
    elif [ -n "`echo $L_OM_REV | $GREP $R_OM_REV`" ]; then
        echo "INFO: OM rev $R_OM_REV is already managed"
	echo -n "MEDIA_LOCATION_OM_MEDIA "
        echo "$L_OM_REV" | grep Path | awk '{print $2}'
        UPDATE_OM_REV=NO
    else
	echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
	exit 12
    fi
fi

if  [ -n "$R_COMINF_REV" ]; then
    echo "INFO: Checking if I already manage COMINF $R_COMINF_REV"
    L_COMINF_REV=`$MANAGE_NFS_MEDIA -a list -m cominf_install -v $R_COMINF_REV`
    if [ -n "`echo $L_COMINF_REV | $EGREP -i \"ERROR|cominf_install\"`"  ]; then
        echo "INFO: COMINF rev $R_COMINF_REV not yet managed"
        UPDATE_COMINF_REV=YES
    elif [ -n "`echo $L_COMINF_REV | $GREP $R_COMINF_REV`" ]; then
        echo "INFO: COMINF rev $R_COMINF_REV is already managed"
	echo -n "MEDIA_LOCATION_COMINF_MEDIA "
        echo "$L_COMINF_REV" | grep Path | awk '{print $2}'
        UPDATE_COMINF_REV=NO
    else
	echo "ERROR: An error has occured reading COMINF software currently managed, please check and retry"
	exit 12
    fi
fi

if  [ -n "$R_OMSAS_REV" ]; then
    echo "INFO: Checking if I already manage OMSAS $R_OMSAS_REV"
    L_OMSAS_REV=`$MANAGE_NFS_MEDIA -a list -m omsas -v $R_OMSAS_REV`
    if [ -n "`echo $L_OMSAS_REV | $EGREP -i \"ERROR\"`"  ]; then
        echo "INFO: OMSAS rev $R_OMSAS_REV not yet managed"
        UPDATE_OMSAS_REV=YES
    elif [ -n "`echo $L_OMSAS_REV | $GREP $R_OMSAS_REV`" ]; then
        echo "INFO: OMSAS rev $R_OMSAS_REV is already managed"
	echo -n "MEDIA_LOCATION_OMSAS_MEDIA "
        echo "$L_OMSAS_REV" | grep Path | awk '{print $2}'
        UPDATE_OMSAS_REV=NO
    else
        echo "ERROR: An error has occured reading OMSAS software currently managed, please check and retry"
        exit 12
    fi
fi

if  [ -n "$R_SUN4U_REV" ]; then
    echo "INFO: Checking if I already manage sun4u Solaris media $R_SUN4U_REV"
    L_SUN4U_REV=`$MANAGE_JUMPSTART -a list -j $R_SUN4U_REV`
    if [ -n "`echo $L_SUN4U_REV | $EGREP -i \"not found|No jumpstart\"`" ]; then 
        echo "INFO: Sparc media rev $R_SUN4U_REV not yet managed"
        UPDATE_SUN4U_REV=YES
    elif [ -n "`echo $L_SUN4U_REV | $GREP $R_SUN4U_REV`" ]; then
        echo "INFO: Sparc media rev $R_SUN4U_REV is already managed"
	echo -n "MEDIA_LOCATION_SPARC_SOL_MEDIA "
        echo "$L_SUN4U_REV" | grep Path | awk '{print $3}'
        UPDATE_SUN4U_REV=NO
    else
	echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
	exit 12
    fi
fi

if  [ -n "$R_i386_REV" ]; then
    echo "INFO: Checking if I already manage i386 Solaris media $R_i386_REV"
    L_i386_REV=`$MANAGE_JUMPSTART -a list -j $R_i386_REV`
    if [ -n "`echo $L_i386_REV | $EGREP -i \"not found|No jumpstart\"`"  ]; then
        echo "INFO: i386 media rev $R_i386_REV not yet managed"
        UPDATE_i386_REV=YES
    elif [ -n "`echo $L_i386_REV | $GREP $R_i386_REV`" ]; then
        echo "INFO: i386 media rev $R_i386_REV is already managed"
	echo -n "MEDIA_LOCATION_i386_SOL_MEDIA "
	echo "$L_i386_REV" | grep Path | awk '{print $3}'
        UPDATE_i386_REV=NO
    else
	echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
	exit 12
    fi
fi
        
    
}
### Function: add_media ###
#
#   Add required media to MWS
#
# Arguments:
#       none
# Return Values:
#       none

add_media()
{
if [ "$UPDATE_i386_REV" = "YES" ]; then
    echo "INFO: Adding media $R_i386_REV"
    echo "INFO: Running $MANAGE_JUMPSTART -a add  -B -p $L_SUN_i386_LOC/../ -N -s $L_SUN_i386_LOC/../sysid_dir/sysidcfg "
    $MANAGE_JUMPSTART -a add  -B -p $L_SUN_i386_LOC/../ -N -s $L_SUN_i386_LOC/../sysid_dir/sysidcfg > /tmp/mws.$$
    echo "INFO: Addition of  $R_i386_REV completed. Checking..."
    L_i386_REV=`$MANAGE_JUMPSTART -a list -j $R_i386_REV`
    if [ -n "`echo $L_i386_REV | $EGREP \"not found|No jumpstart areas created\"`" ]; then
        echo "INFO: i386 media rev $R_i386_REV is still not yet managed"
        echo "ERROR: Problem adding media $R_i386_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_i386_REV - OK"
    fi
###Check if media_lcoation is correct
    if [ -n "`$CAT /tmp/mws.$$ | $GREP "Install Server setup complete"`" ]; then 
        TMP_LOCATION=`$EGREP "^Setting up jumpstart location at" /tmp/mws.$$ | $AWK '{print $6}'`
        echo INFO: i386 Solaris Media Stored at $TMP_LOCATION
        $SED "s|media_location=\/JUMP\/SOL_MEDIA\/[0-9]*|media_location=$TMP_LOCATION|g" $TMP_LOCATION/.consolidated_boot_media > $TMP_LOCATION/.consolidated_boot_media.tmp
        $MV $TMP_LOCATION/.consolidated_boot_media.tmp $TMP_LOCATION/.consolidated_boot_media 
    fi
fi


if [ "$UPDATE_SUN4U_REV" = "YES" ]; then
    echo "INFO: Adding media $R_SUN4U_REV"
    echo "INFO: Running $MANAGE_JUMPSTART -a add  -B -p $L_SUN_SUN4U_LOC/../ -N -s $L_SUN_SUN4U_LOC/../sysid_dir/sysidcfg "
    $MANAGE_JUMPSTART -a add  -B -p $L_SUN_SUN4U_LOC/../ -N -s $L_SUN_SUN4U_LOC/../sysid_dir/sysidcfg > /tmp/mws.$$
    echo "INFO: Addition of $R_SUN4U_REV completed. Checking..."
    L_SUN4U_REV=`$MANAGE_JUMPSTART -a list -j $R_SUN4U_REV`
    if [ -n "`echo $L_SUN4U_REV | $GREP \"not found|No jumpstart areas created\"`" ]; then
        echo "INFO: SUN4U media rev $R_SUN4U_REV is still not yet managed"
        echo "ERROR: Problem adding media $R_SUN4U_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_SUN4U_REV - OK"
    fi
    if [ -n "`$CAT /tmp/mws.$$ | $GREP "Install Server setup complete"`" ]; then
        TMP_LOCATION=`$EGREP "^Setting up jumpstart location at" /tmp/mws.$$ | $AWK '{print $6}'`
        echo INFO: SUN4U Solaris Media Stored at $TMP_LOCATION
        $SED "s|media_location=\/JUMP\/SOL_MEDIA\/[0-9]*|media_location=$TMP_LOCATION|g" $TMP_LOCATION/.consolidated_boot_media > $TMP_LOCATION/.consolidated_boot_media.tmp
        $MV $TMP_LOCATION/.consolidated_boot_media.tmp $TMP_LOCATION/.consolidated_boot_media
    fi
fi


if [ "$UPDATE_i386_OSS_REV" = "YES" ]; then
    echo "INFO: Adding media $R_i386_OSS_REV"
    echo "INFO: Running $MANAGE_NFS_MEDIA -a add -m ossrc -N -p $L_OSS_LOC/ossrc_base_sw/"
    $MANAGE_NFS_MEDIA -a add -m ossrc -N -p $L_OSS_LOC/ossrc_base_sw/
    echo "INFO: Addition of $R_i386_OSS_REV completed. Checking..."
    L_i386_OSS_REV=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_i386_OSS_REV`
    if [ -n "`echo $L_i386_OSS_REV | $GREP ERROR`" ]; then
        echo "ERROR: Problem adding media $R_i386_OSS_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_i386_OSS_REV - OK"
    fi
fi
if  [ -n "$R_SUN4U_OSS_REV" ]; then
    echo "INFO: After adding i386 OSS media, Checking if I already manage OSSRC $R_SUN4U_OSS_REV"
    L_SUN4U_OSS_REV=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_SUN4U_OSS_REV`
    if [ -n "`echo $L_SUN4U_OSS_REV | $EGREP -i \"ERROR|No jumpstart\"`"  ]; then
        echo "INFO: Sparc OSSRC rev $R_SUN4U_OSS_REV not yet managed"
        UPDATE_SUN4U_OSS_REV=YES
    elif [ -n "`echo $L_SUN4U_OSS_REV | $GREP $R_SUN4U_OSS_REV`" ]; then
        echo "INFO: Sparc OSSRC rev $R_SUN4U_OSS_REV is already managed"
	echo -n "MEDIA_LOCATION_SPARC_OSSRC_MEDIA "
        echo "$L_SUN4U_OSS_REV" | grep Path | awk '{print $2}'
        UPDATE_SUN4U_OSS_REV=NO
    else
        echo "ERROR: An error has occured reading ossrc software currently managed, please check and retry"
        exit 12
    fi
fi
if [ "$UPDATE_SUN4U_OSS_REV" = "YES" ]; then
    echo "INFO: Adding media $R_SUN4U_OSS_REV"
    echo "INFO: Running $MANAGE_NFS_MEDIA -a add -m ossrc -N -p $L_OSS_LOC/ossrc_base_sw/"
    $MANAGE_NFS_MEDIA -a add -m ossrc -N -p $L_OSS_LOC/ossrc_base_sw/
    echo "INFO: Addition of $R_SUN4U_OSS_REV completed. Checking..."
    L_SUN4U_OSS_REV=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_SUN4U_OSS_REV`
    if [ -n "`echo $L_SUN4U_OSS_REV | $GREP ERROR`" ]; then
        echo "ERROR: Problem adding media $R_SUN4U_OSS_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_SUN4U_OSS_REV - OK"
    fi
fi

if [ "$UPDATE_OM_REV" = "YES" ]; then
    echo "INFO: Adding media $R_OM_REV"
    $MANAGE_NFS_MEDIA -a add -m om -N -p $L_OM_LOC/om/
    echo "INFO: Addition of $R_OM_REV completed. Checking..."
    L_OM_REV=`$MANAGE_NFS_MEDIA -a list -m om -v $R_OM_REV`
    if [ -n "`echo $L_OM_REV | $GREP ERROR`" ]; then
        echo "ERROR: Problem adding media $R_OM_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_OM_REV - OK"
    fi
fi
if [ "$UPDATE_COMINF_REV" = "YES" ]; then
    echo "INFO: Adding media $R_COMINF_REV"
    $MANAGE_NFS_MEDIA -a add -m cominf_install -N -p $L_COMINF_LOC/cominf_install/
    echo "INFO: Addition of $R_COMINF_REV completed. Checking..."
    L_COMINF_REV=`$MANAGE_NFS_MEDIA -a list -m cominf_install -v $R_COMINF_REV`
    if [ -n "`echo $L_COMINF_REV | $GREP ERROR`" ]; then
        echo "ERROR: Problem adding media $R_COMINF_REV. Exiting"
        exit 13
    else
	echo "INFO: Media $R_COMINF_REV - OK"
    fi
fi
if [ "$UPDATE_OMSAS_REV" = "YES" ]; then
    echo "INFO: Adding media $R_OMSAS_REV"
    $MANAGE_NFS_MEDIA -a add -m omsas -N -p $L_OMSAS_LOC/omsas_base_sw/
    echo "INFO: Addition of $R_OMSAS_REV completed. Checking..."
    L_OMSAS_REV=`$MANAGE_NFS_MEDIA -a list -m omsas -v $R_OMSAS_REV`
    if [ -n "`echo $L_OMSAS_REV | $GREP ERROR`" ]; then
        echo "ERROR: Problem adding media $R_OMSAS_REV. Exiting"
        exit 13
    else
        echo "INFO: Media $R_OMSAS_REV - OK"
    fi
fi
}

create_loc_files()
{
if [ "$UPDATE_i386_OSS_REV" = "YES" ]; then
    echo "INFO: Getting OSSRC SW location"
    OSS_i386_LOC=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_i386_OSS_REV | $EGREP "^Path " | $AWK '{print $2}'`
    echo "INFO: Generating OM Loc File"
    L_OM_LOC=`$MANAGE_NFS_MEDIA -a list -m om -v $R_OM_REV | $EGREP "^Path " | $AWK '{print $2}'` 
    echo "$L_OM_LOC" > $OSS_i386_LOC/om_sw.loc
    if [ -r $OSS_i386_LOC/om_sw.loc ]; then
        echo "INFO: OM Loc file created: $OSS_i386_LOC/om_sw.loc with `$CAT $OSS_i386_LOC/om_sw.loc`"
    else
	echo "ERROR: OM Loc File not created"
        exit 14
    fi
    echo "INFO: Generating SUN4U Solaris Loc File"
    L_SUN4U_LOC=`$MANAGE_JUMPSTART -a list -j $R_SUN4U_REV | $EGREP "^Path " | $AWK -F: '{print $2}' | $SED -e 's/^[ \t]*//'`
    echo "$L_SUN4U_LOC/Solaris_10" > $OSS_i386_LOC/sol_sun4u.loc
    if [ -r $OSS_i386_LOC/sol_sun4u.loc ]; then
        echo "INFO: SUN4U Solaris Loc file created: $OSS_i386_LOC/sol_sun4u.loc with `$CAT $OSS_i386_LOC/sol_sun4u.loc`"
    else
        echo "ERROR: SUN4U Solaris Loc File not created"
        exit 14
    fi
    echo "INFO: Generating i386 Solaris Loc File"
    L_i386_LOC=`$MANAGE_JUMPSTART -a list -j $R_i386_REV | $EGREP "^Path " | $AWK -F: '{print $2}' | $SED -e 's/^[ \t]*//'`
    echo "$L_i386_LOC/Solaris_10" > $OSS_i386_LOC/sol_i86pc.loc
    if [ -r $OSS_i386_LOC/sol_i86pc.loc ]; then
        echo "INFO: i386 Solaris Loc file created: $OSS_i386_LOC/sol_i86pc.loc with `$CAT $OSS_i386_LOC/sol_i86pc.loc`"
    else
        echo "ERROR: i386 Solaris Loc File not created"
        exit 14
    fi
fi

if [ "$UPDATE_SUN4U_OSS_REV" = "YES" ]; then
    echo "INFO: Getting OSSRC SW location"
    OSS_i386_LOC=`$MANAGE_NFS_MEDIA -a list -m ossrc -v $R_i386_OSS_REV | $EGREP "^Path " | $AWK '{print $2}'`
    echo "INFO: Generating OM Loc File"
    L_OM_LOC=`$MANAGE_NFS_MEDIA -a list -m om -v $R_OM_REV | $EGREP "^Path " | $AWK '{print $2}'` 
    echo $L_OM_LOC > $OSS_i386_LOC/om_sw.loc
    if [ -s $OSS_i386_LOC/om_sw.loc ]; then
        echo "INFO: OM Loc file created: $OSS_i386_LOC/om_sw.loc with `$CAT $OSS_i386_LOC/om_sw.loc`"
    else
	echo "ERROR: OM Loc File not created"
        exit 14
    fi
    echo "INFO: Generating SUN4U Solaris Loc File"
    L_SUN4U_LOC=`$MANAGE_JUMPSTART -a list -j $R_SUN4U_REV | $EGREP "^Path " | $AWK -F: '{print $2}' | $SED -e 's/^[ \t]*//'`
    echo "$L_SUN4U_LOC/Solaris_10" > $OSS_i386_LOC/sol_sun4u.loc
    if [ -s $OSS_i386_LOC/sol_sun4u.loc ]; then
        echo "INFO: SUN4U Solaris Loc file created: $OSS_i386_LOC/sol_sun4u.loc with `$CAT $OSS_i386_LOC/sol_sun4u.loc`"
    else
        echo "ERROR: SUN4U Solaris Loc File not created"
        exit 14
    fi
    echo "INFO: Generating i386 Solaris Loc File"
    L_i386_LOC=`$MANAGE_JUMPSTART -a list -j $R_i386_REV | $EGREP "^Path " | $AWK -F: '{print $2}'  | $SED -e 's/^[ \t]*//'`
    echo "$L_i386_LOC/Solaris_10" > $OSS_i386_LOC/sol_i86pc.loc
    if [ -s $OSS_i386_LOC/sol_i86pc.loc ]; then
        echo "INFO: i386 Solaris Loc file created: $OSS_i386_LOC/sol_i86pc.loc with `$CAT $OSS_i386_LOC/sol_i86pc.loc`"
    else
        echo "ERROR: i386 Solaris Loc File not created"
        exit 14
    fi
fi

if [ "$UPDATE_COMINF_REV" = "YES" ]; then
    COMINF_LOC=`$MANAGE_NFS_MEDIA -a list -m cominf_install -v $R_COMINF_REV | $EGREP "^Path " | $AWK '{print $2}'`
    echo "INFO: COMINF Media $R_COMINF_REV added at $COMINF_LOC"
    echo "INFO: Setting om_sw.loc"
    echo $L_OM_LOC > $COMINF_LOC/om_sw.loc
    if [ -n "$L_i386_LOC" ]; then
        echo $L_i386_LOC > $COMINF_LOC/sol_i86pc.loc
        if [ -s $COMINF_LOC/sol_i86pc.loc ]; then
           echo "INFO: i386 Solaris Loc file created: $COMINF_LOC/sol_i86pc.loc with `$CAT $COMINF_LOC/sol_i86pc.loc`"
        else
            echo "ERROR: i386 Solaris Loc File not created"
            exit 14
        fi
    fi
    if [ -n "$L_SUN4U_LOC" ]; then
        echo $L_SUN4U_LOC > $COMINF_LOC/sol_sun4u.loc
        if [ -s $COMINF_LOC/sol_sun4u.loc ]; then
           echo "INFO: sun4u Solaris Loc file created: $COMINF_LOC/sol_sun4u.loc with `$CAT $COMINF_LOC/sol_sun4u.loc`"
        else
            echo "ERROR: sun4u Solaris Loc File not created"
            exit 14
        fi

    fi
fi
   
}

get_om_path()
{
MEDIA_AREA=`cat /ericsson/jumpstart/etc/nfs_media_config/om | grep MEDIA_AREA= | awk -F= '{print $2}'`
MEDIA_DIRECTORY=`cat /ericsson/jumpstart/etc/nfs_media_config/om | grep MEDIA_DIRECTORY= | awk -F= '{print $2}'`
for line in `$FIND ${MEDIA_AREA}${MEDIA_DIRECTORY} -type d |$EGREP -e "${MEDIA_AREA}${MEDIA_DIRECTORY}/OSSRC_O[0-9A-Za-z]*_[^/]*/[0-9A-Za-z]*\.[0-9A-Za-z].[^/]*$"`
do
    echo "CHOOSE: $line"
done
echo "INFO: Please enter Local OM Path from list above:"    
echo -e "INPUT: \c"
read L_OM_LOC
}

mount_iso()
{
if [ -f "$SW_LOC" ]; then
    echo "INFO: Checking if $SW_LOC is an ISO file"
    ISO_CHECK=`$FILE $SW_LOC 2>&1 | $GREP "ISO 9660 filesystem"`
    if [ -z "$ISO_CHECK" ]; then
        echo "ERROR: $SW_LOC is not an ISO file. Exiting"
        exit 40
    fi
    LOFI_DEV=`$LOFIADM -a $SW_LOC`
    LOFI_CHECK=`echo $LOFI_DEV| $GREP /dev/lofi`
    if [ -z "$LOFI_CHECK" ]; then
       echo "ERROR: Could not lofiadm $SW_LOC. Exiting"
       exit 41
    fi
    mkdir /tmp/MOUNTPT.$$
    if [ ! -d /tmp/MOUNTPT.$$ ]; then
        echo "ERROR: Could not create mountpoint /tmp/MOUNTPT.$$. Exiting"
    fi
    $MOUNT -f hsfs $LOFI_DEV /tmp/MOUNTPT.$$
    echo "INFO: ISO mounted as /tmp/MOUNTPT.$$"
    echo "INFO: Setting /tmp/MOUNTPT.$$ at new software location"
    SW_LOC=/tmp/MOUNTPT.$$
fi

}

umount_iso()
{
if [ "$SW_LOC" = "/tmp/MOUNTPT.$$" ]; then
    echo "INFO: Check if /tmp/MOUNTPT.$$ still mounted"
    MOUNT_CHECK=`$MOUNT | $GREP /tmp/MOUNTPT.$$`
    if [ -z "$MOUNT_CHECK" ]; then
        echo "ERROR: /tmp/MOUNTPT.$$ no longer mounted"
        return
    fi
    echo "INFO: Unmounting /tmp/MOUNTPT.$$"
    cd /
    $UMOUNT /tmp/MOUNTPT.$$
    MOUNT_CHECK=`$MOUNT | $GREP /tmp/MOUNTPT.$$`
    if [ -n "$MOUNT_CHECK" ]; then
        echo "ERROR: /tmp/MOUNTPT.$$ still mounted. Problem"
    fi
    echo "INFO: Removing Mountpoint /tmp/MOUNTPT.$$"
    $RMDIR /tmp/MOUNTPT.$$
    echo "INFO: Removing lofiadm mount"
    $LOFIADM -d $LOFI_DEV
fi
}
# ********************************************************************
#
#       Main body of program
#
# ********************************************************************
#
# Determine absolute path to software
get_absolute_path

# Check for files that I need. They should be relative
# to the directory where this script exists
check_files

# Get the server name parameter
while getopts "i:s:l:t:m:" arg
do
    case $arg in
    i) ID_NAME="$OPTARG"
       ;;
    s) SERVER="$OPTARG"
       ;;
    l) SW_LOC="$OPTARG"
       ;;
    t) SW_TYPE="$OPTARG"
       ;;
    m) MEDIA="$OPTARG"
       ;;
   \?) usage_msg
       exit 1
       ;;
    esac
done

shift `expr $OPTIND - 1`

check_params

if [ "$MEDIA" = "iso" ]; then
    mount_iso
fi

check_loc_files

get_revs

get_revs_mws

add_media

create_loc_files

if [ "$MEDIA" = "iso" ]; then
    umount_iso
fi

echo "End"
