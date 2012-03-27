#!/bin/sh

echo 'ETC: custom samba config addon'
echo "include = /root/.etc/samba.conf" >> /etc/samba/smb.conf
/etc/init.d/samba restart > /dev/null

echo 'ETC: fixing PATH for root'
echo 'export PATH=$PATH:/root/.bin' >> /etc/profile

echo 'ETC: fixing SWAPPINESS'
echo 'vm.swappiness = 20' >> /etc/sysctl.conf
