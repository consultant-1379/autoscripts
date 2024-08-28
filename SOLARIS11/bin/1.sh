#!/bin/bash
set -x
cat file3 | while read LINE
do
        echo $LINE
        VAR=`grep -w $LINE file4`
        if [ "$VAR" = "$LINE" ]
        then
        echo matched $LINE >> abfile2
        else
        echo "Not found $LINE" >> abfile2
        fi
done
cat abfile2
#rm abfile2

