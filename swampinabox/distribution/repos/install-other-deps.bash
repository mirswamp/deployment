#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

BINDIR="$(dirname "$0")"

. "$BINDIR/resources/common-helper.functions"

trap "exit_with_error" ERR

function enable_service() {
    service="$1"

    echo "Enabling service: $service"

    if which systemctl 1>/dev/null 2>/dev/null ; then
        systemctl enable "$service"
        return $?
    else
        chkconfig "$service" on
        return $?
    fi
    return 1
}

############################################################################

check_user
check_os_dist_upgrade

echo ""
echo "#########################################"
echo "##### Installing SWAMP dependencies #####"
echo "#########################################"

common_pkgs_to_install=(ant bind-utils curl git httpd libguestfs libguestfs-tools libguestfs-tools-c libvirt mod_ssl ncompress patch perl rubygems unzip zip)

yum_install /usr/bin/scp "${common_pkgs_to_install[@]}"
yum_confirm /usr/bin/scp "${common_pkgs_to_install[@]}"

echo ""
echo "################################"
echo "##### Configuring Services #####"
echo "################################"

if [ -e /usr/lib/systemd/system/mariadb.service -a ! -e /etc/systemd/system/mysql.service ]; then
    echo "Creating symlink from 'mysql.service' to 'mariadb.service'"
    ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
fi

if [ -e /usr/lib/systemd/system/mariadb.service ]; then
    enable_service mariadb
fi

if [ -e /etc/rc.d/init.d/mysql ]; then
    enable_service mysql
fi

enable_service condor
enable_service httpd
enable_service libvirtd

echo ""
echo "#################################################"
echo "##### Creating SWAMP-specific User Accounts #####"
echo "#################################################"

if [ "$(getent passwd swa-daemon)" = "" ]; then
    echo "Adding user: swa-daemon"
    useradd swa-daemon
else
    echo "Found user: swa-daemon"
fi

echo ""
echo "Finished."
exit 0
