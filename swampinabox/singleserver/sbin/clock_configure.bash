#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/swampinabox_install_util.functions

yum_install ntpdate
yum_confirm ntpdate || continue_anyway
ntpdate ntp1.mirsam.org

yum_install ntp
yum_confirm ntp || continue_anyway
chkconfig ntpd on
service ntpd start

rm /etc/localtime
if [ ! -h /etc/localtime ]; then
	ln -sf /usr/share/zoneinfo/UTDC /etc/localtime
fi
