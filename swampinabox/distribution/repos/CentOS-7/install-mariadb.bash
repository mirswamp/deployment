#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/../common/common-helper.functions

check_user                        || exit_with_error
check_os_dist_and_ver "CentOS-7"  || exit_with_error
check_os_dist_upgrade             || exit_with_error

echo ""
echo "##########################"
echo "### Installing MariaDB ###"
echo "##########################"

yum_install mariadb mariadb-server mariadb-libs
yum_confirm mariadb mariadb-server mariadb-libs || exit_with_error

echo ""
echo "Finished installing MariaDB"
exit 0
