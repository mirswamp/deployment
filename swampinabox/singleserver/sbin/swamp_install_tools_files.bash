#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`
RELEASE_NUMBER="$1"
SWAMP_CONTEXT="$2"

mysql_options_file="/opt/swamp/sql/sql.cnf"
mysql_command="mysql --defaults-file=$mysql_options_file"

############################################################################

function remove_distribution_tools_bundle() {
    echo Error: Not implemented 1>&2 # XXX
    return 1
}

function extract_distribution_tools_bundle() {
    echo Error: Not implemented 1>&2 # XXX
    return 1
}

function populate_tools_from_filesystem() {
    encountered_error=0

    echo Querying database for current collection of tool paths

    tool_paths=$($mysql_command -B -N <<< "select tool_path from tool_shed.tool_version")

    if [ $? -ne 0 ]; then
        echo Error: Failed to get tool paths from the database 1>&2
        return 1
    fi

    echo Processing tool paths, populating them as needed

    for path in $tool_paths; do
        if [ ! -e "$path" ]; then
            echo .. Populating $path

            tool_basename="$(basename "$path")"
            tool_dirname="$(dirname "$path")"
            tool_source="/swampcs/releases/$tool_basename"

            if [ ! -e "$tool_source" ]; then
                echo Warning: No such file: $tool_source 1>&2

                tool_source="/swamp/store/SCATools/$tool_basename"

                if [ ! -e "$tool_source" ]; then
                    echo Warning: No such file: $tool_source 1>&2
                    encountered_error=1
                    continue
                fi
            fi
            if ! mkdir -m 755 -p "$tool_dirname" ; then
                echo Error: Failed to create directory: $tool_dirname 1>&2
                encountered_error=1
                continue
            fi
            if ! cp "$tool_source" "$path" ; then
                echo Error: Failed to copy $tool_source to $path 1>&2
                encountered_error=1
                continue
            fi
            if ! chmod 644 "$path" ; then
                echo Warning: Failed to set file permissions: $path
                encountered_error=1
                continue
            fi
        fi
    done

    return $encountered_error
}

############################################################################

if [ "$SWAMP_CONTEXT" = -distribution ]; then
    remove_distribution_tools_bundle
    extract_distribution_tools_bundle
    exit 0

elif [ "$SWAMP_CONTEXT" = -singleserver -o "$SWAMP_CONTEXT" = -mir-swamp ]; then
    populate_tools_from_filesystem
    exit $?

else
    echo Error: Unknown SWAMP context: $SWAMP_CONTEXT 1>&2
    exit 1
fi
