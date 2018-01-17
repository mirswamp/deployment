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
echo "######################"
echo "### Installing PHP ###"
echo "######################"

os_distribution=$(get_os_dist)
os_version=$(get_os_ver)

case "$os_distribution" in
    "Red Hat Linux")
        yum_install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${os_version}.noarch.rpm"
        yum_confirm epel-release || exit_with_error
        ;;
    *)
        yum_install epel-release
        yum_confirm epel-release || exit_with_error
        ;;
esac

yum_install yum-utils
yum_confirm yum-utils || exit_with_error

echo "Configuring Remi's RPM repository"
yum_install "http://rpms.remirepo.net/enterprise/remi-release-${os_version}.rpm"
yum_confirm remi-release || exit_with_error
yum-config-manager --enable remi-php70

yum_install php php-ldap php-mbstring php-mcrypt php-mysqlnd php-pecl-zip php-xml
yum_confirm php php-ldap php-mbstring php-mcrypt php-mysqlnd php-pecl-zip php-xml || exit_with_error

echo ""
echo "Finished installing PHP."
exit 0
