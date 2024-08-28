#!/bin/bash

function check_args()
{
	if [[ ! -z "$OPTION" ]] && [[ "$OPTION" == "ok" ]]
        then
		exit 0
        fi
}


ARGS=`getopt -o "t:" -l "test:" -n "$0" -- "$@"`
if [[ $? -ne 0 ]]
then
        exit 1
fi

eval set -- $ARGS

while true;
do
        case "$1" in
		-t|--test)
			OPTION="$2"
			shift 2;;
		--)
                        shift
			break;;
        esac
done

check_args
exit 1
