#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Add the SWAMP's copyright notice to a file.
#

source_file=$1
tmp_file=$(mktemp /tmp/add-copyright-notice.XXXXXX)

trap 'rm -f "$tmp_file"' ERR EXIT INT TERM

############################################################################

if [ -z "$source_file" ]; then
    echo "Usage: $0 <file to update>" 1>&2
    exit 1
fi
if [ ! -r "$source_file" ]; then
    echo "Error: File is not readable: $source_file" 1>&2
    exit 1
fi
if [ ! -w "$source_file" ]; then
    echo "Error: File is not writeable: $source_file" 1>&2
    exit 1
fi

clear

echo "-----------------------------------------------------------------"
echo "File: $source_file"
echo "-----------------------------------------------------------------"
head -n 18 "$source_file"
echo "-----------------------------------------------------------------"
echo ""

echo -n "Add copyright notice to this file? [N/y] "
read -r answer
echo ""

if [ "$answer" != "y" ]; then
    exit 0
fi

echo -n "Skip how many lines? [default: 0] "
read -r skip_lines
echo ""

if [ -z "$skip_lines" ]; then
    skip_lines=0
fi

cp -p "$source_file" "$tmp_file"    # capture the file's permission bits
{
    head -n "$skip_lines" "$source_file"

    if [ $skip_lines -gt 0 ]; then
        echo ""
    fi

    echo "# This file is subject to the terms and conditions defined in"
    echo "# 'LICENSE.txt', which is part of this source code distribution."
    echo "#"
    echo "# Copyright 2012-2018 Software Assurance Marketplace"
    echo ""

    tail -n +"$((skip_lines + 1))" "$source_file"
} > "$tmp_file"
mv "$tmp_file" "$source_file"
