PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#echo "" > vclog.txt
cp /dev/null /export/scripts/CLOUD/bin/misc/networkmonitor/vclog.txt
cp /dev/null /export/scripts/CLOUD/bin/misc/networkmonitor/alarmlog.txt



echo "  vc | d1  |  d2 | d3  |  d4 | d5  | d6  |  d7 | d8  | d9  | d10 | d11 | d12 | d13 | d14 | d15 | d16 | x1  | x2  | x3  | x4  | x5  | x6  | x7  | x8" 
#echo enter file name
#  read fname
#   exec<$fname

counter=$1
threshold=$2



/export/scripts/CLOUD/bin/misc/networkmonitor/snmp1.sh $counter

sleep 10

/export/scripts/CLOUD/bin/misc/networkmonitor/snmp2.sh $counter


cat /export/scripts/CLOUD/bin/misc/networkmonitor/vclist.txt | while read line 
do
set $line

if [ "$line" == "" ]
then
test=1

#/export/scripts/CLOUD/bin/misc/networkmonitor/calc.sh $1
else
echo 
/export/scripts/CLOUD/bin/misc/networkmonitor/calc.sh $1 $threshold
fi

done

#cat vclog.txt | sendmail -t ray.clarke@ericsson.com

cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vclog.txt" | while read line
do
set $line
#echo $2
#echo $3
pos=#$3
#echo $pos
string="Server Blade $pos"
#echo $string

blade=$(sed -n -e  "/$string/{N;N;p;}" /tmp/stor$2.txt | grep 'Server Name')

echo $1 $2 $3 $4 $blade >> /export/scripts/CLOUD/bin/misc/networkmonitor/alarmlog.txt

done

cat /export/scripts/CLOUD/bin/misc/networkmonitor/alarmlog.txt | sendmail -t ray.clarke@ericsson.com,conor.ryan@ericsson.com
