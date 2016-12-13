#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

echo "Install Platforms"

srcplatforms="$BINDIR/../swampsrc/platforms"
dstplatforms="/swamp/platforms/images"

if [ ! -d "$srcplatforms" ];
then
	echo "No $srcplatforms directory for this install"
	exit
fi

filesystem_paths=""
for platform in $srcplatforms/*.qcow2
do
	base=$(basename $platform)
	path="${base//condor-/}"
	path="${path//-master*/}"
	filesystem_paths="${filesystem_paths},'$path'"
	if [ ! -r "$dstplatforms/$base" ]; then
		echo "cp $platform $dstplatforms"
		cp $platform $dstplatforms
	else 
		echo "Found: $dstplatforms/$base"
	fi
done

filesystem_paths="${filesystem_paths/,/}"
echo "Filesystem paths: $filesystem_paths"
chown -R root:root $dstplatforms
chmod 755 $dstplatforms
chmod 644 $dstplatforms/*

#
# In the options file for MySQL:
#   - Quote the password, in case it contains '#'.
#   - Escape backslashes (the only character that needs escaping).
#
# See: http://dev.mysql.com/doc/refman/5.7/en/option-files.html
#
dbroot=`openssl enc -d -aes-256-cbc -in /etc/.mysql_root  -pass pass:swamp`
dbroot=${dbroot//\\/\\\\}
echo '[client]' > /opt/swamp/sql/sql.cnf
echo "password='$dbroot'" >> /opt/swamp/sql/sql.cnf
echo "user=root" >> /opt/swamp/sql/sql.cnf
chmod 400 /opt/swamp/sql/sql.cnf
opt=--defaults-file=/opt/swamp/sql/sql.cnf

# start mysql
service mysql start

# clean up platform_version table
echo "DELETE FROM platform_store.platform_version WHERE platform_path NOT IN ($filesystem_paths)" | mysql $opt 

# clean up platform table
echo "DELETE FROM platform_store.platform WHERE platform_uuid NOT IN (SELECT platform_uuid FROM platform_store.platform_version)" | mysql $opt

# stop mysql
service mysql stop

/bin/rm -f /opt/swamp/sql/sql.cnf
