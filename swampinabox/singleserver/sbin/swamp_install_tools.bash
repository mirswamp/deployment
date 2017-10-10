#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Install the bundled tools for the current SWAMP-in-a-Box release.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
SWAMP_CONTEXT="$1"
RELEASE_NUMBER="$2"

#
# For the 'distribution' version of SWAMP-in-a-Box.
#
OLD_INSTALL_DIR="/swamp/store/SCATools"
CURRENT_INSTALL_DIR="/swamp/store/SCATools/bundled"
SOURCE_TARBALL="$BINDIR/../../swampinabox-${RELEASE_NUMBER}-tools.tar.gz"

############################################################################

function remove_distribution_tools_bundle() {
    echo "Removing any existing bundled tool files"
    if [ -d "$CURRENT_INSTALL_DIR" ]; then
        rm -rf "$CURRENT_INSTALL_DIR"/*
    fi

    echo "Removing any existing bundled tool files from previous releases"
    for tool_archive in \
            bandit/bandit-8ba3536-3.tar.gz \
            bandit/bandit-py2-0.14.0-2.tar.gz \
            bandit/bandit-py2-0.14.0-4.tar.gz \
            bandit/bandit-py3-0.14.0-2.tar.gz \
            bandit/bandit-py3-0.14.0-4.tar.gz \
            bandit-py2-0.14.0-6.tar.gz \
            bandit-py2-1.3.0.tar.gz \
            bandit-py3-0.14.0-6.tar.gz \
            bandit-py3-1.3.0.tar.gz \
            brakeman/brakeman-3.0.5-2.tar.gz \
            checkstyle-7.4.tar.gz \
            checkstyle/checkstyle-5.7-5.tar.gz \
            checkstyle/checkstyle-6.17.tar.gz \
            checkstyle/checkstyle-6.2-3.tar.gz \
            clang/clang-sa-3.3-1.tar \
            clang/clang-sa-3.3.tar \
            clang/clang-sa-3.7.0-1.tar \
            clang/clang-sa-3.7.0.tar \
            clang/clang-sa-3.8.0-1.tar \
            clang/clang-sa-3.8.0.tar \
            cloc-1.70.tar.gz \
            cloc/cloc-1.64-3.tar \
            cloc/cloc-1.68.tar \
            cppcheck/cppcheck-1.61-1.tar \
            cppcheck/cppcheck-1.61.tar \
            cppcheck/cppcheck-1.70-1.tar \
            cppcheck/cppcheck-1.70.tar \
            cppcheck/cppcheck-1.71-1.tar \
            cppcheck/cppcheck-1.71.tar \
            cppcheck/cppcheck-1.72-1.tar \
            cppcheck/cppcheck-1.72.tar \
            cppcheck/cppcheck-1.73-1.tar \
            cppcheck/cppcheck-1.73.tar \
            cppcheck/cppcheck-1.74-1.tar \
            cppcheck/cppcheck-1.75-1.tar \
            csslint-1.0.4.tar.gz \
            dawn/dawnscanner-1.3.5-3.tar \
            dependency-check-1.4.4.tar.gz \
            dependency-check/dependency-check-1.4.3-3.tar.gz \
            error-prone-2.0.15.tar.gz \
            error-prone/error-prone-1.1.1-5.tar.gz \
            error-prone/error-prone-2.0.9.tar.gz \
            eslint-3.10.1.tar.gz \
            findbugs-3.0.1-2.tar.gz \
            findbugs/findbugs-2.0.2-3.tar.gz \
            findbugs/findbugs-2.0.3-5.tar.gz \
            findbugs/findbugs-3.0.0-3.tar.gz \
            findbugs/findbugs-3.0.1.tar.gz \
            flake8-py2-2.3.0-3.tar.gz \
            flake8-py2-2.4.1-3.tar.gz \
            flake8-py2-3.2.1.tar.gz \
            flake8-py3-2.3.0-3.tar.gz \
            flake8-py3-2.4.1-3.tar.gz \
            flake8-py3-3.2.1.tar.gz \
            flake/flake8-py2-2.3.0-2.tar.gz \
            flake/flake8-py2-2.4.1.tar.gz \
            flake/flake8-py3-2.3.0-2.tar.gz \
            flake/flake8-py3-2.4.1.tar.gz \
            flow-0.37.4.tar.gz \
            gcc/gcc-warn-0.9.tar.gz \
            jshint-2.9.4.tar.gz \
            lizard-1.12.7.tar.gz \
            lizard/lizard-1.10.4-3.tar \
            lizard/lizard-1.12.6.tar.gz \
            php_codesniffer-2.7.1.tar.gz \
            php_codesniffer-3.0.0rc2.tar.gz \
            phpmd-2.5.0.tar.gz \
            pmd-5.5.2.tar.gz \
            pmd/pmd-5.0.4-4.tar.gz \
            pmd/pmd-5.1.0-4.tar.gz \
            pmd/pmd-5.2.3-4.tar.gz \
            pmd/pmd-5.4.1.tar.gz \
            pylint-py2-1.3.1-3.tar.gz \
            pylint-py2-1.4.4-3.tar.gz \
            pylint-py2-1.6.4.tar.gz \
            pylint-py3-1.3.1-3.tar.gz \
            pylint-py3-1.4.4-3.tar.gz \
            pylint-py3-1.6.4.tar.gz \
            pylint/pylint-py2-1.3.1-2.tar.gz \
            pylint/pylint-py2-1.4.4.tar.gz \
            pylint/pylint-py3-1.3.1-2.tar.gz \
            pylint/pylint-py3-1.4.4.tar.gz \
            reek/reek-2.2.1-5.tar.gz \
            reek/reek-3.1-4.tar.gz \
            retire-js-1.2.10.tar.gz \
            rubocop/rubocop-0.31.0-3.tar.gz \
            rubocop/rubocop-0.33.0-2.tar.gz \
            ruby-lint/ruby-lint-2.0.4-2.tar.gz \
            tidy-html5-5.2.0-2.tar.gz \
            xmllint-2.9.4-2.tar.gz \
            ; do
        file_to_remove="${OLD_INSTALL_DIR}/${tool_archive}"
        if [ -f "$file_to_remove" ]; then
            echo ".. Removing: $file_to_remove"
            rm -f "$file_to_remove"
        fi
    done

    for tool_dir in \
            bandit \
            brakeman \
            checkstyle \
            clang \
            cloc \
            cppcheck \
            dawn \
            dependency-check \
            error-prone \
            findbugs \
            flake \
            gcc \
            lizard \
            pmd \
            pylint \
            reek \
            rubocop \
            ruby-lint \
            ; do
        dir_to_remove="${OLD_INSTALL_DIR}/${tool_dir}"
        if [ -d "$dir_to_remove" ]; then
            echo ".. Removing: $dir_to_remove"
            rmdir "$dir_to_remove"
        fi
    done
}

function extract_distribution_tools_bundle() {
    if [ ! -r "$SOURCE_TARBALL" ]; then
        echo "Error: $0: No such file (or file is not readable): $SOURCE_TARBALL" 1>&2
        return 1
    fi

    echo "Creating: $CURRENT_INSTALL_DIR"
    mkdir -p "$CURRENT_INSTALL_DIR"

    echo "Extracting bundled tool files into: $CURRENT_INSTALL_DIR"
    tar -C "$CURRENT_INSTALL_DIR" --strip-components 1 -zxvf "$SOURCE_TARBALL"

    cat > "$CURRENT_INSTALL_DIR"/_DO_NOT_MAKE_CHANGES_HERE.txt <<EOF
The SWAMP-in-a-Box installer/upgrader script is not guaranteed
to preserve any changes made to the contents of this directory.

In particular, do not create additional files in this directory.
Future runs of the SWAMP-in-a-Box installer/upgrader script may
delete such files without warning.
EOF

    echo "Setting filesystem permissions on the tool files"
    chown -R mysql:mysql "$CURRENT_INSTALL_DIR"
    find "$CURRENT_INSTALL_DIR" -type d -exec chmod u=rwx,og=rx,ugo-s '{}' ';'
    find "$CURRENT_INSTALL_DIR" -type f -exec chmod u=rw,og=r,ugo-s   '{}' ';'
}

############################################################################

#
# The database is to be the authoritative list of tools on the system.
#
/opt/swamp/sbin/rebuild_tools_db "$SWAMP_CONTEXT"

#
# Bring the tool archives on the filesystem into sync with the database.
#
if [ "$SWAMP_CONTEXT" = "-distribution" ]; then
    remove_distribution_tools_bundle
    extract_distribution_tools_bundle

elif [ "$SWAMP_CONTEXT" = "-singleserver" -o "$SWAMP_CONTEXT" = "-mir-swamp" ]; then
    #
    # By default, don't modify the filesystem. If someone hasn't pulled the
    # most recent version of the 'db' repository, it's possible all the file
    # paths in the database will be out-of-date.
    #
    echo "Skipping installation of tool archives: Context is: $SWAMP_CONTEXT"

else
    echo "Error: $0: Unknown SWAMP context: $SWAMP_CONTEXT" 1>&2
    exit 1
fi

exit $encountered_error
