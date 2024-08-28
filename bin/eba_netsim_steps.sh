#!/bin/bash

# Copying files from /proj/ossrc/

if [[ -f /netsim/netsimdir/eba_sgsn_athlone.zip ]]
then
        echo "INFO: /netsim/netsimdir/eba_sgsn_athlone.zip already exists, not copying again"
else
        echo "INFO: Copying /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/eba_sgsn_athlone.zip to /netsim/netsimdir/"
        cp /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/eba_sgsn_athlone.zip /netsim/netsimdir/
fi

if [[ -f /netsim/netsimdir/eba_testbox_RNC_FT.zip ]]
then
        echo "INFO: /netsim/netsimdir/eba_testbox_RNC_FT.zip already exists, not copying again"
else
        echo "INFO: Copying /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/eba_testbox_RNC_FT.zip to /netsim/netsimdir/"
        cp /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/eba_testbox_RNC_FT.zip /netsim/netsimdir/
fi

if [[ -f /netsim/netsimdir/exported_items/Testbox.configuration ]]
then
        echo "INFO: /netsim/netsimdir/exported_items/Testbox.configuration already exists, not copying again"
else
        echo "INFO: Copying /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/Testbox.configuration to /netsim/netsimdir/exported_items/"
        cp /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/Testbox.configuration /netsim/netsimdir/exported_items/
fi

if [[ -f /netsim/netsimdir/exported_items/Testbox.configurationtext ]]
then
        echo "INFO: /netsim/netsimdir/exported_items/Testbox.configurationtext already exists, not copying again"
else
        echo "INFO: Copying /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/Testbox.configurationtext to /netsim/netsimdir/exported_items/"
        cp /proj/ossrc/eba/FT/scripts/Netsim_for_testbox/Testbox.configurationtext /netsim/netsimdir/exported_items/
fi

# Importing the netsim configuration
echo "INFO: Importing netsim configuration called Testbox"
su - netsim -c "echo -e '.select configuration\n.config import Testbox' | /netsim/inst/netsim_pipe"

# Creating soft links
echo "INFO: Creating softlinks"
su - netsim -c "mkdir -p /netsim/eba_sgsn_output/"

LIST=""
SEQUENCE_OUTPUT=$(
seq -w 1 50 | while read line
do
        echo "GSN${line}"
done
)
LIST="$LIST\n$SEQUENCE_OUTPUT"

SEQUENCE_OUTPUT=$(
seq -w 1 3 | while read line
do
        echo "HWPP0${line}"
done
)
LIST="$LIST\n$SEQUENCE_OUTPUT"

SEQUENCE_OUTPUT=$(
seq -w 6 7 | while read line
do
        echo "cGSN_R${line}"
done
)
LIST="$LIST\n$SEQUENCE_OUTPUT"

echo -e "$LIST" | while read line
do
        if [[ "$line" == "" ]]
        then
                continue
        fi
        FROM_LINK="/netsim/eba_sgsn_output/$line"
        TO_LINK="/netsim/netsim_dbdir/simdir/netsim/netsimdir/eba_sgsn_athlone/$line/fs/tmp/OMS_LOGS/ebs/ready"
        rm -rf $FROM_LINK > /dev/null 2>&1
        #echo "Creating a link from $FROM_LINK to $TO_LINK"
        su - netsim -c "ln -s $TO_LINK $FROM_LINK > /dev/null"
done
