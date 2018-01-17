#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install the bundled platforms for the current SWAMP-in-a-Box release.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
SWAMP_CONTEXT="$1"
RELEASE_NUMBER="$2"

#
# For the 'distribution' version of SWAMP-in-a-Box.
#
SOURCE_TARBALL="$BINDIR/../../swampinabox-${RELEASE_NUMBER}-platforms.tar.gz"
DESTINATION_DIR="/swamp/platforms/images"

############################################################################

function remove_deprecated_distribution_files() {
    echo "Checking for and removing deprecated platform files"
    for file_to_remove in \
            /swamp/platforms/images/condor-centos-5.11-32-master-2016080901.qcow2 \
            /swamp/platforms/images/condor-centos-5.11-64-master-2016080901.qcow2 \
            /swamp/platforms/images/condor-debian-7.0-64-master-2015012801.qcow2 \
            /swamp/platforms/images/condor-dynamic-centos-6.8-64-viewer-master-2016080901.qcow2 \
            /swamp/platforms/images/condor-dynamic-centos-6.8-64-viewer-master-2016102101.qcow2 \
            /swamp/platforms/images/condor-fedora-19.0-64-master-2015012801.qcow2 \
            /swamp/platforms/images/condor-scientific-5.9-64-master-2015012801.qcow2 \
            /swamp/platforms/images/condor-scientific-5.11-32-master-2016080901.qcow2 \
            /swamp/platforms/images/condor-scientific-5.11-64-master-2016080901.qcow2 \
            /swamp/platforms/images/condor-scientific-6.4-64-master-2015071401.qcow2 \
            /swamp/platforms/images/condor-ubuntu-12.04-64-master-2015012801.qcow2 \
            /swamp/platforms/images/condor-ubuntu-16.04-64-master-2016102702.qcow2 \
            /swamp/platforms/images/condor-universal-centos-6.8-64-viewer-master-2016110801.qcow2 \
            ; do
        if [ -f "$file_to_remove" ]; then
            echo ".. Removing: $file_to_remove"
            rm -f "$file_to_remove"
        fi
    done
}

############################################################################

function extract_distribution_platforms_bundle() {
    if [ ! -r "$SOURCE_TARBALL" ]; then
        echo "Error: $0: No such file (or file is not readable): $SOURCE_TARBALL" 1>&2
        exit 1
    fi
    if [ ! -d "$DESTINATION_DIR" ]; then
        echo "Error: $0: No such directory: $DESTINATION_DIR" 1>&2
        exit 1
    fi

    echo "Extracting bundled platform files into: $DESTINATION_DIR"
    tar -C "$DESTINATION_DIR" --strip-components 1 -zxvf "$SOURCE_TARBALL"

    echo "Setting filesystem permissions on the platform files"
    chown -R root:root "$DESTINATION_DIR"
    find "$DESTINATION_DIR" -type d -exec chmod u=rwx,og=rx,ugo-s '{}' ';'
    find "$DESTINATION_DIR" -type f -exec chmod u=rw,og=r,ugo-s   '{}' ';'
}

############################################################################

#
# Update the platform image files on the filesystem.
#
if [ "$SWAMP_CONTEXT" = "-distribution" ]; then
    remove_deprecated_distribution_files
    extract_distribution_platforms_bundle

elif [ "$SWAMP_CONTEXT" = "-singleserver" -o "$SWAMP_CONTEXT" = "-mir-swamp" ]; then
    #
    # Do not modify the filesystem. Gluster should be up-to-date already.
    #
    echo "Skipping installation of platform images: Context is: $SWAMP_CONTEXT"

else
    echo "Error: $0: Unknown SWAMP context: $SWAMP_CONTEXT" 1>&2
    exit 1
fi

#
# Rebuild the "platforms" database based on the available platform image files.
#
/opt/swamp/sbin/rebuild_platforms_db

exit $encountered_error
