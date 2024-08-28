#!/bin/bash


echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line


exec &>> /tmp/capture$1.txt

#exec 3<>/tmp/capture$1.txt


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




/usr/bin/expect <<EOF

spawn /usr/bin/ssh $2@$oa1 -o StrictHostKeyChecking=no
expect "$2@"
send "$3\r"
expect "atc7000-"

send "show interconnect list\r"
expect "Totals" 



spawn /usr/bin/ssh $2@$oa1 -o StrictHostKeyChecking=no
expect "$2@"
send "$3\r"
expect "atc7000-"

send "show server info all\r"
expect "atc700-oa$1>" 

exit 0

#sed -e '/BROCADE/b' -e '/Server Blade/b' -e '/Port 1/b' -e d /tmp/capture$1.txt | tee /tmp/stor$1.txt

EOF
exec &>-
sed -e '/BROCADE/b' -e '/Server Blade/b' -e '/Server Name/b' -e '/Ethernet FlexNIC LOM:1-a/b' -e '/Port 1/b' -e '/Port 2/b' -e d /tmp/capture$1.txt | dos2unix | tee /tmp/stor$1.txt

done






