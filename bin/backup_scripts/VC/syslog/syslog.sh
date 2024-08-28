#!/bin/bash


echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line




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




expect <<EOF
set timeout 20 
spawn /usr/bin/ssh $2@$vc1 -o StrictHostKeyChecking=no
expect "Password"
send "$3\r"
expect {

"'->'"
{
}
"Please use"
{
}

timeout {
        send_user "I timed out\n"

}
}

send "add log-target Destination=10.42.34.140 Severity=Warning Transport=UDP Port=514 Security=None Format=RFC3164 State=Enabled\r"

expect {

 "SUCCESS" {
exit 0

}
timeout {
        send_user "I timed out\n"
}                                        }





spawn /usr/bin/ssh $2@$vc2 -o StrictHostKeyChecking=no
expect "Password"
send "$3\r"
expect "'->'"

send "add log-target Destination=10.42.34.140 Severity=Warning Transport=UDP Port=514 Security=None Format=RFC3164 State=Enabled\r"
expect {

 "SUCCESS" {
exit 0


}
timeout {
        send_user "I timed out\n"
exit 1

}                                        }



EOF

done







