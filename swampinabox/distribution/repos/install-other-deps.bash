#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

swamp_context=$1

echo
echo "### Installing Other Dependencies"
echo

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/resources/common-helper.functions

check_user            || exit 1
check_os_dist_upgrade || exit 1

############################################################################

common_packages=(
    ant
    bind-utils
    curl
    git
    httpd
    mariadb
    mariadb-server
    mariadb-libs
    mod_ssl
    ncompress
    patch
    perl
    perl-parent
    python34
    rubygems
    unzip
    xz
    zip
)

vm_packages=(
    libguestfs
    libguestfs-tools
    libguestfs-tools-c
    libvirt
)

if [ "${swamp_context}" = "-docker" ]
then 
    echo
    echo "Will not install libguestfs or libvirt in a docker image."
    echo
else
    common_packages=(
        "${common_packages[@]}"
        "${vm_packages[@]}"
    )
fi

yum_install "${common_packages[@]}"
yum_confirm "${common_packages[@]}" || exit_with_error

echo
echo "Finished installing other dependencies"