#!/bin/bash

LOCAL_IP_ADDRESS=`host $HOSTNAME | awk '{print $4}'`
ifconfig -a | grep -i "inet6 " | grep "Scope:Global" | awk '{print $3}' | sort -u | awk -F\/ '{print $1}' > /tmp/ipv6_address_cache.txt
ifconfig -a | grep -i "inet " | awk '{print $2}' | awk -F: '{print $2}' | sort -ut. -k1,1 -k2,2n -k3,3n -k4,4n |  grep -v "127.0.0.1" | grep -v "^$LOCAL_IP_ADDRESS$" > /tmp/ipv4_address_cache.txt
