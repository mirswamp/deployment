#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

echo Workspace: ${WORKSPACE:?WORKSPACE is not set}

cd $WORKSPACE/deployment/swamp/installer

export RELEASE_NUMBER
RELEASE_NUMBER=${RELEASE_NUMBER:=1.08.DEV}

# Set up perl
export PATH=/opt/perl5/perls/perl-5.18.1/bin:$PATH
perl -v
make clean rpm

cd $WORKSPACE/deployment/swamp/ds-installer
make clean rpm

cd $WORKSPACE/deployment/swamp/swamp-web-server-installer
make clean rpm
