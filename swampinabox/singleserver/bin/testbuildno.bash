#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

CURRENT_RELEASE_NUMBER=`curl -s http://swa-build-1/config.xml | grep RELEASE_NUMBER | sed -e "s/^.*RELEASE_NUMBER=//" | sed -e "s/.DEV.*$//"`

echo $CURRENT_RELEASE_NUMBER

