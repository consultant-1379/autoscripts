#!/usr/bin/sh
EXPECT=/ericsson/solaris/bin/expect

IMPORTPASS="secmgmt"
PASSPHRASE="netsim"
if [ $# = 0 ]; then
echo "Usage : createpem.sh <host.p12>"
echo "You must give a host.p12 file as an argument."
exit
fi; 
CREATEPEMCMD="/usr/sfw/bin/openssl pkcs12 -in $1 -out total.pem"
$EXPECT << EOF >> ./log.txt 2>&1
spawn ${CREATEPEMCMD}
expect "Enter Import Password:"
send "${IMPORTPASS}\n"
expect "Enter PEM pass phrase:"
send "${PASSPHRASE}\n"
expect "Verifying password - Enter PEM pass phrase:"
send "${PASSPHRASE}\n"
set output [ wait ]
expect eof
exit [lindex \$output 3]
EOF
#echo "Creating the file key.pem"
#cat total.pem | nawk -f createpem.awk MATCHSTR="host_key" regex=".*END RSA.*" > key.pem 
#echo "Creating the file certs.pem"
#cat total.pem | nawk -f createpem.awk MATCHSTR="host_cert" regex=".*END CERT.*" > certs.pem
#echo "Creating the file cacerts.pem"
#cat total.pem | nawk -f createpem.awk MATCHSTR="pks_cert" regex=".*END CERT.*" skip=1 > cacerts.pem
