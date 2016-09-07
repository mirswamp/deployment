#!/bin/bash

BINDIR=`dirname $0`
echo BINDIR: $BINDIR
echo PWD: `pwd`
. $BINDIR/../sbin/getargs.function
getargs "$*"
retval=$?
