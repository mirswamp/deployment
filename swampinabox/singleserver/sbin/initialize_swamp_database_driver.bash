#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

BINDIR=`dirname $0`

if [ "$(whoami)" != "root" ]; then
    echo "Error: $0 must be performed as root."
    echo "Exiting ..."
    exit
fi

DBPASSWORD="swampinabox"
echo -n "Enter database root password: [$DBPASSWORD] "
read ANSWER
if [ ! -z $ANSWER ]; then
    DBPASSWORD=$ANSWER
fi

SWAMPADMINPASSWORD="swamp"
echo -n "Enter database root password: [$SWAMPADMINPASSWORD] "
read ANSWER
if [ ! -z $ANSWER ]; then
    SWAMPADMINPASSWORD=$ANSWER
fi

echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo $SWAMPADMINPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

$BINDIR/../sbin/swampinabox_install_database.bash -install -singleserver
$BINDIR/../sbin/swamp_install_tools.bash
$BINDIR/../sbin/manage_services.bash start mysql
