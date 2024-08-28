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
output=$(sed -e "/atesx$server/b" -e d /tmp/stor$1.txt) 


if [ "$output" == "" ] 
then

test=1 

else

output=$(sed -n -e '/'atesx$server'/{N;N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 1')
findA=$(sed -n -e '/'atesx$server'/{N;N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Port 2')
findb=$(sed -n -e '/'atesx$server'/{N;p;}' /tmp/stor$1.txt | grep -v 'Server Name' | grep 'Ethernet FlexNIC') 



srvfnd=$srvfnd+1
#echo $srvfnd

if [[ ! "$output" =~ "50:01" ]]
then



echo ""atesx"$server"\;""chassis"$chassis"{***HBA not found ***}""

output3=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output3" == "" ]
          then

echo ""atesx"$server"{***BROCADE not found ***}""

     fi 

else






output2=$(sed -e /BROCADE/b -e d /tmp/stor$1.txt)
      if [ "$output2" == "" ]
          then
echo ""atesx"$server"{***BROCADE not found ***}""
else







out=""atesx"$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;"$findb" 
echo  $out

fi

fi

fi







done






if [[ ! $srvfnd == 0 ]] 
then
test=2

else
echo ""atesx"$server"{***Server not found ***}""


fi


done






