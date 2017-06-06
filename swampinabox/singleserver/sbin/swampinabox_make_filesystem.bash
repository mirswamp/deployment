#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

mkdir -p /everglades
chown root:root /everglades
chmod 755 /everglades
if ! grep everglades /etc/fstab; then
	echo 'swa-gfs-dt-01:/ev0	/everglades	 glusterfs	defaults,_netdev	0 0' >> /etc/fstab
fi
mount -a
mount -va -t glusterfs

mkdir -p /swamp/incoming
chown apache:apache /swamp/incoming
chmod 0775 /swamp/incoming
chmod ugo-s /swamp/incoming

mkdir -p /swamp/outgoing
chown mysql:apache /swamp/outgoing
chmod 2775 /swamp/outgoing
chmod uo-s /swamp/outgoing

mkdir -p /swamp/working
chmod 755 /swamp/working

mkdir -p /swamp/working/results
chown mysql:mysql /swamp/working/results
chmod 755 /swamp/working/results

mkdir -p /swamp/working/project
chown root:root /swamp/working/project
chmod 755 /swamp/working/project

mkdir -p /swamp/platforms
chmod 755 /swamp/platforms

rm -rf /var/lib/libvirt/images
if [ ! -h /var/lib/libvirt/images ]; then
	ln -s /everglades/platforms/images /var/lib/libvirt/images
fi

rm -rf /swamp/platforms/images
if [ ! -h /swamp/platforms/images ]; then
	ln -s /everglades/platforms/images /swamp/platforms/images
fi

mkdir -p /swamp/SCAProjects
chown mysql:mysql /swamp/SCAProjects
chmod 755 /swamp/SCAProjects

mkdir -p /swamp/store
chmod 755 /swamp/store

mkdir -p /swamp/store/SCAPackages
chown mysql:mysql /swamp/store/SCAPackages
chmod 755 /swamp/store/SCAPackages

rm -rf /swamp/store/SCATools
if [ ! -h /swamp/store/SCATools ]; then
	ln -s /everglades/store/SCATools /swamp/store/SCATools
fi

if [ ! -h /var/www/html/results ]; then
	ln -s /swamp/outgoing /var/www/html/results
fi
if [ ! -h /var/www/html/wwwresults ]; then
	ln -s /var/www/html/results /var/www/html/wwwresults
fi
if [ ! -h /var/www/html/swamp-web-server/public/downloads ]; then
	ln -s /swamp/outgoing /var/www/html/swamp-web-server/public/downloads
fi
if [ ! -h /var/www/html/swamp-web-server/public/uploads ]; then
	ln -s /swamp/incoming /var/www/html/swamp-web-server/public/uploads
fi
if [ ! -h /var/www/html/swamp-web-server/public/results ]; then
	ln -s /var/www/html/results /var/www/html/swamp-web-server/public/results
fi
