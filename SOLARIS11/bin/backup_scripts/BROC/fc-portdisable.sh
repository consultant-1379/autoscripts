#!/bin/bash -x
#echo enter file name
#  read fname
cat shortlist.txt | while read line
do

        chass=`echo "$line" | awk '{print $1}'`
        user=`echo "$line" | awk '{print $2}'`
        pass=`echo "$line" | awk '{print $3}'`

sanip="`nslookup atc7000-$chass$san | grep Address: | grep -v 53 | sed 's/Address: //'`"

done

if [[ $sanip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
echo $sanip
#else
#echo "ee"
#fi


test=1
/usr/bin/expect <<EOF


spawn /usr/bin/ssh $user@$sanip -o StrictHostKeyChecking=no
expect "$2@"
send "$pass\r"
expect "Use Control-C"
send "\r"
expect "atc7000-"
send "portdisable 20-23 0\r"
expect "atc7000-"
EOF
else
test=1


fi

done
if [[ $test == 0 ]]
then
exit 1
else
exit 0
fi

#done
