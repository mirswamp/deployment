#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo ""
echo "### Building the SWAMP-in-a-Box RPMs"
echo ""

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BACKEND_TARGET=$1
WORKSPACE=$2
RELEASE_NUMBER=$3
BUILD_NUMBER=$4

export RELEASE_NUMBER
export BUILD_NUMBER

startupdir=$(pwd)

echo "Version: $RELEASE_NUMBER (build $BUILD_NUMBER)"
echo "Target: $BACKEND_TARGET"
echo "Workspace: $WORKSPACE"

############################################################################

function do_make {
    make "$@" || exit_with_error
}

function exit_with_error {
    echo "" 1>&2
    echo "Error: Build is NOT complete" 1>&2
    exit 1
}

echo ""
echo "========================"
echo "=== Perl Runtime RPM ==="
echo "========================"
cd "$startupdir"
cd "$WORKSPACE/deployment/swamp/runtime-installer"
echo "Current working directory: $(pwd)"
do_make clean rpm

echo ""
echo "====================================="
echo "=== Perl and Database Backend RPM ==="
echo "====================================="
cd "$startupdir"
cd "$WORKSPACE/deployment/swamp/installer"
echo "Current working directory: $(pwd)"
do_make clean "$BACKEND_TARGET"

echo ""
echo "=============================================="
echo "=== HTML frontend and swamp-web-server RPM ==="
echo "=============================================="
cd "$startupdir"
cd "$WORKSPACE/deployment/swamp/swamp-web-server-installer"
echo "Current working directory: $(pwd)"
do_make clean rpm

echo ""
echo "==============================================="
echo "=== Found the following RPMs for this build ==="
echo "==============================================="
cd "$startupdir"
echo "Current working directory: $(pwd)"
rm -f "$WORKSPACE"/deployment/swamp/RPMS/*
find "$WORKSPACE"/deployment/swamp/*/RPMS \
    -name '*.rpm' \
    -print \
    -exec cp "{}" "$WORKSPACE/deployment/swamp/RPMS" ";"

echo ""
echo "================================="
echo "=== Cleaning build byproducts ==="
echo "================================="
for package_dir in \
        "$WORKSPACE/deployment/swamp/runtime-installer" \
        "$WORKSPACE/deployment/swamp/installer" \
        "$WORKSPACE/deployment/swamp/swamp-web-server-installer" \
        ; do
    cd "$startupdir"
    cd "$package_dir"
    echo "Current working directory: $(pwd)"
    do_make clean
done

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo "Finished building the SWAMP-in-a-Box RPMs"
else
    echo "Finished building the SWAMP-in-a-Box RPMs, but with errors" 1>&2
fi
exit $encountered_error
