#!/bin/bash

usage_msg()
{
        echo "Usage: $0 -c CONFIG -m MOUNTPOINT -n DB_NAME -d DDEV_SIZE -l LDEV_SIZE -p SQL_DEF_USER_PW"
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

	if [[ -z "$DB_NAME" ]]
        then
                echo "ERROR: You must give the db name using -n name"
                exit 1
        fi
	if [[ -z "$DDEV_SIZE" ]]
        then
                echo "ERROR: You must give the size of ddev using -d size"
                exit 1
        fi
	#if [[ -z "$LDEV_SIZE" ]]
	#then
        #        echo "ERROR: You must give the size of ldev using -l size"
        #        exit 1
        #fi
	if [[ -z "$SYBASE_PASSWORD" ]]
        then
                echo "ERROR: You must set the sybase password using -p password"
                exit 1
        fi
}

while getopts "c:m:n:d:l:p:" arg
do
    case $arg in
        c) CONFIG="$OPTARG"
            ;;
        m) MOUNTPOINT="$OPTARG"
        ;;
	n) DB_NAME="$OPTARG"
	;;
	d) DDEV_SIZE="$OPTARG"
	;;
	l) LDEV_SIZE="$OPTARG"
	;;
	p) SYBASE_PASSWORD="$OPTARG"
	;;
        \?) usage_msg
            exit 1
            ;;
    esac
done

check_args

# Get cap and small of each size
if [[ "$LDEV_SIZE" != "" ]]
then
	LDEV_SIZE_CAP=`echo "$DDEV_SIZE" | tr '[:upper:]' '[:lower:]'`
	LDEV_SIZE_SMALL=`echo "$LDEV_SIZE" | tr '[:upper:]' '[:lower:]'`
	LDEV_NAME="ldev_$DB_NAME"
	/opt/VRTS/bin/qiomkfile -e $LDEV_SIZE_CAP  /ossrc/sybdev/oss/syblog/$LDEV_NAME
	if [[ $? -ne 0 ]]
	then
	        echo "ERROR: There was a problem running qiomkfile, check output above"
	        exit 1
	fi
	LDEV_STRING1="disk resize name=\"$LDEV_NAME\",size=\"$LDEV_SIZE_CAP\"
go"
	LDEV_STRING2="alter database ffaxblrdb log on $LDEV_NAME =\"$LDEV_SIZE_SMALL\""
fi


DDEV_SIZE_CAP=`echo "$DDEV_SIZE" | tr '[:upper:]' '[:lower:]'`
DDEV_SIZE_SMALL=`echo "$DDEV_SIZE" | tr '[:upper:]' '[:lower:]'`
DDEV_NAME="ddev_$DB_NAME"
/opt/VRTS/bin/qiomkfile -e $DDEV_SIZE_CAP  /ossrc/sybdev/oss/sybdata/$DDEV_NAME
if [[ $? -ne 0 ]]
then
	echo "ERROR: There was a problem running qiomkfile, check output above"
	exit 1
fi

ISQL_PATH=`bash -l -c "which isql"`

su - sybase  << INPUT
$ISQL_PATH -Usa -P$SYBASE_PASSWORD <<EOF
disk resize name="$DDEV_NAME",size="$DDEV_SIZE_CAP"  
go
$LDEV_STRING1

alter database ffaxblrdb on $DDEV_NAME ="$DDEV_SIZE_SMALL"
$LDEV_STRING2
EOF
INPUT
