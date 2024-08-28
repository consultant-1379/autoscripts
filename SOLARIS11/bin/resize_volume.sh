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

	if [[ -z "$VOLUME_NAME" ]]
        then
                echo "ERROR: You must give the volume name using -n name"
                exit 1
        fi
	if [[ -z "$VOLUME_SIZE" ]]
        then
                echo "ERROR: You must give the volume size using -s size"
                exit 1
        fi
	if [[ -z "$UNIT_TO_USE" ]]
	then
                echo "ERROR: You must give the unit to use using -u unit"
                exit 1
        fi
}

while getopts "c:m:n:s:u:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	n) VOLUME_NAME="$OPTARG"
	;;
	s) VOLUME_SIZE="$OPTARG"
	;;
	u) UNIT_TO_USE="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

number_of_disk_mirrors=`vxdisk list | awk '{print $3}' | grep disk | grep -c mirr`
if [[ $number_of_disk_mirrors -gt 0 ]]
then
	# Mirrored
	mirror_number="2"
else
	mirror_number="1"
fi
output=$(
$EXPECT - <<EOF

set force_conservative 1
set timeout -1
spawn /ericsson/dmr/bin/dmtool v z
while {true} {
	expect {
		"How many mirrors should be defined" {
			send "$mirror_number\r"
		}
		"Is this a good mirror definition" {
			send "y\r"
		}
		"Is this correct" {
			send "y\r"
		}
		"Continue" {
			send "y\r"
		}
		"Select Volume" {
			send "0\r"
		}
		eof {
			break
		}
	}
}
EOF
)

NUMBER=$(
	echo "$output" | while read line
	do
		if [[ `echo $line | awk '{print $2}'` == "$VOLUME_NAME" ]]
		then
			echo "$line" | awk '{print $1}'
			break
		fi
	done
)

if [[ "$NUMBER" == "" ]]
then
	echo "ERROR: Wasn't able to get the volume number for this volume name"
	echo "$output"
	exit 1
fi


# Do the resize

output=$(
$EXPECT - <<EOF

set force_conservative 1
set timeout -1
spawn /ericsson/dmr/bin/dmtool v z
while {true} {
        expect {
                "How many mirrors should be defined" {
                        send "$mirror_number\r"
                }
                "Is this a good mirror definition" {
                        send "y\r"
                }
                "Is this correct" {
                        send "y\r"
                }
                "Continue" {
                        send "y\r"
                }
                "Select Volume" {
                        send "$NUMBER\r"
                }
		"Unit to use" {
			send "$UNIT_TO_USE\r"
		}
		"Too small" {
                        exit 1
                }
		"Enter new size for" {
			send "$VOLUME_SIZE\r"
		}
		"Confirm new size" {
			send "y\r"
		}
		"Cannot allocate space" {
			exit 1
		}
                eof {
                        break
                }
        }
}
EOF
)
if [[ $? -eq 0 ]]
then
	exit 0
else
	echo "$output"
	exit 1
fi
