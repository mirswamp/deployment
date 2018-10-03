#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

echo ""
echo "### Building SWAMP-in-a-Box Installer"
echo ""

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

############################################################################

version_number=$1
build_number=$2
skip_rpms=""
skip_tar_file=""

#
# During development, it is sometimes convenient to reuse the RPMs from
# a previous build or to skip tar'ing and untar'ing the installer archive.
#
for option in "${@:3}" ; do
    case "$option" in
        *skip-rpm*)       skip_rpms=yes ;;
        *skip-tarball*)   skip_tar_file=yes ;;
        *skip-tar-ball*)  skip_tar_file=yes ;;
        *skip-tarfile*)   skip_tar_file=yes ;;
        *skip-tar-file*)  skip_tar_file=yes ;;
    esac
done

############################################################################

show_usage_and_exit() {
    cat 1>&2 <<EOF
Usage: $0 <version number> <build number> [options]

Build the SWAMP-in-a-Box installer.

Options:
  --skip-rpms      Do not build new RPMs (use ones built previously)
  --skip-tar-file  Do not build the installer tar file
EOF
    exit 1
}

if [ "$(whoami)" = "root" ]; then
    echo "Error: Refusing to run as 'root'" 1>&2
    exit 1
fi
if [ -z "$version_number" ]; then
    echo "Error: Required argument is missing: version number" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi
if [ -z "$build_number" ]; then
    echo "Error: Required argument is missing: build number" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi

############################################################################

#
# The directory where all the relevant Git repositories are checked out.
#
WORKSPACE=$(cd -- "$BINDIR"/../../../.. && pwd)

#
# The location of the SWAMP-in-a-Box installer and runtime scripts.
#
DEPLOYMENT=$WORKSPACE/deployment
SIB_ROOT=$DEPLOYMENT/swampinabox

#
# Determine whether to use a build number different from what was provided.
#
if [ "$build_number" = "now" ]; then
    build_number=$(date +"%Y%m%d%H%M%S").sib.dev
fi
if [ "$skip_rpms" = "yes" ]; then
    rpm_name=swampinabox-backend
    rpm_file=$(find \
                    "$DEPLOYMENT"/swamp/RPMS -name "${rpm_name}-*.rpm" \
                | head -n 1)
    rpm_basename=$(basename -- "$rpm_file" .noarch.rpm)
    rpm_version=${rpm_basename//${rpm_name}-/}

    version_number=${rpm_version//-*/}
    build_number=${rpm_version//*-/}
fi

#
# The location where the installer archive will be built.
# This is chosen to be convenient for development.
#
BUILD_DIR=$SIB_ROOT/distribution/swampinabox-${version_number}-installer
INSTALLER_TAR_FILE=${BUILD_DIR}.tar.gz

#
# The location where the final installer bundle will be placed.
#
RELEASE_ROOT=$WORKSPACE/export/swampinabox/distribution
RELEASE_DIR=$RELEASE_ROOT/swampinabox-${version_number}-installer

############################################################################

echo "Version number:     $version_number"
echo "Build number:       $build_number"
echo "Workspace:          $WORKSPACE"
echo "Build directory:    $BUILD_DIR"
echo "Release directory:  $RELEASE_DIR"

############################################################################

build_rpms() {
    if [ "$skip_rpms" = "yes" ]; then
        return 0
    fi

    "$SIB_ROOT"/singleserver/sbin/swampinabox_build_rpms.bash \
        "swampinabox" \
        "$WORKSPACE" \
        "$version_number" \
        "$build_number"
}

build_installer_tar_file() {
    #
    # Create $BUILD_DIR and its sub-directories.
    # Overwrite the results of a previous build.
    #
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"/bin
    mkdir -p "$BUILD_DIR"/dependencies/htcondor
    mkdir -p "$BUILD_DIR"/log
    mkdir -p "$BUILD_DIR"/sbin

    #
    # Copy the installer scripts. The "singleserver" collection contains
    # symlinks into the "runtime" collection, so follow those links and copy
    # the actual files.
    #
    cp -d  "$SIB_ROOT"/distribution/bin/*  "$BUILD_DIR"/bin/.
    cp -rH "$SIB_ROOT"/singleserver/sbin/* "$BUILD_DIR"/sbin/.
    cp     "$SIB_ROOT"/distribution/sbin/* "$BUILD_DIR"/sbin/.

    #
    # Copy runtime files that we need before the RPMs are installed.
    #
    cp "$SIB_ROOT"/runtime/sbin/create_mysql_root     "$BUILD_DIR/sbin/."
    cp "$SIB_ROOT"/runtime/sbin/create_mysql_root_cnf "$BUILD_DIR/sbin/."

    #
    # Copy dependencies that are bundled with the installer.
    #
    local version_re='([[:digit:]]+)([.][[:digit:]]+)*'
    local dependencies_conf=$DEPLOYMENT/inventory/dependencies.txt

    local htcondor_version
    htcondor_version=$(grep -o -E "condor-${version_re}" "$dependencies_conf")
    htcondor_version=${htcondor_version//condor-/}

    cp /swampcs/htcondor/condor-"${htcondor_version}"-*.tar.gz "$BUILD_DIR"/dependencies/htcondor/.

    #
    # Copy and create other files.
    #
    cp -r "$SIB_ROOT"/distribution/repos                  "$BUILD_DIR"/.
    cp -r "$SIB_ROOT"/distribution/sample_packages        "$BUILD_DIR"/.
    cp    "$SIB_ROOT"/singleserver/bin/set_passwords.bash "$BUILD_DIR"/bin/.
    cp -r "$SIB_ROOT"/singleserver/config_templates       "$BUILD_DIR"/.
    cp -r "$DEPLOYMENT"/swamp/RPMS                        "$BUILD_DIR"/.

    echo "$version_number $build_number" > "$BUILD_DIR"/bin/version.txt

    #
    # Remove unneeded files that were copied because we used globs.
    #
    rm     "$BUILD_DIR"/sbin/find_release_number.pl
    rm     "$BUILD_DIR"/sbin/getargs.function
    rm     "$BUILD_DIR"/sbin/initialize_swamp_database_driver.bash
    rm     "$BUILD_DIR"/sbin/open_vswitch.bash
    rm -rf "$BUILD_DIR"/sbin/runtime/doc
    rm     "$BUILD_DIR"/sbin/swampinabox_build_rpms.bash

    #
    # Ensure that file permissions are accurate.
    # Assume that execute bits are set properly in source control.
    #
    chmod -R u=rwX,og=rX "$BUILD_DIR"

    #
    # Final steps.
    #
    if [ "$skip_tar_file" = "yes" ]; then
        echo ""
        echo "Built directory: $BUILD_DIR"
        return 0
    fi

    tar -cz \
        -f "$INSTALLER_TAR_FILE" \
        -C "$(dirname -- "$BUILD_DIR")" \
        "$(basename -- "$BUILD_DIR")"
    rm -rf "$BUILD_DIR"
    echo ""
    echo "Built tar file: $INSTALLER_TAR_FILE"
}

release_files() {
    #
    # Create $RELEASE_DIR.
    # Overwrite the results of a previous build.
    #
    rm -rf "$RELEASE_DIR"
    mkdir -p "$RELEASE_DIR"

    #
    # Copy the installer tar file and documentation.
    #
    mv "$INSTALLER_TAR_FILE"                                "$RELEASE_DIR"/.
    cp "$SIB_ROOT"/runtime/doc/*_manual.{html,pdf}          "$RELEASE_DIR"/.
    cp "$SIB_ROOT"/distribution/util/extract-installer.bash "$RELEASE_DIR"/.
    sed -i -e "s/SED_VERSION/$version_number/" "$RELEASE_DIR"/extract-installer.bash

    #
    # Generate MD5 checksums.
    #
    for path in "$RELEASE_DIR"/* ; do
        if [ -f "$path" ]; then
            { cd -- "$(dirname -- "$path")" && md5sum "$(basename -- "$path")"
            } > "$path".md5
        fi
    done

    #
    # Ensure that file permissions are accurate.
    # Assume that execute bits are set properly in source control.
    #
    chmod -R u=rwX,og=rX "$RELEASE_DIR"
    find "$RELEASE_DIR" -type f -exec chmod ugo=rX '{}' ';'

    #
    # Final steps.
    #
    echo ""
    echo "Built release directory: $RELEASE_DIR"
    ls -lha "$RELEASE_DIR"
}

############################################################################

#
# Build the SWAMP RPMs and the SWAMP-in-a-Box installer tar file.
#
build_rpms || exit 1
build_installer_tar_file

#
# Build the final installer bundle.
#
if [ ! -f "$INSTALLER_TAR_FILE" ] || [ "$skip_tar_file" = "yes" ]; then
    echo ""
    echo "Skipping release step: Did not make tar file"
elif [ ! -d "$RELEASE_ROOT" ]; then
    echo ""
    echo "Skipping release step: Not a directory: $RELEASE_ROOT"
else
    release_files
fi

#
# Write out the final disposition of the build.
#
if [ $encountered_error -eq 0 ]; then
    echo ""
    echo "Finished building the installer"
else
    echo "" 1>&2
    echo "Finished building the installer, but with errors" 1>&2
fi
exit $encountered_error
