#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`

echo ""
echo "########################################"
echo "##### Configuring swampcs/releases #####"
echo "########################################"

if ! grep swampcs /etc/fstab
then
	echo ""
	echo "Installing gluster packages"
	yum -y install glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse

	echo ""
	echo "Adding /swampcs glusterfs mount point"
	echo "swa-gfs-dt-03:/cs0	/swampcs	 glusterfs	defaults,_netdev,ro	0 0" >> /etc/fstab

	echo ""
	echo "Mounting /swampcs"
	mkdir -p /swampcs
	mount /swampcs
fi
