#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on the current host.
#

BINDIR="$(dirname "$0")"
relayhost="128.104.153.20"
now="$(date +"%Y%m%d_%H%M%S")"

#
# Ensure that we're running as 'root' because we will be creating the
# DB password files here, before running the core install/upgrade script.
#
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

#
# Ensure that temporary DB password files get removed.
#
source "$BINDIR/../sbin/swampinabox_install_util.functions"
trap 'remove_db_password_files' EXIT
trap 'remove_db_password_files ; exit 1' INT TERM

#
# Determine the install type, log file location, etc.
#
if [ -d "$BINDIR/../log" ]; then
    swamp_log_dir="$BINDIR/../log"
else
    swamp_log_dir="."
fi

if [[ "$0" =~ install_swampinabox ]]; then
    source "$BINDIR/../sbin/getargs.function"
    getargs "-install $*" || exit 1
    swamp_log_file="$swamp_log_dir/install_swampinabox_$now.log"
else
    source "$BINDIR/../sbin/getargs.function"
    getargs "-upgrade $*" || exit 1
    swamp_log_file="$swamp_log_dir/upgrade_swampinabox_$now.log"
fi

#
# Attempt to ensure that the SWAMP Git repositories have been checked out
# into the expected locations.
#
for repo in db deployment proprietary services swamp-web-server www-front-end; do
    if [ ! -d "$WORKSPACE/$repo" ]; then
        echo "Error: Missing SWAMP Git repository: $WORKSPACE/$repo" 1>&2
        exit 1
    fi
done

#
# Save encrypted DB password(s) into files for use by other scripts.
# Minimize the chance of the passwords appearing in process listings.
#
reset_umask=$(umask -p)
umask 0377

echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 0400 /etc/.mysql_root
echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 0400 /etc/.mysql_web
echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 0400 /etc/.mysql_java
echo "$SWAMPADMINPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 0400 /etc/.mysql_admin

$reset_umask

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
        "-singleserver" \
    |& tee "$swamp_log_file"
main_install_exit_code=$?

#
# Copy the log file for the install/upgrade, if we can.
#
if [ -d /opt/swamp/log ]; then
    cp "$swamp_log_file" /opt/swamp/log
fi
exit $main_install_exit_code
