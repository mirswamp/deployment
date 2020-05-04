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

# test for mysql service running
service mysql status
status=$?
if [ "$status" -ne 0 ]; then
	echo "Error: mysql is not running."
	echo "Exiting ..."
	exit
fi

DBROOT="swampinabox"
echo -n "Enter database root password: [$DBROOT] "
read ANSWER
if [ ! -z $ANSWER ]; then
    DBROOT=$ANSWER
fi

# test for mysql root access here
echo '[client]' > /opt/swamp/sql/sql.cnf
echo password=$DBROOT >> /opt/swamp/sql/sql.cnf
echo user=root >> /opt/swamp/sql/sql.cnf
chmod 400 /opt/swamp/sql/sql.cnf
opt=--defaults-file=/opt/swamp/sql/sql.cnf
result=`echo "SELECT user, host from mysql.user;" | mysql $opt 2>&1`
/bin/rm -f /opt/swamp/sql/sql.cnf
if [[ "$result" =~ ERROR ]]; then
	echo "Error: could not access mysql with root user."
	echo "Exiting ..."
	exit
fi

echo -n "Enter remote host name for ip lookup: "
read ANSWER
if [ ! -z $ANSWER ]; then
    REMOTEHOST=$ANSWER
	REMOTEIP=`host $REMOTEHOST | cut -f4 -d ' '`
	echo "remote ip address: $REMOTEIP"
	# set passwords in database
	echo '[client]' > /opt/swamp/sql/sql.cnf
	echo password=$DBROOT >> /opt/swamp/sql/sql.cnf
	echo user=root >> /opt/swamp/sql/sql.cnf
	chmod 400 /opt/swamp/sql/sql.cnf
	opt=--defaults-file=/opt/swamp/sql/sql.cnf
	result=`echo "CREATE USER 'root'@'${REMOTEIP}' IDENTIFIED BY '${DBROOT}';" | mysql $opt mysql 2>&1`
	echo "CREATE result: $result"
	result=`echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${REMOTEIP}';" | mysql $opt mysql 2>&1`
	echo "GRANT result: $result"
	/bin/rm -f /opt/swamp/sql/sql.cnf
fi
