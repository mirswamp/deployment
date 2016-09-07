#!/bin/bash
BINDIR=`dirname $0`

if [ -e /usr/lib/systemd/system/mariadb.service -a ! -e /etc/systemd/system/mysql.service ]; then
    echo "Creating symlink from mysql.service to mariadb.service"
    ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
fi
