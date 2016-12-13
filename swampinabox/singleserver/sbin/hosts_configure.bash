#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

hostip=`$BINDIR/../sbin/find_ip_address.pl $HOSTNAME`
if [ -z "$hostip" ]; then
	echo "Error - cannot determine ip address for: $HOSTNAME"
	echo "A manual adjustment of /etc/hosts is required"
	exit
fi
domain=`$BINDIR/../sbin/find_domainname.pl $HOSTNAME`
if [ -z "$domain" ]; then
	echo "Error - cannot determine domain for: $HOSTNAME"
	echo "A manual adjustment of /etc/hosts is required"
	exit
fi
hostalias=${HOSTNAME%.$domain}
echo "hostname: $HOSTNAME alias: $hostalias ip: $hostip domain: $domain"
if grep $hostip /etc/hosts; then
	echo "Contents of /etc/hosts:"
	cat /etc/hosts
else
	echo "Adding $hostip $HOSTNAME $hostalias to /etc/hosts"
	echo "$hostip $HOSTNAME $hostalias" >> /etc/hosts
fi
