#!/bin/bash
BINDIR=`dirname $0`

RELAYHOST="$1"

echo "Patching postfix"
postqueue -f
diff -wu /etc/postfix/main.cf $BINDIR/../swamponabox_installer/main.cf | sed -e "s/SED_HOSTNAME/$HOSTNAME/" | sed -e "s/RELAYHOST/$RELAYHOST/" | patch /etc/postfix/main.cf
service postfix restart
