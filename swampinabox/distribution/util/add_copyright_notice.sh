#!/bin/sh

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# Add the SWAMP's copyright notice to a file.
#

source_file=$1

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

############################################################################

clear

echo "-----------------------------------------------------------------"
echo "File: $source_file"
echo "-----------------------------------------------------------------"
head -n 18 "$source_file"
echo "-----------------------------------------------------------------"
echo

printf 'Add copyright notice to this file? [N/y] '
read -r answer
printf '\n'

if [ "$answer" != "y" ]; then
    exit 0
fi

printf 'Skip how many lines? [default: 0] '
read -r skip_lines
printf '\n'

if [ -z "$skip_lines" ]; then
    skip_lines=0
fi

############################################################################

tmp_file=""
trap 'rm -f "$tmp_file"' EXIT
tmp_file=$(mktemp "$(basename -- "$0")".XXXXXXXX)

cp -p "$source_file" "$tmp_file"    # capture the file's permission bits
{
    head -n "$skip_lines" "$source_file"

    if [ $skip_lines -gt 0 ]; then
        echo
    fi

    echo "# This file is subject to the terms and conditions defined in"
    echo "# 'LICENSE.txt', which is part of this source code distribution."
    echo "#"
    echo "# Copyright 2012-2019 Software Assurance Marketplace"
    echo

    tail -n +"$((skip_lines + 1))" "$source_file"
} > "$tmp_file"
mv "$tmp_file" "$source_file"
