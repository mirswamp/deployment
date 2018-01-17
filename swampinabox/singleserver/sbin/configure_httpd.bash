#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure Apache (httpd) for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

BINDIR="$(dirname "$0")"

httpd_ver="$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')"
httpd_conf_target="/etc/httpd/conf/httpd.conf"
httpd_conf_template="$BINDIR/../config_templates/httpd-${httpd_ver}.conf"
ssl_conf_target="/etc/httpd/conf.d/ssl.conf"
php_ini_target="/etc/php.ini"

############################################################################

echo "Detected 'httpd' version: $httpd_ver"

if [ -r "$httpd_conf_template" ]; then
    echo "Patching: $httpd_conf_target (from: $httpd_conf_template)"
    diff -wu "$httpd_conf_target" "$httpd_conf_template" | patch "$httpd_conf_target"
else
    echo "Error: $0: No such file (or file is not readable): $httpd_conf_template" 1>&2
    encountered_error=1
fi

############################################################################

"$BINDIR/swampinabox_patch_ssl_conf.pl" "$ssl_conf_target"

############################################################################

echo "Patching: $php_ini_target"
if ! "$BINDIR/swampinabox_patch_php_ini.pl" "$php_ini_target" ; then
    echo "Warning: Failed to patch: $php_ini_target" 1>&2
    echo "Warning: Uploading large packages to the SWAMP might fail" 1>&2
    encountered_error=1
fi

exit $encountered_error
