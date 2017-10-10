#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Configure the timezone for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
SWAMP_CONTEXT="$1"

. "$BINDIR/swampinabox_install_util.functions"

############################################################################

if [ "$SWAMP_CONTEXT" = "-singleserver" ]; then
    yum_install ntpdate
    yum_confirm ntpdate

    yum_install ntp
    yum_confirm ntp
    chkconfig ntpd on

    # ntpd must be stopped before executing ntpdate
    "$BINDIR/manage_services.bash" stop ntpd
    ntpdate ntp1.mirsam.org
    "$BINDIR/manage_services.bash" start ntpd
fi

rm /etc/localtime
if [ ! -h /etc/localtime ]; then
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
fi

exit $encountered_error
