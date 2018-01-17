#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Exit with zero if the given file contains the SWAMP
# copyright notice. Otherwise, exit with non-zero.
#

file_to_check="$1"
copyright_string="Copyright 2012-2018 Software Assurance Marketplace"

if [ -z "$file_to_check" ]; then
    echo "Usage: $0 <file to check>" 1>&2
    exit 1
fi

if [ ! -r "$file_to_check" ]; then
    echo "Error: No such file (or file is not readable): $file_to_check" 1>&2
    exit 1
fi

if grep "$copyright_string" "$file_to_check" 1>/dev/null 2>/dev/null ; then
    exit 0
else
    echo "$file_to_check"
    exit 1
fi
