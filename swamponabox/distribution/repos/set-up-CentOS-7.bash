#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`

. "$BINDIR"/set-up-common.functions

"$BINDIR"/set-up-common-pre.bash "$SCRIPT_NAME" || exit 1

echo ""
echo "########################################"
echo "##### Configuring yum Repositories #####"
echo "########################################"

echo ""
echo "================"
echo "=== HTCondor ==="
echo "================"

echo "Copying htcondor-stable-rhel7.repo to /etc/yum.repos.d"
cp "$BINDIR"/htcondor-stable-rhel7.repo /etc/yum.repos.d

echo "Importing GPG key"
rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor

echo ""
echo "==============="
echo "=== MariaDB ==="
echo "==============="

echo "Nothing to do"

echo""
echo "==============="
echo "=== PHP 7.0 ==="
echo "==============="

yum_install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum_install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum_install yum-utils
yum_confirm epel-release remi-release yum-utils || exit_with_error

yum-config-manager --enable remi-php70
yum_update

echo ""
echo "########################################"
echo "##### Installing Required Packages #####"
echo "########################################"

"$BINDIR"/set-up-common-yum.bash || exit 1

yum_install mariadb mariadb-server
yum_confirm mariadb mariadb-server || exit_with_error

"$BINDIR"/set-up-common-post.bash || exit 1
