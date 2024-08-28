#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -i INPUT_CHOICE"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$INPUT_CHOICE" ]]
        then
                echo "ERROR: You must give an input choice using -i"
                exit 1
        fi
	if [[ -z "$SECOND_CHOICE" ]]
        then
                echo "ERROR: You must give a second input choice using -s"
                exit 1
        fi
	if [[ -z "$MWS_IP" ]]
        then
                echo "ERROR: You must give an MWS ip using -o"
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

while getopts "m:c:i:s:o:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	i) INPUT_CHOICE="$OPTARG"
	;;
	s) SECOND_CHOICE="$OPTARG"
	;;
	c) CONFIG="$OPTARG"
	;;
	o) MWS_IP="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

umount /sw_mount/ > /dev/null 2>&1
mkdir /sw_mount/ > /dev/null 2>&1
mount $MWS_IP:$OMSAS_MEDIA/omsas_base_sw/ /sw_mount/
if [[ -f /sw_mount/bin/install.sh ]]
then
	$EXPECT - <<EOF
	set force_conservative 1
	set timeout -1

	spawn /sw_mount/bin/install.sh
	while {"1" == "1"} {
	expect {
		"please enter one of the specified alternatives exactly as shown"
		{
			expect "Choose one:" {
	                        send "$SECOND_CHOICE\r"
                	}
		}
		"Choose one:"
		{
			send "$INPUT_CHOICE\r"
		}
		"Do you want to install all new packages"
		{
			send "y\r"
		}
		"nstall the new version"
		{
			send "y\r"
		}
		eof
		{
			catch wait result
	                exit [lindex \$result 3]
		}
	}
EOF

	EXIT_CODE=$?
	umount /sw_mount/ > /dev/null 2>&1
	rm -rf /sw_mount/ > /dev/null 2>&1

	if [[ $EXIT_CODE -ne 0 ]]
	then
	        echo "ERROR: Security installation didn't complete successfully, please check output above"
	        exit 1
	fi

else
	echo "ERROR: Couldn't find install.sh, maybe we couldn't mount the directory from the MWS"
	exit 1
fi
