#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Installing SWAMP RPMs"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
RUNTIME=$BINDIR/runtime

. "$RUNTIME"/bin/swamp_utility.functions

############################################################################

rpms_dir=$1
release_num=$2
build_num=$3
mode=$4

if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

swamp_root=/opt/swamp
web_root=/var/www/html

asmt_backend_config=${swamp_root}/etc/swamp.conf
web_backend_config=${web_root}/swamp-web-server/.env
web_frontend_config=${web_root}/config/config.json

############################################################################

#
# We cannot do a fresh install of the SWAMP RPMs if there are SWAMP RPMs
# already installed. The 'yum install' will either behave as an upgrade, or
# see things as a downgrade and do nothing.
#
if [ "$mode" = "-install" ]; then
    yum_erase \
            swamp-rt-java swamp-rt-perl \
            swamp-web-server \
            swampinabox-backend swamponabox-backend \
        || : # do not put too much faith in 'yum's exit code
fi

#
# The install process for the SWAMP RPMs will set incorrect values in
# configuration files if there are stale '.rpmsave' files present. Scripts
# will copy old values forward from those files.
#
for file in \
        "$asmt_backend_config".rpmsave \
        "$web_backend_config".rpmsave \
        "$web_frontend_config".rpmsave \
        ; do
    if [ -f "$file" ]; then
        now=$(date +"%Y%m%d_%H%M%S")
        echo "Renaming $file to $file.$now"
        mv "$file" "$file.$now"
    fi
done

############################################################################

rpm_version=${release_num}-${build_num}
yum_install \
        "${rpms_dir}/swamp-rt-perl-${rpm_version}.noarch.rpm" \
        "${rpms_dir}/swampinabox-backend-${rpm_version}.noarch.rpm" \
        "${rpms_dir}/swamp-web-server-${rpm_version}.noarch.rpm" \
    || : # do not put too much faith in 'yum's exit code

wrong_rpms=""
for pkg in swamp-rt-perl swampinabox-backend swamp-web-server ; do
    if [ "$(get_rpm_version "$pkg")" != "$rpm_version" ]; then
        wrong_rpms="$wrong_rpms $pkg"
    fi
done

if [ ! -z "$wrong_rpms" ]; then
    echo
    echo "Error: Failed to install the SWAMP RPMs: ${wrong_rpms# }" 1>&2
    exit 1
fi

############################################################################

#
# TODO baydemir: Incorporate these tasks into their respective RPMs.
# They are properly viewed as ensuring that the RPMs install complete,
# internally consistent, and usable sets of files.
#

if [ ! -h "$web_root"/swamp-web-server ]; then
    echo "Creating symlink at ${web_root}/swamp-web-server"
    rm -f "$web_root"/swamp-web-server
    ln -s /var/www/swamp-web-server "$web_root"/swamp-web-server
fi

if [ "$mode" = "-install" ]; then
    echo "Creating $web_frontend_config"
    cp "$web_root"/config/config.swampinabox.json "$web_frontend_config"
fi

############################################################################

#
# The RPMs should be ensuring that the permissions on these files are set
# correctly, but there is no real harm in also setting them here.
#
echo "Setting permissions on $asmt_backend_config"
chown swa-daemon:mysql      "$asmt_backend_config"
chmod 440                   "$asmt_backend_config"

echo "Setting permissions on $web_backend_config"
chown apache:apache         "$web_backend_config"
chmod 400                   "$web_backend_config"

echo "Setting permissions on $web_frontend_config"
chown root:root             "$web_frontend_config"
chmod 444                   "$web_frontend_config"

############################################################################

#
# TODO baydemir: Incorporate these tasks into their respective RPMs.
# They are properly viewed as ensuring that the RPMs install complete,
# internally consistent, and usable sets of files.
#

echo "Updating $web_backend_config for Laravel 5.5"
"$RUNTIME"/sbin/swamp_copy_config -i "$web_backend_config" \
    --quote-for-laravel-55 \
    -o "$web_backend_config" \
    --no-space

echo "Setting Laravel APP_ENV in $web_backend_config"
"$RUNTIME"/sbin/swamp_patch_config -i "$web_backend_config" \
    --key "APP_ENV" \
    --val "SWAMP-in-a-Box" \
    --no-space

if [ "$mode" = "-install" ]; then
    echo "Setting Laravel APP_KEY in $web_backend_config"
    #
    # Set APP_KEY to nothing before generating it. The 'artisan'
    # command fails silently if it does not like the current value.
    #
    sed -i -E -e 's/^(\s*)APP_KEY(\s*)=(.*)$/APP_KEY=/' "$web_backend_config"
    (cd -- "$web_root"/swamp-web-server && php artisan key:generate --quiet)
fi

#
# Clear and rebuild Laravel's caches (CSA-3670).
#
php /var/www/swamp-web-server/artisan cache:clear
php /var/www/swamp-web-server/artisan route:cache
php /var/www/swamp-web-server/artisan package:discover

echo "Setting permissions on Laravel's working directories"
for dir in \
        "$web_root"/swamp-web-server/bootstrap/cache \
        "$web_root"/swamp-web-server/storage/app \
        "$web_root"/swamp-web-server/storage/framework \
        "$web_root"/swamp-web-server/storage/framework/cache \
        "$web_root"/swamp-web-server/storage/framework/sessions \
        "$web_root"/swamp-web-server/storage/framework/views \
        "$web_root"/swamp-web-server/storage/logs \
        ; do
    chown -R apache:apache "$dir"
done

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished installing the RPMs"
else
    echo
    echo "Finished installing the RPMs, but with errors" 1>&2
fi
exit $encountered_error
