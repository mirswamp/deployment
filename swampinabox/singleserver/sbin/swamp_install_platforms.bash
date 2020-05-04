#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Install the platform files for the current SWAMP-in-a-Box release.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
swamp_context=$1
release_number=$2

#
# For the 'distribution' version of SWAMP-in-a-Box.
#
old_install_dir="/swamp/platforms/images"
new_install_dir="/swamp/platforms/images"
source_tarball="$BINDIR/../../swampinabox-${release_number}-platforms.tar.gz"

############################################################################

function remove_deprecated_distribution_files() {
    echo "Checking for and removing deprecated platform files"
    for old_file in \
            condor-centos-5.11-32-master-2016080901.qcow2 \
            condor-centos-5.11-64-master-2016080901.qcow2 \
            condor-debian-7.0-64-master-2015012801.qcow2 \
            condor-debian-7.11-64-master-2016100501.qcow2 \
            condor-debian-7.11-64-master-2018091101.qcow2 \
            condor-debian-7.11-64-master-2019010100.qcow2 \
            condor-debian-8.6-64-master-2016100501.qcow2 \
            condor-debian-8.11-64-master-2018091101.qcow2 \
            condor-debian-8.11-64-master-2019010100.qcow2 \
            condor-dynamic-centos-6.8-64-viewer-master-2016080901.qcow2 \
            condor-dynamic-centos-6.8-64-viewer-master-2016102101.qcow2 \
            condor-fedora-19.0-64-master-2015012801.qcow2 \
            condor-fedora-18-64-master-2019010100.qcow2 \
            condor-fedora-19-64-master-2019010100.qcow2 \
            condor-fedora-20-64-master-2019010100.qcow2 \
            condor-scientific-5.9-64-master-2015012801.qcow2 \
            condor-scientific-5.11-32-master-2016080901.qcow2 \
            condor-scientific-5.11-64-master-2016080901.qcow2 \
            condor-scientific-6.4-64-master-2015071401.qcow2 \
            condor-ubuntu-10.04-64-master-2016102702.qcow2 \
            condor-ubuntu-12.04-64-master-2015012801.qcow2 \
            condor-ubuntu-12.04-64-master-2016102702.qcow2 \
            condor-ubuntu-12.04-64-master-2019010100.qcow2 \
            condor-ubuntu-16.04-64-master-2016102702.qcow2 \
            condor-ubuntu-16.04-64-master-2017092701.qcow2 \
            condor-ubuntu-16.04-64-master-2018012401.qcow2 \
            condor-ubuntu-16.04-64-master-2018070301.qcow2 \
            condor-ubuntu-16.04-64-master-2019010100.qcow2 \
            condor-ubuntu-16.04-64-master-2019082701.qcow2 \
            condor-universal-centos-6.8-64-viewer-master-2016110801.qcow2 \
            condor-universal-centos-6.9-64-viewer-master-2017101001.qcow2 \
            condor-universal-centos-6.9-64-viewer-master-2018032001.qcow2 \
            ; do
        file_to_remove="${old_install_dir}/${old_file}"
        if [ -f "$file_to_remove" ]; then
            echo "Removing: $file_to_remove"
            rm -f "$file_to_remove"
        fi
    done
    echo "Finished checking for and removing deprecated files"
}

############################################################################

function extract_distribution_bundle() {
    echo "Extracting bundled platform files into: $new_install_dir"
    echo "(this will take some time)"
    tar -C "$new_install_dir" --strip-components 1 -zxvf "$source_tarball"
    echo "Finished extracting files"

    echo "Setting file system permissions"
    chown -R root:root "$new_install_dir"
    find "$new_install_dir" -type d -exec chmod u=rwx,og=rx,ugo-s '{}' ';'
    find "$new_install_dir" -type f -exec chmod u=rw,og=r,ugo-s   '{}' ';'
}

############################################################################

if [ "$swamp_context" = "-distribution" ]; then
    remove_deprecated_distribution_files
    extract_distribution_bundle

    if [ $encountered_error -eq 0 ]; then
        echo "Finished installing platform files"
    else
        echo "Error: Finished installing platform files, but with errors" 1>&2
    fi
fi
exit $encountered_error
