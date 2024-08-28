#!/bin/bash

if [[ ! -f /home/nmsadm/.ssh/id_rsa ]]
then
	su - nmsadm -c "ssh-keygen -t rsa -f /home/nmsadm/.ssh/id_rsa -P ''"
fi


if [[ ! -f /.ssh/id_rsa ]]
then
	ssh-keygen -t rsa -f /.ssh/id_rsa -P ''
fi
