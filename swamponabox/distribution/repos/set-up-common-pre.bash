#!/bin/bash
BINDIR=`dirname "$0"`
SCRIPT_NAME=$1

. "$BINDIR"/set-up-common.functions

check_os_dist_and_ver "$SCRIPT_NAME"

if [ $? -ne 0 ]; then
    echo "Exiting ..."
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo "Error: This set up script must be run as root."
    echo "Exiting ..."
    exit 1
fi

echo -n "Checking for yum ... "
which yum

if [ $? -ne 0 ]; then
    echo "Error: yum is not found in $USER's path."
    echo "Exiting ..."
    exit 1
fi

exit 0
