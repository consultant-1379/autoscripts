PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
#echo "Type paramter:"
counter=$1
#read counter

#echo enter file name
#  read fname

#   exec<$fname
#   value=0
#while read line

cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vclist.txt" | while read line
do



set $line
vc1="`/usr/bin/nslookup atc7000-$1vc1 | /bin/grep Address: | grep -v 53 | /bin/sed 's/Address: //'`"
vc2="`/usr/bin/nslookup atc7000-$1vc2 | /bin/grep Address: | grep -v 53 | /bin/sed 's/Address: //'`"



if [[ $vc1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
ttt=3
else
echo "ee"
exit 1
fi

exec &>> /tmp/no$1.txt
/usr/bin/snmpwalk -v 1 -c public $vc1 $counter | /bin/awk '{print $4}' | /usr/bin/tee vc1no$1.txt
/usr/bin/snmpwalk -v 1 -c public $vc2 $counter | /bin/awk '{print $4}' | /usr/bin/tee vc2no$1.txt

/usr/bin/paste vc1no$1.txt vc1sno$1.txt > vc1nut$1.txt
/usr/bin/paste vc2no$1.txt vc2sno$1.txt > vc2nut$1.txt

/usr/bin/tail -n +4 vc2nut$1.txt | /usr/bin/tee vc2nu$1.txt
/usr/bin/tail -n +4 vc1nut$1.txt | /usr/bin/tee vc1nu$1.txt



done
