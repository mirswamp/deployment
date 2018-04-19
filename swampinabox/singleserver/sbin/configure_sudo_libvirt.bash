#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure 'sudo' and 'libvirt' for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")

############################################################################

echo "Checking for and removing old configuration files"
for old_file in /etc/sudoers.d/10_slotusers ; do
    if [ -f "$old_file" ]; then
        echo "Removing: $old_file"
        rm -f "$old_file"
    fi
done
echo "Finished checking for and removing old configuration files"

echo "Installing the SWAMP sudoers configuration"
install -m 640 -o root -g root "$BINDIR/../config_templates/10_swamp_sudo_config" /etc/sudoers.d/.

echo "Installing qemu-kvm-us"
install -m 755 -o root -g root "$BINDIR/../config_templates/qemu-kvm-us"  /usr/libexec/qemu-kvm-us

echo "Creating the slotusers group"
groupadd -f slotusers

if ! groupmems -g slotusers -l | grep swa-daemon 1>/dev/null 2>/dev/null ; then
    echo "Adding the swa-daemon user to the slotusers group"
    groupmems -g slotusers -a swa-daemon
fi

#
# 'libvirtd' needs to be running for the 'virsh' commands below to work.
#
"$BINDIR/manage_services.bash" restart libvirtd

#
# CSA-2693: Destroy the old 'swamponabox' network before adding 'swampinabox'.
#
if virsh net-uuid swamponabox 1>/dev/null 2>/dev/null ; then
    virsh net-destroy swamponabox
    virsh net-undefine swamponabox
fi

if ! virsh net-uuid swampinabox 1>/dev/null 2>/dev/null ; then
    virsh net-define "$BINDIR/../config_templates/swampinabox.xml"
    virsh net-autostart swampinabox
    virsh net-start swampinabox
fi

exit $encountered_error
