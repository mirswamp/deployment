#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/swampinabox_install_util.functions

WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
MODE="$4"

if [ "$MODE" == "-install" ]; then
    echo ""
    echo "Installing RPMS"
else
    echo ""
    echo "Upgrading RPMS"
fi

echo ""
echo "WORKSPACE: $WORKSPACE"
echo "RELEASE_NUMBER: $RELEASE_NUMBER"
echo "BUILD_NUMBER: $BUILD_NUMBER"
echo "MODE: $MODE"

#
# Determine httpd.conf file to use.
#

httpd_ver=$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')

echo ""
echo "Detected httpd version: ${httpd_ver}"

if [ ! -e $BINDIR/../config_templates/httpd-${httpd_ver}.conf ]; then
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

    for file in /opt/swamp/etc/swamp.conf.rpmsave \
                /var/www/html/config/config.json.rpmsave \
                /var/www/html/scripts/config.js.rpmsave \
                /var/www/html/scripts/config/config.js.rpmsave \
                /var/www/swamp-web-server/.env.rpmsave; do
        if [ -e "$file" ]; then
            now=$(date +"%Y%m%d_%H%M%S")
            src_file="$file"
            dest_file="$file.$now.swampinabox"

            echo "Renaming $src_file to $dest_file"
            mv "$src_file" "$dest_file"
        fi
    done
fi

if [ "$MODE" == "-upgrade" ]; then
    #
    # When upgrading the 'swamp-web-server' RPM from 1.27, something
    # apparently gets confused about /var/www/html/scripts/config.js no
    # longer being marked as a configuration file. Our workaround is to
    # remove the old RPM, install the new RPM (below), and rely on the RPM's
    # post-script to copy over configuration settings as needed.
    #
    swamp_web_server_ver=$(rpm -q --qf '%{VERSION}' swamp-web-server)

    if [[ "$swamp_web_server_ver" =~ 1.27 ]]; then
        yum_erase swamp-web-server.noarch
    fi
fi

echo ""
echo "Installing SWAMP runtime components"
yum_install $WORKSPACE/RPMS/swamp-rt-java-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm
yum_install $WORKSPACE/RPMS/swamp-rt-perl-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP backend"
yum_install $WORKSPACE/RPMS/swampinabox-backend-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP web server"
yum_install $WORKSPACE/RPMS/swamp-web-server-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Finished installing SWAMP RPMs"
yum_confirm swamp-rt-java swamp-rt-perl swampinabox-backend swamp-web-server || exit_with_error

echo ""
echo "Setting permissions on swamp.conf"
chgrp mysql /opt/swamp/etc/swamp.conf
chmod 440 /opt/swamp/etc/swamp.conf

echo ""
echo "Creating symlinks for SWAMP web server directories"
if [ ! -h /var/www/html/swamp-web-server ]; then
    ln -s /var/www/swamp-web-server /var/www/html/swamp-web-server
fi

echo "Patching SWAMP backend web server configuration"
sed -i -e "s/SED_ENVIRONMENT/SWAMP-in-a-Box/"  /var/www/swamp-web-server/.env

echo "Setting permissions on SWAMP backend web server configuration"
chown apache:apache /var/www/swamp-web-server/.env
chmod 400           /var/www/swamp-web-server/.env

if [ "$MODE" = "-install" ]; then
    echo "Setting Laravel application key"
    (cd /var/www/swamp-web-server ; php artisan key:generate --quiet)
fi

echo "Setting permissions SWAMP frontend web server configuration"
if [ "$MODE" = "-install" ]; then
    cp /var/www/html/config/config.swampinabox.json /var/www/html/config/config.json
fi
chown root:root /var/www/html/config/config.json
chmod 444       /var/www/html/config/config.json

echo "Patching httpd.conf"
diff -wu /etc/httpd/conf/httpd.conf $BINDIR/../config_templates/httpd-${httpd_ver}.conf | patch /etc/httpd/conf/httpd.conf

echo "Patching php.ini"
$BINDIR/../sbin/swampinabox_patch_php_ini.pl /etc/php.ini

patch_php_ok=$?
if [ $patch_php_ok -ne 0 ]; then
    echo "Warning: Failed to patch php.ini file."
    echo "Warning: Uploading large packages to SWAMP might fail."
fi

exit 0
