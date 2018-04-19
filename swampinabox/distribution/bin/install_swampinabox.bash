#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on the current host.
#

BINDIR="$(dirname "$0")"
relayhost="\$mydomain"
now="$(date +"%Y%m%d_%H%M%S")"

#
# Determine the install type, log file location, etc.
#
if [ -d "$BINDIR/../log" ]; then
    swamp_log_dir="$BINDIR/../log"
else
    swamp_log_dir="."
fi

if [[ "$0" =~ install_swampinabox ]]; then
    MODE="-install"
    swamp_log_file="$swamp_log_dir/install_swampinabox_$now.log"
else
    MODE="-upgrade"
    swamp_log_file="$swamp_log_dir/upgrade_swampinabox_$now.log"
fi

WORKSPACE="$BINDIR/.."
read -r RELEASE_NUMBER BUILD_NUMBER < "$BINDIR/version.txt"

#
# Execute the core of the install/upgrade process.
#
set -o pipefail
"$BINDIR/../sbin/swampinabox_do_install.bash" \
        "$WORKSPACE" \
        "$RELEASE_NUMBER" \
        "$BUILD_NUMBER" \
        "$relayhost" \
        "$MODE" \
        "$swamp_log_file" \
        "-distribution" \
    |& tee "$swamp_log_file"
main_install_exit_code=$?

#
# Copy the log file for the install/upgrade, if we can.
#
if [ -d /opt/swamp/log ]; then
    cp "$swamp_log_file" /opt/swamp/log
fi
exit $main_install_exit_code
