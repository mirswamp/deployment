#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# Install the SWAMP database tables, stored procedures, and records.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
MODE="$1"
SWAMP_CONTEXT="$2"

############################################################################

#
# Note: 'mysql_init.pl' (used below) starts the 'mysql' service and leaves
# it running, so we can't use the '{start,stop}_mysql_service' functions from
# 'db_support.functions'.
#

. /opt/swamp/sbin/db_support.functions

function do_clean_up() {
    remove_mysql_options_file
    "$BINDIR/manage_services.bash" stop mysql
}

function exit_with_error() {
    do_clean_up
    exit 1
}

trap 'exit_with_error' INT TERM

############################################################################

function install_directory() {
    #
    # Nothing to do
    #
    return 0
}

function upgrade_directory() {
    if [ -r /opt/swamp/sql/upgrades_directory/upgrade_script.sql ]; then
        echo "Running upgrade scripts"
        (cd /opt/swamp/sql/upgrades_directory ; $mysql_command < upgrade_script.sql)
    fi
    echo "Upgrading stored procedures"
    $mysql_command < /opt/swamp/sql/project_procs.sql
}

function install_data() {
    #
    # Add database users. The passwords need to be escaped for SQL.
    #
    echo "Initializing database users"

    dbweb=$(openssl enc -d -aes-256-cbc -in /etc/.mysql_web -pass pass:swamp)
    dbweb=${dbweb//\'/\'\'}
    dbweb=${dbweb//\\/\\\\}

    dbjava=$(openssl enc -d -aes-256-cbc -in /etc/.mysql_java -pass pass:swamp)
    dbjava=${dbjava//\'/\'\'}
    dbjava=${dbjava//\\/\\\\}

    echo "CREATE USER 'web'@'%' IDENTIFIED BY '${dbweb}';" | $mysql_command mysql
    echo "CREATE USER 'java_agent'@'%' IDENTIFIED BY '${dbjava}';" | $mysql_command mysql
    echo "CREATE USER 'java_agent'@'localhost' IDENTIFIED BY '${dbjava}';" | $mysql_command mysql

    echo "Installing 'sys_exec'"
    $mysql_command < /opt/swamp/sql/sys_exec.sql

    echo "Running pre-scripts"
    $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_prescript.sql
    if [ "$SWAMP_CONTEXT" = "-distribution" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_prescript_distribution.sql
    fi
    if [ "$SWAMP_CONTEXT" = "-singleserver" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_prescript_single_server.sql
    fi

    echo "Installing tables"
    $mysql_command < /opt/swamp/sql/project_tables.sql
    $mysql_command < /opt/swamp/sql/platform_store_tables.sql
    $mysql_command < /opt/swamp/sql/package_store_tables.sql
    $mysql_command < /opt/swamp/sql/assessment_tables.sql
    $mysql_command < /opt/swamp/sql/viewer_store_tables.sql
    $mysql_command < /opt/swamp/sql/tool_shed_tables.sql
    $mysql_command < /opt/swamp/sql/metric_tables.sql

    echo "Installing stored procedures"
    $mysql_command < /opt/swamp/sql/project_procs.sql
    $mysql_command < /opt/swamp/sql/platform_store_procs.sql
    $mysql_command < /opt/swamp/sql/tool_shed_procs.sql
    $mysql_command < /opt/swamp/sql/package_store_procs.sql
    $mysql_command < /opt/swamp/sql/assessment_procs.sql
    $mysql_command < /opt/swamp/sql/viewer_store_procs.sql
    $mysql_command < /opt/swamp/sql/metric_procs.sql

    echo "Populating tables"
    $mysql_command < /opt/swamp/sql/populate_assessment.sql
    $mysql_command < /opt/swamp/sql/populate_package_store.sql
    $mysql_command < /opt/swamp/sql/populate_project.sql
    $mysql_command < /opt/swamp/sql/populate_tool_shed.sql
    $mysql_command < /opt/swamp/sql/populate_viewer_store.sql

    echo "Running post-scripts"
    $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_postscript.sql
    if [ "$SWAMP_CONTEXT" == "-distribution" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_postscript_distribution.sql
    fi
    if [ "$SWAMP_CONTEXT" == "-singleserver" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_install_postscript_single_server.sql
    fi

    echo "Installing SWAMP admin user"
    swampadmin=$(openssl enc -d -aes-256-cbc -in /etc/.mysql_admin -pass pass:swamp)
    swampadmin=${swampadmin//\'/\'\'}
    swampadmin=${swampadmin//\\/\\\\}
    echo "INSERT INTO user (user_uid, username, password, first_name, last_name, preferred_name, email, affiliation, admin, enabled_flag) VALUES ('80835e30-d527-11e2-8b8b-0800200c9a66', 'admin-s', '${swampadmin}', 'System', 'Admin', 'admin', null, null, 1, 1);" | $mysql_command project
}

function upgrade_data() {
    echo "Running pre-scripts"
    $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_prescript.sql
    if [ "$SWAMP_CONTEXT" == "-distribution" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_prescript_distribution.sql
    fi
    if [ "$SWAMP_CONTEXT" == "-singleserver" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_prescript_single_server.sql
    fi

    if [ -r /opt/swamp/sql/upgrades_data/upgrade_script.sql ]; then
        echo "Running upgrade scripts"
        (cd /opt/swamp/sql/upgrades_data ; $mysql_command < upgrade_script.sql)
    fi

    echo "Upgrading stored procedures"
    $mysql_command < /opt/swamp/sql/platform_store_procs.sql
    $mysql_command < /opt/swamp/sql/tool_shed_procs.sql
    $mysql_command < /opt/swamp/sql/package_store_procs.sql
    $mysql_command < /opt/swamp/sql/assessment_procs.sql
    $mysql_command < /opt/swamp/sql/viewer_store_procs.sql
    $mysql_command < /opt/swamp/sql/metric_procs.sql

    echo "Running post-scripts"
    $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_postscript.sql
    if [ "$SWAMP_CONTEXT" == "-distribution" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_postscript_distribution.sql
    fi
    if [ "$SWAMP_CONTEXT" == "-singleserver" ]; then
        $mysql_command < /opt/swamp/sql/swamp_in_a_box_upgrade_postscript_single_server.sql
    fi
}

############################################################################

if [ ! -r /etc/.mysql_root -a ! -r /etc/.mysql ]; then
    echo "Error: $0: Unable to read password file" 1>&2
    exit_with_error
fi

create_mysql_options_file

if [ "$MODE" == "-install" ]; then
    #
    # Note: 'mysql_init.pl' starts the 'mysql' service and leaves it running.
    #
    if ! /opt/swamp/sql/mysql_init.pl ; then
        echo "Error: $0: Failed to initialize database using 'mysql_init.pl'" 1>&2
        exit_with_error
    fi
    install_directory
    install_data
else
    "$BINDIR/manage_services.bash" start mysql
    echo "Backing up current database"
    if ! /opt/swamp/sql/backup_db ; then
        echo "Error: $0: Failed to backup database using 'backup_db'" 1>&2
        exit_with_error
    fi
    upgrade_directory
    upgrade_data
fi

do_clean_up

exit $encountered_error
