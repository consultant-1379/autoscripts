#!/bin/bash

 
declare -i srvfnd 


server=$1
srvfnd=0
#echo $srvfnd
#echo "top"

for line in `cat alist.txt`
do
set $line
chassis=$1
echo $2

echo $chassis

cat /tmp/stor$chassis.txt | 
(
while read line



do



#echo $line

if [[ "$line" =~ "Server Name" ]] 

then
#echo $line
echo $line > /tmp/search.txt

server=$(sed -e '/atesx/b' -e d /tmp/search.txt | awk '{print $3}' | awk '{split($0,array,".")} END{print array[1]}')

#echo $server


if [ "$server" == "" ] 
then

test=1 

else

output=$(sed -n -e '/'$server.'/{N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 1')
findA=$(sed -n -e '/'$server.'/{N;N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 2')
findB=$(sed -n -e '/'$server.'/{N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'LOM:1-a' | sed 's/Ethernet FlexNIC//g')

#echo $output
#echo $findA
#echo $findB


srvfnd=$srvfnd+1
#echo $srvfnd

if [[ ! "$output" =~ "50:01" ]]
then



echo "$server"\;""chassis"$chassis"{***HBA not found ***}""

output3=$(sed -e /BROCADE/b -e d /tmp/stor$chassis.txt)
      if [ "$output3" == "" ]
          then

echo "$server"{***BROCADE not found ***}""

     fi 

else






output2=$(sed -e /BROCADE/b -e d /tmp/stor$chassis.txt)
      if [ "$output2" == "" ]
          then
echo "$server"{***BROCADE not found ***}""
else







out="$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;"$findB" 
echo  $out

fi

fi

fi













if [[ ! $srvfnd == 0 ]] 
then
test=2

else
echo "$server"{***Server not found ***}""


fi
fi
done
)

done






