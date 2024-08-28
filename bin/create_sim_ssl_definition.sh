#!/bin/bash

usage_msg()
{
        echo "Usage: $0"
        exit 1
}
check_args()
{
	echo ""
}

while getopts "s:n:d:c:a:k:p:" arg
do
    case $arg in
	s) SIMNAME="$OPTARG"
	;;
        n) DEFINITION_NAME="$OPTARG"
	;;
        d) DESCRIPTION="$OPTARG"
        ;;
	c) CERT_PATH="$OPTARG"
        ;;
	a) CACERT_PATH="$OPTARG"
	;;
	k) KEY_PATH="$OPTARG"
	;;
	p) KEY_PASSWORD="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

SUPPORTED_SSL_TYPES="RNC
RBS
RXI
ERBS"

MML=".open $SIMNAME
.show simnes"
NODE_LIST_FULL=`su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"`
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
NODE_LIST=`echo "$NODE_LIST_FULL" | grep -v "In Address" | grep -v "OK" | grep -v ">>" | awk '{print $1, $3}'`
FIRST_NODE_TYPE="`echo \"$NODE_LIST\" | head -1 | awk '{print $2}'`"
if [[ ! `echo "$SUPPORTED_SSL_TYPES" | grep "^$FIRST_NODE_TYPE$"` ]]
then
	echo "INFO: Not creating ssl security definition for $SIMNAME as it has a node type that doesn't support ssl, $FIRST_NODE_TYPE"
	exit 0
fi

echo "INFO: Creating ssl security definition for $SIMNAME"
MML=".open $SIMNAME
.select configuration
.setssliop createormodify $DEFINITION_NAME
.setssliop description $DESCRIPTION
.setssliop clientcertfile $CERT_PATH
.setssliop clientcacertfile $CACERT_PATH
.setssliop clientkeyfile $KEY_PATH
.setssliop clientpassword $KEY_PASSWORD
.setssliop clientverify 0
.setssliop clientdepth 1
.setssliop servercertfile $CERT_PATH
.setssliop servercacertfile $CACERT_PATH
.setssliop serverkeyfile $KEY_PATH
.setssliop serverpassword $KEY_PASSWORD
.setssliop serververify 0
.setssliop serverdepth 1
.setssliop protocol_version sslv2|sslv3|tlsv1
.setssliop save force"

su - netsim -c "echo \"$MML\" | /netsim/inst/netsim_pipe -stop_on_error"
if [[ $? -ne 0 ]]
then
        echo "ERROR: Something went wrong running the mml commands"
        exit 1
fi
