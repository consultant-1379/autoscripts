#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -m MOUNTPOINT -c CONFIG"
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

	if [[ -z "$PARAMETER" ]]
        then
                echo "ERROR: You must set the parameter using -p parameter"
                exit 1
        fi
	if [[ -z "$VALUE" ]]
        then
                echo "ERROR: You must set the value using -v value"
                exit 1
        fi
}

while getopts "m:c:p:v:" arg
do
    case $arg in
        m) MOUNTPOINT="$OPTARG"
        ;;
        c) CONFIG="$OPTARG"
        ;;
	p) PARAMETER="$OPTARG"
	;;
	v) VALUE="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args


# Variables and constants
SPECIAL="_+_+_+"
PROMPTS_ALLOWED=20

DOMAIN="dc=`echo "$LDAPDOMAIN" | sed 's/\./,dc=/g'`"

# Create the temporary ldif file	
if pgrep ns-slapd > /dev/null; then

echo "dn: cn=SecurityPolicy,$DOMAIN
changetype: modify
replace: ${PARAMETER}
${PARAMETER}: ${VALUE}" > /tmp/${HOSTNAME}_temp.ldif

cat  /tmp/${HOSTNAME}_temp.ldif
ldapmodify -D 'cn=directory manager' -a -v -f  /tmp/${HOSTNAME}_temp.ldif -w $ns_data_migration_pass

exit_code=$?
rm /tmp/${HOSTNAME}_temp.ldif
if [[ $exit_code -ne 0 ]]
then
	echo "ERROR: Something went wrong running the ldapmodify"
fi
exit $exit_code

else

if [[ $PARAMETER != "ds-cfg-min-password-length" ]]; then

echo $ns_data_migration_pass > /tmp/${HOSTNAME}_temp.ldif
/opt/opendj/bin/dsconfig set-password-policy-prop --port 4444 --bindDN "cn=Directory Manager" --bindPasswordFile /tmp/${HOSTNAME}_temp.ldif --policy-name "$LDAPDOMAIN Password Policy" --set ${PARAMETER}:${VALUE} --trustAll --no-prompt 
exit_code=$?
rm /tmp/${HOSTNAME}_temp.ldif

else

echo "dn: cn=$LDAPDOMAIN Length-Based Password Validator,cn=Password Validators,cn=config
changetype: modify
replace: ${PARAMETER}
${PARAMETER}: ${VALUE}" > /tmp/${HOSTNAME}_temp1.ldif
ldapmodify -D 'cn=directory manager' -a -v -f  /tmp/${HOSTNAME}_temp1.ldif -w $ns_data_migration_pass
exit_code=$?
rm /tmp/${HOSTNAME}_temp1.ldif
fi

if [[ $exit_code -ne 0 ]]
then
        echo "ERROR: Something went wrong running the ldapmodify"
fi
exit $exit_code

 
fi
