#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

BINDIR="$(dirname "$0")"

############################################################################

complete_doc="$BINDIR/../administrator_manual.txt"
rev_num=$(git branch | grep -E '^\*' | sed -E -e 's/^..(.*)$/\1/')
rev_date=$(date +"%Y-%m-%d %H:%M:%S %z")

if [[ "$rev_num" =~ ^[[:digit:]] ]]; then
    rev_num=$(echo "$rev_num" | sed -E -e 's/^([^-.]*(\.[^-.]*)*).*$/\1/')
fi

echo "Building: Version $rev_num, $rev_date"

############################################################################

rm -f "$complete_doc"    # in case a previous build failed

for src_file in "$BINDIR"/*.txt ; do
    { cat "$src_file"; echo; echo; } >> "$complete_doc"
done

for cmd in asciidoctor asciidoctor-pdf ; do
    if which "$cmd" 1>/dev/null 2>/dev/null ; then
        echo "Running: $cmd"
        $cmd -a data-uri \
             -a icons=font \
             -a numbered \
             -a max-width=55em \
             -a revdate="$rev_date" \
             -a revnumber="$rev_num" \
             -a toc \
             "$complete_doc"
    fi
done

rm -f "$complete_doc"
