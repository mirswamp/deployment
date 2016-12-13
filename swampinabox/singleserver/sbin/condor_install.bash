#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/swampinabox_install_util.functions

#
# CSA-2693: Remove old configuration files.
#

rm -f \
    /etc/condor/config.d/swamponabox_debug.conf \
    /etc/condor/config.d/swamponabox_descriptors.conf \
    /etc/condor/config.d/swamponabox_jobcontrol.conf \
    /etc/condor/config.d/swamponabox_main.conf \
    /etc/condor/config.d/swamponabox_network.conf \
    /etc/condor/config.d/swamponabox_slots.conf \
    /etc/condor/config.d/swamponabox_vm.conf

#
# Install HTCondor and configuration files for SWAMP-in-a-Box.
#

yum_install condor-all
yum_confirm condor-all || exit_with_error

mkdir -p /slots
chown condor:condor /slots
cp -r $BINDIR/../swampinabox_installer/config.d /etc/condor

hostip=`$BINDIR/../sbin/find_ip_address.pl $HOSTNAME`
if [ -n "$hostip" ]; then
    echo "Patching swampinabox_network.conf for Condor using ip: $hostip"
    sed -i "s/HOSTIP/$hostip/" /etc/condor/config.d/swampinabox_network.conf
fi

domain="$HOSTNAME"
if [ -n "$domain" ]; then
    echo "Patching swampinabox_jobcontrol.conf for Condor using domain: $domain"
    sed -i "s/PATCH_DEFAULT_DOMAIN_NAME//" /etc/condor/config.d/swampinabox_jobcontrol.conf
    sed -i "s/PATCH_UID_DOMAIN/$domain/" /etc/condor/config.d/swampinabox_jobcontrol.conf
    sed -i "s/PATCH_ALLOW_WRITE/$domain/" /etc/condor/config.d/swampinabox_jobcontrol.conf
fi

chkconfig condor on
service condor start

exit 0
