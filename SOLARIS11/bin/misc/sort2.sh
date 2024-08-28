#!/bin/bash


echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line

server=$1



cat list.txt | 
(
while read line
do
set $line
chassis=$1

output = grep -A1 '$server' /tmp/stor$1.txt 

if [ "$output" == "" ]; then
    echo "not found";
else
    echo "found";

fi



#echo  ""
#echo -e "---------------------------------------------"

#sed -e '/BROCADE/b' -e d /tmp/stor$1.txt

done


)


#cat /tmp/stor69.txt | sed -n -e '/$1/{N;p;}'
#cat /tmp/stor69.txt | sed -e '/BROCADE/b'

#sed -e '/BROCADE/b' -e '/Server Blade/b' -e '/Server Name/b' -e '/Port/b' -e d /tmp/capture$1.txt | tee /tmp/stor$1.txt

done






