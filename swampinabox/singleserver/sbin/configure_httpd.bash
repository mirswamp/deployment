#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Configuring Web Server components for SWAMP-in-a-Box."
echo

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

BINDIR=$(dirname "$0")

httpd_version="$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')"

config_dir=$BINDIR/../config_templates/httpd
httpd_conf_template=$config_dir/httpd-${httpd_version}.conf
sib_conf_template=$config_dir/swampinabox-${httpd_version}.conf

httpd_conf="/etc/httpd/conf/httpd.conf"
php_ini="/etc/php.ini"
sib_conf="/etc/httpd/conf.d/swampinabox.conf"
ssl_conf="/etc/httpd/conf.d/ssl.conf"

############################################################################

echo "Found httpd version '$httpd_version'"

case "$httpd_version" in
    2.2)
        echo "Copying $httpd_conf"
        cp "$httpd_conf_template" "$httpd_conf"
        ;;
    2.4)
        if [ ! -e "$sib_conf" ]; then
            echo "Restoring unmodified $httpd_conf, but with port 80 disabled"
            cp "$httpd_conf_template" "$httpd_conf"
        fi
        echo "Copying $sib_conf"
        cp "$sib_conf_template" "$sib_conf"
        ;;
    *)
        echo
        echo "Error: Unsupported version of httpd: $httpd_version" 1>&2
        encountered_error=1
esac

echo ""
"$BINDIR/swampinabox_patch_ssl_conf.pl" "$ssl_conf"

echo ""
echo "Patching $php_ini"

if ! "$BINDIR/runtime/sbin/swamp_patch_config" -i "$php_ini" \
            --key post_max_size \
            --val 800M \
            --key upload_max_filesize \
            --val 800M \
            --key max_execution_time \
            --val 120
then
    echo "" 1>&2
    echo "Warning: Failed to patch: $php_ini" 1>&2
    echo "Warning: Uploading large packages to the SWAMP might fail" 1>&2
    encountered_error=1
fi

exit $encountered_error
