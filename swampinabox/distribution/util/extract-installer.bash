#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

#
# Assuming the SWAMP-in-a-Box distribution tarballs are in the same
# directory as this script, this script will create a directory for the
# SWAMP-in-a-Box installer and extract the tarballs into it.
#

tarballs_dir=$BINDIR
installer_dir=$tarballs_dir/swampinabox-installer
installer_log_dir=$installer_dir/log

exit_with_error() {
    echo ""
    echo "Error encountered. Check above for details."
    exit 1
}

echo "Creating ${installer_dir#./}"
mkdir -p "$installer_dir" || exit_with_error

echo "Creating ${installer_log_dir#./}"
mkdir -p "$installer_log_dir" || exit_with_error

sleep 2  # Pause so that the user can see that directories were created

for tarball in "$tarballs_dir"/*.tar.gz; do
    echo ""
    echo "Extracting ${tarball#./}"
    tar -xzv --no-same-owner --no-same-permissions -C "${installer_dir}" -f "${tarball}" || exit_with_error
done

echo ""
echo "The SWAMP-in-a-Box installer can be found in: ${installer_dir}"
