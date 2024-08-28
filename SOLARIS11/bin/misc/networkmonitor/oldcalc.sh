#colno=0

chassis=$1
echo -n 1_$1

#cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vc1nu$1.txt" | while read line 


FILE=vc1nu$chassis.txt
exec 3<&0
exec 0<$FILE


while read line  

do
set $line
big=$1
small=$2
RESULT=$(( $big - $small  ))
((colno++))

echo $colno
if [  $RESULT -gt 10000 ]
then

#          if [  $colno -lt 17 ] 
#             then

#          echo ray
#          else
          t=4
#          fi



else
t=3
fi

printf '%6s' $RESULT

done

exec 0<&3



printf '%s\n' 
echo -n 2_$chassis
cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vc2nu$chassis.txt" | while read line 
do
set $line
big=$1
small=$2
RESULT=$(( $big  - $small  ))

printf '%6s' $RESULT

done





#done
