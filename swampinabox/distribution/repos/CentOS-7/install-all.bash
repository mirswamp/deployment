#!/usr/bin/env bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/../common/common-helper.functions

check_user                        || exit_with_error
check_os_dist_and_ver "CentOS-7"  || exit_with_error

"$BINDIR"/install-htcondor.bash   || exit 1
"$BINDIR"/install-mariadb.bash    || exit 1
"$BINDIR"/install-php.bash        || exit 1

"$BINDIR"/../common/install-and-configure-deps.bash || exit 1

exit 0
