#!/bin/bash
BINDIR=`dirname "$0"`

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

universal_skips="-name .git -prune"
copyright_check="$universal_skips , -type f -exec $PWD/$BINDIR/verify-copyright-notice.bash {} ;"

cd ~/swamp

find db $copyright_check

find services/java/*.*  $copyright_check
find services/java/src  $copyright_check
find services/perl      $copyright_check

find deployment -name jdk1.8.0_45 -prune , $copyright_check
