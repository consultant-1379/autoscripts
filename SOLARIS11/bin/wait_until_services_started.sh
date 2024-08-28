#!/bin/bash
while [[ `svcs -a | grep "\*" | grep -v eric_bootstrap_wrapper` ]]
#while [[ `svcs -xv | grep "/milestone/multi-user"` ]]
do
        sleep 1
done

#while [[ `svcs -x | grep State | grep -v disabled` ]]
#do
#	sleep 1
#done
