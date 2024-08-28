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


        result=`ldaplist 2>/dev/null | grep dn`
        if [[ "$result" == "" ]]
        then

                if [[ "`grep $OMSERVM_IP_ADDR /etc/hosts`" == "" ]]
                then
                        echo "$OMSERVM_IP_ADDR $OMSERVM_FQHN" >> /etc/hosts
                fi

                rm -f /var/ldap/*.db

                if [[ "$OMSAS_HOSTNAME" != "" ]]
                then
                        echo "Getting rootca.cer from omsas"
                        root_ca_server="$OMSAS_HOSTNAME"
COMMAND="
lcd /var/tmp/
cd /opt/ericsson/csa/certs/
get DSCertCA.pem rootca.cer
bye"
                else
                        echo "Getting rootca.cer from infra"
                        root_ca_server="$OMSERVM_HOSTNAME"
COMMAND="
lcd /var/tmp/
cd /var/tmp/
get rootca.cer
bye"
                fi
                        $EXPECT - <<EOF
                        set force_conservative 1
                        set timeout -1

                        # autologin variables
                        set prompt ".*(%|#|\\$|>):? $"

                        # set login variables before attempting to login
                        set loggedin "0"

                        spawn sftp $root_ca_server
                                expect {
                                        "Are you sure" {
                                                send "yes\r"
                                                exp_continue -continue_timer
                                        }
                                        "assword:" {
                                                send "shroot12\r"
                                                exp_continue -continue_timer
                                       }
                                        -re \$prompt {
                                                set loggedin "1"
                                        }
					}


                                if {\$loggedin == "1"} {
                                        send_user "\nLogged in fine, running command\n"
                                        send "$COMMAND\r"
                                        expect {
                                                "eof" {
                                                        send_user "\nFinished sftp of rootca.cer\n"
                                                        exit 0
                                                }
                                        }
                                } else {
                                        send_user "\nERROR: Failed to sftp rootca.cer\n"
                                        exit 1
                                }
EOF

			if [[ $? -ne 0 ]]
			then
				exit 1
			fi

                                $EXPECT - <<EOF
                                set force_conservative 1
                                set timeout -1

                                spawn /usr/sfw/bin/certutil -N -d /var/ldap
                                while 1 {
                                        expect {
                                                "new password:" {
							sleep 1
							send "ldapadmin\r"
						}
						"enter password:" {
							sleep 1
							send "ldapadmin\r"
						}
                                                eof {
							catch wait result
							exit [lindex \$result 3]
						}
                                        }
                                }
EOF

		if [[ $? -ne 0 ]]
		then
			exit 1
		fi

                /usr/sfw/bin/certutil -A -d /var/ldap -n "cacert" -t C,, -i /var/tmp/rootca.cer

		if [[ $? -ne 0 ]]
                then
                        exit 1
                fi

                /usr/sfw/bin/certutil -L -d /var/ldap

		if [[ $? -ne 0 ]]
                then
                        exit 1
                fi

                chmod 444 /var/ldap/*.db
                result=`ldapsearch -h $OMSERVM_FQHN -P /var/ldap/cert8.db -b "" -s base "objectclass=*" namingcontexts`
                if [[ $? -ne 0 ]] || [[ "$result" == "" ]]
                then
			echo "$result"
                        echo "SSL Test Failed during ldap setup, see above, exiting."
			exit 1
                else
                        /opt/ericsson/sck/bin/configure_ldap.bsh -g -y

			if [[ $? -ne 0 ]]
	                then
	                        exit 1
	                fi
                        #new install part
                                #/usr/local/bin/expect - <<EOF
                                $EXPECT - <<EOF
                                set force_conservative 1
                                set timeout -1

                                spawn /opt/ericsson/sck/bin/configure_ldap.bsh -m
                                while 1 {
                                        expect {
                                                "ERROR:" {
                                                        send_user "\nFound error, exiting\n"
                                                        exit 1
                                                }
                                                "now on the Master Server? :" { send "y\r" }
                                                "LDAP DS IP address" { send "$OMSERVM_IP_ADDR\r" }
                                                "LDAP domain name" { send "$LDAPDOMAIN\r" }
                                                "LDAP migration bind DN" { send "\r" }
                                                "Are the values ok?" { send "y\r" }
                                                "LDAP migration bind password" { send "$ns_data_migration_pass\r" }
						eof {
                                                        catch wait result
                                                        exit [lindex \$result 3]
                                                }
                                        }
                                }
EOF

			if [[ $? -ne 0 ]]
                        then
                                exit 1
                        fi
                                DOMAIN="dc=`echo "$LDAPDOMAIN" | sed 's/\./,dc=/g'`"
                                result=`ldapsearch -h $OMSERVM_FQHN -D "cn=proxyagent,ou=profile,$DOMAIN" -w $dm_pass -P /var/ldap/cert8.db -b "$DOMAIN" "objectclass=*" | grep dn`
                        if [[ $? -ne 0 ]] || [[ "$result" == "" ]]
                        then
                                echo "ldapsearch result doesn't look right"
				exit 1
                        else
                                $EXPECT - <<EOF
                                set force_conservative 1
                                set timeout -1

                                spawn /opt/ericsson/sck/bin/configure_ldap.bsh -i
                                while 1 {
                                        expect {
                                                "ERROR" {
                                                        send_user "\nAn error occured\n"
							exit 1
                                                }
                                                "migration already completed?" { send "y\r" }
                                                "Continue to run LDAP" { send "y\r" }
                                                "Continue to re-initialise?" { send "y\r" }
                                                "LDAP DS IP address" { send "$OMSERVM_IP_ADDR\r" }
                                                "LDAP domain name" { send "$LDAPDOMAIN\r" }
                                                "LDAP client profile name" { send "\r" }
                                                "LDAP proxy agent DN" { send "\r" }
                                                "LDAP proxy DN" { send "\r" }
                                                "Are the values ok?" { send "y\r" }
                                                "LDAP proxy agent password:" { send "$proxyagent_pass\r" }
                                                "Proxy Bind Password:" { send "$proxyagent_pass\r" }
						eof {
                                                        catch wait result
                                                        exit [lindex \$result 3]
                                                }
                                        }
                                }
EOF

			if [[ $? -ne 0 ]]
                        then
                                exit 1
                        fi
				$EXPECT - <<EOF
                                set force_conservative 1
                                set timeout -1

                                spawn /opt/ericsson/sck/bin/configure_ldap.bsh -e
				while 1 {
	                                expect {
						"Install post-migration /etc" {
							sleep 1
							send "y\r"
						}
						eof {
							catch wait result
							exit [lindex \$result 3]
						}
	                                }
				}
EOF

			if [[ $? -ne 0 ]]
                        then
                                exit 1
                        fi
                                result=`ldaplist | grep dn`
                                if [[ "$result" == "" ]]
                                then
                                        echo "ldaplist output doesn't look right, setup failed."
					exit 1
                                fi
                        fi
                fi
        else
                echo "Skipping, ldap already setup"
        fi
