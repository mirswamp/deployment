#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

STAGING_AREA=$(readlink -e "$1")

#
# Prevent this script from going off into the wilderness.
#
if [ -z "$STAGING_AREA" ] || [ "$STAGING_AREA" = "/" ]; then
   exit 1
fi

set -x

#
# Set default permissions on files and directories.
# Assume that execute bits are set properly in source control.
#
chmod -R u=rwX,og=rX "$STAGING_AREA"

#
# Set the log directory to be writeable by anyone.
#
if [ -d "$STAGING_AREA"/opt/swamp/log ]; then
    chmod ug=rwx,o=rwxt "$STAGING_AREA"/opt/swamp/log
fi

#
# Set restrictive permissions on files that contain sensitive data.
# Leave directories traversable, though.
#
find "$STAGING_AREA" -name services.conf -exec chmod u=rw,og="" "{}" ";"
find "$STAGING_AREA" -name swamp.conf    -exec chmod u=rw,og="" "{}" ";"

for dir in \
        "$STAGING_AREA"/opt/swamp/sbin \
        "$STAGING_AREA"/opt/swamp/sql \
        ; do
    if [ -d "$dir" ]; then
        find "$dir" -type f -exec chmod u=rwX,og="" "{}" ";"
    fi
done

#
# Remove execute bits from the web application's files.
# They seem to get set in source control for no real reason.
#
for dir in \
        "$STAGING_AREA"/var/www/html \
        "$STAGING_AREA"/var/www/swamp-web-server \
        ; do
    if [ -d "$dir" ]; then
        find "$dir" -type f -exec chmod a-x "{}" ";"
    fi
done
