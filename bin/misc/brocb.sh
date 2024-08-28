cat /tmp/edm1.info | grep -v "not found"| while read line
do
host=`echo $line | awk -F\; '{print $1}'`
hba_b=`echo $line | awk -F\; '{print $4}' | awk '{print $3}'`
chassis=`echo $line | awk -F\; '{print $2}'`
case $chassis in
	chassis14)
		UPLINK=atcx457_SPB3
		;;
	chassis49)
		UPLINK=atcx457_SPB3
		;;
	chassis63)
		UPLINK=atcx457_SPB3
		;;
	chassis69)
		UPLINK=atcx457_SPB3
		;;
	chassis39)
		UPLINK=atcx457_SPB0
		;;
	chassis53)
		UPLINK=atcx457_SPB0
		;;
	chassis44)
		UPLINK=atcx457_SPB0
		;;
	chassis72)
		UPLINK=atcx457_SPB0
		;;
          chassis66)
                UPLINK=atcx457_SPB2
                ;;


          chassis95)
                UPLINK=atcx458_SPB0
                ;;
chassis84)
      UPLINK=atcx458_SPB0
      ;;


	*)
		UPLINK=#########NotKnownChassis########
		;;
esac
echo "alicreate \"${host}_2\",\"$hba_b\""
echo "zonecreate \"Z_${host}_2_to_${UPLINK}\",\"${host}_2;${UPLINK}\""
echo "cfgadd \"ZC_Fabric_B\",\"Z_${host}_2_to_${UPLINK}\""
echo -e "\n######Next Zone######\n\n"
done



