#!/bin/bash

 
declare -i srvfnd 

echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line

server=$1
srvfnd=0
#echo $srvfnd
#echo "top"

for line in `cat list.txt`
do
set $line
chassis=$1

output=$(sed -e '/'atesx$server.'/b' -e d /tmp/stor$1.txt) 


if [ "$output" == "" ] 
then

test=1 

else

output=$(sed -n -e '/'atesx$server.'/{N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 1')
output4=$(sed -n -e '/'atesx$server.'/{N;N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 2')




srvfnd=$srvfnd+1
#echo $srvfnd

if [[ ! "$output" =~ "50:01" ]]
then



    echo atesx$server
    echo atc7000-$chassis 
    echo "HBA not found *********************"
    echo "-----------------------------------"

output3=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output3" == "" ]
          then

     echo "BROCADE not found *****************"
    echo  "-----------------------------------"
     fi 

else






output2=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output2" == "" ]
          then
           echo atesx$server 
           echo atc7000-$chassis 
           echo "BROCADE not found******************"
           echo "-----------------------------------"           

else







out= "${server}":"${chassis}":"${output}":"$output4"  
out1=${output}

echo $out
#echo $out1
#    echo  "$chassis" ; echo "$server" 
#    echo   "$output2\c" 
#    echo -n $output  
#    echo -n  $output4

fi

fi

fi







done






if [[ ! $srvfnd == 0 ]] 
then
test=2

else

    echo atesx$server
    echo "Server not found*******************"
    echo "-----------------------------------"


fi


done






