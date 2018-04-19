#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Build a SWAMP-in-a-Box release for distribution.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
RELEASE_NUMBER=$1
BRANCH=$2
BUILD_NUMBER=$3
SKIP_RPMS=""
SKIP_TARBALL=""

for option in "${@:4}" ; do
    if [[ "$option" =~ skip-rpm ]]; then
        SKIP_RPMS="yes"
    elif [[ "$option" =~ skip-tarball ]]; then
        SKIP_TARBALL="yes"
    fi
done

WORKSPACE="$BINDIR/../../.."
IFS='.' read -r RELEASE MAJOR MINOR <<< "$RELEASE_NUMBER"

############################################################################

function show_usage_and_exit() {
    echo "Usage: $0 <release number> master|release|<name> <build number> [options]" 1>&2
    exit 1
}

if [ "$(whoami)" = "root" ]; then
    echo "Error: Refusing to run as root" 1>&2
    show_usage_and_exit
fi
if [ -z "$RELEASE" ] || [ -z "$MAJOR" ]; then
    echo "Error: Release number is required" 1>&2
    show_usage_and_exit
fi
if [ -z "$BUILD_NUMBER" ]; then
    echo "Error: Build number is required" 1>&2
    show_usage_and_exit
fi

echo ""
echo "###################################"
echo "##### Command-line Parameters #####"
echo "###################################"
echo ""

echo "RELEASE_NUMBER:     $RELEASE_NUMBER"
echo "RELEASE:            $RELEASE"
echo "MAJOR:              $MAJOR"
echo "MINOR:              $MINOR"
echo "BRANCH:             $BRANCH"
echo "BUILD_NUMBER:       $BUILD_NUMBER"

############################################################################

if [[ "$0" =~ jenkins_build ]]; then
    RELEASE_ROOT="$WORKSPACE/export/swampinabox/distribution"
elif [[ "$0" =~ swampinabox_build ]]; then
    RELEASE_ROOT="/export/swamponabox/distribution"
fi

if [ "$BUILD_NUMBER" = "now" ]; then
    BUILD_NUMBER="$(date +"%Y%m%d%H%M%S").sib"
fi

if [ "$SKIP_RPMS" = "yes" ]; then
    random_rpm=$(find "$WORKSPACE/deployment/swamp/RPMS" -name "swamp-web-server-*.rpm")
    random_rpm=$(basename "$random_rpm")
    BUILD_NUMBER=$(echo "$random_rpm" | sed 's/^.*-\([[:digit:]]\+.*\)\.noarch\.rpm$/\1/')
fi

# rpm release number
RELEASE_NUMBER="${RELEASE}.${MAJOR}"
if [ ! -z "$MINOR" ]; then
    RELEASE_NUMBER="${RELEASE}.${MAJOR}.${MINOR}"
fi

# installer staging area and tarball
BUILD_RESULT="$BINDIR/swampinabox-${RELEASE_NUMBER}-installer"
BUILD_RESULT_TARBALL="${BUILD_RESULT}.tar.gz"

# distribution release directory
RELEASE_DIRECTORY="${RELEASE_ROOT}/swampinabox-${RELEASE_NUMBER}-${BRANCH}"

echo ""
echo "#########################################"
echo "##### Distribution Build Parameters #####"
echo "#########################################"
echo ""

echo "WORKSPACE:          $WORKSPACE ($(cd "$WORKSPACE" ; pwd))"
echo "BUILD_RESULT:       $BUILD_RESULT"
echo "RELEASE_NUMBER:     $RELEASE_NUMBER"
echo "BUILD_NUMBER:       $BUILD_NUMBER"
echo "RELEASE_ROOT:       $RELEASE_ROOT"
echo "RELEASE_DIRECTORY:  $RELEASE_DIRECTORY"

############################################################################
# BUILD RPMS
# ----------
function build_rpms() {
    echo ""
    echo "#########################"
    echo "##### Building RPMS #####"
    echo "#########################"
    echo ""

    if [ "$SKIP_RPMS" = "yes" ]; then
        echo "Skipping."
        return 0
    fi

    "$BINDIR/../singleserver/sbin/swampinabox_build_rpms.bash" \
        "swampinabox" \
        "$WORKSPACE" \
        "$RELEASE_NUMBER" \
        "$BUILD_NUMBER"
}

############################################################################
# BUILD SRC TAR FILE
# ------------------
function build_src_tar() {
    echo ""
    echo "#################################"
    echo "##### Building Src Tar File #####"
    echo "#################################"
    echo ""

    set -x

    # create BUILD_RESULT directory and subdirectories
    rm -rf "$BUILD_RESULT"
    mkdir -p "$BUILD_RESULT"
    mkdir -p "$BUILD_RESULT/bin"
    mkdir -p "$BUILD_RESULT/log"
    mkdir -p "$BUILD_RESULT/sbin"

    # copy RPMs
    cp -r "$WORKSPACE/deployment/swamp/RPMS" "$BUILD_RESULT/."

    # copy install scripts
    cp -H "$BINDIR"/../singleserver/sbin/* "$BUILD_RESULT/sbin/."
    cp    "$BINDIR"/sbin/*                 "$BUILD_RESULT/sbin/."
    cp -d "$BINDIR"/bin/*                  "$BUILD_RESULT/bin/."

    # copy runtime files that we need before the RPMs are installed
    cp    "$BINDIR"/../runtime/sbin/create_mysql_root      "$BUILD_RESULT/sbin/."
    cp    "$BINDIR"/../runtime/sbin/create_mysql_root_cnf  "$BUILD_RESULT/sbin/."

    # copy other files
    cp    "$BINDIR/../singleserver/bin/set_passwords.bash" "$BUILD_RESULT/bin/."
    cp -r "$BINDIR/../singleserver/config_templates"       "$BUILD_RESULT/."
    cp -r "$BINDIR/sample_packages"                        "$BUILD_RESULT/."
    cp -r "$BINDIR/repos"                                  "$BUILD_RESULT/."

    # make sure executables are actually executable
    chmod 0755 "$BUILD_RESULT"/bin/*
    chmod 0755 "$BUILD_RESULT"/sbin/*

    # write version.txt
    echo "$RELEASE_NUMBER $BUILD_NUMBER" > "$BUILD_RESULT/bin/version.txt"

    # remove extraneous files
    rm "$BUILD_RESULT/sbin/find_release_number.pl"
    rm "$BUILD_RESULT/sbin/getargs.function"
    rm "$BUILD_RESULT/sbin/initialize_swamp_database_driver.bash"
    rm "$BUILD_RESULT/sbin/open_vswitch.bash"
    rm "$BUILD_RESULT/sbin/swampinabox_build_rpms.bash"
    rm "$BUILD_RESULT/sbin/yum_install.bash"

    set +x

    if [ "$SKIP_TARBALL" = "yes" ]; then
        echo ""
        echo "Built directory: $BUILD_RESULT"
        return 0
    fi

    set -x

    # create gzip tar bundle
    tar -cvz \
        -f "$BUILD_RESULT_TARBALL" \
        -C "$(dirname "$BUILD_RESULT")" \
        "$(basename "$BUILD_RESULT")"
    rm -rf "$BUILD_RESULT"

    set +x

    echo ""
    echo "Built tarball: $BUILD_RESULT_TARBALL"
}

############################################################################
# RELEASE TAR FILES
# -----------------
function release_tar_files() {
    echo ""
    echo "###############################"
    echo "##### Releasing Tar Files #####"
    echo "###############################"
    echo ""

    set -x

    rm -rf "$RELEASE_DIRECTORY"
    mkdir -p "$RELEASE_DIRECTORY"

    mv "$BUILD_RESULT_TARBALL"                       "$RELEASE_DIRECTORY/."
    cp "$BINDIR"/doc/administrator_manual.{html,pdf} "$RELEASE_DIRECTORY/."
    cp "$BINDIR"/doc/reference_manual.{html,pdf}     "$RELEASE_DIRECTORY/."
    cp "$BINDIR"/util/extract-installer.bash         "$RELEASE_DIRECTORY/."
    sed -i "s/SED_VERSION/$RELEASE_NUMBER/"          "$RELEASE_DIRECTORY/extract-installer.bash"

    set +x

    echo ""
    echo "Final contents of '$RELEASE_DIRECTORY':"
    ls -lh "$RELEASE_DIRECTORY/"
}

############################################################################

if ! build_rpms ; then
    echo "" 1>&2
    echo "Error: Failed to build RPMs" 1>&2
    exit 1
fi

build_src_tar

if [ "$SKIP_TARBALL" = "yes" ]; then
    echo ""
    echo "Skipping release step: Didn't make tarball"
elif [ ! -d "$RELEASE_ROOT" ]; then
    echo ""
    echo "Skipping release step: No such directory: $RELEASE_ROOT"
else
    release_tar_files
fi

if [ $encountered_error -eq 0 ]; then
    echo ""
    echo "Build process completed"
else
    echo "" 1>&2
    echo "Error: Build process completed, but with errors" 1>&2
fi

exit $encountered_error
