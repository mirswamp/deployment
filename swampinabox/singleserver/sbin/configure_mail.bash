#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`

RELAYHOST="$1"

echo "Patching postfix"
postqueue -f
diff -wu /etc/postfix/main.cf $BINDIR/../swampinabox_installer/main.cf | sed -e "s/SED_HOSTNAME/$HOSTNAME/" | sed -e "s/RELAYHOST/$RELAYHOST/" | patch /etc/postfix/main.cf
service postfix restart
