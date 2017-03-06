#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`

#
# Install the platforms for the current release.
#

srcplatforms="$BINDIR/../swampsrc/platforms"
dstplatforms="/swamp/platforms/images"

if [ ! -d "$srcplatforms" ];
then
    echo "No $srcplatforms directory for this install"
    exit
fi

for platform in $srcplatforms/*.qcow2
do
    base=$(basename $platform)
    path="${base//condor-/}"
    path="${path//-master*/}"
    if [ ! -r "$dstplatforms/$base" ]; then
        echo "cp $platform $dstplatforms"
        cp $platform $dstplatforms
    else
        echo "Found: $dstplatforms/$base"
    fi
done

chown -R root:root $dstplatforms
chmod 755 $dstplatforms
chmod 644 $dstplatforms/*

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
