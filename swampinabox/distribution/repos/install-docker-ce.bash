#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Installing Docker"
echo

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/resources/common-helper.functions

check_user            || exit 1
check_os_dist_and_ver || exit 1
check_os_dist_upgrade || exit 1

############################################################################

if command -v docker 1>/dev/null 2>&1
then
    echo "Found 'docker' executable, not installing packages"
else
    #
    # Based on the directions at:
    #
    #   https://docs.docker.com/install/linux/docker-ce/centos/
    #
    yum_install yum-utils device-mapper-persistent-data lvm2
    yum_confirm yum-utils device-mapper-persistent-data lvm2 || exit_with_error
    yum-config-manager --add-repo "$BINDIR"/resources/docker-ce.repo || exit_with_error

    yum_install docker-ce docker-ce-cli containerd.io
    yum_confirm docker-ce docker-ce-cli containerd.io || exit_with_error
fi

echo
echo "Finished installing Docker"
