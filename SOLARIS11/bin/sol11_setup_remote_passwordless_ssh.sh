#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -t TO_SERVER"
        exit 1
}

check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
}

while getopts "m:t:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	t) TO_SERVER="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

FROM_SERVER=`hostname`

# Check if passwordless ssh is already setup
ssh -qtn -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 "${TO_SERVER}" ls > /dev/null 2>&1
if [ $? -eq 0 ]
then
	echo "INFO: Passwordless ssh is already setup from $FROM_SERVER to $TO_SERVER"
	exit 0
fi

# Perform steps as per documentation
if [[ ! -f /root/.ssh/id_rsa.pub ]]
then
	chmod 0700 /root/.ssh
	cd /.ssh
	ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ""
fi

SCP_COMMAND="scp /root/.ssh/id_rsa.pub root@${TO_SERVER}:/root/.ssh/${FROM_SERVER}.key"
CAT_COMMAND="ssh ${TO_SERVER} 'cat /root/.ssh/${FROM_SERVER}.key >> /root/.ssh/authorized_keys2;rm /root/.ssh/${FROM_SERVER}.key'"
ALL_COMMANDS="${SCP_COMMAND};${CAT_COMMAND}"

$EXPECT - <<EOF
	set force_conservative 1
	set timeout -1

	spawn bash -c "$ALL_COMMANDS"
	while {"1" == "1"} {
		expect {
			"assword:"
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
	}
EOF

if [[ $? -ne 0 ]]
then
	exit 1
fi

ssh -qtn -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 "$TO_SERVER" ls > /dev/null 2>&1
if [ $? -eq 0 ]
then
	exit 0
else
	exit 1
fi
