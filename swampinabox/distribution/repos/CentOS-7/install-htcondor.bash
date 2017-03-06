#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/../common/common-helper.functions

check_user                        || exit_with_error
check_os_dist_and_ver "CentOS-7"  || exit_with_error

echo ""
echo "###########################"
echo "### Installing HTCondor ###"
echo "###########################"

echo "Copying htcondor-stable-rhel7.repo to /etc/yum.repos.d"
cp "$BINDIR"/htcondor-stable-rhel7.repo /etc/yum.repos.d

echo "Importing GPG key"
rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor

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

echo ""
echo "Finished installing HTCondor"
exit 0
