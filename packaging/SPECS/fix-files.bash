#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

STAGING_AREA=$(readlink -e "$1")

#
# Prevent this script from going off into the wilderness.
#
if [ -z "$STAGING_AREA" ] || [ "$STAGING_AREA" = "/" ]; then
   exit 1
fi

set -x

#
# Remove source-control artifacts.
#
find "$STAGING_AREA" -name .gitignore -exec rm -f "{}" ";"
