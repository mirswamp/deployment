#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`
RELAYHOST="128.104.153.1"

. $BINDIR/../sbin/swampinabox_install_util.functions
. $BINDIR/../sbin/getargs.function

#
# Ensure that temporary DB password files get removed.
#
trap 'stty echo; remove_db_password_files 1>/dev/null 2>/dev/null; exit 1;' INT TERM EXIT

#
# Determine install type, log file location, etc.
#
NOW=$(date +"%Y%m%d_%H%M%S")

if [ -e "$BINDIR/../../log" ]; then
    SWAMP_LOGDIR="$BINDIR/../../log"
else
    SWAMP_LOGDIR="."
fi

if [[ "$0" =~ "install_swampinabox" ]]; then
    getargs "-install $*" || exit 1
    SWAMP_LOGFILE="$SWAMP_LOGDIR/install_swampinabox_$NOW.log"
else
    getargs "-upgrade $*" || exit 1
    SWAMP_LOGFILE="$SWAMP_LOGDIR/upgrade_swampinabox_$NOW.log"
fi

#
# Check that requirements for the install have been met
#
$BINDIR/../sbin/swampinabox_check_prerequisites.bash "$MODE" -singleserver || exit 1

echo ""
echo "############################################################"
echo "##### Checking for Source Files in Developer Directory #####"
echo "############################################################"
if [ ! -d $WORKSPACE/deployment/swamp ]; then
    echo ""
    echo "There is no deployment directory in which to build rpms"
    echo "Create a workspace in a developer's home directory such as /home/<user>/swamp"
    echo "Change to that directory and execute git_clone.bash"
    echo "Then execute $0"
    exit 1
else
    echo ""
    echo "Found deployment directory: $WORKSPACE/deployment/swamp"
fi

echo ""
echo "###########################################"
echo "##### Setting Database Password Files #####"
echo "###########################################"
reset_umask=$(umask -p)
umask 377

echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo $SWAMPADMINPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

$reset_umask

#
# Execute the core of the install/upgrade process.
#
$BINDIR/../sbin/swampinabox_do_install.bash \
        "$WORKSPACE" \
        "$RELEASE_NUMBER" \
        "$BUILD_NUMBER" \
        "$RELAYHOST" \
        "$MODE" \
        "$SWAMP_LOGFILE" \
        "-singleserver" \
    |& tee "$SWAMP_LOGFILE"
