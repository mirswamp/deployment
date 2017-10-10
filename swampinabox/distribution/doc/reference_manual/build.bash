#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR="$(dirname "$0")"
COMPLETE_DOC="$BINDIR/../reference_manual.txt"

trap 'rm -f "$COMPLETE_DOC"; exit 1' ERR
set -o errtrace

############################################################################

rm -f "$COMPLETE_DOC"    # in case a previous build failed

echo "Building source document: $COMPLETE_DOC"

for src_file in "$BINDIR"/*.txt; do
    echo ".. Including: $src_file"
    { cat "$src_file"; echo; echo; } >> "$COMPLETE_DOC"
done

for cmd in asciidoctor asciidoctor-pdf; do
    if which "$cmd" 1>/dev/null 2>/dev/null ; then
        echo "Running: $cmd"
        $cmd -a data-uri -a icons=font -a toc -a max-width=55em -a numbered "$COMPLETE_DOC"
    fi
done

rm -f "$COMPLETE_DOC"
