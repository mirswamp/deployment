#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

echo "Install Tools"
srctools="$BINDIR/../swampsrc/tools"
dsttools="/swamp/store/SCATools"
if [ ! -d "$srctools" ];
then
	echo "No $srctools directory for this install"
	exit
fi
echo "cp -r $srctools/* $dsttools"
cp -r $srctools/* $dsttools
chown -R mysql:mysql $dsttools
chmod -R 755 $dsttools
