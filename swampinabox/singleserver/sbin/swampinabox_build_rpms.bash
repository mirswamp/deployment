#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

# uses BACKEND_TARGET, WORKSPACE, RELEASE_NUMBER, BUILD_NUMBER, BUILD_QUIETLY

BACKEND_TARGET="$1"
WORKSPACE="$2"
RELEASE_NUMBER="$3"
BUILD_NUMBER="$4"
BUILD_QUIETLY="$5"

echo "BACKEND_TARGET: $BACKEND_TARGET"
echo "WORKSPACE: $WORKSPACE"
echo "RELEASE_NUMBER: $RELEASE_NUMBER"
echo "BUILD_NUMBER: $BUILD_NUMBER"

if [ -z "$BACKEND_TARGET" ]; then
    echo "Error: BACKEND_TARGET is empty"
    exit 1
fi
if [ -z "$WORKSPACE" ]; then
    echo "Error: WORKSPACE is empty"
    exit 1
fi
if [ -z "$RELEASE_NUMBER" ]; then
    echo "Error: RELEASE_NUMBER is empty"
    exit 1
fi

export RELEASE_NUMBER
export BUILD_NUMBER
export PATH=/opt/perl5/perls/perl-5.18.1/bin:$PATH

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
echo "=== Building Java jar Files ==="
echo "==============================="
cd $WORKSPACE/services/java
pwd
if [[ "$BUILD_QUIETLY" = "-quiet" ]]; then
    ant -file swamp08.xml clean jar 1>/dev/null || exit_with_error
else
    ant -file swamp08.xml clean jar || exit_with_error
fi

echo ""
echo "========================================="
echo "=== Making Perl and Java Runtime RPMs ==="
echo "========================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/runtime-installer
pwd
do_make clean rpm
find . -name *.rpm

echo ""
echo "==================================================="
echo "=== Making Perl, Java, and Database Backend RPM ==="
echo "==================================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/installer
pwd
do_make clean $BACKEND_TARGET
find . -name *.rpm

echo ""
echo "====================================================="
echo "=== Making HTML frontend and swamp-web-server RPM ==="
echo "====================================================="
cd $startupdir
cd $WORKSPACE/deployment/swamp/swamp-web-server-installer
pwd
do_make clean rpm
find . -name *.rpm

echo ""
echo "==============================================="
echo "=== Found the following RPMs for this build ==="
echo "==============================================="
cd $startupdir
mkdir -p $WORKSPACE/deployment/swamp/RPMS
rm -f $WORKSPACE/deployment/swamp/RPMS/*
find $WORKSPACE/deployment/swamp/*/RPMS -name *.rpm -exec cp {} $WORKSPACE/deployment/swamp/RPMS \; -print
