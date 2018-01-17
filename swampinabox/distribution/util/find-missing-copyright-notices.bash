#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Find files missing the SWAMP copyright notice.
# Assumes the standard SWAMP developer repository checkouts.
#

BINDIR="$(dirname "$0")"
universal_skips="-name .git -prune"
copyright_check="$universal_skips , -type f -exec $(pwd)/$BINDIR/verify-copyright-notice.bash {} ;"

cd ~/swamp

find db         $copyright_check
find services   $copyright_check
find deployment $copyright_check
