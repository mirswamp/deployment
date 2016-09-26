#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`
INITIALDIR=`pwd`

# uses WORKSPACE, RELEASE_NUMBER, BUILD_NUMBER
# if WORKSPACE is not present issue an error
. $BINDIR/../sbin/getargs.function
getargs "-findmax -increment $*"
retval=$?
if [ $retval -ne 0 ]; then
	exit
fi

echo "Upgrade Backend"
echo "MODE: $MODE"
echo "WORKSPACE: $WORKSPACE"
echo "RELEASE_NUMBER: $RELEASE_NUMBER"
echo "BUILD_NUMBER: $BUILD_NUMBER"
echo "BINDIR: $BINDIR"
echo "INITIALDIR: $INITIALDIR"

echo ""
export RELEASE_NUMBER

cd $WORKSPACE
cd services/java
pwd
ant -file swamp08.xml jar

export PATH=/opt/perl5/perls/perl-5.18.1/bin:$PATH

cd $WORKSPACE/deployment/swamp/installer
pwd
make clean rpm > /dev/null 2>&1

WORKSPACE=$WORKSPACE/deployment/swamp
echo "WORKSPACE: $WORKSPACE"

cd $INITIALDIR
pwd

echo ""
echo "Stopping services"
$BINDIR/../sbin/manage_services.bash stop

echo ""
echo "Installing swamp backend"
yum install -y $WORKSPACE/installer/RPMS/noarch/swampinabox-backend-$RELEASE_NUMBER-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Restarting services"
$BINDIR/../sbin/manage_services.bash restart

echo ""
echo "Listing IPTABLES rules"
iptables --list-rules
