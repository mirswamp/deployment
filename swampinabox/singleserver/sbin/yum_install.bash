#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install all dependencies for hosted/development instances of SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1' ERR
set -o errtrace

BINDIR="$(dirname "$0")"

. "$BINDIR/../../distribution/repos/resources/common-helper.functions"

############################################################################

echo ""
echo "###############################################################"
echo "##### Installing Dependencies Common to All SiB Instances #####"
echo "###############################################################"

"$BINDIR/../../distribution/repos/install-all.bash"

echo ""
echo "########################################################################"
echo "##### Installing Dependencies for Hosted/Development SiB Instances #####"
echo "########################################################################"

yum_install glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse
yum_confirm glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse

yum_install --nogpgcheck xfsprogs
yum_confirm              xfsprogs

yum_install gcc cmake libxml2-devel
yum_confirm gcc cmake libxml2-devel

yum_install rpm-build rubygems python-pip
yum_confirm rpm-build rubygems python-pip

pip install wheel

echo ""
echo "################################"
echo "##### Configuring /swampcs #####"
echo "################################"

if ! grep /swampcs /etc/fstab 1>/dev/null 2>/dev/null ; then
    echo "Adding '/swampcs' glusterfs mount point"
    echo "swa-gfs-dt-03:/cs0	/swampcs	 glusterfs	defaults,_netdev,ro	0 0" >> /etc/fstab

    echo "Mounting '/swampcs'"
    mkdir -p /swampcs
    mount /swampcs
else
    echo "Found '/swampcs' in '/etc/fstab'"
fi

echo ""
echo "Finished."
exit $encountered_error
