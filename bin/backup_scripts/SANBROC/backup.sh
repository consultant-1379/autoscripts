#!/bin/bash
#echo enter file name
#  read fname

#   exec<$fname
#   value=0
#while read line
#do

#set $line

chass=$1
user=$2
pass=$3

date="`date +"%m-%d-%y"`"


sanip="`nslookup atds300b-$chass | grep Address: | grep -v 53 | sed 's/Address: //'`"


if [[ $sanip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
#echo $sanip
#else
#echo "ee"
#fi



/usr/bin/expect <<EOF


spawn /usr/bin/ssh $user@$sanip -o StrictHostKeyChecking=no
expect "$2@"
send "$pass\r"
expect "Use Control-C"
send "\r"
expect "at"
send "configupload\r"
expect "Protocol" 
send "\r"
expect "Server"
send "10.42.34.68\r"
expect "User Name"
send "root\r" 
expect "Path/Filename"
send "../tmp/backup/atds300b$chass-$date\r"
expect "Section"
send "\r"
expect "Password"
send "shroot12\r"
expect "configUpload complete"
EOF
else
exit 1

fi


#done


