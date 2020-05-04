#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

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
    libguestfs
    libguestfs-tools
    libguestfs-tools-c
    libvirt
    mod_ssl
    ncompress
    patch
    perl
    perl-parent
    python34
    rubygems
    unzip
    zip
)

yum_install "${common_packages[@]}"
yum_confirm "${common_packages[@]}" || exit_with_error

echo
echo "Finished installing other dependencies"
