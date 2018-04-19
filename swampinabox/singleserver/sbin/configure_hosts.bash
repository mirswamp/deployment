#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Make sure the current host is actually in /etc/hosts.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")

############################################################################

if [ ! -f "/etc/hosts" ]; then
    echo "Error: No such file: /etc/hosts" 1>&2
    exit 1
fi

host_ip="$("$BINDIR/find_ip_address.pl" "$HOSTNAME")"
if [ -z "$host_ip" ]; then
    echo "Error: Cannot determine an IP address for $HOSTNAME" 1>&2
    echo "A manual adjustment of /etc/hosts is required." 1>&2
    exit 1
fi

domain="$("$BINDIR/find_domainname.pl" "$HOSTNAME")"
if [ -z "$domain" ]; then
    echo "Error: Cannot determine the domain for $HOSTNAME" 1>&2
    echo "A manual adjustment of /etc/hosts is required." 1>&2
    exit 1
fi

host_alias="${HOSTNAME%.$domain}"

if ! host_config="$(grep "^$host_ip\\>" /etc/hosts 2>/dev/null)" ; then
    echo "Appending '$host_ip $HOSTNAME $host_alias' to /etc/hosts"
    echo "$host_ip $HOSTNAME $host_alias" >> /etc/hosts
else
    echo "Detected host info:  $host_ip $HOSTNAME $host_alias"
    echo "Info in /etc/hosts:  $host_config"

    if ! grep "$HOSTNAME" 1>/dev/null 2>/dev/null <<< "$host_config" ; then
        echo "" 1>&2
        echo "Warning: /etc/hosts doesn't list $HOSTNAME for $host_ip" 1>&2
        echo "A manual adjustment of /etc/hosts might be required." 1>&2
        exit 1
    fi
fi

exit $encountered_error
