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


cat list.txt | 
(
while read line
do
set $line
chassis=$1

output=$(sed -n -e '/'atesx$server.'/{N;p;}' /tmp/stor$1.txt) 


if [ "$output" == "" ] 
then

test=1 

else

srvfnd=$srvfnd+1
echo $srvfnd

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




    echo "found" 
    echo atesx$server 
    echo atc7000-$chassis 
    echo $output2 
    echo $output 
    echo "-----------------------------------"

fi

fi

fi







done


)



echo $srvfnd 
#echo "loop"
#if [$srvfnd == 1 ]  then

#test=2

#else

#    echo "Server not found"
#    echo atesx$server

#fi


done






