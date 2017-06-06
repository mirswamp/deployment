#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

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
    /etc/condor/config.d/swamponabox_vm.conf \
    \
    /etc/condor/config.d/swampinabox_debug.conf \
    /etc/condor/config.d/swampinabox_descriptors.conf \
    /etc/condor/config.d/swampinabox_jobcontrol.conf \
    /etc/condor/config.d/swampinabox_main.conf \
    /etc/condor/config.d/swampinabox_network.conf \
    /etc/condor/config.d/swampinabox_slots.conf \
    /etc/condor/config.d/swampinabox_vm.conf

#
# Install HTCondor configuration files for SWAMP-in-a-Box.
#

install -m 755 -o condor -g condor -d /slots

if [ ! -d /etc/condor/config.d ]; then
    install -m 755 -o root -g root -d /etc/condor/config.d
fi

for config_file in $BINDIR/../config_templates/config.d/* ; do
    install -m 644 -o root -g root "$config_file" /etc/condor/config.d
done

chkconfig condor on
service condor start

exit 0
