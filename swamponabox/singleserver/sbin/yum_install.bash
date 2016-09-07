#!/bin/bash
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

yum_install libguestfs libguestfs-tools libguestfs-tools-c libvirt

yum_install bind-utils
yum_install git ant patch
yum_install zip ncompress
yum_install httpd mod_ssl
yum_install php php-mcrypt php-mysqlnd php-mbstring
yum_install MariaDB

chkconfig httpd on
chkconfig libvirtd on

