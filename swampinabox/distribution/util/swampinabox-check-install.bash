#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Check various "low-level" aspects of the SWAMP-in-a-Box install.
# Exit with non-zero if any potential issues are found.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

# if [ "$(whoami)" != "root" ]; then
#     echo "Error: This utility must be run as root. Perhaps use 'sudo'." 1>&2
#     exit 1
# fi

############################################################################
#
# Check that we have a consistent install of the SWAMP RPMs.
#

function yum_confirm() {
    encountered_not_installed=0
    installed_pkgs_list="$(yum list installed)"

    for pkg in $*; do
        echo -n "Checking for RPM $pkg ... "
        if grep ^$pkg\\. 1>/dev/null 2>/dev/null <<< "$installed_pkgs_list" ; then
            echo "installed"
        else
            echo "not installed"
            encountered_not_installed=1
        fi
    done
    return $encountered_not_installed
}

function get_rpm_version() {
    pkg="$1"
    if yum_confirm "$pkg" 1>/dev/null 2>/dev/null ; then
        rpm -q --qf '%{VERSION}-%{RELEASE}' "$pkg"
    else
        echo ""
    fi
}

rpm_versions=()

for pkg in swamp-rt-perl swampinabox-backend swamp-web-server ; do
    version=$(get_rpm_version "$pkg")
    rpm_versions+=($version)

    if [ -z "$version" ]; then
        echo "Error: Missing RPM: $pkg" 1>&2
        encountered_error=1
    fi
done

if [ "${rpm_versions[0]}" != "${rpm_versions[1]}" -o \
     "${rpm_versions[1]}" != "${rpm_versions[2]}" -o \
     "${rpm_versions[2]}" != "${rpm_versions[0]}" ]; then
    echo "Error: Found inconsistent versions of the SWAMP RPMs" 1>&2
    encountered_error=1
fi

############################################################################
#
# Check permissions on configuration files that contain passwords.
#

function check_filesystem_permissions() {
    path="$1"
    owner="$2"
    group="$3"
    mode="$4"

    if [ ! -e "$path" ]; then
        echo "Error: No such file: $path" 1>&2
        encountered_error=1
    else
        permissions="$(stat -c "%U/%G %a" "$path")"
        if [ "$permissions" != "$owner/$group $mode" ]; then
            echo "Error: Incorrect permissions: $path" 1>&2
            echo ".. Found: $permissions" 1>&2
            echo ".. Expected: $owner/$group $mode" 1>&2
            encountered_error=1
        fi
    fi
    return 0    # function completed normally
}

check_filesystem_permissions /opt/swamp/etc/swamp.conf swa-daemon mysql 440
check_filesystem_permissions /var/www/swamp-web-server/.env apache apache 400

############################################################################
#
# Check that the installer's various temporary files no longer exist.
#

for path in /etc/.mysql* /opt/swamp/sql/sql.cnf ; do
    if [ -e "$path" ]; then
        echo "Error: File exists: $path" 1>&2
        encountered_error=1
    fi
done

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo "No problems found."
else
    echo "ERROR: Found potential problems with the current install." 1>&2
fi

exit $encountered_error
