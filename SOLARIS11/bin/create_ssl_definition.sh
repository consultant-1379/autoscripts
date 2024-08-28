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

while getopts "n:d:c:a:k:p:" arg
do
    case $arg in
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

echo "INFO: Creating ssl security definition"
MML=".select configuration
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
