#!/bin/bash

yum -y install ntpdate
ntpdate ntp1.mirsam.org
yum -y install ntp
chkconfig ntpd on
service ntpd start
rm /etc/localtime
if [ ! -h /etc/localtime ]; then
	ln -sf /usr/share/zoneinfo/UTDC /etc/localtime
fi
