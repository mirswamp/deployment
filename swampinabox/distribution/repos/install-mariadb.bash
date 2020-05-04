#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Installing MariaDB"
echo

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/resources/common-helper.functions

check_user            || exit 1
check_os_dist_and_ver || exit 1
check_os_dist_upgrade || exit 1

############################################################################

case "$(get_os_version)" in
    6)
        echo "Copying 'MariaDB55.repo' to '/etc/yum.repos.d'"
        cp "$BINDIR"/resources/MariaDB55.repo /etc/yum.repos.d/.

        echo "Importing GPG key"
        rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

        yum_install MariaDB-client MariaDB-server MariaDB-shared
        yum_confirm MariaDB-client MariaDB-server MariaDB-shared || exit_with_error
        ;;
    7)
        yum_install mariadb mariadb-server mariadb-libs
        yum_confirm mariadb mariadb-server mariadb-libs || exit_with_error
        ;;
    *)
        echo
        echo "Error: Unsupported OS version" 1>&2
        exit_with_error
        ;;
esac

echo
echo "Finished installing MariaDB"
