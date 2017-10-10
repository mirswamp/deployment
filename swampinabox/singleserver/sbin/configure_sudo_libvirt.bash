#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Configure sudo and libvirt for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"

############################################################################

install -m 640 -o root -g root "$BINDIR/../config_templates/10_slotusers" /etc/sudoers.d/.
install -m 755 -o root -g root "$BINDIR/../config_templates/qemu-kvm-us"  /usr/libexec/qemu-kvm-us

groupadd -f slotusers

if ! groupmems -g slotusers -l | grep swa-daemon 1>/dev/null 2>/dev/null ; then
    groupmems -g slotusers -a swa-daemon
fi

"$BINDIR/manage_services.bash" restart libvirtd

#
# CSA-2693: Destroy the old "swamponabox" network before adding "swampinabox".
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
