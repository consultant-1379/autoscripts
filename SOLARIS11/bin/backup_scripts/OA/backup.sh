#!/bin/bash



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
expect "atc7000-"

send "upload config ftp://root:shroot12@10.42.34.68/tmp/backup/oa$1_$date\r"
expect {

 "Successfully uploaded" {
exit 0

}
timeout {
        send_user "I timed out\n"
}                                        }



spawn /usr/bin/ssh $2@$oa2 -o StrictHostKeyChecking=no
expect "$2@"
send "$3\r"
expect "atc7000-"

send "upload config ftp://root:shroot12@10.42.34.68/tmp/backup/oa$1_$date\r"


expect {

 "Successfully uploaded" {
exit 0

}
timeout {
        send_user "I timed out\n"
exit 1

}                                        }



EOF









