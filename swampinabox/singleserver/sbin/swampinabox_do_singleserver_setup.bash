#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# Do the set up tasks that the "distribution" install requires the user to
# do separately from the main install and the set up tasks that are specific
# to a "singleserver" install.
#
# Note: Because a "singleserver" install is intended primarily for internal
# development, this script generally assumes that its commands will succeed.
#

echo ""
echo "### Setting Up This Host for a \"singleserver\" SWAMP-in-a-Box"
echo ""

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$BINDIR/runtime/bin/swamp_utility.functions"
source "$BINDIR/swampinabox_install_util.functions"

mode=$1
relay_host=$2

if [ "$mode" != "-install" ]; then
    echo "Nothing to do (not an install)"
    exit 0
fi

############################################################################

"$BINDIR/../../distribution/repos/install-all.bash" || exit 1

echo ""
echo "### Installing Dependencies Specific to \"singleserver\" SWAMP-in-a-Boxes"
echo ""

development_dependencies=(
    glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse
    cmake gcc libxml2-devel rpm-build python-pip
)

yum_install "${development_dependencies[@]}"
yum_install --nogpgcheck xfsprogs
pip install wheel

############################################################################

echo ""
echo "### Configuring Gluster File Systems and Mount Points"
echo ""

if ! grep /everglades /etc/fstab 1>/dev/null 2>&1 ; then
    echo "Adding /everglades glusterfs mount point"
    echo "swa-gfs-dt-01:/ev0	/everglades	 glusterfs	defaults,_netdev,ro	0 0" >> /etc/fstab
    if [ ! -d /everglades ]; then
        mkdir -p          /everglades
        chown root:root   /everglades
        chmod u=rwx,og=rx /everglades
    fi
else
    echo "Found /everglades in /etc/fstab"
fi

if ! grep /swampcs /etc/fstab 1>/dev/null 2>&1 ; then
    echo "Adding /swampcs glusterfs mount point"
    echo "swa-gfs-dt-03:/cs0	/swampcs	 glusterfs	defaults,_netdev,ro	0 0" >> /etc/fstab
    if [ ! -d /swampcs ]; then
        mkdir -p          /swampcs
        chown root:root   /swampcs
        chmod u=rwx,og=rx /swampcs
    fi
else
    echo "Found /swampcs in /etc/fstab"
fi

echo "Mounting glusterfs file systems"
mount -a -t glusterfs

############################################################################

echo ""
echo "### Configuring the System Clock"
echo ""

yum_install ntpdate
yum_install ntp
enable_service ntpd

#
# 'ntpd' must be stopped before running 'ntpdate'.
#
tell_services stop ntpd
ntpdate ntp1.mirsam.org
tell_services start ntpd

############################################################################

echo ""
echo "### Configuring Postfix"
echo ""

echo "Flushing Postfix's queue"
postqueue -f

echo "Patching /etc/postfix/main.cf"
diff -wu /etc/postfix/main.cf "$BINDIR/../config_templates/postfix/main.cf" \
    | sed -e "s/SED_HOSTNAME/$HOSTNAME/" \
    | sed -e "s/RELAYHOST/$relay_host/" \
    | patch -s /etc/postfix/main.cf

tell_services restart postfix

echo "Finished setting up this host for a \"singleserver\" SWAMP-in-a-Box"
