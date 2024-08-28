#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG -o MWS_IP -p PREFIX -f FORCE"
        exit 1
}
check_args()
{
        if [[ -z "$MOUNTPOINT" ]]
        then
                echo "ERROR: You must say where the mountpoint is"
                exit 1
        fi
	if [[ -z "$MWS_IP" ]]
        then
                echo "ERROR: You must give an MWS ip using -o"
                exit 1
        fi
	if [[ -z "$PREFIX" ]]
        then
                echo "ERROR: You must give an prefix using -p"
                exit 1
        fi
	if [[ -z "$FORCE" ]]
        then
                echo "ERROR: You must give a force option using -f"
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

while getopts "m:c:p:o:f:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
	c) CONFIG="$OPTARG"
	;;
	o) MWS_IP="$OPTARG"
	;;
	p) PREFIX="$OPTARG"
        ;;
	f) FORCE="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args
. $MOUNTPOINT/expect/expect_functions

X_OM_LOC=`eval echo \\$${PREFIX}_OM_LOC`
umount /nh_mount/ > /dev/null 2>&1
mkdir /nh_mount/ > /dev/null 2>&1
mount $MWS_IP:$X_OM_LOC/om/security/ /nh_mount/
if [[ -f /nh_mount/JASScustm.pkg ]]
then
	if [[ -f /tmp/JASScustm.pkg ]]
	then
		rm -rf /tmp/JASScustm.pkg
	fi
	cp /nh_mount/JASScustm.pkg /tmp/
	umount /nh_mount/ > /dev/null 2>&1
	rm -rf /sw_mount/ > /dev/null 2>&1

	INSTALLED_VERSION_INFO=`pkginfo -l JASScustm 2>&1 | grep VERSION`
	if [[ $? -eq 0 ]]
	then
		INSTALLED_ALREADY="yes"
	else
		INSTALLED_ALREADY="no"
	fi
	MOUNTED_VERSION_INFO=`pkginfo -l -d /tmp/JASScustm.pkg 2>&1 | grep VERSION`
	if [[ "$FORCE" == "yes" ]] || [[ "$INSTALLED_VERSION_INFO" != "$MOUNTED_VERSION_INFO" ]]
	then
		if [[ "$INSTALLED_ALREADY" == "yes" ]]
		then
			echo "Removing old JASScustm.pkg package"
			$EXPECT - <<EOF
			        set force_conservative 1
			        set timeout -1
			
			        spawn /usr/sbin/pkgrm JASScustm
			        while {"1" == "1"} {
			        expect {
			                "Do you want to remove this package"
			                {
			                        sleep 1
			                        send "y\r"
			                }
					"Do you want to continue with the removal of this package"
					{
						sleep 1
			                        send "y\r"
					}
			                eof
			                {
			                        catch wait result
			                        exit [lindex \$result 3]
			                }
		        	}
EOF
			if [[ $? -ne 0 ]]
			then
				echo "ERROR: Something went wrong uninstalling the old version of JASScustm.pkg, see above"
				exit 1
			fi
		fi

		echo "Installing the new package"
		$EXPECT - <<EOF
		        set force_conservative 1
		        set timeout -1
		
		        spawn /usr/sbin/pkgadd -d /tmp/JASScustm.pkg
		        while {"1" == "1"} {
		        expect {
		                "Select package"
		                {
					sleep 1
					send "\r"
		                }
				"Do you want to continue with the installation of"
				{
					sleep 1
					send "y\r"
				}
		                eof
		                {
		                        catch wait result
		                        exit [lindex \$result 3]
		                }
		        }
EOF

	else
		echo "The correct version of JASScustm.pkg is already installed, not forcibly reinstalling it"
		exit 123
	fi

	EXIT_CODE=$?

	if [[ $EXIT_CODE -ne 0 ]]
	then
	        echo "ERROR: Installation of node hardening package didn't complete successfully, please check output above"
	        exit 1
	fi

else
	echo "ERROR: Couldn't find JASScustm.pkg on the O&M DVD, maybe we couldn't mount the directory from the MWS"
	exit 1
fi

echo "Applying node hardening"
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1

        spawn /opt/SUNWjass/bin/eric-hardening-apply.sh
        while {"1" == "1"} {
        expect {
		"Are you sure that you want to continue"
		{
                        sleep 1
                        send "yes\r"
                }
                eof
                {
                        catch wait result
                        exit [lindex \$result 3]
                }
        }
EOF
EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]
then
	echo "ERROR: Enabling of node hardening didn't complete successfully, please check output above"
	exit 1
fi

echo "INFO: Disabling password ageing after node hardening"

BOOTARGS=/ericsson/config/bootargs
OSS_ID=system
OMSERVM_ID=om_serv_master
OMSERVS_ID=om_serv_slave
NEDSS_ID=smrs_slave

if [ -f $BOOTARGS ]
then
    #Decide what server the script is being run on
    SERVER_TYPE=$(grep config= $BOOTARGS | sed 's/^.*config=//g' | sed 's/ .*//g')

    if [[ $SERVER_TYPE == $OSS_ID||$SERVER_TYPE == $OMSERVM_ID||$SERVER_TYPE == $OMSERVS_ID||$SERVER_TYPE == $NEDSS_ID ]]
    then
        #Disable password ageing for extra users based on server type
        case $SERVER_TYPE in
            $OSS_ID)
                echo "INFO: Server type is ossmaster"
                passwd -x -1 -u sybase
                passwd -x -1 -u ossftp
                passwd -x -1 -u storadm
                passwd -x -1 -u storobs
                ;;
            $OMSERVM_ID|$OMSERVS_ID)
                echo "INFO: Server type is omserv_master | omserv_slave"
                passwd -x -1 -u scsuser
                passwd -x -1 -u neuser
                ;;
            $NEDSS_ID)
                echo "INFO: Server type is smrs_slave/nedss"
                ;;
        esac

        #Get the list of SMRS users
        SMRS_USERS=$(egrep -e "WRAN|GRAN|LRAN|CORE" /etc/passwd | sed s/:.*$//g)

        #Disable password ageing for SMRS users
        for SMRS_USER in $SMRS_USERS
        do
            passwd -x -1 -u $SMRS_USER
        done
        echo "INFO: Finished disabling password ageing after node hardening"
    else
        echo "INFO: Inapplicable server \"${SERVER_TYPE}\""
    fi
else
    echo "INFO: Couldn't determine server type. Password ageing won't be disabled as inapplicable server assumed"
fi

echo "Rebooting"
init 6
