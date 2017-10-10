#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Configure postfix for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
RELAYHOST="$1"

############################################################################

echo "Patching postfix"
postqueue -f
diff -wu /etc/postfix/main.cf "$BINDIR/../config_templates/main.cf" | sed -e "s/SED_HOSTNAME/$HOSTNAME/" | sed -e "s/RELAYHOST/$RELAYHOST/" | patch /etc/postfix/main.cf
"$BINDIR/manage_services.bash" restart postfix

exit $encountered_error
