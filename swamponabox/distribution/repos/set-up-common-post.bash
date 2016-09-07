#!/bin/bash

echo ""
echo "################################"
echo "##### Configuring Services #####"
echo "################################"

if [ -e /usr/lib/systemd/system/mariadb.service -a ! -e /etc/systemd/system/mysql.service ]; then
    echo "Creating symlink from mysql.service to mariadb.service"
    ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
fi

echo "Enabling httpd service"
chkconfig httpd on

echo "Enabling libvirtd service"
chkconfig libvirtd on

echo ""
echo "#################################################"
echo "##### Creating SWAMP-specific User Accounts #####"
echo "#################################################"

if [ "$(getent passwd swa-daemon)" == "" ]; then
    echo "Adding swa-daemon user"
    useradd swa-daemon
else
    echo "Found swa-daemon user"
fi
