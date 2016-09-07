#!/bin/bash
BINDIR=`dirname $0`

cp $BINDIR/../swamponabox_installer/10_slotusers /etc/sudoers.d/.
groupadd -f slotusers
groupmems -g slotusers -a swa-daemon
yum -y install perl-parent
yum -y install guestfish
install -m 755 $BINDIR/../swamponabox_installer/qemu-kvm-us /usr/libexec/qemu-kvm-us
service libvirtd restart
status=$(virsh net-info swamponabox 2>&1)
if [[ $status == *"not found:"* ]]
then
	virsh net-define $BINDIR/../swamponabox_installer/swamponabox.xml
	virsh net-autostart swamponabox
	virsh net-start swamponabox
fi
