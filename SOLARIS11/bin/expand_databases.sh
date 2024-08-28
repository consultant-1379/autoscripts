#!/bin/bash

if [[ `/opt/ericsson/sck/bin/config_ossrc_server -h | grep "\-UTRAN"` ]]
then
	/opt/ericsson/sck/bin/config_ossrc_server -a -utran 0 -gsm 0 -core 0 -lte 0 -irat 0 -f
else
	/opt/ericsson/sck/bin/config_ossrc_server -a -U 0 -G 0 -C 0 -L 0 -i 0 -F
fi
