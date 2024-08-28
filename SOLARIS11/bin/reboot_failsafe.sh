#!/bin/bash

cp /boot/grub/menu.lst /boot/grub/menu.lst.tmp
cat /boot/grub/menu.lst.tmp | sed 's/^default.*/default 1/g' > /boot/grub/menu.lst
reboot
