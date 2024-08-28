#!/bin/bash
echo "INFO: Setting up the shell prompt"
EXT_HOSTNAME=`cat /etc/HOSTNAME`
ERICSSON_CONFIG=`cat /ericsson/config/ericsson_use_config|awk -F= '{print $2}'`
if [ ! -f /.profile ]
then
   touch /.profile
fi

if [ ! -f /.bashrc ]
then
   touch /.bashrc
fi

if [ "$ERICSSON_CONFIG" == "system" ]
then
   CHECK_FOR_EDIT=`grep "EDITED for Cloud External Hostname" /opt/ericsson/sck/data/oss.cshrc`
   if [ -z "$CHECK_FOR_EDIT" ]
   then
      cp /opt/ericsson/sck/data/oss.cshrc /tmp/oss.cshrc
      sed  's/\`uname -n\`/\`uname -n\`-\`cat \/etc\/HOSTNAME\`/g' /tmp/oss.cshrc > /opt/ericsson/sck/data/oss.cshrc
      echo "### EDITED for Cloud External Hostname###" >> /opt/ericsson/sck/data/oss.cshrc
      cp /etc/skel/.profile /tmp/.profile
      sed  's/\`uname -n\`/\`uname -n\`-\`cat \/etc\/HOSTNAME\`/g' /tmp/.profile > /etc/skel/.profile
      cp /.profile /tmp/.profile
      sed  's/\`uname -n\`/\`uname -n\`-\`cat \/etc\/HOSTNAME\`/g' /tmp/.profile > /.profile
      cp /home/nmsadm/.profile /tmp/.profile
      sed  's/\`uname -n\`/\`uname -n\`-\`cat \/etc\/HOSTNAME\`/g' /tmp/.profile > /home/nmsadm/.profile
      cp /etc/skel/.bashrc /tmp/.bashrc
      grep -v "PS1" /tmp/.bashrc > /etc/skel/.bashrc
      cp /.bashrc /tmp/.bashrc
      grep -v "PS1" /tmp/.bashrc > /.bashrc
      cp /home/nmsadm/.bashrc /tmp/.bashrc
      grep -v "PS1" /tmp/.bashrc > /home/nmsadm/.bashrc
   fi
exit
fi
if [ "$ERICSSON_CONFIG" == "appserv" ]
   then
   CHECK_FOR_EDIT=`grep "EDITED for Cloud External Hostname" /.profile`
   if [ -z "$CHECK_FOR_EDIT" ]
   then
      CHECK_FOR_PROMPT=`grep PS1 /.profile`
      if [ -n "${CHECK_FOR_PROMPT}" ]
      then
         cp /.profile /tmp/.profile
         sed 's/\`uname -n\`/\`uname -n\`-\`cat \/etc\/HOSTNAME\`/g' /tmp/.profile > /.profile
         cp /.bashrc /tmp/.bashrc
         grep -v "PS1" /tmp/.bashrc > /.bashrc
         echo "### EDITED for Cloud External Hostname###" >> /.profile
      else
        echo "PS1=\"\`uname -n\`-\`cat /etc/HOSTNAME\` # \"" >> /.profile
        echo "export PS1" >> /.profile
        echo "### EDITED for Cloud External Hostname###" >> /.profile
      fi
   fi
else
   CHECK_FOR_EDIT=`grep "EDITED for Cloud External Hostname" /etc/skel/.profile`
   if [ -z "$CHECK_FOR_EDIT" ]
   then
      echo "PS1=\"\`uname -n\`-\`cat /etc/HOSTNAME\` # \"" >> /etc/skel/.profile
      echo "export PS1" >> /etc/skel/.profile
      echo "### EDITED for Cloud External Hostname###" >> /etc/skel/.profile
      CHECK_FOR_PROMPT=`grep "export PS1" /.profile`
      if [ -s "$CHECK_FOR_PROMPT" ]
      then
         cp /.profile /tmp/.profile
         sed 's/\`uname -n\`/\`uname -n\`-\`cat /etc/HOSTNAME\`/g' /tmp/.profile > /.profile
         cp /.bashrc /tmp/.bashrc
         grep -v "PS1" /tmp/.bashrc > /.bashrc
         echo "### EDITED for Cloud External Hostname###" >> /.profile
      else
         echo "PS1=\"\`uname -n\`-\`cat /etc/HOSTNAME\` # \""  >> /.profile
         echo "export PS1" >> /.profile
         cp /.bashrc /tmp/.bashrc
         grep -v "PS1" /tmp/.bashrc > /.bashrc
        echo "### EDITED for Cloud External Hostname###" >> /.profile
      fi
   fi
fi
