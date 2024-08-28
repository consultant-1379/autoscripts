#!/bin/bash

cd /home/comnfadm/.ssh
cat OMINFServer.pub >> authorized_keys2

# Remove duplicate lines

cat authorized_keys2 | sort -u > authorized_keys2.temp
mv authorized_keys2.temp authorized_keys2

rm OMINFServer.pub
chown -R comnfadm:other /home/comnfadm/.ssh/
chmod -R 0700 /home/comnfadm/.ssh/

