#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Install packages specific to "singleserver" SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

function yum_install() {
    echo "Installing: $*"
    yum -y install $*
}

yum_install glusterfs glusterfs-api glusterfs-cli glusterfs-libs glusterfs-fuse
yum_install --nogpgcheck xfsprogs
yum_install rpm-build

yum_install rubygems python-pip
pip install wheel

exit $encountered_error
