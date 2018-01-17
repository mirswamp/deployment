#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Build the SWAMP RPMs for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BACKEND_TARGET="$1"
WORKSPACE="$2"
RELEASE_NUMBER="$3"
BUILD_NUMBER="$4"
BUILD_QUIETLY="$5"

echo "Target:             $BACKEND_TARGET"
echo "Workspace:          $WORKSPACE"
echo "Release number:     $RELEASE_NUMBER"
echo "Build number:       $BUILD_NUMBER"

if [ -z "$BACKEND_TARGET" ]; then
    echo "Error: BACKEND_TARGET is empty" 1>&2
    exit 1
fi
if [ -z "$WORKSPACE" ]; then
    echo "Error: WORKSPACE is empty" 1>&2
    exit 1
fi
if [ -z "$RELEASE_NUMBER" ]; then
    echo "Error: RELEASE_NUMBER is empty" 1>&2
    exit 1
fi

export RELEASE_NUMBER
export BUILD_NUMBER
export PATH="/opt/perl5/perls/perl-5.18.1/bin:$PATH"

startupdir="$(pwd)"

function do_make() {
    if [ "$BUILD_QUIETLY" = "-quiet" ]; then
        make $* 1>/dev/null 2>/dev/null || exit_with_error
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
mkdir -p "$WORKSPACE/deployment/swamp/RPMS"
rm -f "$WORKSPACE"/deployment/swamp/RPMS/*
find "$WORKSPACE"/deployment/swamp/*/RPMS -name '*.rpm' -exec cp '{}' "$WORKSPACE/deployment/swamp/RPMS" ';' -print

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

exit $encountered_error
