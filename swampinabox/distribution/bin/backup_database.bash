#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

# sets global variable ANSWER
function read_password() {
	which="$1"
	user="$2"
	confirm="$3"
	prompt="Enter $which $user password (empty string to skip): "
	if [ "$confirm" == "noconfirm" ]; then
		prompt="Enter $which password for $user (empty string to exit): "
	fi
	read -s -e -r -p "$prompt" ANSWER
	echo ""
	if [ -z "$ANSWER" ]; then
		return
	fi
	if [ "$confirm" == "noconfirm" ]; then
		return
	fi
	prompt="Confirm $which password for $user: "
	read -s -e -r -p "$prompt" CONFIRM
	echo ""
	if [ "$CONFIRM" != "$ANSWER" ]; then
		echo "Error - $user password confirmation failed"
		echo "Exiting ..."
		exit
	fi
}

# sets global variable OPTFILE
function configure_root_password() {
	echo '[client]' > /opt/swamp/sql/sql.cnf
	echo "user='root'" >> /opt/swamp/sql/sql.cnf
	echo "password='$DBROOT'" >> /opt/swamp/sql/sql.cnf
	chmod 400 /opt/swamp/sql/sql.cnf
	OPTFILE=--defaults-file=/opt/swamp/sql/sql.cnf
}

if [ "$(whoami)" != "root" ]; then
    echo "Error: $0 must be performed as root."
    echo "Exiting ..."
    exit
fi

# test for mysql service running
service mysql status
status=$?
if [ "$status" -ne 0 ]; then
	echo "Error: mysql is not running."
	echo "Exiting ..."
	exit
fi

read_password current "database root" noconfirm
if [ -z "$ANSWER" ]; then
	echo "Exiting ..."
	exit
fi
ANSWER=${ANSWER//\\/\\\\}
ANSWER=${ANSWER//\'/\\\'}
DBROOT="$ANSWER"

# test for mysql root access here
configure_root_password "$DBROOT"
result=`echo "SELECT user, host from mysql.user;" | mysql $OPTFILE 2>&1`
if [[ "$result" =~ ERROR ]]; then
	/bin/rm -f /opt/swamp/sql/sql.cnf
	echo "Error: could not access mysql with root user."
	echo "Exiting ..."
	exit
fi

if [ ! -r /opt/swamp/sql/backup_db ]; then
	/bin/rm -f /opt/swamp/sql/sql.cnf
	echo "Error: /opt/swamp/sql/backup_db backup script not found"
	echo "Exiting ..."
	exit
fi

/opt/swamp/sql/backup_db
if [ $? -ne 0 ];
then
	echo "Error: /opt/swamp/sql/backup_db failed with exit code: $?"
else
	echo "swamp database and schema backed up to current directory"
fi

/bin/rm -f /opt/swamp/sql/sql.cnf
