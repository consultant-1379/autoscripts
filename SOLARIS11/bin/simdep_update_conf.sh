#!/bin/bash

#env variables
scriptName=`basename $0`

SIMDEP_CONF_FILE_PATH=/var/simnet/simdep/conf/
SIMDEP_CONF_FILE_NAME="conf.txt"
SIMDEP_CONF_FILE=${SIMDEP_CONF_FILE_PATH}$SIMDEP_CONF_FILE_NAME

# Colors
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

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

while getopts "c:m:f:" arg
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


function message ()
{

        local MESSAGE="$1"
        local TYPE=$2

        COLOR=$white
        if [[ "$TYPE" == "ERROR" ]]
        then
                COLOR=$red
        fi
        if [[ "$TYPE" == "LINE" ]]
        then
                COLOR=$magenta
        fi
        if [[ "$TYPE" == "WARNING" ]]
        then
                COLOR=$yellow
        fi
        if [[ "$TYPE" == "SUMMARY" ]]
        then
                COLOR=$green
        fi
        if [[ "$TYPE" == "SCRIPT" ]]
        then
                COLOR=$cyan
        fi
        if [[ `echo "$MESSAGE" | egrep "^INFO:|^ERROR:|^WARNING:"` ]]
        then
                local FORMATTED_DATE="`date | awk '{print $2 "_" $3}'`"
                local FORMATTED_TIME="`date | awk '{print $4}'`"
                MESSAGE="[$FORMATTED_DATE $FORMATTED_TIME] $MESSAGE"
        fi
        echo -en $COLOR
        echo -en "$MESSAGE"
        echo -en $white

}

function change_line ()
{
    local OLD_LINE=$1
    local NEW_LINE=$2

    sed -i '/\(^'$OLD_LINE'\)/c\\'$NEW_LINE'' $SIMDEP_CONF_FILE
}

message "INFO:-$scriptName ..starting execution of $scriptName \n" INFO

if [[ ! -s $SIMDEP_CONF_FILE ]]
then
    message "ERROR:-$scriptName: $SIMDEP_CONF_FILE does not exist \n" ERROR
    message "ERROR:-$scriptName: exiting with code (123)\n" ERROR
    exit 123;
fi


if [[ ! -z $ROLLOUT_LTE ]]
then
    message "INFO:-$scriptName: ROLLOUT_LTE variable is set in cloud config \n" INFO
    message "INFO:-$scriptName: Overriding default value to ROLLOUT_LTE=$ROLLOUT_LTE \n" INFO
    change_line "ROLLOUT_LTE" "ROLLOUT_LTE=$ROLLOUT_LTE"
#else
#    echo "ROLLOUT_LTE=$ROLLOUT_LTE"
fi

if [[ ! -z $ROLLOUT_WRAN ]]
then
    message "INFO:-$scriptName: ROLLOUT_WRAN variable is set in cloud config \n" INFO
    message "INFO:-$scriptName: Overriding default value to ROLLOUT_WRAN=$ROLLOUT_WRAN \n" INFO
    change_line "ROLLOUT_WRAN" "ROLLOUT_WRAN=$ROLLOUT_WRAN"
fi

if [[ ! -z $ROLLOUT_GRAN ]]
then
    message "INFO:-$scriptName: ROLLOUT_GRAN variable is set in cloud config \n" INFO
    message "INFO:-$scriptName: Overriding default value to ROLLOUT_GRAN=$ROLLOUT_GRAN \n" INFO
    change_line "ROLLOUT_GRAN" "ROLLOUT_GRAN=$ROLLOUT_GRAN"
fi

if [[ ! -z $ROLLOUT_CORE ]]
then
    message "INFO:-$scriptName: ROLLOUT_CORE variable is set in cloud config \n" INFO
    message "INFO:-$scriptName: Overriding default value to ROLLOUT_CORE=$ROLLOUT_CORE \n" INFO
    change_line "ROLLOUT_CORE" "ROLLOUT_CORE=$ROLLOUT_CORE"
fi

if [[ ! -z $ROLLOUT_PICO ]]
then
    message "INFO:-$scriptName: ROLLOUT_PICO variable is set in cloud config \n" INFO
    message "INFO:-$scriptName: Overriding default value to ROLLOUT_PICO=$ROLLOUT_PICO \n" INFO
    change_line "ROLLOUT_PICO" "ROLLOUT_PICO=$ROLLOUT_PICO"
fi

message "INFO:-$scriptName: ..ended execution of $scriptName \n" INFO

