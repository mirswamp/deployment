#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

RELEASE_NUMBER="$1"
BRANCH="$2"
BUILD_NUMBER="$3"
SKIP_RPMS="$4"

WORKSPACE="$BINDIR/../../.."
echo "RELEASE_NUMBER:  $RELEASE_NUMBER"
echo "BRANCH:          $BRANCH"
echo "BUILD_NUMBER:    $BUILD_NUMBER"
echo "WORKSPACE:       $WORKSPACE"

if [[ "$0" =~ "jenkins_build" ]]; then
    BUILD_MODE="-jenkins"
    RELEASE_ROOT="$WORKSPACE/export/swampinabox/distribution"
elif [[ "$0" =~ "swampinabox_build" ]]; then
    BUILD_MODE="-swampinabox"
    RELEASE_ROOT="/export/swamponabox/distribution"
fi

IFS='.' read RELEASE MAJOR MINOR <<< "$RELEASE_NUMBER"
echo "RELEASE: $RELEASE"
echo "MAJOR: $MAJOR"
echo "MINOR: $MINOR"

# input argument error checking
function usage() {
    error_message="$1"
    echo $error_message
    echo "usage: $0 <release number=release.major[.minor]> master|release|<name> <build number>"
    echo "example: $0 1.26 master now"
    exit
}

if [ -z "$RELEASE" -o -z "$MAJOR" ]; then
    usage "Error - release number: $RELEASE_NUMBER not valid - expecting RELEASE.MAJOR[.MINOR]"
fi

if [ -z "$BUILD_NUMBER" ]; then
    usage "Error - build number: $BUILD_NUMBER not valid - expecting an integer or now"
elif [ "$BUILD_NUMBER" = "now" ]; then
    BUILD_NUMBER=`date +"%Y%m%d%H%M%S"`
fi
if [ "$SKIP_RPMS" = "--skip-rpms" ]; then
    random_rpm=$(find $WORKSPACE/deployment/swamp/RPMS -name 'swamp-web-server*.rpm')
    random_rpm=$(basename "$random_rpm")
    BUILD_NUMBER=$(echo "$random_rpm" | sed 's/^.*-\([[:digit:]]\+\).noarch.*/\1/')
fi

if [ -z "$WORKSPACE" -o ! -d "$WORKSPACE/deployment" ]; then
    usage "Error - workspace: $WORKSPACE not valid - expecting directory with swamp source code"
fi

# short version number
SHORT_RELEASE_NUMBER="${RELEASE}.${MAJOR}"
if [ -n "$MINOR" ]; then
    SHORT_RELEASE_NUMBER="${RELEASE}.${MAJOR}.${MINOR}"
fi

# installer staging area and tarball
BUILD_RESULT="$BINDIR/swampinabox-${SHORT_RELEASE_NUMBER}-installer"
BUILD_RESULT_TARBALL="${BUILD_RESULT}.tar.gz"

# git checkout branch
RELEASE_BRANCH="$BRANCH"
if [ "$BRANCH" == "release" ]; then
    RELEASE_BRANCH="${SHORT_RELEASE_NUMBER}-release"
fi

# rpm release number
RELEASE_NUMBER="${SHORT_RELEASE_NUMBER}"
if [ "$BRANCH" == "release" ]; then
    RELEASE_NUMBER="${SHORT_RELEASE_NUMBER}.swampinabox_release"
fi

# distribution release directory
RELEASE_DIRECTORY="${RELEASE_ROOT}/swampinabox-${SHORT_RELEASE_NUMBER}-${BRANCH}"

echo ""
echo "#################################################"
echo "##### Distribution Configuration Parameters #####"
echo "#################################################"
echo ""

echo "WORKSPACE:          $WORKSPACE ($(cd "$(dirname "$WORKSPACE")" && pwd)/$(basename "$WORKSPACE"))"
echo "RELEASE_ROOT:       $RELEASE_ROOT"
echo "BUILD_RESULT:       $BUILD_RESULT"
echo "RELEASE_BRANCH:     $RELEASE_BRANCH"
echo "RELEASE_NUMBER:     $RELEASE_NUMBER"
echo "BUILD_NUMBER:       $BUILD_NUMBER"
echo "RELEASE_DIRECTORY:  $RELEASE_DIRECTORY"

# BUILD RPMS
# ----------
function build_rpms() {
    echo ""
    echo "######################"
    echo "##### Build RPMS #####"
    echo "######################"
    echo ""

    if [ "$SKIP_RPMS" = "--skip-rpms" ]; then
        echo "Skipping."
        return 0
    fi

    # update release branch
    if [[ "$BUILD_MODE" = "-swampinabox" ]]; then
        $BINDIR/../singleserver/bin/git_checkout.pl $RELEASE_BRANCH
    fi

    # build rpms with RELEASE_NUMBER BUILD_NUMBER
    if [[ "$BUILD_MODE" = "-swampinabox" ]]; then
        QUIET_FLAG="-quiet"
    else
        QUIET_FLAG=""
    fi
    $BINDIR/../singleserver/sbin/swampinabox_build_rpms.bash swampinabox $WORKSPACE $RELEASE_NUMBER $BUILD_NUMBER $QUIET_FLAG
}

# BUILD SRC TAR FILE
# ------------------
function build_src_tar() {
    echo ""
    echo "##############################"
    echo "##### Build Src Tar File #####"
    echo "##############################"
    echo ""

    # create BUILD_RESULT directory and subdirectories
    rm -rf "${BUILD_RESULT}"
    mkdir -p "${BUILD_RESULT}"
    mkdir -p "${BUILD_RESULT}/bin"
    mkdir -p "${BUILD_RESULT}/log"
    mkdir -p "${BUILD_RESULT}/sbin"

    # copy RPMS to BUILD_RESULT/RPMS
    cp -r $WORKSPACE/deployment/swamp/RPMS $BUILD_RESULT/.

    # copy generic src files
    cp $BINDIR/../singleserver/sbin/* $BUILD_RESULT/sbin/.

    # copy distribution specific src files
    cp -d $BINDIR/bin/*   $BUILD_RESULT/bin/.
    cp    $BINDIR/sbin/*  $BUILD_RESULT/sbin/.

    # copy runtime files that we need before the RPMs are installed
    cp $BINDIR/../runtime/bin/swamp_get_potential_web_hosts $BUILD_RESULT/sbin/.

    # copy bin files
    cp $BINDIR/../singleserver/bin/set_passwords.bash $BUILD_RESULT/bin/.

    # copy patch, auxiliary, and health files
    cp -r $BINDIR/../singleserver/config_templates  $BUILD_RESULT/.
    cp -r $BINDIR/../singleserver/health_scripts    $BUILD_RESULT/.
    cp -r $BINDIR/sample_packages                   $BUILD_RESULT/.
    cp -r $BINDIR/repos                             $BUILD_RESULT/.

    # write version.txt
    echo "$RELEASE_NUMBER $BUILD_NUMBER $SHORT_RELEASE_NUMBER" > $BUILD_RESULT/bin/version.txt

    # remove extraneous src files
    rm $BUILD_RESULT/repos/set-up-swampcs.bash
    rm $BUILD_RESULT/sbin/find_release_number.pl
    rm $BUILD_RESULT/sbin/getargs.function
    rm $BUILD_RESULT/sbin/open_vswitch.bash
    rm $BUILD_RESULT/sbin/swampinabox_build_rpms.bash
    rm $BUILD_RESULT/sbin/swampinabox_clean_rpms.bash
    rm $BUILD_RESULT/sbin/yum_install.bash

    # create gzip tar bundle
    tar -cvz \
        -f ${BUILD_RESULT_TARBALL} \
        -C $(dirname ${BUILD_RESULT}) \
        $(basename $BUILD_RESULT)
}

# RELEASE TAR FILES
# -----------------
# tar.gz files are copied/moved to $RELEASE_DIRECTORY
function release_tar_files() {
    echo ""
    echo "#############################"
    echo "##### Release Tar Files #####"
    echo "#############################"
    echo ""

    platforms_bundle="${RELEASE_ROOT}/swampinabox-${SHORT_RELEASE_NUMBER}-platforms.tar.gz"
    tools_bundle="${RELEASE_ROOT}/swampinabox-${SHORT_RELEASE_NUMBER}-tools.tar.gz"

    set -x

    mkdir -p "$RELEASE_DIRECTORY"

    cp "$platforms_bundle"                    "$RELEASE_DIRECTORY/."
    cp "$tools_bundle"                        "$RELEASE_DIRECTORY/."
    mv "$BUILD_RESULT_TARBALL"                "$RELEASE_DIRECTORY/."
    cp "$BINDIR/doc"/README*                  "$RELEASE_DIRECTORY/."
    cp "$BINDIR/util/extract-installer.bash"  "$RELEASE_DIRECTORY/."
    sed -i "s/SED_VERSION/${SHORT_RELEASE_NUMBER}/" "${RELEASE_DIRECTORY}/extract-installer.bash"

    set +x

    chmod -R o+w "$RELEASE_DIRECTORY"

    echo ""
    echo "Final contents of $RELEASE_DIRECTORY:"
    ls -lh $RELEASE_DIRECTORY/
}

# CLEAN INTERMEDIATE BUILD ARTIFACTS
# ----------------------------------
function clean_build_byproducts() {
    echo ""
    echo "#####################################"
    echo "##### Cleaning build byproducts #####"
    echo "#####################################"
    echo ""
    rm -rf "$BUILD_RESULT"
    $BINDIR/../singleserver/sbin/swampinabox_clean_rpms.bash $WORKSPACE $QUIET_FLAG
}

build_rpms

if [ $? -ne 0 ]; then
    echo "Error: Failed to build RPMs. Run the build by hand to determine the cause."
    exit 1
fi

build_src_tar
clean_build_byproducts

if [ -d "$RELEASE_ROOT" ];
then
    release_tar_files
    echo ""
    echo "Distribution preserved in: $RELEASE_DIRECTORY"
else
    echo ""
    echo "Built ${BUILD_RESULT_TARBALL}"
    echo "$RELEASE_ROOT is not available to preserve this distribution"
fi
