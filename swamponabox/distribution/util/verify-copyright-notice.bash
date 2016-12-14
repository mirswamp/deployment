#!/bin/bash
BINDIR=`dirname "$0"`

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

copyright_string="Copyright 2012-2016 Software Assurance Marketplace"

if grep -q "$copyright_string" "$1"; then
    exit 0
else
    echo "$1"
    exit 1
fi
