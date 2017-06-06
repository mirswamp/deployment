#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Assuming that each tarball expands out into a single directory whose
# immediate sub-directories are what will eventually make it into a VM,
# list out the sizes, in KB, of those immediate sub-directories.
#

CMD='for file in */*; do if [[ -d $file || -h $file || $file =~ "noarch" ]]; then du -Lks $file; fi; done;'

############################################################################

file_with_paths_list="$1"

if [ -z "$file_with_paths_list" ]; then
    echo "Usage: $0 <file with one tarball path per line>"
    exit 1
fi

paths_list=$(cat "$file_with_paths_list")

while read -r path_to_object; do
    object=`basename $path_to_object`

    TMPDIR=`mktemp -d tmp.object.XXXXXX`

    echo "### $object ($TMPDIR)"

    tar -C $TMPDIR -xf $path_to_object
    (cd $TMPDIR ; bash -c "$CMD" | awk '{print $1}' | sort -ug | tail -n 3)
done <<< "$paths_list"
