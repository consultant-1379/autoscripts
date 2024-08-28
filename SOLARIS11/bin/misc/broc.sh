cat /tmp/dm1.info | grep -v "not found"| while read line
do
host=`echo $line | awk -F\; '{print $1}'`
hba_a=`echo $line | awk -F\; '{print $3}' | awk '{print $3}'`
chassis=`echo $line | awk -F\; '{print $2}'`
case $chassis in
	chassis14)
		UPLINK=atcx457_SPA3
		;;
	chassis49)
		UPLINK=atcx457_SPA3
		;;
	chassis63)
		UPLINK=atcx457_SPA3
		;;
	chassis69)
		UPLINK=atcx457_SPA3
		;;
	chassis39)
		UPLINK=atcx457_SPA0
		;;
	chassis53)
		UPLINK=atcx457_SPA0
		;;
	chassis44)
		UPLINK=atcx457_SPA0
		;;
	chassis72)
		UPLINK=atcx457_SPA0
		;;

	chassis66)
		UPLINK=atcx457_SPA2
		;;

	chassis95)
		UPLINK=atcx458_SPA0
		;;

	chassis84)
		UPLINK=atcx458_SPA0
		;;



	*)
		UPLINK=#########NotKnownChassis########
		;;
esac
echo "alicreate \"${host}_1\",\"$hba_a\""
echo "zonecreate \"Z_${host}_1_to_${UPLINK}\",\"${host}_1;${UPLINK}\""
echo "cfgadd \"ZC_Fabric_A\",\"Z_${host}_1_to_${UPLINK}\""
echo -e "\n######Next Zone######\n\n"
done

