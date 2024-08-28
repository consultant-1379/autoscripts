#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -a ADMIN_SERVER_PRESENT"
        exit 1
}
check_args()
{
	if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi

	if [[ -z "$ADMIN_SERVER_PRESENT" ]]
        then
                echo "ERROR: You must say whether the admin server is present with -a"
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

while getopts "c:m:a:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
	;;
	m) MOUNTPOINT="$OPTARG"
	;;
	a) ADMIN_SERVER_PRESENT="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

# If there is an admin server, choose different answers
if [[ "$ADMIN_SERVER_PRESENT" == "no" ]]
then
	DISTRIBUTE_ANSWER="n"
else
	DISTRIBUTE_ANSWER="y"
fi

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

function configure_csa ()
{

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn scp -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no /var/tmp/ERICsinst/config/secinst_`hostname`_config.zip root@$OMSAS_HOSTNAME:/var/tmp

while {"1" == "1"} {
expect {
	"assword:" {send "shroot12\r"}
	eof {
		catch wait result
		exit [lindex \$result 3]
	}
}
}

EOF

if [[ $? -ne 0 ]]
then
        echo "ERROR: Failed to scp the secinst_`hostname`_config.zip file to the omsas, please check output above"
        exit 1
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ssh -t -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no root@$OMSAS_HOSTNAME "$MOUNTPOINT/bin/get_lock.sh -f /tmp/configsh.lock -p 1234 -t 3600 -r yes"
while {"1" == "1"} {
expect {
        "assword:" {send "shroot12\r"}
        eof {
		catch wait result
                exit [lindex \$result 3]
	}
}
}

EOF

if [[ $? -ne 0 ]]
then
        echo "ERROR: Failed to get the configsh lock"
        exit 1
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ssh -t -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no root@$OMSAS_HOSTNAME "/opt/ericsson/secinst/bin/config.sh -R /var/tmp/secinst_`hostname`_config.zip "
while {"1" == "1"} {
expect {
        "assword:" {send "shroot12\r"}
        eof {
		catch wait result
                exit [lindex \$result 3]
	}
}
}

EOF

EXIT_CODE=$?
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn ssh -t -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no root@$OMSAS_HOSTNAME "rm -rf /tmp/configsh.lock"
while {"1" == "1"} {
expect {
        "assword:" {send "shroot12\r"}
        eof {break}
}
}
EOF

if [[ $EXIT_CODE -ne 0 ]]
then
        echo "ERROR: config.sh failed on the omsas, please check output above"
        exit 1
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn scp -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no root@$OMSAS_HOSTNAME:/var/tmp/ERICsinst/config/secinst_`hostname`_response.zip /var/tmp
while {"1" == "1"} {
expect {
        "assword:" {send "shroot12\r"}
        eof {
		catch wait result
                exit [lindex \$result 3]
	}
}
}

EOF

if [[ $? -ne 0 ]]
then
	echo "ERROR: Failed to scp the secinst_`hostname`_response.zip file from the omsas, please check output above"
        exit 1
fi

$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

spawn /opt/ericsson/secinst/bin/config.sh -r /var/tmp/secinst_`hostname`_response.zip -v -v -v
while {"1" == "1"} {
expect {
	"Are you sure you want to continue connecting" {
                send "yes\r"
        }
    -re {change the ssl assignment to slapd now.*\]} {
        send "y\r"
        expect "directory manager\":"
        send "$dm_pass\r"
    }

    "Adding CaasAdmin user" {
        expect -re {password for.*:}
        send "$CAASADM_PASS\r"
        expect -re {password for.*:}
        send "$CAASADM_PASS\r"
    }
    "*com\r\nSelect ldap domain:" {
        send "2\r"
      }
    "*globaldomain\r\nSelect ldap domain:" {
        send "1\r"
     }
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
     "*Enter bind password:" {
       send "$dm_pass\r"
    }
	"password for \"cn=CaasAdmin,$DOMAIN\":" {
        send "$CAASADM_PASS\r"

    }
	"Do you wish to distribute INFRA IPs for" {
		sleep 1
		send "$DISTRIBUTE_ANSWER\r"
	}
	"Select user credential Signing Algorithm" {
       		 sleep 1
        	send "$SHA256_VALUE\r"
	}

	"assword:" {
                send "shroot12\r"
        }
    "Bring the created zipfile to the OMSAS and process the request" {
	expect eof {
		exit 99
	}
    }

    eof {
	catch wait result
	exit [lindex \$result 3]
	}
}
}

EOF

EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]] && [[ $EXIT_CODE -ne 99 ]]
then
        echo "ERROR: config.sh didn't complete successfully (exit code was $EXIT_CODE), please check output above"
        exit 1
fi

return $EXIT_CODE

}


##########################################################


## First run of config.sh without -r or -R
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1
spawn /opt/ericsson/secinst/bin/config.sh -v -v -v
expect "Detecting installed packages"
while {"1" == "1"} {
expect {
	"Are you sure you want to continue connecting" {
		send "yes\r"
	}
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

 "*com\r\nSelect ldap domain:" {
        send "2\r"
    }
 "*globaldomain\r\nSelect ldap domain:" {
        send "1\r"
    }

	"password:" {
		send "shroot12\r"
	}
	"Do you wish to distribute INFRA IPs for" {
                sleep 1
                send "$DISTRIBUTE_ANSWER\r"
        }
        "Bring the created zipfile to the OMSAS and process the request" {
	        expect eof {
	                exit 99
	        }
        }
        eof {
                catch wait result
                exit [lindex \$result 3]
        }
}
}

EOF

EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]] && [[ $EXIT_CODE -ne 99 ]]
then
        echo "ERROR: config.sh didn't complete successfully (exit code was $EXIT_CODE), please check output above"
        exit 1
fi

# Check initial config.sh exit code
if [[ $EXIT_CODE -eq 99 ]]
then
	#echo "INFO: Going to run config.sh commands with -r and -R because secinst_`hostname`_config.zip got created"

	COUNTER=1
	while [[ $COUNTER -lt 10 ]]
	do
		if [[ $COUNTER -eq 4 ]]
		then
			echo "WARNING: Not running the config.sh with -r and -R again as it was done 3 times already, please check if anything might be wrong"
			break
		fi
	
		echo "INFO: Running the config.sh -r and -R commands, attempt $COUNTER"
	        configure_csa
		EXIT_CODE=$?
	        if [[ $EXIT_CODE -eq 99 ]]
	        then
	                echo "INFO: The secinst_`hostname`_config.zip got created again"
	        else
			echo "INFO: The secinst_`hostname`_config.zip didn't get created again"
	                break
	        fi
		let COUNTER=COUNTER+1
	done
else
	echo "INFO: The secinst_`hostname`_config.zip didn't get created, not running config.sh with -r and -R"
fi
