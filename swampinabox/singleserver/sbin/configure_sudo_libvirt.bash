#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo
echo "### Configuring 'sudo' and 'libvirt'"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/runtime/bin/swamp_utility.functions

############################################################################

echo "Removing old configuration files"
for old_file in \
        /etc/sudoers.d/10_slotusers \
        ; do
    if [ -f "$old_file" ]; then
        echo "Removing: $old_file"
        rm -f "$old_file"
    fi
done

echo "Installing 10_swamp_sudo_config"
install \
    -m 640 -o root -g root \
    "$BINDIR"/../config_templates/sudoers/10_swamp_sudo_config \
    /etc/sudoers.d/.

echo "Installing qemu-kvm-us"
install \
    -m 755 -o root -g root \
    "$BINDIR"/../config_templates/qemu-kvm-us \
    /usr/libexec/.

############################################################################

#
# 'libvirtd' needs to be running for the 'virsh' commands below to work.
#
tell_service libvirtd restart

if ! virsh net-uuid swampinabox 1>/dev/null 2>&1 ; then
    echo "Defining the swampinabox virtual network"
    virsh -q net-define "$BINDIR"/../config_templates/libvirt/swampinabox.xml

    echo "Starting the swampinabox virtual network"
    virsh -q net-start swampinabox
    virsh -q net-autostart swampinabox
else
    echo "Found the swampinabox virtual network"
fi

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished configuring 'sudo' and 'libvirt'"
else
    echo
    echo "Finished configuring 'sudo' and 'libvirt', but with errors" 1>&2
fi
exit $encountered_error
