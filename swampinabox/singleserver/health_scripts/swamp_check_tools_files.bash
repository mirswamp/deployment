#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

mysql_options_file="/opt/swamp/sql/sql.cnf"
mysql_command="mysql --defaults-file=$mysql_options_file"

############################################################################

echo "Querying database for current collection of tool paths and checksums"

tool_paths=$($mysql_command -B -N <<< "select tool_path from tool_shed.tool_version")

if [ $? -ne 0 ]; then
    echo "Error: Failed to get tool paths from the database" 1>&2
    exit 1
fi

############################################################################

echo "Processing tool paths"

encountered_error=0

for path in $tool_paths; do
    if [ ! -e "$path" ]; then
        echo "Error: No such file: $path" 1>&2
        encountered_error=1
        continue
    fi

    checksum=$($mysql_command -B -N <<< "select checksum from tool_shed.tool_version where tool_path = '$path'")
    computed_checksum=$(sha512sum "$path" | awk '{ print $1 }')

    if [ "$checksum" != "$computed_checksum" ]; then
        echo "Error: Checksum failed: $path" 1>&2
        encountered_error=1
        continue
    fi
done

exit $encountered_error
