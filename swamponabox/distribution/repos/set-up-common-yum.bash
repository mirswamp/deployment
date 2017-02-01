#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/set-up-common.functions

COMMON_PKGS_TO_INSTALL="ant
    bind-utils
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
    php
    php-mbstring
    php-mcrypt
    php-mysqlnd
    php-pecl-zip
    php-xml
    zip"

yum_install /usr/bin/scp
yum_install $COMMON_PKGS_TO_INSTALL
yum_confirm $COMMON_PKGS_TO_INSTALL || exit_with_error

#
# We will use the 'versionlock' plugin for yum to ensure
# that a specific version of HTCondor is installed.
#

target_condor="8.4.11"

yum_install yum-plugin-versionlock
yum_confirm yum-plugin-versionlock || exit_with_error

echo ""
echo "Attempting to lock 'condor' packages to version ${target_condor}"

yum versionlock delete "condor*${target_condor}*"
yum versionlock delete "*:condor*${target_condor}*"
yum versionlock "condor*${target_condor}*" || exit_with_error

installed_condor=$(rpm -q --qf '%{VERSION}' condor)
if [ $? -ne 0 ]; then
    installed_condor="0.0.0"
fi

compare_versions "$installed_condor" "$target_condor"
comparison=$?

if [ $comparison -eq 2 ]; then
    yum_downgrade 'condor*' || exit_with_error
fi
if [ $comparison -eq 0 ]; then
    yum_update 'condor*' || exit_with_error
fi

yum_install condor-all
yum_confirm condor-all || exit_with_error

exit 0
