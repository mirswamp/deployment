#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

# uses WORKSPACE, BUILD_QUIETLY

WORKSPACE="$1"
BUILD_QUIETLY="$2"

echo "WORKSPACE: $WORKSPACE"

if [ -z "$WORKSPACE" ]; then
    echo "Error: WORKSPACE is empty"
    exit 1
fi

startupdir=`pwd`

function do_make() {
    if [[ "$BUILD_QUIETLY" = "-quiet" ]]; then
        make $* 2>/dev/null 1>/dev/null || exit_with_error
    else
        make $* || exit_with_error
    fi
}

function exit_with_error() {
    echo ""
    echo "Error encountered."
    exit 1
}

echo ""
echo "==============================="
echo "=== Cleaning Java jar Files ==="
echo "==============================="
cd $WORKSPACE/services/java
pwd
if [[ "$BUILD_QUIETLY" = "-quiet" ]]; then
    ant -file swamp08.xml clean 1>/dev/null || exit_with_error
else
    ant -file swamp08.xml clean || exit_with_error
fi

echo ""
echo "==========================================="
echo "=== Cleaning Perl and Java Runtime RPMs ==="
echo "==========================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/runtime-installer
pwd
do_make clean

echo ""
echo "====================================================="
echo "=== Cleaning Perl, Java, and Database Backend RPM ==="
echo "====================================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/installer
pwd
do_make clean

echo ""
echo "======================================================="
echo "=== Cleaning HTML frontend and swamp-web-server RPM ==="
echo "======================================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/swamp-web-server-installer
pwd
do_make clean
