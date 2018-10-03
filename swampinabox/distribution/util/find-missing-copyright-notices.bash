#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Find files that are missing the SWAMP's copyright notice.
#

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

workspace=$(cd -- "$BINDIR"/../../../.. && pwd)
copyright="Copyright 2012-2018 Software Assurance Marketplace"

#
# Focus on files that are part of the SWAMP's backend.
#
is_ignorable_path() {
    case "$1" in
        */proprietary/*)       return 0 ;;
        */swamp-web-server/*)  return 0 ;;
        */www-front-end/*)     return 0 ;;
        */.git/*)              return 0 ;;
        */.gitignore)          return 0 ;;

        */deployment/swampinabox/singleserver/db_dump/*)  return 0 ;;
        */services/perl/agents/Scarf_Parsing_C/*)         return 0 ;;
    esac
    return 1
}

#
# Loop over files in the workspace, and check each one.
#
while IFS="" read -r path ; do
    if    ! is_ignorable_path "$path" \
       && ! grep -I -- "$copyright" "$path" 1>/dev/null 2>&1
    then
        echo "$path"
    fi
done < <(find "$workspace" -type f | sort -u)
