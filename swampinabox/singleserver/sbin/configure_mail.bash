#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Configure postfix for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
swamp_context=$1
relayhost=$2

############################################################################

if [ "$swamp_context" = "-singleserver" ]; then
    echo "Flushing Postfix's queue"
    postqueue -f

    echo "Patching /etc/postfix/main.cf"
    diff -wu /etc/postfix/main.cf "$BINDIR/../config_templates/main.cf" | \
        sed -e "s/SED_HOSTNAME/$HOSTNAME/" | \
        sed -e "s/RELAYHOST/$relayhost/" | \
        patch -s /etc/postfix/main.cf

    "$BINDIR/manage_services.bash" restart postfix
fi

exit $encountered_error
