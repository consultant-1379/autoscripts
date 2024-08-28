function read_options_file {
	CONFIG_DIR=/automation/configs/$1
	OPTIONS_FILE=/$CONFIG_DIR/variables.txt
	STATUS_DIR=/automation/configs/$1/status/
	if [[ -f $OPTIONS_FILE ]]
	then
        	. $OPTIONS_FILE
	else
        	echo "Can't find options file $OPTIONS_FILE"
        	exit 1
	fi
	THIS_IP=`ifconfig -a | grep inet | grep -v 127.0.0.1 | awk '{print $2}'`
}
