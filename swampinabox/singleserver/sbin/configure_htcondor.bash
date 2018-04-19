#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure HTCondor for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")

############################################################################

#
# CSA-2693: Remove old configuration files.
#
echo "Checking for and removing old configuration files"
for old_file in \
        /etc/condor/config.d/swamponabox_debug.conf \
        /etc/condor/config.d/swamponabox_descriptors.conf \
        /etc/condor/config.d/swamponabox_jobcontrol.conf \
        /etc/condor/config.d/swamponabox_main.conf \
        /etc/condor/config.d/swamponabox_network.conf \
        /etc/condor/config.d/swamponabox_slots.conf \
        /etc/condor/config.d/swamponabox_vm.conf \
        \
        /etc/condor/config.d/swampinabox_condor_q.conf \
        /etc/condor/config.d/swampinabox_debug.conf \
        /etc/condor/config.d/swampinabox_descriptors.conf \
        /etc/condor/config.d/swampinabox_jobcontrol.conf \
        /etc/condor/config.d/swampinabox_main.conf \
        /etc/condor/config.d/swampinabox_network.conf \
        /etc/condor/config.d/swampinabox_slots.conf \
        /etc/condor/config.d/swampinabox_vm.conf \
        \
        /etc/condor/config.d/swampinabox_01_debug.conf \
        /etc/condor/config.d/swampinabox_10_network.conf \
        /etc/condor/config.d/swampinabox_20_main.conf \
        /etc/condor/config.d/swampinabox_30_jobcontrol.conf \
        /etc/condor/config.d/swampinabox_40_slots.conf \
        /etc/condor/config.d/swampinabox_50_vm_universe.conf \
        /etc/condor/config.d/swampinabox_90_condor_developers.conf \
        /etc/condor/config.d/swampinabox_90_condor_q.conf \
        /etc/condor/config.d/swampinabox_90_descriptors.conf \
        ; do
    if [ -f "$old_file" ]; then
        echo "Removing: $old_file"
        rm -f "$old_file"
    fi
done
echo "Finished checking for and removing old configuration files"

#
# Install HTCondor configuration files for SWAMP-in-a-Box.
#
if [ ! -d /slots ]; then
    echo "Creating /slots directory"
    install -m 755 -o condor -g condor -d /slots
fi
if [ ! -d /etc/condor/config.d ]; then
    echo "Creating /etc/condor/config.d directory"
    install -m 755 -o root -g root -d /etc/condor/config.d
fi
for config_file in "$BINDIR"/../config_templates/config.d/* ; do
    config_file_basename=$(basename "$config_file")

    #
    # Avoid overwriting the concurrency limits because they are configured
    # by the user.
    #
    if    [ "$config_file_basename" != "swampinabox_90_concurrency_limits.conf" ] \
       || [ ! -e "/etc/condor/config.d/$config_file_basename" ]
    then
        echo "Installing $config_file_basename"
        install -m 644 -o root -g root "$config_file" /etc/condor/config.d
    fi
done

exit $encountered_error
