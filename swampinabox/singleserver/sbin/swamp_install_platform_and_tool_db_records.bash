#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Install the database records for tools and platforms.
# Intended for use in a docker build in place of `rebuild_tools_db` and `rebuild_platforms_db` 
# (which calls `install_platform -s`)
# This script expects that the mysql service is running and that /opt/swamp/sql/sql.cnf exists
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

if [ "$(whoami)" != "root" ]; then
    echo "Error: This utility must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

############################################################################

BINDIR=$(dirname "$0")
swamp_context=$1

sql_temp=$(mktemp /tmp/rebuild_tools_db.XXXXXXXX)

source "$BINDIR/runtime/sbin/db_support.functions"

############################################################################

if [ "$swamp_context" != "-docker" ]
then
    echo "Error: this utility is for use only in a docker build context."
    exit 1
fi

############################################################################

inventory_file_list=(tools-bundled.txt tools-metric.txt)
tool_remove_all_script="/opt/swamp/sql/util/delete_non_user_tools.sql"

echo "Resetting the tools database by removing existing tools"
do_mysql_command "$tool_remove_all_script"

############################################################################

echo "Adding bundled tools for the current release to the database"
for inventory_file in "${inventory_file_list[@]}" ; do
    while read -r tool_archive ; do
        tool_id=$(echo "$tool_archive" | sed -E -e 's/.gz$//' -e 's/.tar$//')
        params_sql="/opt/swamp/sql/tools/$tool_id.sql"
        install_sql="/opt/swamp/sql/util/tool_install.sql"

        echo "Adding: $tool_id"
        do_mysql_command "$params_sql" "$install_sql"
    done < "/opt/swamp/etc/$inventory_file"
done
echo "Finished adding tools to the database"

############################################################################

echo "Adding tool compatibility information to the database"
echo "Adding: (bundled tools)"
do_mysql_command "/opt/swamp/sql/populate_tool_metadata.sql"

for tool_meta_sql in /opt/swamp/sql/tools_add_on/*.meta.sql ; do
        tool_id=$(basename "$tool_meta_sql" .meta.sql)
        params_sql="/opt/swamp/sql/tools_add_on/$tool_id.sql"

        echo "select tool_version_uuid from tool_shed.tool_version where tool_uuid = @tool_uuid;" > "$sql_temp"
        tool_version_uuids=$(do_mysql_command "$params_sql" "$sql_temp")

    if [ ! -z "$tool_version_uuids" ]; then
        while read -r tool_version_uuid ; do
            escaped_tool_version_uuid=$tool_version_uuid
            escaped_tool_version_uuid=${escaped_tool_version_uuid//\'/\'\'/}
            escaped_tool_version_uuid=${escaped_tool_version_uuid//\\/\\\\/}

            echo "Adding: $tool_id ($tool_version_uuid)"
            echo "set @tool_version_uuid = '$escaped_tool_version_uuid';" > "$sql_temp"
            do_mysql_command "$params_sql" "$sql_temp" "$tool_meta_sql"
        done <<< "$tool_version_uuids"
    fi
done

echo "Finished adding tool compatibility information to the database"

############################################################################

echo "Adding the Ubuntu 16.04 platform to the database"

do_mysql_command "/opt/swamp/sql/platforms/ubuntu-16.04-64.sql"

echo "updating package types for installed tools and platforms"
do_mysql_command "/opt/swamp/sql/util/configure_package_types_after_platform_install.sql"


if [ $encountered_error -eq 0 ]; then
    echo "Finished adding tools and platforms to the database"
else
    echo "Error: Finished adding tools and platforms to the database, but with errors" 1>&2
fi