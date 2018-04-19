#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install the SWAMP RPMs and update associated configuration files.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
workspace=$1
release_number=$2
build_number=$3
mode=$4

config_json="/var/www/html/config/config.json"
dot_env="/var/www/swamp-web-server/.env"
swamp_conf="/opt/swamp/etc/swamp.conf"

source "$BINDIR/swampinabox_install_util.functions"

############################################################################

echo "Mode: $mode"
echo "Release number: $release_number"
echo "Build number: $build_number"
echo "Workspace: $workspace"

if [ "$mode" = "-install" ]; then
    echo ""
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
    if [ "$(get_rpm_version "$pkg")" != "${release_number}-${build_number}" ]; then
        rpms_to_install+=($workspace/RPMS/${pkg}-${release_number}-${build_number}.noarch.rpm)
    fi
done

if [ ${#rpms_to_install[@]} -ne 0 ]; then
    echo ""
    echo "Installing new SWAMP RPMs"
    yum_install "${rpms_to_install[@]}"

    rpms_with_wrong_version=$(check_rpm_versions "${release_number}-${build_number}" swamp-rt-perl swampinabox-backend swamp-web-server)

    if [ ! -z "$rpms_with_wrong_version" ]; then
        echo "Error: Expected versions of RPMs not installed: $rpms_with_wrong_version" 1>&2
        exit 1
    fi
else
    echo "All RPMs appear to be installed already"
fi

echo ""

if [ ! -h /var/www/html/swamp-web-server ]; then
    echo "Creating symlinks for SWAMP web server directories"
    ln -s /var/www/swamp-web-server /var/www/html/swamp-web-server
fi

if [ "$mode" = "-install" ]; then
    echo "Creating the initial version of $(basename "$config_json")"
    cp /var/www/html/config/config.swampinabox.json "$config_json"
fi

echo "Setting file system permissions on $(basename "$config_json")"
chown root:root "$config_json"
chmod 444       "$config_json"

echo "Setting file system permissions on $(basename "$dot_env")"
chown apache:apache "$dot_env"
chmod 400           "$dot_env"

echo "Setting file system permissions on $(basename "$swamp_conf")"
chown swa-daemon:mysql "$swamp_conf"
chmod 440              "$swamp_conf"

echo "Patching $(basename "$dot_env")"
sed -i -e "s/SED_ENVIRONMENT/SWAMP-in-a-Box/" "$dot_env"
/opt/swamp/sbin/swamp_copy_config -i "$dot_env" -o "$dot_env" --no-space --quote-for-laravel-55

if [ "$mode" = "-install" ]; then
    echo "Setting Laravel application key"
    #
    # CSA-3156: Set APP_KEY to nothing before generating it. The 'artisan'
    # command fails silently if it doesn't like the current value.
    #
    sed -i -e 's/^\s*APP_KEY\s*=.*$/APP_KEY=/' "$dot_env"
    (cd /var/www/swamp-web-server ; php artisan key:generate --quiet)
fi

exit $encountered_error
