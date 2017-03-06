#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`
CHECK_CONTENTS=""
DRY_RUN=""
WORKSPACE="../../../.."

#
# Define a wrapper for rsync.
#

function do_rsync() {
    src=$1
    dst=$2

    # Sync recursively, preserving time stamps.  By default, rsync uses file
    # size and mod time to determine whether to skip a file.
    #
    # Do not sync other metadata --- such as permissions, owner, group ---
    # because that needs to be determined by the live install.

    rsync -rtlvP \
          --exclude-from="$BINDIR/update_web_files.ignore_list" \
          $DRY_RUN \
          $CHECK_CONTENTS \
          $src \
          $dst
}

#
# Check for command-line options.
#

args=($*)
for arg in "${args[@]}"
do
    if [[ $arg =~ "dry" || $arg == "-n" ]]; then
        DRY_RUN="--dry-run"
    elif [[ $arg =~ "force" || $arg =~ "check" || $arg == "-c" ]]; then
        CHECK_CONTENTS="--checksum"
    elif [[ $arg == "-nc" || $arg == "-cn" ]]; then
        DRY_RUN="--dry-run"
        CHECK_CONTENTS="--checksum"
    else
        echo "Warning: Option not recognized: $arg"
    fi
done

#
# Sync directories.
#

if [ "$(whoami)" != "root" ]; then
    echo "Warning: This will likely fail if you're not root or using sudo."
    echo -n "Continue anyway? [N/y] "
    read ANSWER
    if [ "$ANSWER" != "y" ]; then
        echo "Exiting ..."
        exit
    fi
fi

do_rsync $WORKSPACE/swamp-web-server/	/var/www/swamp-web-server
do_rsync $WORKSPACE/www-front-end/		/var/www/html
