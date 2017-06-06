#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`
RELEASE_NUMBER="$1"
SWAMP_CONTEXT="$2"

mysql_options_file="/opt/swamp/sql/sql.cnf"
mysql_command="mysql --defaults-file=$mysql_options_file"

encountered_error=0

############################################################################

script_to_remove_tools=""
dirs_with_tool_scripts=""

if [ "$SWAMP_CONTEXT" = -distribution ] ; then

    script_to_remove_tools="/opt/swamp/sql/util/delete_non_user_tools.sql"
    dirs_with_tool_scripts="/opt/swamp/sql/tools"

elif [ "$SWAMP_CONTEXT" = -singleserver -o "$SWAMP_CONTEXT" = -mir-swamp ] ; then

    script_to_remove_tools="/opt/swamp/sql/util/delete_all_tools.sql"
    dirs_with_tool_scripts="/opt/swamp/sql/tools /opt/swamp/sql/tools_other"

else

    echo Error: Unknown SWAMP context: $SWAMP_CONTEXT 1>&2
    exit 1

fi

############################################################################

echo Removing existing bundled tools from the database

if ! $mysql_command < "$script_to_remove_tools" ; then

    echo Warning: Failed to remove existing tools from the database 1>&2
    encountered_error=1

fi

############################################################################

echo Adding bundled tools for the current release to the database

for dir in $dirs_with_tool_scripts; do
    for tool_params_script in "$dir"/*.sql; do

        tool="$tool_params_script"
        tool="$(basename "$tool" .sql)"

        default_params=$(cat "$tool_params_script")
        install_script=$(cat /opt/swamp/sql/util/tool_install.sql)

        echo .. Adding $tool

        if ! $mysql_command <<< "$default_params $install_script" ; then

            echo Warning: Failed to add $tool to the database 1>&2
            encountered_error=1

        fi
    done
done

############################################################################

echo Populating metadata into the database for all tools

if ! $mysql_command < "/opt/swamp/sql/populate_tool_metadata.sql" ; then

    echo Warning: Failed to populate metadata into the database 1>&2
    encountered_error=1

fi

exit $encountered_error
