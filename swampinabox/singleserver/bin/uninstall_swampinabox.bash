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

swamp_packages=(
	swamp-csaweb
	swamponabox-backend
	swampinabox-backend
	swamp-registry-web-server
	swamp-rt-java
	swamp-rt-perl
)

support_packages=(
	glusterfs 
	glusterfs-api 
	glusterfs-cli 
	glusterfs-libs 
	glusterfs-fuse 
	xfsprogs
	libguestfs
	libguestfs-tools
	libguestfs-tools-c
	libvirt
	patch
	bind-utils
	git
	mod_ssl
	ant
	rpm-build
	php
	php-mcrypt
	php-mysqlnd
	httpd
	MariaDB
	swamp-rt-1.21-7
	ntpdate
	ntp
	condor-8.2.7-300022
	perl-parent
	guestfish
)

function usage() {
	echo "usage $0 erase | eraseS | erases | list | listS | lists | help"
	exit
}

function list_packages() {
	for package in $*
	do
		echo "  $package"
	done
}

if [ $# -eq 0 ]; then
	usage
fi

for arg in $@
do
	case $arg in
		list)
			echo "Support packages to erase:"
			list_packages ${support_packages[@]}
			echo "Swamp packages to erase:"
			list_packages ${swamp_packages[@]}
		;;
		listS)
			echo "Swamp packages to erase:"
			list_packages ${swamp_packages[@]}
		;;
		lists)
			echo "Support packages to erase:"
			list_packages ${support_packages[@]}
		;;
		erase)
			$BINDIR/../sbin/manage_services.bash stop
			for package in ${swamp_packages[@]}
			do
				yum_erase $package
			done
			for package in ${support_packages[@]}
			do
				yum_erase $package
			done
		;;
		eraseS)
			$BINDIR/../sbin/manage_services.bash stop
			for package in ${swamp_packages[@]}
			do
				yum_erase $package
			done
		;;
		erases)
			$BINDIR/../sbin/manage_services.bash stop
			for package in ${support_packages[@]}
			do
				yum_erase $package
			done
		;;
		help)
			usage
		;;
		*)
			echo "Unknown argument: $arg"
			usage
		;;
	esac
done
