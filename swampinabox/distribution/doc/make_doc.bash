#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Build the HTML and PDF versions of the SWAMP-in-a-Box manuals.
#

BINDIR=$(dirname "$0")
target=$1

temp_src="$BINDIR/$(basename "$target").txt"
revision_number=$(git branch | grep -E '^\*' | sed -E -e 's/^..//' -e 's/-release$//')
revision_date=$(date +"%Y-%m-%d %H:%M:%S %z")

############################################################################

if [ ! -d "$target" ]; then
    echo "Usage: $0 <directory with source files>" 1>&2
    exit 1
fi

echo "Building: Version $revision_number, $revision_date"
echo "AsciiDoc source: $temp_src"

rm -f "$temp_src"    # in case a previous build failed

for doc_part in "$target"/*.txt ; do
    echo "Including: $doc_part"
    { cat "$doc_part"; echo; echo; } >> "$temp_src"
done

for cmd in asciidoctor asciidoctor-pdf ; do
    if which "$cmd" 1>/dev/null 2>/dev/null ; then
        echo "Running: $cmd"
        $cmd -a data-uri \
             -a icons=font \
             -a numbered \
             -a max-width=55em \
             -a revdate="$revision_date" \
             -a revnumber="$revision_number" \
             -a toc \
             "$temp_src"
    fi
done

rm -f "$temp_src"
