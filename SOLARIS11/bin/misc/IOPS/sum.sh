#!/bin/bash


declare -i srvfnd
sum=0
echo enter file name
  read fname

   exec<$fname
   value=0
while read line
do
set $line
echo $line
sum=[[$sum+$line]]
#echo $sum
done
