#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

echo Workspace: ${WORKSPACE:?WORKSPACE is not set}

cd $WORKSPACE/deployment/swamp/installer

#RELEASE_NUMBER controls the major/minor release number in ALL RPMs.
export RELEASE_NUMBER
RELEASE_NUMBER=${RELEASE_NUMBER:=1.08.DEV}

# Set up perlbrew.
# if [ -z "$PERLBREW_ROOT" ];then
# export PERLBREW_ROOT=/opt/perl5
# source ${PERLBREW_ROOT}/etc/bashrc
# perlbrew switch perl-5.18.1
# perlbrew list
# fi
export PATH=/opt/perl5/perls/perl-5.18.1/bin:$PATH
perl -v
make tests clean rpm

cd $WORKSPACE/deployment/swamp/ds-installer
make

# These require git specific changes
cd $WORKSPACE/deployment/swamp/swamp-web-server-installer
make tests clean rpm

# Now make the documentation if desired
if [ -n "$GENDOCS" ];then
    cd $WORKSPACE/deployment/doc
    mkdir -p doxygen
    DOCROOT=doxygen make doc
fi
