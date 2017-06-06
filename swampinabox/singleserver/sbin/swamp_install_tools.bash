#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`
RELEASE_NUMBER="$1"

. "$BINDIR/swampinabox_install_util.functions"

trap 'remove_mysql_options_file; exit 1' INT TERM

start_mysql_service
create_mysql_options_file

"$BINDIR"/swamp_install_tools_db.bash "$RELEASE_NUMBER" -singleserver
"$BINDIR"/swamp_install_tools_files.bash "$RELEASE_NUMBER" -singleserver

remove_mysql_options_file
stop_mysql_service
