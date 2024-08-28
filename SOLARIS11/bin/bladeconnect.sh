#!/bin/bash


ILO_HOSTNAME=atc7000-12b1ilo.athtem.eei.ericsson.se
ILO_USERNAME=root
ILO_PASSWORD=shroot12

ILO_PROMPT="->"

expect << EOF
set force_conservative 1
set timeout 60


spawn ssh -o StrictHostKeyChecking=no -l $ILO_USERNAME $ILO_HOSTNAME

while 1 {
expect {
        "assword:" {
                send "$ILO_PASS\r"
        }
	-re $ILO_PROMPT {
		send "stop /system1/oemhp_vsp1\r"
		expect {
			-re $ILO_PROMPT
			{
				set timeout -1
				send_user "vsp\r"
				expect {
					"Requested service is unavailable, it is already in use by a different client."
					{
						send_user "\nERROR: Couldn't get access to the virtual serial port\n"
						exit 1
					}
				}
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

