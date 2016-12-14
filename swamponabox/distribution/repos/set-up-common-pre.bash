#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`
SCRIPT_NAME=$1

. "$BINDIR"/set-up-common.functions

check_os_dist_and_ver "$SCRIPT_NAME" || exit 1

if [ "$(whoami)" != "root" ]; then
    echo "Error: This set up script must be run as root."
    exit_with_error
fi

for prog in rpm yum cp ln useradd; do
    echo -n "Checking for $prog ... "
    which $prog
    if [ $? -ne 0 ]; then
        echo "Error: $prog is not found in $USER's path."
        exit_with_error
    fi
done

exit 0
