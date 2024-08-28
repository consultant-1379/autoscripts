#!/bin/bash
GLOBIGNORE="*"
VAPP=$1

echo "Setup DDC DDP script starting"
echo "FTP the DDP Tar package to Masterserver"
scp /export/scripts/CLOUD/CIinfra/DDPI_UPLOAD.tar.gz root@ossmaster:/opt/ericsson/ddc/bin/

echo "Installation of DDP Tar begins"
ssh -qT ossmaster "cd /opt/ericsson/ddc/bin;rm -rf DDPI_UPLOAD;rm -rf DDPI_UPLOAD.tar;gunzip DDPI_UPLOAD.tar.gz;tar -xvf DDPI_UPLOAD.tar"

echo "Setting up FTP Account name & password"
if [ $VAPP == "Sol11_Cloud_CDB_Auto_Deployment_1" ]
then
	ftpUserName="lmi_vApp_Motel"
	ftpPassword="aprtmnbv"
elif [ $VAPP == "Sol11_Cloud_CDB_Auto_Deployment_2" ]
then
        ftpUserName="lmi_vApp_Motel_2"
        ftpPassword="_vApp_Motel_2"
elif [ $VAPP == "Sol11_Cloud_CDB_Auto_Deployment_3" ]
then
        ftpUserName="lmi_vApp_Motel_3"
        ftpPassword="_vApp_Motel_3"
elif [ $VAPP == "Sol11_Cloud_CDB_Auto_Deployment_4" ]
then
        ftpUserName="lmi_vApp_Motel_4"
        ftpPassword="_vApp_Motel_4"
else
	echo "Vapp Name did not match"
	exit 0
fi
echo "Using FTP User name $ftpUserName"
echo "Using FTP Password  $ftpPassword"

echo "Writing the Cron Entry into Masterserver"
cronjob="00,30 * * * * /opt/ERICddc/bin/sendStats $ftpUserName $ftpPassword"

ssh -qT ossmaster "rm -rf /tmp/root.cron;crontab -l | grep -v sendStats > /tmp/root.cron;"
ssh -qT ossmaster "GLOBIGNORE="*";echo $cronjob >> /tmp/root.cron;crontab /tmp/root.cron"

echo "Configuring DDC config file"
ssh -qT ossmaster "echo $ftpUserName > /var/ericsson/ddc_data/config/ddp.txt"

echo "copying the Remote Installer Script"
scp /export/scripts/CLOUD/bin/CDBRemoteInstall.sh root@ossmaster:/opt/ericsson/ddc/bin/

echo "running the Remote installer script"
ssh -qT ossmaster "cd /opt/ericsson/ddc/bin/;chmod +x CDBRemoteInstall.sh;./CDBRemoteInstall.sh"

echo "DDC DDP Setup Completed"
exit 0
