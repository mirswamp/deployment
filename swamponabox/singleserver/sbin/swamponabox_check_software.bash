#!/bin/bash

if [ "$(getenforce)" == "Enforcing" ]; then
    echo "Warning: SELinux is enforcing and SWAMP will not function properly."
    echo -n "Continue with the install anyway? [N/y] "
    read ANSWER
    if [ "$ANSWER" != "y" ]; then
        echo "You can disable SELinux by editing /etc/selinux/config"
        echo "and setting SELINUX=disabled, and then rebooting this host."
        echo "Exiting ..."
        exit 1
    fi
fi

if [ "$(whoami)" != "root" ]; then
    echo "Error: The install must be performed as root."
    echo "Exiting ..."
    exit 1
fi

if [[ "$(perl -v 2>&1)" =~ "command not found" ]]; then
    echo "perl is required to run the SWAMP installation scripts."
    echo "Error: perl is not found in $USER's path."
    echo "Exiting ..."
    exit 1
fi

exit 0
