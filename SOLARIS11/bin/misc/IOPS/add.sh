#!/usr/bin/bash

file="omsasval.txt"
cat ${file} | 
(
while read name num
echo $num
do
sum=$((sum + num ))
echo $sum
done
)
