#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo ""
echo "### Checking the Prerequisites for SWAMP-in-a-Box"
echo ""

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$BINDIR/runtime/bin/swamp_utility.functions"

mode=$1
swamp_context=$2
version=$3
build=$4
rpms_dir=$5

if [ "$swamp_context" = "-singleserver" ]; then
    echo "Nothing to check (\"singleserver\" SWAMP-in-a-Box)"
    exit 0
fi

############################################################################

#
# Check whether the SWAMP-in-a-Box installer has been downloaded and
# extracted in the expected manner.
#
for archive_file in \
        "$BINDIR/../../swampinabox-${version}-platforms.tar.gz" \
        "$BINDIR/../../swampinabox-${version}-tools.tar.gz" \
        ; do
    if [ ! -f "$archive_file" ]; then
        echo "Error: No such file: $archive_file" 1>&2
        exit 1
    fi
done

############################################################################

#
# Check whether this host's hardware meets our requirements.
#
"$BINDIR/runtime/bin/swamp_check_vm_support" \
    || exit 1
"$BINDIR/swampinabox_check_hardware.pl" \
        "$mode" \
        "$swamp_context"  \
        --rpms-dir="${rpms_dir}" \
    || exit 1

#
# Check whether this host's software meets our requirements.
#
if [ "$(getenforce)" = "Enforcing" ]; then
    echo "" 1>&2
    echo "Error: SELinux is enforcing. The SWAMP will not function properly." 1>&2
    echo "To disable SELinux, do the following:" 1>&2
    echo "" 1>&2
    echo "   1. Edit /etc/selinux/config and set SELINUX=disabled." 1>&2
    echo "   2. Reboot this host." 1>&2
    exit 1
fi
if ! check_for_commands \
        basename cat cp dirname head ln lsmod mktemp rm df stty tail \
        chgrp chmod chown chsh groupadd groupmems \
        awk diff install sed patch \
        chkconfig service \
        compress gunzip jar rpm sha512sum tar unzip yum zip \
        guestfish qemu-img virsh virt-copy-out virt-make-fs \
        curl mysql openssl perl php
then
    echo "Perhaps run the SWAMP-in-a-Box \"set up\" scripts." 1>&2
    exit 1
fi

############################################################################

#
# Check whether an install vs. upgrade is appropriate for this host.
#
for pkg in swampinabox-backend swamp-web-server ; do
    installed_ver=$(get_rpm_version "$pkg")

    if [ "$mode" = "-install" ] && [ ! -z "$installed_ver" ]; then
        echo ""
        cat <<EOF
#####################################################################

SWAMP-in-a-Box version $installed_ver appears to be installed.
Installing version $version will *erase* existing data and configuration.

EOF
        echo -n "Are you sure you want to install version $version? [N/y] "
        read -r answer
        echo ""
        if [ "$answer" != "y" ]; then
            exit 1
        fi
        break
    fi
    if [ "$mode" = "-upgrade" ] && [ -z "$installed_ver" ]; then
        echo "" 1>&2
        echo "Error: The $pkg RPM is not installed" 1>&2
        echo "Perhaps run the SWAMP-in-a-Box *install* script." 1>&2
        exit 1
    fi
    if [ "$mode" = "-upgrade" ] && [[ "$installed_ver" =~ ^1[.](27|28)[.-] ]]; then
        echo "" 1>&2
        echo "Error: Upgrading from $installed_ver is not supported" 1>&2
        echo "Perhaps upgrade to an earlier SWAMP-in-a-Box version first." 1>&2
        exit 1
    fi
done

echo "Finished checking the prerequisites for SWAMP-in-a-Box"
