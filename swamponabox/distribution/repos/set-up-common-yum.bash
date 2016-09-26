#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/set-up-common.functions

COMMON_PKGS_TO_INSTALL="ant
    bind-utils
    condor-all
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

exit 0
