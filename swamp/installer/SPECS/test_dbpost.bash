#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

DBPASSWORD="swampinabox"
ADMINPASSWORD="swamp"
SWAMPADMINPASSWORD="{BCRYPT}$(php -r "echo password_hash('$ADMINPASSWORD', PASSWORD_BCRYPT);")"
echo "Creating password files"
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo $SWAMPADMINPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

if [ "$1" == "init" ]; then
	echo "Executing mysql_init.pl"
	/opt/swamp/sql/mysql_init.pl
else
	echo "Executing database script"
	bash ./swampinabox-post-data.txt 1
fi

echo "Removing password files"
rm -f /etc/.mysql_root
rm -f /etc/.mysql_web
rm -f /etc/.mysql_java
rm -f /etc/.mysql_admin

echo "Hello World!"
