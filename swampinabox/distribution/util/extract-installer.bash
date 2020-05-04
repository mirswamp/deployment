#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Extract the SWAMP-in-a-Box installer.
# The tar file(s) must be in the same directory as this script.
#

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

#
# This version string should be replaced with a real value when the
# build script assembles the final, distributable installer bundle.
#
version=SED_VERSION

#
# The locations of the installer tar file(s) and final directory.
#
installer_dir=$BINDIR/swampinabox-$version-installer
installer_tar_file=$BINDIR/swampinabox-$version-installer.tar.gz

############################################################################

if [ ! -r "$installer_tar_file" ]; then
    echo "Error: File is not readable: $installer_tar_file" 1>&2
    exit 1
fi

echo "Extracting: $installer_tar_file"
echo ""
if ! tar -xzv --no-same-owner --no-same-permissions -C "$BINDIR" -f "$installer_tar_file" ; then
    echo "" 1>&2
    echo "Error: Something unexpected happened, check above for details" 1>&2
    exit 1
fi
echo ""
echo "The SWAMP-in-a-Box installer can be found in:"
echo ""
echo "    $installer_dir"
echo ""
