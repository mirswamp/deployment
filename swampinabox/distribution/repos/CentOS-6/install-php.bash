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

echo""
echo "######################"
echo "### Installing PHP ###"
echo "######################"

yum_install epel-release yum-utils
yum_confirm epel-release yum-utils || exit_with_error

echo "Configuring Remi's RPM repository"
yum_install http://rpms.remirepo.net/enterprise/remi-release-6.rpm
yum_confirm remi-release || exit_with_error
yum-config-manager --enable remi-php70

yum_install php php-ldap php-mbstring php-mcrypt php-mysqlnd php-pecl-zip php-xml
yum_confirm php php-ldap php-mbstring php-mcrypt php-mysqlnd php-pecl-zip php-xml || exit_with_error

echo ""
echo "Finished installing PHP"
exit 0
