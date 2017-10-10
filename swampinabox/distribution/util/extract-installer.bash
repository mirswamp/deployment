#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Extract the SWAMP-in-a-Box installer.
# Assumes that this script is in the same directory as the tarballs.
#

BINDIR="$(dirname "$0")"
VERSION="SED_VERSION"
INSTALLER_TARBALL="$BINDIR/swampinabox-${VERSION}-installer.tar.gz"
INSTALLER_DIR="$BINDIR/swampinabox-${VERSION}-installer"

exit_with_error() {
    echo ""
    echo "Error encountered. Check above for details." 1>&2
    exit 1
}

if [ ! -r "$INSTALLER_TARBALL" ]; then
    echo "Error: No such file (or file is not readable): $INSTALLER_TARBALL" 1>&2
    exit 1
fi

echo "Extracting: $INSTALLER_TARBALL"
echo ""
tar -xzv --no-same-owner --no-same-permissions -C "$BINDIR" -f "$INSTALLER_TARBALL" || exit_with_error
echo ""
echo "The SWAMP-in-a-Box installer can be found in: $INSTALLER_DIR"
