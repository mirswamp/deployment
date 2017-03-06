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
echo "RELEASE_NUMBER:	$RELEASE_NUMBER"
echo "BRANCH:		$BRANCH"
echo "BUILD_NUMBER:	$BUILD_NUMBER"
echo "WORKSPACE:	$WORKSPACE"

BUILD_RESULT="$BINDIR/build_swampinabox"

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

if [ -z "$RELEASE" -o -z "$MAJOR" ];
then
	usage "Error - release number: $RELEASE_NUMBER not valid - expecting RELEASE.MAJOR[.MINOR]"
fi

if [ -z "$BUILD_NUMBER" ];
then
	usage "Error - build number: $BUILD_NUMBER not valid - expecting an integer or now"
elif [ "$BUILD_NUMBER" == "now" ];
then
	BUILD_NUMBER=`date +"%Y%m%d%H%M%S"`;
fi

# git checkout branch
if [ "$BRANCH" == "release" ];
then
	# pull branch from release
	RELEASE_BRANCH="${RELEASE}.${MAJOR}-release"
	# rpm release number
	RELEASE_NUMBER="${RELEASE}.${MAJOR}.SWAMPINABOX_RELEASE"
	# distribution release directory
	RELEASE_DIRECTORY="${RELEASE_ROOT}/SWAMPINABOX-${RELEASE}.${MAJOR}-RELEASE"
	if [ -n "$MINOR" ];
	then
		RELEASE_BRANCH="${RELEASE}.${MAJOR}.${MINOR}-release"
		# rpm release number
		RELEASE_NUMBER="${RELEASE}.${MAJOR}.${MINOR}.SWAMPINABOX_RELEASE"
		# distribution release directory
		RELEASE_DIRECTORY="${RELEASE_ROOT}/SWAMPINABOX-${RELEASE}.${MAJOR}.${MINOR}-RELEASE"
	fi
elif [ "$BRANCH" == "master" ];
then
	# pull branch from master
	RELEASE_BRANCH="master"
	# rpm release number
	if [ -z "$MINOR" ];
	then
		MINOR=0
	fi
	RELEASE_NUMBER="${RELEASE}.${MAJOR}.${MINOR}.SWAMPINABOX_MASTER"
	# distribution release directory
	RELEASE_DIRECTORY="${RELEASE_ROOT}/SWAMPINABOX-${RELEASE}.${MAJOR}.${MINOR}-MASTER"
else
	# pull branch from $BRANCH
	RELEASE_BRANCH="$BRANCH"
	# rpm release number
	if [ -z "$MINOR" ];
	then
		MINOR=0
	fi
	RELEASE_NUMBER="${RELEASE}.${MAJOR}.${MINOR}.SWAMPINABOX_${BRANCH}"
	# distribution release directory
	RELEASE_DIRECTORY="${RELEASE_ROOT}/SWAMPINABOX-${RELEASE}.${MAJOR}.${MINOR}-${BRANCH}"
fi

if [ -z "$WORKSPACE" -o ! -d "$WORKSPACE/deployment" ];
then
	usage "Error - workspace: $WORKSPACE not valid - expecting directory with swamp source code"
fi

echo ""
echo "#################################################"
echo "##### Distribution Configuration Parameters #####"
echo "#################################################"
echo ""

echo "WORKSPACE:		$WORKSPACE ($(cd "$(dirname "$WORKSPACE")" && pwd)/$(basename "$WORKSPACE"))"
echo "RELEASE_ROOT:		$RELEASE_ROOT"
echo "BUILD_RESULT:		$BUILD_RESULT"
echo "RELEASE_BRANCH:		$RELEASE_BRANCH"
echo "RELEASE_NUMBER:		$RELEASE_NUMBER"
echo "BUILD_NUMBER:		$BUILD_NUMBER"
echo "RELEASE_DIRECTORY:	$RELEASE_DIRECTORY"

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

	# copy RPMS to BUILD_RESULT/swampsrc/RPMS
	mkdir -p $BUILD_RESULT/swampsrc
	cp -r $WORKSPACE/deployment/swamp/RPMS $BUILD_RESULT/swampsrc/.

	# copy generic src files
	mkdir -p $BUILD_RESULT/sbin
	cp $BINDIR/../singleserver/sbin/* $BUILD_RESULT/sbin/.

	# remove extraneous src files
	rm $BUILD_RESULT/sbin/find_release_number.pl
	rm $BUILD_RESULT/sbin/getargs.function
	rm $BUILD_RESULT/sbin/open_vswitch.bash
	rm $BUILD_RESULT/sbin/swampinabox_build_rpms.bash
	rm $BUILD_RESULT/sbin/swampinabox_clean_rpms.bash
	rm $BUILD_RESULT/sbin/yum_install.bash

	# copy distribution specific src files
	cp -r $BINDIR/bin    $BUILD_RESULT/.
	cp    $BINDIR/sbin/* $BUILD_RESULT/sbin/.

	# copy bin files
	cp $BINDIR/../singleserver/bin/set_passwords.bash $BUILD_RESULT/bin/.

	# copy patch, auxiliary, and health files
	cp -r $BINDIR/../singleserver/swampinabox_installer   $BUILD_RESULT/.
	cp -r $BINDIR/../singleserver/swampinabox_web_config  $BUILD_RESULT/.
	cp -r $BINDIR/../singleserver/health_scripts          $BUILD_RESULT/.

	# write version.txt
	echo "$RELEASE_NUMBER $BUILD_NUMBER" > $BUILD_RESULT/bin/version.txt

    # create gzip tar bundle
    tar -cvz \
        -C $(dirname $BUILD_RESULT) \
        -f $(dirname $BUILD_RESULT)/build_swampinabox-src.tar.gz \
        --exclude=set-up-swampcs.bash \
        $(basename $BUILD_RESULT) sample_packages repos
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

    platforms_bundle=$(find "$RELEASE_ROOT"/build_swampinabox-platforms-*.tar.gz | sort -r | head -n 1)
    tools_bundle=$(find "$RELEASE_ROOT"/build_swampinabox-tools-*.tar.gz | sort -r | head -n 1)

    mkdir -p "$RELEASE_DIRECTORY"
    chmod o+w "$RELEASE_DIRECTORY"

    echo "mv '$BINDIR/build_swampinabox-src.tar.gz' '$RELEASE_DIRECTORY'"
    mv "$BINDIR/build_swampinabox-src.tar.gz" "$RELEASE_DIRECTORY"

    echo "cp '$platforms_bundle' '$RELEASE_DIRECTORY'"
    cp "$platforms_bundle" "$RELEASE_DIRECTORY/build_swampinabox-platforms.tar.gz"

    echo "cp '$tools_bundle' '$RELEASE_DIRECTORY'"
    cp "$tools_bundle" "$RELEASE_DIRECTORY/build_swampinabox-tools.tar.gz"

    echo "Copying other installer files to '$RELEASE_DIRECTORY'"
    cp "$BINDIR/util/extract-installer.bash" "$RELEASE_DIRECTORY"
    cp "$BINDIR/doc"/README* "$RELEASE_DIRECTORY"

    chmod -R o+w "$RELEASE_DIRECTORY"

    echo ""
    echo "Final contents of $RELEASE_DIRECTORY:"
    ls -lh $RELEASE_DIRECTORY/
}

# CLEAN INTERMEDIATE BUILD ARTIFACTS
# ----------------------------------
function clean_rpms() {
	echo ""
	echo "######################"
	echo "##### Clean RPMS #####"
	echo "######################"
	echo ""
	$BINDIR/../singleserver/sbin/swampinabox_clean_rpms.bash $WORKSPACE $QUIET_FLAG
}

build_rpms

if [ $? -ne 0 ]; then
    echo "Error: Failed to build RPMs. Run the build by hand to determine the cause."
    exit 1
fi

build_src_tar
clean_rpms

if [ "$SKIP_RPMS" = "--skip-rpms" ]; then
	echo ""
	echo "Built $BINDIR/build_swampinabox-src.tar.gz"
	exit 0
fi

if [ -d "$RELEASE_ROOT" ];
then
    release_tar_files
    echo ""
    echo "Distribution preserved in: $RELEASE_DIRECTORY"
else
    echo ""
    echo "$RELEASE_ROOT is not available to preserve this distribution"
fi
