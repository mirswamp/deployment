#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

echo ""
echo "### Assembling SWAMP-in-a-Box Release"
echo ""

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

extensions=(html pdf tar.gz bash)
version=$1
release_dir=$2

############################################################################

show_usage_and_exit() {
    echo "Usage: $0 <version number> <release dir> <source dir> ..." 1>&2
    exit 1
}

if [ -z "$version" ]; then
    echo "Error: Required argument is missing: version number" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi
if [ -z "$release_dir" ]; then
    echo "Error: Required argument is missing: release directory" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi
if [ -e "$release_dir" ]; then
    echo "Error: Already exists: $release_dir" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi
if [ -z "${*:3}" ]; then
    echo "Error: Required arguments are missing: source directories" 1>&2
    echo "" 1>&2
    show_usage_and_exit
fi

############################################################################

#
# Assemble the release by first copying the contents of one or more source
# directories to a "release" directory. Then create a 'md5sums.txt' file
# based on '.md5' files in the source directories and a hard-coded list of
# extensions to consider.
#

echo "Version:            $version"
echo "Release directory:  $release_dir"
echo "Working directory:  $(pwd)"
echo ""

mkdir -p "$release_dir"

for path in "${@:3}" ; do
    cp -r "$path"/* "$release_dir"/.
done

rm -f "$release_dir"/md5sums.txt

for ext in "${extensions[@]}" ; do
    while IFS="" read -r path ; do
        cat "$path" >> "$release_dir"/md5sums.txt
        rm -f "$path"
    done < <(find "$release_dir" -type f -name "*.${ext}.md5" | sort -u)
done

echo "$version" > "$release_dir"/version.txt
chmod -R u=rwX,og=rX "$release_dir"
find "$release_dir" -type f -exec chmod ugo=rX '{}' ';'

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo "Finished assembling the release"
else
    echo "" 1>&2
    echo "Finished assembling the release, but with errors" 1>&2
fi
exit $encountered_error
