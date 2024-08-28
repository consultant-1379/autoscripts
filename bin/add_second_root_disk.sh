#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -p PREFIX"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$PREFIX" ]]
        then
                echo "ERROR: You must say what the prefix of the node is"
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

while getopts "m:c:p:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	p) PREFIX="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions
if [[ -f /ericsson/dmr/etc/dm_define ]]
then
	echo "INFO: Mirror definition already found, please delete /ericsson/dmr/etc/dm_define if you wish to redefine"
	exit 0
fi

if [[ "$PREFIX" == "ADM1" ]]
then
	OTHER_NODE_PREFIX="ADM2"
else
	OTHER_NODE_PREFIX="ADM1"
fi

NODE_HOSTNAME=`eval echo \\$${PREFIX}_HOSTNAME`
OTHER_NODE_HOSTNAME=`eval echo \\$${OTHER_NODE_PREFIX}_HOSTNAME`

FIRST_ROOT_NAME=`vxdisk list | grep -v DEVICE | grep SVM | awk '{print $1}'`
FIRST_ROOT_C=`echo $FIRST_ROOT_NAME |  awk '{split($0,a,"c"); print a[2]}' | awk '{split($0,a,"t"); print a[1]'}`
FIRST_ROOT_T=`echo $FIRST_ROOT_NAME | awk '{split($0,a,"t"); print a[2]}' | awk '{split($0,a,"d"); print a[1]'}`
SECOND_ROOT_T=`expr $FIRST_ROOT_T + 1`
SECOND_ROOT_NAME="c${FIRST_ROOT_C}t${SECOND_ROOT_T}d0s2"
if [[ `vxdisk list | grep -v DEVICE | grep $SECOND_ROOT_NAME` ]]
then
	echo "INFO: Using $SECOND_ROOT_NAME as 2nd root DISK"
else
	echo "ERROR: cannot get 2nd root disk"
	exit 1
fi
TMP_DMR_FILE=/tmp/dmr_{$OTHER_NODE_HOSTNAME}_config
ssh -qt $OTHER_NODE_HOSTNAME /ericsson/dmr/bin/dmtool s d > $TMP_DMR_FILE
DISK2=`egrep " disk2 " $TMP_DMR_FILE | awk '{print $1}'`
DISK3=`egrep " disk3 " $TMP_DMR_FILE | awk '{print $1}'`
DISK2MIRR=`egrep " disk2mirr " $TMP_DMR_FILE | awk '{print $1}'`
DISK3MIRR=`egrep " disk3mirr " $TMP_DMR_FILE | awk '{print $1}'`
rm $TMP_DMR_FILE
if [[ -z "`vxdisk list | grep \"$DISK2\"`" ]]
then
	echo "ERROR: disk2 not found on $NODE_HOSTNAME"
	exit 1
fi
if [[ -z "`vxdisk list | grep \"$DISK3\"`" ]]
then
	echo "ERROR: disk3 not found on $NODE_HOSTNAME"
	exit 1
fi
if [[ -z "`vxdisk list | grep \"$DISK2MIRR\"`" ]]
then
	echo "ERROR: disk2mirr not found on $NODE_HOSTNAME"
	exit 1
fi
if [[ -z "`vxdisk list | grep \"$DISK3MIRR\"`" ]]
then
	echo "ERROR: disk3mirr not found on $NODE_HOSTNAME"
	exit 1
fi

$EXPECT - <<EOF
                        set force_conservative 1
                        set timeout 120

                        # autologin variables
                        set prompt ".*(%|#|\\$|>):? $"
			set stty_init "rows 10000"
                        spawn /ericsson/dmr/bin/dmtool s s
                        while 1 {
                            expect {
                                "How many mirrors should be defined" 
								{ 
									send "2\r"
								}
								"Continue (y/n)"
								{
									send "y\r"
								}
								"Are data disks OK" 
								{ 
									send "y\r"
								}
                                "Is this a good mirror definition" 
								{ 
									send "y\r"
								}
								"Enter ROOT disk for Mirror 1" 
								{
									while 1 {
										expect {
											"More"
											{
												send "q\r"
											}
											"Enter selection"
											{ 
												send "$FIRST_ROOT_NAME\r" 
												break
											}
										}
									}
								}
								"Enter all DATA disks for Mirror 1" 
								{
									while 1 {
										expect {
											"More"
											{
												send "q\r"
											}
											"Enter selection" 
											{ 
												send "$DISK2 $DISK3\r" 
												break
											}
										}
									}
								}
								"Enter ROOT disk for Mirror 2" 
								{
									while 1 {
										expect {
											"More"
											{
												send "q\r"
											}
											"Enter selection" 
											{ 
												send "$SECOND_ROOT_NAME\r" 
												break
											}
										}
									}
                                }
								"Enter all DATA disks for Mirror 2" 
								{
									while 1 {
										expect {
											"More"
											{
												send "q\r"
											}
											"Enter selection" 
											{ 
												send "$DISK2MIRR $DISK3MIRR\r" 
												break
											}
										}
									}
								}
								"Is this correct (y/n)"
								{
									send "y\r"
								}
                                eof {break}
                            }
                        }
EOF


$EXPECT - <<EOF
set force_conservative 1
set timeout -1

set stty_init "rows 10000"
spawn /ericsson/dmr/bin/dmtool ro a
	while {"1" == "1"} {
	expect {
		"Enter disk to add as a root disk" {
			send "$SECOND_ROOT_NAME\r"
		}
		"Problem deleting meta device" {
			exit 1
		}
		"Continue" {
			send "y\r"
		}
		"Installing GRUB"
                {
			expect "stage2" {
				sleep 30
				exit 0
			}
                }
		eof
		{
			exit 0
		}
	}
}
EOF

if [[ $? -ne 0 ]]
then
	exit 1
fi

/ericsson/dmr/bin/dmtool m 2
