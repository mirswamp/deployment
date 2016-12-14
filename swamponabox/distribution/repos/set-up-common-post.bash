#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/set-up-common.functions

echo ""
echo "################################"
echo "##### Configuring Services #####"
echo "################################"

if [ -e /usr/lib/systemd/system/mariadb.service -a ! -e /etc/systemd/system/mysql.service ]; then
    echo "Creating symlink from mysql.service to mariadb.service"
    ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
fi

if [ -e /usr/lib/systemd/system/mariadb.service ]; then
    echo "Enabling mariadb service"
    systemctl enable mariadb || exit_with_error
fi

if [ -e /etc/rc.d/init.d/mysql ]; then
    echo "Enabling mysql service"
    chkconfig mysql on || exit_with_error
fi

echo "Enabling httpd service"
chkconfig httpd on || exit_with_error

echo "Enabling libvirtd service"
chkconfig libvirtd on || exit_with_error

echo ""
echo "#################################################"
echo "##### Creating SWAMP-specific User Accounts #####"
echo "#################################################"

if [ "$(getent passwd swa-daemon)" == "" ]; then
    echo "Adding swa-daemon user"
    useradd swa-daemon || exit_with_error
else
    echo "Found swa-daemon user"
fi

exit 0
