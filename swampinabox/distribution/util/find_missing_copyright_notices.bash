#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Finding files missing copyright notices"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

show_usage_and_exit() {
    cat 1>&2 <<EOF
Usage: $0 [options] <path to search>

Find files that are missing the SWAMP's copyright notice.

Options:
  --replace   Replace the year in old notices with the current year
  --help, -?  Display this message
EOF
    exit 1
}

############################################################################

root_path=""
do_replace=""
tmp_file=""

for option in "$@" ; do
    case "$option" in
        --replace)            do_replace=yes ;;
        -\?|-h|-help|--help)  show_usage_and_exit ;;
        *)                    root_path=$option ;;
    esac
done

if [ -z "$root_path" ]; then
    echo "Error: Path to search is required" 1>&2
    echo
    show_usage_and_exit
fi
if [ ! -r "$root_path" ]; then
    echo "Error: Not readable: $root_path" 1>&2
    exit 1
fi

############################################################################

#
# Define the copyright notices to search for.
# Assume that "old" notices are out-of-date by only one year.
#
this_year=$(date +"%Y")
last_year=$((this_year - 1))

old_notice="Copyright 2012-${last_year} Software Assurance Marketplace"
new_notice="Copyright 2012-${this_year} Software Assurance Marketplace"

#
# Define the paths that this script should ignore.
# In particular, 'git's files should never be modified directly.
#
is_valid_path() {
    case "$1" in
        */.git/*)     return 1 ;;
        */.gitignore) return 1 ;;
    esac
    return 0
}

############################################################################

while IFS="" read -r path ; do
    if    is_valid_path "$path" \
       && ! grep -q -I -- "$new_notice" "$path"
    then
        printf '%s\n' "$path"

        if    [ "$do_replace" = "yes" ] \
           && grep -q -I -- "$old_notice" "$path"
        then
            #
            # NOTE: The syntax for 'sed's '-i' option varies between
            # implementations. Thus, we go through some contortions in
            # order to make this script work on multiple platforms.
            #
            if [ -z "$tmp_file" ]; then
                trap 'rm -f "$tmp_file"' EXIT
                tmp_file=$(mktemp "$(basename -- "$0")".XXXXXXXX)
            fi
            cp "$path" "$tmp_file"
            sed -e "s/$old_notice/$new_notice/" <"$tmp_file" >"$path"
        fi
    fi
done < <(find "$root_path" -type f | sort -u)

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished finding files"
else
    echo
    echo "Finished finding files, but with errors" 1>&2
fi
exit $encountered_error
