#!/bin/bash


echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line

echo $1



sed -n -e '/atesx1690/{N;p;}' /tmp/stor69.txt
sed -e '/BROCADE/b' -e d /tmp/stor69.txt




#cat /tmp/stor69.txt | sed -n -e '/$1/{N;p;}'
#cat /tmp/stor69.txt | sed -e '/BROCADE/b'

#sed -e '/BROCADE/b' -e '/Server Blade/b' -e '/Server Name/b' -e '/Port/b' -e d /tmp/capture$1.txt | tee /tmp/stor$1.txt

done






