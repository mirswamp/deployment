#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`

if [ -e /usr/lib/systemd/system/mariadb.service -a ! -e /etc/systemd/system/mysql.service ]; then
    echo "Creating symlink from mysql.service to mariadb.service"
    ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
fi
