#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT"
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

while getopts "m:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions


        cd /
        if [[ `/opt/ericsson/saoss/bin/security.ksh -settings | grep "Currently set to ON"` ]]
        then
                echo "OK: Security is already on"
		exit 0
        else
		if [[ ! -f /ericsson/config/ossrc.p12 ]]
		then
			echo "ERROR: The /ericsson/config/ossrc.p12 file must exist before enabling security"
			exit 1
		fi

output=$($EXPECT - <<EOF
set force_conservative 1
set timeout 160
set prompt ".*(%|#|\\$|>):? $"

spawn /opt/ericsson/saoss/bin/security.ksh -change
while 1 {
        expect {
                "Proceed?" {send "y\r"}
        eof { break }
}
EOF
)
		sleep 5
echo above
/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs
                /opt/ericsson/nms_cif_sm/bin/smtool progress
	/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs
		# Waiting for smtool to become unavailable"

		SMTOOL_TIMEOUT=10
                SMTOOL_ATTEMPTS=120
                echo "INFO: Waiting for smtool to become unavailable"
                # Check is OSS up by doing smtool prog and checking return code
                SMTOOL_WORKING=0
                while [[ $SMTOOL_WORKING -ne 1 && $TRY_NO -lt $SMTOOL_ATTEMPTS ]]
                do

                        smout="`/opt/ericsson/nms_cif_sm/bin/smtool list 2>/dev/null`"
                        if [[ $? -eq 0 ]]
                        then
                                sleep $SMTOOL_TIMEOUT
                                TRY_NO=$(( $TRY_NO+1 ))
                        else
                                SMTOOL_WORKING=1
                        fi
                done

                if [[ "$SMTOOL_WORKING" -ne 1 ]]
                then
                        echo "ERROR: Smtool didn't stop responding after $SMTOOL_ATTEMPTS attempts with $SMTOOL_TIMEOUT between each attempt.."
                        exit 1
                fi

		####################################################################################


		SMTOOL_TIMEOUT=10
		SMTOOL_ATTEMPTS=120
		echo "INFO: Waiting for smtool to become available again"
		# Check is OSS up by doing smtool prog and checking return code
		SMTOOL_WORKING=0
		while [[ $SMTOOL_WORKING -ne 1 && $TRY_NO -lt $SMTOOL_ATTEMPTS ]]
		do
		
		        smout="`/opt/ericsson/nms_cif_sm/bin/smtool list 2>/dev/null`"
		        if [[ $? -ne 0 ]]
		        then
		                sleep $SMTOOL_TIMEOUT
		                TRY_NO=$(( $TRY_NO+1 ))
		        else
		                SMTOOL_WORKING=1
		        fi
		done

		if [[ "$SMTOOL_WORKING" -ne 1 ]]
		then
		        echo "ERROR: Smtool didn't respond after $SMTOOL_ATTEMPTS attempts with $SMTOOL_TIMEOUT between each attempt.."
		        exit 1
		fi
echo"below"
/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs
		/opt/ericsson/nms_cif_sm/bin/smtool progress

       		/opt/ericsson/nms_cif_sm/bin/smtool -list | grep scs 
	        /opt/ericsson/saoss/bin/security.ksh -settings

                if [[ `/opt/ericsson/saoss/bin/security.ksh -settings | grep "Currently set to ON"` ]]
                then
			exit 0
                else
			echo "ERROR: It looks like security didn't get enabled for some reason"
			exit 1
                fi
        fi
