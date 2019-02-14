#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo
echo "### Installing PHP"
echo

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/resources/common-helper.functions

check_user            || exit 1
check_os_dist_and_ver || exit 1
check_os_dist_upgrade || exit 1

############################################################################

os_version=$(get_os_version)

case "$(get_os_distribution)" in
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

yum_install "http://rpms.remirepo.net/enterprise/remi-release-${os_version}.rpm"
yum_confirm remi-release || exit_with_error

echo "Enabling Remi's PHP 7.0 RPM repository ..."
yum-config-manager --enable remi-php70 || exit_with_error

php_packages=(
    php
    php-ldap
    php-mbstring
    php-mcrypt
    php-mysqlnd
    php-pecl-zip
    php-xml
)

yum_install "${php_packages[@]}"
yum_confirm "${php_packages[@]}" || exit_with_error

echo
echo "Finished installing PHP"
