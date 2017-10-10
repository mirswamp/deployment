#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/../common/common-helper.functions

check_user                        || exit_with_error
check_os_dist_and_ver "CentOS-6"  || exit_with_error
check_os_dist_upgrade             || exit_with_error

echo ""
echo "##########################"
echo "### Installing MariaDB ###"
echo "##########################"

echo "Copying MariaDB55.repo to /etc/yum/repos.d"
cp "$BINDIR"/MariaDB55.repo /etc/yum.repos.d

echo "Importing GPG key"
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

yum_install MariaDB-client MariaDB-server MariaDB-shared
yum_confirm MariaDB-client MariaDB-server MariaDB-shared || exit_with_error

echo ""
echo "Finished installing MariaDB"
exit 0
