#!/bin/bash


echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line


exec &>> /tmp/MACcapture$1.txt

#exec 3<>/tmp/MACcapture$1.txt


date="`date +"%m-%d-%y"`"

vc1="`nslookup atc7000-$1vc1 | grep Address: | grep -v 53 | sed 's/Address: //'`"
vc2="`nslookup atc7000-$1vc2 | grep Address: | grep -v 53 | sed 's/Address: //'`"



if [[ $vc1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
echo $vc1
else
echo "ee"
exit 1
fi




/usr/bin/expect <<EOF

spawn /usr/bin/ssh $2@$vc1 -o StrictHostKeyChecking=no
expect "Password"
send "$3\r"
expect "'->'"

send "show interconnect-mac-table enc0:1\r"
expect "'->'" 


send "show interconnect-mac-table enc0:2\r"
expect "'->'" 


exit 0

#sed -e '/BROCADE/b' -e '/Server Blade/b' -e '/Port 1/b' -e d /tmp/capture$1.txt | tee /tmp/stor$1.txt

EOF
exec &>-
cat /tmp/MACcapture$1.txt | dos2unix | grep -v '(lag)' | tee /tmp/MACstor$1.txt

done






