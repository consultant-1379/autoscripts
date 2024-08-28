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
output=$(sed -e "/atrcxb$server/b" -e d /tmp/stor$1.txt) 


if [ "$output" == "" ]
then

output=$(sed -e "/atesx$server/b" -e d /tmp/stor$1.txt)
fi


if [ "$output" == "" ] 
then

test=1 

else

output=$(sed -n -e '/'$server'/{N;N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 1')
findA=$(sed -n -e '/'$server'/{N;N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 2')
findb=$(sed -n -e '/'$server'/{N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'LOM:1-a' | sed 's/Ethernet FlexNIC//g') 



srvfnd=$srvfnd+1
#echo $srvfnd

if [[ ! "$output" =~ "50:01" ]]
then



echo "$server"\;""chassis"$chassis"{***HBA not found ***}""

output3=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output3" == "" ]
          then

echo "$server"{***BROCADE not found ***}""

     fi 

else






output2=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output2" == "" ]
          then
echo "$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;""{***BROC not found ***}""
else







out=""atrcxb"$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;"$findb" 
echo  $out

fi

fi

fi







done






if [[ ! $srvfnd == 0 ]] 
then
test=2

else
echo "$server"{***Server not found ***}""


fi


done






