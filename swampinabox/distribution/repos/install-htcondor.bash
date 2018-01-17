#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

BINDIR="$(dirname "$0")"

. "$BINDIR/resources/common-helper.functions"

############################################################################

check_os_dist_and_ver  || exit_with_error
check_user             || exit_with_error
check_os_dist_upgrade  || exit_with_error

echo ""
echo "###########################"
echo "### Installing HTCondor ###"
echo "###########################"

os_version=$(get_os_ver)
repo_file="$BINDIR/resources/htcondor-stable-rhel${os_version}.repo"

if [ ! -r "$repo_file" ]; then
    echo "Error: No such file: $repo_file" 1>&2
    exit_with_error
fi

echo "Copying '$(basename "$repo_file")' to '/etc/yum.repos.d'"
cp "$repo_file" /etc/yum.repos.d/.

echo "Importing GPG key"
rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor

#
# We will use the 'versionlock' plugin for yum to ensure that a specific
# version of HTCondor stays installed on the system. We first remove any
# existing version lock so that we can upgrade HTCondor to the most recent
# minor version. We then re-instate the version lock so that a future 'yum
# update' can't cause a newer, untested major version to be installed.
#

target_condor="8.6"

yum_install yum-plugin-versionlock
yum_confirm yum-plugin-versionlock || exit_with_error

if yum versionlock list | grep -- :condor- 1>/dev/null 2>/dev/null ; then
    echo ""
    echo "Removing version lock on 'condor-*'"
    yum versionlock delete "*:condor-*"
fi

echo ""
yum_install "condor-all-${target_condor}.*"
yum_confirm condor-all || exit_with_error

echo ""
echo "Adding version lock on 'condor-*'"
yum versionlock add condor-* || exit_with_error

echo ""
echo "Finished installing HTCondor."
exit 0
