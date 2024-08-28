#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT"
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

while getopts "c:m:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

DOMAIN="dc=`echo "$LDAPDOMAIN" | sed 's/\./,dc=/g'`"
if [[ -z "$IPSECUSER_PASS" ]]
then
        IPSECUSER_PASS="$NEUSER_PASS"
fi
if [[ ! -z "$SHA256" ]]
then
        if [[ "$SHA256" == "yes" ]]
        then
                SHA256_VALUE=2
        else
                SHA256_VALUE=1
        fi
else
        SHA256_VALUE=1

fi

function OMSAS_Configuration
{
        $EXPECT - <<EOF
                        set force_conservative 1
                        set timeout -1

        spawn /opt/ericsson/secinst/bin/config.sh 
        expect "Detecting installed packages"
        while {"1" == "1"} {
        expect {
                "*Enter password for \"cn=Directory Manager\":" {
                        send "$dm_pass\r"
                }
                "*Enter password for \"cn=Directory manager\":" {
                        send "$dm_pass\r"
                }

                "*Enter password for \"cn=directory Manager\":" {
                        send "$dm_pass\r"
                }

                "*Enter password for \"cn=directory manager\":" {
                        send "$dm_pass\r"
                }
                "*Enter password for .cn=directory manager:" {
                        send "$dm_pass\r"
                }

                "*Enter bind password:" {
                        send "$dm_pass\r"
                }

		 "algorithm for"
                {
                        sleep 1
                        send "$SHA256_VALUE\r"
                }

                "create a CAAS Admin user now" {
                        send "y\r"
                        expect "username for the new user"
                        send "$CAASADM_USER\r"
                  expect "New Password:"
                        send "$CAASADM_PASS\r"
                        expect "Re-enter new Password:"
                        send "$CAASADM_PASS\r"
                }

                "password for \"cn=CaasAdmin,$DOMAIN\":" {
                        send "$CAASADM_PASS\r"
                }

                "ssl assignment to slapd now" {
                        send "y\r"
                }

                "Enter new password for " {
                        send "$CAASADM_PASS\r"
                        expect "Confirm password for"
                        send "$CAASADM_PASS\r"
                }

                "The user scsuser is the user" {
                        expect "set one now"
                        sleep 1
                        send "y\r"
                        expect "New Password:"
                        send "$SCSUSER_PASS\r"
                        expect "Re-enter new Password:"
                        send "$SCSUSER_PASS\r"
                }

                "The user neuser is the user" {
                        expect "set one now"
                        send "y\r"
                        expect "New Password:"
                        send "$NEUSER_PASS\r"
                        expect "Re-enter new Password:"
                        send "$NEUSER_PASS\r"
                }
                -re "The ipsecsmrs is the SMRS user|ipsecsmrs name too long" {
                sleep 1
                        expect "set one now"
                        send "y\r"
                        expect "New Password:"
                        send "$IPSECUSER_PASS\r"
                        expect "Re-enter new Password:"
                        send "$IPSECUSER_PASS\r"
                }
                "Please give the domain name for CDP" {
                        send "\r"
                }
		-re {\[([0-9]+)\] dc=(?:(?!global).).*Select ldap domain:} {
                        send "\$expect_out(1,string)\r"
		}
		 
		"*com\r\nSelect ldap domain:" {
		        send "2\r"
   		 }
		 "*globaldomain\r\nSelect ldap domain:" {
        		send "1\r"
   		 }

                "and fetch the IOR"
                {
                        send "y\r"
                }
                "Do you wish to generate"
                {
                        sleep 1
                        send "n\r"
                }
		 "Do you wish to connect"
                {
                        sleep 1
                        send "n\r"
                }
                "Do you wish to create"
                {
                                        sleep 1
                                        send "n\r"
                }
                "Select signature algorithm for"
                {
                        sleep 1
                        send "$SHA256_VALUE\r"
                }
		"signature algorithm for"
                {
                        sleep 1
                        send "$SHA256_VALUE\r"
                }
                "password:"
                {
                        send "shroot12\r"
                }
                "Password:"
                {
                                        send "shroot12\r"
                }
                "Are you sure you want to continue connecting"
                {
                        send "yes\r"
                }

                eof {
                        catch wait result
                        exit [lindex \$result 3]
                }
      }
EOF
}

function CSA_Workaround
{
	svcadm disable -st csa || return
	ps -ef |grep csa |grep -v grep |awk '{print $2}' | xargs kill > /dev/null 2>&1
	rm -rf /opt/ericsson/csa/domains/csa
}

echo  "INFO:Running OMSAS configuration"
OMSAS_Configuration
exitCode=$?
if [[ $exitCode -ne 0 ]]
then
        echo "WARNING: Normal Configuration failed. Checking the CSA deployment status"
       /opt/ericsson/cadm/bin/pkiAdmin ca list -cacerts > /tmp/csaCheck.txt
        if [[ `grep -i 'CA name' /tmp/csaCheck.txt | wc -l` -eq 0  || `cat /opt/ericsson/csa/domains/csa/logs/server.log* | grep -c "redeploy ejbca"` -ne 0  ]]
        then
                echo "WARNING: Normal Configuration failed. Re-running after re deploy CSA"
                CSA_Workaround
                OMSAS_Configuration
                exitCode=$?
                if [[ $exitCode -ne 0 ]]
                then
                        echo "ERROR: Config.sh is not OK. Configuration failed even after re deploy of CSA."
                        exit 1

                fi
        else
                echo "ERROR: Config.sh is not OK. Server is not proper, please check."
                exit 1
        fi
fi

