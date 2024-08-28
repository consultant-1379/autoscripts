#!/bin/bash

 
declare -i srvfnd 


server=$1
srvfnd=0
#echo $srvfnd
#echo "top"

for line in `cat allnoncllist.txt`
do
set $line

hbacnt=0
brocnt=0

chassis=$1


cat /tmp/stor$chassis.txt |
(
while read line


do


#echo $line

if [[ "$line" =~ "Server Name" ]] 

then
#echo $line
echo $line > /tmp/search.txt

server=$(sed -e '/'atrcxb'/b' -e d /tmp/search.txt | awk '{print $3}' | awk '{split($0,array,".")} END{print array[1]}')

if [ "$server" == "" ]

then

server=$(sed -e '/'ethrcxb'/b' -e d /tmp/search.txt | awk '{print $3}' | awk '{split($0,array,".")} END{print array[1]}')

fi




if [ "$server" == "" ] 
then

test=1 

else

output=$(sed -n -e '/'$server'/{N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 1: 50')
hba2=$(sed -n -e '/'$server'/{N;N;N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 1: 50')
hba3=$(sed -n -e '/'$server'/{N;N;N;N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 2: 50')

findA=$(sed -n -e '/'$server'/{N;N;N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'Port 2: 50')
findB=$(sed -n -e '/'$server'/{N;p;}' /tmp/stor$chassis.txt | grep -v 'Server Name' | grep 'LOM:1-a' | sed 's/Ethernet FlexNIC//g')

#echo $output
#echo $findA
#echo $findB


srvfnd=$srvfnd+1
#echo $srvfnd

if [[ ! "$output" =~ "50:01" ]]
then



echo "$server"\;""chassis"$chassis"{***HBA not found ***}""

#hbacnt=$[hbacnt+1]
((hbacnt++))



output3=$(sed -e /BROCADE/b -e d /tmp/stor$chassis.txt)
      if [ "$output3" == "" ]
          then
brocnt=1
echo "$server"{***BROCADE not found ***}""

     fi 

else






output2=$(sed -e /BROCADE/b -e d /tmp/stor$chassis.txt)
      if [ "$output2" == "" ]
          then

brocnt=1
echo "$server"\;""chassis"$chassis"{***BROCADE not found ***}""
else

if [ "$hba3" == "" ]
then

out="$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;"$findB"
echo  $out

else




out="$server"\;""chassis"$chassis"\;"$output"\;"$findA"\;"$hba2"\;"$hba3"\;"$findB" 
echo  $out
fi
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

summ=""chassis"$chassis"\;"{****no of HBA missings*****}$hbacnt"\;"{****no of BROC missings*****}$brocnt"
echo $summ
#echo  $chassis
#echo $hbacnt
#echo $brocnt


)

done






