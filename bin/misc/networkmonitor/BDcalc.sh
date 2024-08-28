colno=0

#chassis=$1
#threshold=$2

#echo -n 1_$1

#cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vc1nu$1.txt" | while read line 


FILE=BD1nu.txt
exec 3<&0
exec 0<$FILE
while read line  

do
set $line
#echo $line
big=$1
small=$2
RESULT=$(( $big - $small  ))
((colno++))

#echo $colno
#if [  $RESULT -gt $threshold ]
#then

#          if [  $colno -lt 17 ] 
#             then

#          echo "vc1 $chassis $colno $RESULT" >> /export/scripts/CLOUD/bin/misc/networkmonitor/vclog.txt
#          else
#          t=4
#          fi



#else
#t=3
#fi

if [  $RESULT -gt 9999 ]
then
kRESULT=$((RESULT/1000))

shinynewnumber=$( printf "%0.f\n" $kRESULT )

RESULT=$shinynewnumber.K
else
t=1
fi

echo $RESULT
#'printf '%6s' $RESULT

done

exec 0<&3



#printf '%s\n' 
#echo -n 2_$chassis





#cat "/export/scripts/CLOUD/bin/misc/networkmonitor/vc2nu$chassis.txt" | while read line 

#colno=0

#FILE=vc2nu$chassis.txt
#exec 3<&0
#exec 0<$FILE
#while read line  

#do
#((colno++))


#set $line
#big=$1
#small=$2
#RESULT=$(( $big  - $small  ))

#if [  $RESULT -gt $threshold ]
#then

#          if [  $colno -lt 17 ]
#             then
#          echo "vc2 $chassis $colno $RESULT" >> /export/scripts/CLOUD/bin/misc/networkmonitor/vclog.txt
#          else
#          t=4
#          fi



#else
#t=3
#fi


#if [  $RESULT -gt 9999 ]
#then
#kRESULT=$((RESULT/1000))

#hinynewnumber=$( printf "%0.f\n" $kRESULT )

#RESULT=$shinynewnumber.K
#else
#t=1
#fi





#printf '%6s' $RESULT

#done





#done
