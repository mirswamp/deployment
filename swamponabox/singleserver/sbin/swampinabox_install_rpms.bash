#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/swampinabox_install_util.functions

# uses WORKSPACE, RELEASE_NUMBER, BUILD_NUMBER, EMAIL, MODE
WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
EMAIL="$4"
MODE="$5"

if [ "$MODE" == "-install" ]; then
    echo "Installing RPMS"
else
    echo "Upgrading RPMS"
fi

echo ""
echo "WORKSPACE: $WORKSPACE"
echo "RELEASE_NUMBER: $RELEASE_NUMBER"
echo "BUILD_NUMBER: $BUILD_NUMBER"
echo "EMAIL: $EMAIL"
echo "MODE: $MODE"

#
# Determine httpd.conf file to use.
#

httpd_ver=$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')

echo ""
echo "Detected httpd version: ${httpd_ver}"

if [ ! -e $BINDIR/../swampinabox_web_config/httpd-${httpd_ver}.conf ]; then
    echo "Error: Cannot find source file for patching httpd.conf"
fi

echo ""
echo "Stopping services"
service mysql stop
service httpd stop
service condor stop

if [ "$MODE" == "-install" ]; then
    echo ""
    echo "Removing current SWAMP RPMs"
    yum_erase \
        swamp-rt-java.noarch \
        swamp-rt-perl.noarch \
        swamp-web-server.noarch \
        swampinabox-backend.noarch \
        swamponabox-backend.noarch
fi

echo ""
echo "Installing SWAMP runtime components"
yum_install $WORKSPACE/RPMS/swamp-rt-java-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm
yum_install $WORKSPACE/RPMS/swamp-rt-perl-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP web server"
yum_install $WORKSPACE/RPMS/swamp-web-server-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP backend"
yum_install $WORKSPACE/RPMS/swampinabox-backend-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Finished installing SWAMP RPMs"
yum_confirm swamp-rt-java swamp-rt-perl swamp-web-server swampinabox-backend || exit_with_error

echo ""
echo "Configuring SWAMP daemons"
cp -rf $BINDIR/../swampinabox_installer/config/swampinabox.conf /opt/swamp/etc/.
chown swa-daemon:swa-daemon /opt/swamp/etc/swampinabox.conf
chmod 750 /opt/swamp/etc/swampinabox.conf
cp -rf $BINDIR/../swampinabox_installer/scripts/swampd-swampinabox /etc/init.d/swamp
chown swa-daemon:swa-daemon /etc/init.d/swamp
chmod 755 /etc/init.d/swamp

echo "Patching swamp.conf"
sed -i "s/HOSTNAME/$HOSTNAME/g" /opt/swamp/etc/swamp.conf
chgrp mysql /opt/swamp/etc/swamp.conf
chmod 440 /opt/swamp/etc/swamp.conf

echo "Patching templ.xml"
diff -wu /usr/local/etc/swamp/templ.xml $BINDIR/../swampinabox_installer/templ.xml | patch /usr/local/etc/swamp/templ.xml

if [ "$MODE" == "-install" ]; then
    echo ""
    echo "Configuring web server"
    if [ ! -h /var/www/html/swamp-web-server ]; then
        ln -s /var/www/swamp-web-server /var/www/html/swamp-web-server
    fi

    echo "Patching SWAMP backend web server configuration"
    cat $BINDIR/../swampinabox_web_config/swamp-web-server/env.swamp-web-server | sed -e "s/HOSTNAME/$HOSTNAME/g" > /var/www/swamp-web-server/.env

    echo "Setting SWAMP backend web server Laravel application key"
    (cd /var/www/swamp-web-server ; php artisan key:generate --quiet)

    echo "Patching SWAMP frontend web server configuration"
    cat $BINDIR/../swampinabox_web_config/html/scripts/config.js | sed -e "s/HOSTNAME/$HOSTNAME/g" > /var/www/html/scripts/config.js

    echo "Patching httpd.conf"
    diff -wu /etc/httpd/conf/httpd.conf $BINDIR/../swampinabox_web_config/httpd-${httpd_ver}.conf | patch /etc/httpd/conf/httpd.conf

    echo "Patching php.ini"
    $BINDIR/../sbin/swampinabox_patch_php_ini.pl /etc/php.ini

    patch_php_ok=$?
    if [ $patch_php_ok -ne 0 ]; then
        echo "Warning: Failed to patch php.ini file."
        echo "Warning: Uploading large packages to SWAMP might fail."
    fi
fi

if [ -f /etc/sysconfig/iptables ]; then
    echo "Patching iptables"
    diff -wu /etc/sysconfig/iptables $BINDIR/../swampinabox_web_config/iptables | patch /etc/sysconfig/iptables
else
    install -m 600 -o root -g root $BINDIR/../swampinabox_web_config/iptables /etc/sysconfig/iptables
fi
service iptables restart

exit 0
