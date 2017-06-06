#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`
RELEASE_NUMBER="$1"

#
# Install the platforms for the current release.
#

SOURCE_TARBALL="$BINDIR/../../swampinabox-${RELEASE_NUMBER}-platforms.tar.gz"
DESTINATION_DIR="/swamp/platforms/images"

if [ ! -r "$SOURCE_TARBALL" ]; then
    echo "Error: $SOURCE_TARBALL does not exist or is not readable"
    exit 1
fi

echo "Extracting platforms into $DESTINATION_DIR"
tar -C "$DESTINATION_DIR" --strip-components 1 -zxvf "$SOURCE_TARBALL"

chown -R root:root "$DESTINATION_DIR"
find "$DESTINATION_DIR" -type d -exec chmod u=rwx,og=rx,ugo-s '{}' ';'
find "$DESTINATION_DIR" -type f -exec chmod u=rw,og=r,ugo-s   '{}' ';'

#
# Delete platforms from older releases that have been deprecated.
#

function remove_file() {
    target="$1"
    if [ -e "$target" ]; then
        echo "Removing $target"
        rm -f "$target"
    fi
}

echo "Checking for deprecated platforms"
for file_to_remove in \
        /swamp/platforms/images/condor-debian-7.0-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-dynamic-centos-6.8-64-viewer-master-2016080901.qcow2 \
        /swamp/platforms/images/condor-dynamic-centos-6.8-64-viewer-master-2016102101.qcow2 \
        /swamp/platforms/images/condor-fedora-19.0-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-scientific-5.9-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-scientific-6.4-64-master-2015071401.qcow2 \
        /swamp/platforms/images/condor-ubuntu-12.04-64-master-2015012801.qcow2 \
        ; do
    remove_file "$file_to_remove"
done

#
# Update the database to match what's available.
#

echo "Updating database with currently installed platforms"

service mysql start
/opt/swamp/sbin/rebuild_db_platforms
service mysql stop
