#!/bin/bash


ILO_HOSTNAME=atc7000-12b1ilo.athtem.eei.ericsson.se
ILO_USERNAME=root
ILO_PASSWORD=shroot12

ILO_PROMPT="->"

BOOT_DEVICE=5

expect << EOF
set force_conservative 1
set timeout 60


spawn ssh -o StrictHostKeyChecking=no -l $ILO_USERNAME $ILO_HOSTNAME

while 1 {
expect {
        "assword:" {
                send "$ILO_PASSWORD\r"
        }
	-re $ILO_PROMPT {
		send "set /system1/bootconfig1/bootsource${BOOT_DEVICE} bootorder=1\r"
		expect {
			"COMMAND COMPLETED"
			{
				exit 0
			}
			-re $ILO_PROMPT
			{
				exit 1
			}
			"FAILED"
			{
				exit 1
			}
			timeout
			{
				exit 1
			}
		}
	}
        eof {
		exit 1
        }
        timeout {
                send_user "Timed out\n"
                exit 1
        }
}
}
EOF

