#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure the time zone and set the clock.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
swamp_context=$1

source "$BINDIR/swampinabox_install_util.functions"

############################################################################

if [ "$swamp_context" = "-singleserver" ]; then
    yum_install ntpdate
    yum_confirm ntpdate

    yum_install ntp
    yum_confirm ntp
    chkconfig ntpd on

    #
    # 'ntpd' must be stopped before executing 'ntpdate'.
    #
    "$BINDIR/manage_services.bash" stop ntpd
    ntpdate ntp1.mirsam.org
    "$BINDIR/manage_services.bash" start ntpd
fi

#
# CSA-2807: No longer need to force UTC.
#
# rm /etc/localtime
# if [ ! -h /etc/localtime ]; then
#     ln -sf /usr/share/zoneinfo/UTC /etc/localtime
# fi

exit $encountered_error
