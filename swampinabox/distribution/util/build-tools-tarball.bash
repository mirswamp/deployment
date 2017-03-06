#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

start_dir=$(pwd)
tools_store=/swamp/store/SCATools
tools_tarball=build_swampinabox-tools-$(date +%Y%m%d).tar.gz
tools_tarball_root=build_swampinabox
tools_build_root="$tools_tarball_root"/swampsrc/tools

file_with_tools_list="$1"

if [ -z "$file_with_tools_list" ]; then
    echo "Usage: $0 <file with one tool per line>"
    exit 1
fi

if [ -d "$tools_tarball_root" ]; then
    echo "Error: $tools_tarball_root already exists"
    exit 1
fi

echo "##### Reading tools list"
tools_list=$(cat "$file_with_tools_list")

echo "##### Creating build tree"
cd "$start_dir"
mkdir -p "$tools_build_root"

echo "##### Populating build tree"
while read -r tool; do
    echo $tool

    cd "$tools_store"
    tool_file=$(find . -name "$tool")
    tool_dir=$(dirname "$tool_file")

    if [ -z "$tool_file" ]; then
        echo ""
        echo "Error: Couldn't find $tool"
        exit 1
    fi

    cd "$start_dir"/"$tools_build_root"
    mkdir -p "$tool_dir"
    cp "$tools_store"/"$tool_file" "$tool_dir"
done <<< "$tools_list"

echo "##### Creating $tools_tarball"
cd "$start_dir"
find "$tools_tarball_root" -type f -exec chmod a-wx '{}' ';'
tar zcvf "$tools_tarball" "$tools_tarball_root"
