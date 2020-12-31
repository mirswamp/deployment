#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

swamp_context=$1

if [ "${swamp_context}" = "-docker" ]
then 
    echo
    echo "Installing dependencies in a docker image."
    echo "VM-related dependencies will not be installed."
fi

echo
echo "### Installing Docker, PHP, and Other Dependencies"
echo

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/resources/common-helper.functions

check_user            || exit 1
check_os_dist_and_ver || exit 1
check_os_dist_upgrade || exit 1

############################################################################

"$BINDIR"/install-docker-ce.bash                   || exit 1
"$BINDIR"/install-php.bash                         || exit 1
"$BINDIR"/install-other-deps.bash "${swamp_context}" || exit 1

echo
echo "Finished installing Docker, PHP, and other dependencies"