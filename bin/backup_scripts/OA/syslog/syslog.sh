#!/bin/bash

echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line



date="`date +"%m-%d-%y"`"

oa1="`nslookup atc7000-$1oa1 | grep Address: | grep -v 53 | sed 's/Address: //'`"
oa2="`nslookup atc7000-$1oa2 | grep Address: | grep -v 53 | sed 's/Address: //'`"



if [[ $oa1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
echo $oa1
else
echo "ee"
exit 1
fi




expect <<EOF
set timeout 100
spawn /usr/bin/ssh $2@$oa1 -o StrictHostKeyChecking=no
expect "$2@"
send "$3\r"
expect "*7000-"

send "SET REMOTE SYSLOG SERVER 10.42.34.140\r"


expect "Remote system log"


send "SET REMOTE SYSLOG PORT 514\r"


expect "Remote system log"



send "ENABLE SYSLOG REMOTE\r"


expect "Remote system"





EOF

done







