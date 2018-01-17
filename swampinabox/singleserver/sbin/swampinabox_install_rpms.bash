#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install the SWAMP RPMs and update associated configuration files.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
MODE="$4"

. "$BINDIR/swampinabox_install_util.functions"

old_swamp_web_server_version="$(get_rpm_version swamp-web-server)"

############################################################################

echo "Workspace: $WORKSPACE"
echo "Release number: $RELEASE_NUMBER"
echo "Build number: $BUILD_NUMBER"
echo "Mode: $MODE"

echo ""
echo "Stopping services"
"$BINDIR/manage_services.bash" stop httpd condor mysql

if [ "$MODE" = "-install" ]; then
    echo ""
    echo "Removing currently installed SWAMP RPMs"
    for pkg in \
            swamp-rt-java \
            swamp-rt-perl \
            swamp-web-server \
            swampinabox-backend \
            swamponabox-backend \
            ; do
        if yum_confirm "$pkg" ; then
            yum_erase "$pkg"
        fi
    done
fi

echo ""
echo "Checking for old '.rpmsave' files"
for file in /opt/swamp/etc/swamp.conf.rpmsave \
            /var/www/html/config/config.json.rpmsave \
            /var/www/html/scripts/config.js.rpmsave \
            /var/www/html/scripts/config/config.js.rpmsave \
            /var/www/swamp-web-server/.env.rpmsave \
            ; do
    if [ -f "$file" ]; then
        now="$(date +"%Y%m%d%H%M%S")"
        src_file="$file"
        dest_file="$file.$now"

        echo "Renaming '$src_file' to '$dest_file'"
        mv "$src_file" "$dest_file"
    fi
done

echo ""
echo "Determining RPMs to install"

rpms_to_install=()

for pkg in swamp-rt-perl swampinabox-backend swamp-web-server; do
    if [ "$(get_rpm_version "$pkg")" != "${RELEASE_NUMBER}-${BUILD_NUMBER}" ]; then
        rpms_to_install+=($WORKSPACE/RPMS/${pkg}-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm)
    fi
done

if [ ${#rpms_to_install[@]} -ne 0 ]; then
    echo ""
    echo "Installing new SWAMP RPMs"
    yum_install "${rpms_to_install[@]}"

    rpms_with_wrong_version=$(check_rpm_versions "${RELEASE_NUMBER}-${BUILD_NUMBER}" swamp-rt-perl swampinabox-backend swamp-web-server)

    if [ ! -z "$rpms_with_wrong_version" ]; then
        encountered_error=1
        echo "Error: $0: Expected versions of RPMs not installed: $rpms_with_wrong_version" 1>&2
        exit_with_error
    fi
else
    echo "All RPMs appear to be installed already"
fi

echo ""

if [ ! -h /var/www/html/swamp-web-server ]; then
    echo "Creating symlinks for SWAMP web server directories"
    ln -s /var/www/swamp-web-server /var/www/html/swamp-web-server
fi

if [ "$MODE" = "-install" ]; then
    echo "Setting Laravel application key"
    (cd /var/www/swamp-web-server ; php artisan key:generate --quiet)
fi

echo "Setting permissions on swamp.conf"
chgrp mysql /opt/swamp/etc/swamp.conf
chmod 440   /opt/swamp/etc/swamp.conf

echo "Setting permissions on SWAMP backend web server configuration"
chown apache:apache /var/www/swamp-web-server/.env
chmod 400           /var/www/swamp-web-server/.env

echo "Setting permissions on SWAMP frontend web server configuration"
if [ "$MODE" = "-install" ]; then
    cp /var/www/html/config/config.swampinabox.json /var/www/html/config/config.json
fi
chown root:root /var/www/html/config/config.json
chmod 444       /var/www/html/config/config.json

echo "Patching SWAMP backend web server configuration"
sed -i -e "s/SED_ENVIRONMENT/SWAMP-in-a-Box/" /var/www/swamp-web-server/.env

exit $encountered_error
