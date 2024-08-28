#!/usr/bin/expect -f
set timeout -1
spawn /opt/ERICddc/bin/installRemote -t NETSIM -h netsim -i
expect "Enter root password for netsim:"
send "shroot\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t UAS -h uas1
expect "Enter root password for uas1:"
send "shroot12\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t EBAS -h ebas
expect "Enter root password for ebas:"
send "shroot12\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t NEDSS -h nedss
expect "Enter root password for nedss:"
send "shroot12\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t OTHER -h omsas
expect "Enter root password for omsas:"
send "shroot12\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t OTHER -h omsrvm
expect "Enter root password for omsrvm:"
send "shroot12\r"
expect "root@ossmaster"

spawn /opt/ERICddc/bin/installRemote -t OTHER -h omsrvs
expect "Enter root password for omsrvs:"
send "shroot12\r"
expect "root@ossmaster"
