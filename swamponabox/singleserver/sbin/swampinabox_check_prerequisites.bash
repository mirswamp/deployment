#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`
SRCDIR=$BINDIR/../swampsrc

MODE="$1"

if [ "$2" == '-check-hardware' -a "$MODE" == "-install" ]; then
    CHECK_HARDWARE="yes"
else
    CHECK_HARDWARE="no"
fi

REQUIRED_CORES=2
REQUIRED_MEM=8192  # in MB

function confirm_continue() {
    echo -n "Continue with the install? [N/y] "
    read answer
    if [ "$answer" != "y" ]; then
        echo ""
        echo "Installation is not complete."
        return 1
    fi
    return 0
}

############################################################################

if [ "$CHECK_HARDWARE" == "yes" ]; then
    physical_cpus=$((`cat /proc/cpuinfo | grep -i -e 'physical id' | sort -u | wc -l`))
    cores_per_cpu=$((`cat /proc/cpuinfo | grep -i -e 'core id'     | sort -u | wc -l`))
    total_cores=$((physical_cpus * cores_per_cpu))

    if [ $total_cores -lt $REQUIRED_CORES ]; then
        echo ""
        echo "Found $physical_cpus physical CPUs, and $cores_per_cpu cores per physical CPU"
        echo "Warning: Found $total_cores cores total, need at least $REQUIRED_CORES"
        confirm_continue || exit 1
    fi
fi

if [ "$CHECK_HARDWARE" == "yes" ]; then
    physical_mem=$((`cat /proc/meminfo | grep -i 'MemTotal' | head -n 1 | awk '{print $2}'` / 1024))

    if [ $physical_mem -lt $REQUIRED_MEM ]; then
        echo ""
        echo "Warning: Found ${physical_mem} MB physical memory, need at least ${REQUIRED_MEM} MB"
        confirm_continue || exit 1
    fi
fi

if [ "$(getenforce)" == "Enforcing" ]; then
    echo ""
    echo "Warning: SELinux is enforcing and SWAMP will not function properly."
    echo -n "Continue with the install anyway? [N/y] "
    read answer
    if [ "$answer" != "y" ]; then
        echo ""
        echo "You can disable SELinux by editing /etc/selinux/config"
        echo "and setting SELINUX=disabled, and then rebooting this host."
        echo ""
        echo "Installation is not complete."
        exit 1
    fi
fi

if [ "$(whoami)" != "root" ]; then
    echo "Error: The install must be performed as root."
    echo ""
    echo "Error encountered. Installation is not complete."
    exit 1
fi

echo ""

for prog in \
        cp ln rm \
        chgrp chmod chown chsh \
        awk diff sed patch \
        chkconfig service \
        compress jar tar yum zip \
        condor_history condor_q condor_rm condor_status condor_submit \
        guestfish qemu-img virsh virt-copy-out virt-make-fs \
        mysql openssl perl php \
        stty; do
    echo -n "Checking for $prog ... "
    which $prog
    if [ $? -ne 0 ]; then
        echo ""
        echo "Error: $prog is not found in $USER's path."
        echo "Check that the set up script for your system was run, or install $prog."
        echo ""
        echo "Error encountered. Installation is not complete."
        exit 1
    fi
done

if [ "$CHECK_HARDWARE" == "yes" ]; then
    AVAILABLE_DISK=$(df -P -B 1G / | tail -n 1 | awk '{print $4}')

    #
    # Query sizes in bytes, then convert to GB.
    #

    tools_size=$(du -bcs "$SRCDIR"/tools | tail -n 1 | awk '{print $1}')
    platforms_size=$(du -bcs "$SRCDIR"/platforms | tail -n 1 | awk '{print $1}')
    rpms_size=0

    for i in `rpm -q -p --queryformat '%{SIZE}\n' "$SRCDIR"/RPMS/*.rpm`; do
        ((rpms_size += i))
    done

    install_size=$(( (rpms_size + tools_size + platforms_size) / (1024 * 1024 * 1024) ))

    echo ""
    echo "The SWAMP-in-a-Box install requires approximately $install_size GB of disk space"

    if [ "$((install_size + 2))" -le "$AVAILABLE_DISK" ]; then
        echo "Found $AVAILABLE_DISK GB free on the / partition"
    else
        echo "Warning: Found $AVAILABLE_DISK GB free on the / partition"
    fi
    confirm_continue || exit 1
fi

exit 0
