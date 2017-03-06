#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Remove files that are left over from older releases of SWAMP-in-a-Box.
# We can't delete and rebuild the platforms and tools directories because
# the site might have "add-ons" installed.
#

function remove_file() {
    target="$1"
    if [ -e "$target" ]; then
        echo "Removing $target"
        rm -f "$target"
    fi
}

function remove_dir() {
    target="$1"
    if [ -e "$target" ]; then
        echo "Removing $target"
        rmdir "$target"
    fi
}

#
# 1.27.* -> 1.28.1: Remove old platforms and tools.
#
for file_to_remove in \
        /swamp/store/SCATools/bandit/bandit-8ba3536-3.tar.gz \
        /swamp/store/SCATools/bandit/bandit-py2-0.14.0-2.tar.gz \
        /swamp/store/SCATools/bandit/bandit-py3-0.14.0-2.tar.gz \
        /swamp/store/SCATools/clang/clang-sa-3.3.tar \
        /swamp/store/SCATools/clang/clang-sa-3.7.0.tar \
        /swamp/store/SCATools/clang/clang-sa-3.8.0.tar \
        /swamp/store/SCATools/cloc/cloc-1.64-3.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.61.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.70.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.71.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.72.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.73.tar \
        /swamp/store/SCATools/lizard/lizard-1.10.4-3.tar \
        ; do

    remove_file "$file_to_remove"
done

#
# 1.28.1 -> 1.29: Remove old tools. (No changes to platforms.)
#
for file_to_remove in \
        /swamp/store/SCATools/bandit/bandit-py2-0.14.0-4.tar.gz \
        /swamp/store/SCATools/bandit/bandit-py3-0.14.0-4.tar.gz \
        /swamp/store/SCATools/cloc/cloc-1.68.tar \
        /swamp/store/SCATools/flake/flake8-py2-2.3.0-2.tar.gz \
        /swamp/store/SCATools/flake/flake8-py2-2.4.1.tar.gz \
        /swamp/store/SCATools/flake/flake8-py3-2.3.0-2.tar.gz \
        /swamp/store/SCATools/flake/flake8-py3-2.4.1.tar.gz \
        /swamp/store/SCATools/lizard/lizard-1.12.6.tar.gz \
        /swamp/store/SCATools/pylint/pylint-py2-1.3.1-2.tar.gz \
        /swamp/store/SCATools/pylint/pylint-py2-1.4.4.tar.gz \
        /swamp/store/SCATools/pylint/pylint-py3-1.3.1-2.tar.gz \
        /swamp/store/SCATools/pylint/pylint-py3-1.4.4.tar.gz \
        ; do

    remove_file "$file_to_remove"
done

for dir_to_remove in \
        /swamp/store/SCATools/bandit \
        /swamp/store/SCATools/cloc \
        /swamp/store/SCATools/flake \
        /swamp/store/SCATools/lizard \
        /swamp/store/SCATools/pylint \
        ; do

    remove_dir "$dir_to_remove"
done
