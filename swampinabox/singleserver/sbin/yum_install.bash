#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`

function yum_erase() {
	echo "Erasing: $*"
	yum -y erase $*
}

function yum_install() {
	echo "Installing: $*"
	yum -y install $*
}

if [ "$(getent passwd swa-daemon)" == "" ]; then
	echo "Adding swa-daemon user"
	useradd swa-daemon
else
	echo "Found swa-daemon user"
fi

yum_install glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse
yum_install --nogpgcheck xfsprogs
yum_install rpm-build

yum_install guestfish libguestfs libguestfs-tools libguestfs-tools-c libvirt

yum_install bind-utils
yum_install git ant patch
yum_install zip ncompress rubygems python-pip
pip install wheel
yum_install httpd mod_ssl
yum_install php php-mcrypt php-mysqlnd php-mbstring
yum_install MariaDB
yum_install condor-all

chkconfig httpd on
chkconfig libvirtd on
