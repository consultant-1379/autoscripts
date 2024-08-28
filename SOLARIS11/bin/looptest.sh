#!/bin/bash
cat test | while read line
do
	exit 1
done
echo here
