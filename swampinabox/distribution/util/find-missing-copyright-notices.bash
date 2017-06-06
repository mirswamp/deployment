#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Find files missing the SWAMP copyright notice.
# Assumes the standard SWAMP developer repository checkouts.
#

BINDIR=`dirname "$0"`

universal_skips="-name .git -prune"
copyright_check="$universal_skips , -type f -exec $PWD/$BINDIR/verify-copyright-notice.bash {} ;"

cd ~/swamp

find db $copyright_check

find services/java/*.*  $copyright_check
find services/java/src  $copyright_check
find services/perl      $copyright_check

find deployment -name 'jdk1.8*' -prune , $copyright_check
