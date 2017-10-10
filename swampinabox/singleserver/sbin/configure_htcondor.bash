#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Configure HTCondor for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"

############################################################################

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
if [ ! -d /slots ]; then
    install -m 755 -o condor -g condor -d /slots
fi
if [ ! -d /etc/condor/config.d ]; then
    install -m 755 -o root -g root -d /etc/condor/config.d
fi
for config_file in "$BINDIR"/../config_templates/config.d/* ; do
    config_file_basename=$(basename "$config_file")

    #
    # Avoid overwriting the concurrency limits because they are configured
    # by the user.
    #
    if [ "$config_file_basename" != "swampinabox_90_concurrency_limits.conf" -o \
         ! -e "/etc/condor/config.d/$config_file_basename" ]
    then
        install -m 644 -o root -g root "$config_file" /etc/condor/config.d
    fi
done

if which systemctl 1>/dev/null 2>/dev/null ; then
    if ! systemctl enable condor ; then
        echo "Warning: $0: Failed to enable service: condor" 1>&2
        echo "It might need to be started manually if the host is rebooted." 1>&2
        encountered_error=1
    fi
else
    if ! chkconfig condor on ; then
        echo "Warning: $0: Failed to enable service: condor" 1>&2
        echo "It might need to be started manually if the host is rebooted." 1>&2
        encountered_error=1
    fi
fi

exit $encountered_error
