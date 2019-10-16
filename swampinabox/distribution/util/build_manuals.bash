#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo
echo "### Building the SWAMP-in-a-Box manuals"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)

############################################################################

for target in \
        "$(cd -- "$BINDIR"/../../runtime/doc/administrator_manual && pwd)" \
        "$(cd -- "$BINDIR"/../../runtime/doc/reference_manual && pwd)" \
        ; do

    revdate=$(date +"%Y-%m-%d %H:%M:%S %z")
    revnumber=$(cd -- "$target" && git branch \
                   | grep '^\*' \
                   | sed -e 's/^..//' -e 's/-release$//')

    #
    # The AsciiDoc tools require a single source file. Hence, create an
    # appropriately named temporary file into which we can concatenate all
    # the source files.
    #
    parent_dir=$(dirname -- "$target")
    manual_name=$(basename -- "$target")

    tmp_file=""
    trap 'rm -f "$tmp_file"' EXIT
    tmp_file=$(mktemp "$parent_dir"/"$manual_name".XXXXXXXX)

    #
    # Build the single source file, and run the AsciiDoc tools.
    #
    echo "Processing $target ($revnumber, $revdate)"
    echo > "$tmp_file"

    for doc_part in "$target"/*.txt ; do
        { cat "$doc_part" ; echo ; echo ; } >> "$tmp_file"
    done
    for cmd in asciidoctor asciidoctor-pdf ; do
        if command -v "$cmd" 1>/dev/null 2>&1
        then
            echo "Running $cmd"
            $cmd -a data-uri \
                 -a doctype=book \
                 -a icons=font \
                 -a numbered \
                 -a pdf-page-size=Letter \
                 -a revdate="$revdate" \
                 -a revnumber="$revnumber" \
                 -a toc=left \
                 "$tmp_file"
        fi
    done
    rm -f "$tmp_file"
done

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished building the manuals"
else
    echo
    echo "Finished building the manuals, but with errors" 1>&2
fi
exit $encountered_error
