#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`
RELEASE_NUMBER="$1"

if [ -z "$RELEASE_NUMBER" ]; then
    echo "Error: Usage: '$0' <release number>"
    exit 1
fi

. "$BINDIR/swampinabox_install_util.functions"

trap 'remove_mysql_options_file; exit 1' INT TERM

SOURCE_TARBALL="$BINDIR/../../swampinabox-${RELEASE_NUMBER}-tools.tar.gz"
DESTINATION_DIR="/swamp/store/SCATools/bundled"
OLD_INSTALL_DIR="/swamp/store/SCATools"

TOOL_SCRIPTS_DIR="/opt/swamp/sql/tools"
TOOL_INSTALL_SCRIPT="/opt/swamp/sql/util/tool_install.sql"
TOOL_UNINSTALL_ALL_SCRIPT="/opt/swamp/sql/util/delete_non_user_tools.sql"
TOOL_METADATA_SCRIPT="/opt/swamp/sql/populate_tool_metadata.sql"

############################################################################
#
# Clean out the exiting collection of bundled tool archives.
#

if [ ! -d "$DESTINATION_DIR" ]; then
    mkdir -p "$DESTINATION_DIR"
fi

echo "Removing any existing bundled tool files in '$DESTINATION_DIR'"
rm -rf "$DESTINATION_DIR"/*

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
        echo "Removing '$file_to_remove'"
        rm -f "$file_to_remove" || echo "Failed to remove file: '$file_to_remove'"
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
        echo "Removing '$dir_to_remove'"
        rmdir "$dir_to_remove" || echo "Failed to remove directory: '$dir_to_remove'"
    fi
done

############################################################################
#
# Install the bundled tool archives for the current release.
#

if [ ! -r "$SOURCE_TARBALL" ]; then
    echo "Error: '$SOURCE_TARBALL' does not exist or is not readable"
    exit 1
fi

echo "Extracting bundled tool files into '$DESTINATION_DIR'"
tar -C "$DESTINATION_DIR" --strip-components 1 -zxvf "$SOURCE_TARBALL"

cat > "$DESTINATION_DIR"/_DO_NOT_MAKE_CHANGES_HERE.txt <<EOF
The SWAMP-in-a-Box installer/upgrader script is not guaranteed
to preserve any changes made to the contents of this directory.

In particular, do not create additional files in this directory.
Future runs of the SWAMP-in-a-Box installer/upgrader script may
delete such files without warning.
EOF

echo "Setting file system permissions on the tool files"
chown -R mysql:mysql "$DESTINATION_DIR"
find "$DESTINATION_DIR" -type d -exec chmod u=rwx,og=rx,ugo-s '{}' ';'
find "$DESTINATION_DIR" -type f -exec chmod u=rw,og=r,ugo-s   '{}' ';'

############################################################################
#
# Update the database to reflect the new collection of bundled tools.
#
encountered_error=0

start_mysql_service
create_mysql_options_file

echo "Removing existing bundled tools from the database"
$mysql_command < "$TOOL_UNINSTALL_ALL_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to remove existing bundled tools from the database"
    encountered_error=1
fi

for tool_archive in "$DESTINATION_DIR"/*.tar "$DESTINATION_DIR"/*.tar.gz; do
    if [ ! -f "$tool_archive" ]; then
        continue
    fi

    tool="$tool_archive"
    tool="$(basename "$tool" ".gz")"
    tool="$(basename "$tool" ".tar")"
    tool_script="${TOOL_SCRIPTS_DIR}/${tool}.sql"

    if [ ! -f "$tool_script" ]; then
        echo "Warning: Unable to find database script for tool archive: '$tool_archive'"
        encountered_error=1
        continue
    fi

    default_params=$(cat "${tool_script}")
    custom_params="set @tool_path = '${tool_archive//\'/\\\'}';"
    install_script=$(cat "${TOOL_INSTALL_SCRIPT}")

    echo "Adding '$tool' to the database"
    echo "$default_params" "$custom_params" "$install_script" | $mysql_command
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to add '$tool' to the database"
        encountered_error=1
        continue
    fi
done

#
# Update the database with metadata for all possible tools.
#
echo "Updating metadata for all tools"
$mysql_command < "$TOOL_METADATA_SCRIPT"

remove_mysql_options_file
stop_mysql_service

exit $encountered_error
