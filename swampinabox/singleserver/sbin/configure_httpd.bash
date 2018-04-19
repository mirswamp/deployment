#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure Apache (httpd) for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

BINDIR=$(dirname "$0")

httpd_version="$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')"
httpd_conf_template="$BINDIR/../config_templates/httpd-${httpd_version}.conf"

httpd_conf="/etc/httpd/conf/httpd.conf"
php_ini="/etc/php.ini"
ssl_conf="/etc/httpd/conf.d/ssl.conf"

############################################################################

echo "Found httpd version $httpd_version"

if [ -f "$httpd_conf_template" ]; then
    echo "Patching $httpd_conf"
    diff -wu "$httpd_conf" "$httpd_conf_template" | patch "$httpd_conf"
else
    echo "" 1>&2
    echo "Error: No such file: $httpd_conf_template" 1>&2
    encountered_error=1
fi

echo ""
"$BINDIR/swampinabox_patch_ssl_conf.pl" "$ssl_conf"

echo ""
echo "Patching $php_ini"

if ! /opt/swamp/sbin/swamp_patch_config -i "$php_ini" \
            --key post_max_size \
            --val 800M \
            --key upload_max_filesize \
            --val 800M
then
    echo "" 1>&2
    echo "Warning: Failed to patch: $php_ini" 1>&2
    echo "Warning: Uploading large packages to the SWAMP might fail" 1>&2
    encountered_error=1
fi

exit $encountered_error
