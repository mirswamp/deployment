#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

. "$BINDIR"/swampinabox_install_util.functions

# uses MODE
MODE="$1"

if [ "$MODE" == "-install" ]; then
	echo "Install Database"
else
	echo "Upgrade Database"
fi
echo ""
echo "MODE: $MODE"

function install_directory() {
	echo "install directory"
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
}

function upgrade_directory() {
	echo "upgrade directory"
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
	if [ -r /opt/swamp/sql/upgrades_directory/upgrade_script.sql ]
	then
		echo 'Running SQL upgrade script(s) against database...'
		cd /opt/swamp/sql/upgrades_directory
		mysql $opt < upgrade_script.sql
	fi
	echo "stored procedures"
	mysql $opt < /opt/swamp/sql/project_procs.sql 
}

function install_data() {
	echo "install data"
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
	#
	# Add database users. The passwords need to be escaped for SQL.
	#
	echo "install user_setup"

	dbweb=`openssl enc -d -aes-256-cbc -in /etc/.mysql_web -pass pass:swamp`
	dbweb=${dbweb//\'/\'\'}
	dbweb=${dbweb//\\/\\\\}

	dbjava=`openssl enc -d -aes-256-cbc -in /etc/.mysql_java -pass pass:swamp`
	dbjava=${dbjava//\'/\'\'}
	dbjava=${dbjava//\\/\\\\}

	echo "CREATE USER 'web'@'%' IDENTIFIED BY '${dbweb}';" | mysql $opt mysql
	echo "CREATE USER 'java_agent'@'%' IDENTIFIED BY '${dbjava}';" | mysql $opt mysql
	echo "CREATE USER 'java_agent'@'localhost' IDENTIFIED BY '${dbjava}';" | mysql $opt mysql

	echo "install sys_exec"
	mysql $opt < /opt/swamp/sql/sys_exec.sql

	echo "install prescript"
	mysql $opt < /opt/swamp/sql/swamp_in_a_box_install_prescript.sql

	echo "install tables"
	mysql $opt < /opt/swamp/sql/project_tables.sql
	mysql $opt < /opt/swamp/sql/platform_store_tables.sql
	mysql $opt < /opt/swamp/sql/package_store_tables.sql
	mysql $opt < /opt/swamp/sql/assessment_tables.sql
	mysql $opt < /opt/swamp/sql/viewer_store_tables.sql
	mysql $opt < /opt/swamp/sql/tool_shed_tables.sql
	mysql $opt < /opt/swamp/sql/metric_tables.sql

	echo "install stored procedures"
	mysql $opt < /opt/swamp/sql/project_procs.sql
	mysql $opt < /opt/swamp/sql/platform_store_procs.sql
	mysql $opt < /opt/swamp/sql/tool_shed_procs.sql
	mysql $opt < /opt/swamp/sql/package_store_procs.sql
	mysql $opt < /opt/swamp/sql/assessment_procs.sql
	mysql $opt < /opt/swamp/sql/viewer_store_procs.sql
	mysql $opt < /opt/swamp/sql/metric_procs.sql

	echo "install populate: assessment"
	mysql $opt < /opt/swamp/sql/populate_assessment.sql
	echo "install populate: package_store"
	mysql $opt < /opt/swamp/sql/populate_package_store.sql
	echo "install populate: platforms"
	mysql $opt < /opt/swamp/sql/populate_platforms.sql
	echo "install populate: project"
	mysql $opt < /opt/swamp/sql/populate_project.sql
	echo "install populate: tool_shed"
	mysql $opt < /opt/swamp/sql/populate_tool_shed.sql
	echo "install populate: viewer_store"
	mysql $opt < /opt/swamp/sql/populate_viewer_store.sql
	echo "install populate: non_commercial"
	mysql $opt < /opt/swamp/sql/populate_tools_non_commercial.sql
	echo "install populate: metric"
	mysql $opt < /opt/swamp/sql/populate_metric.sql

	hostname=$HOSTNAME
	outgoing="https://$hostname/results/"
	codedx="https://$hostname/"
	echo "base urls $outgoing and $codedx"
	echo "INSERT INTO system_setting (system_setting_code, system_setting_value) VALUES ('OUTGOING_BASE_URL', '$outgoing');" | mysql $opt assessment
	echo "INSERT INTO system_setting (system_setting_code, system_setting_value) VALUES ('CODEDX_BASE_URL', '$codedx');" | mysql $opt assessment

	echo "install postscript"
	mysql $opt < /opt/swamp/sql/swamp_in_a_box_install_postscript.sql

	echo "install admin user"
	swampadmin=`openssl enc -d -aes-256-cbc -in /etc/.mysql_admin -pass pass:swamp`
	swampadmin=${swampadmin//\'/\'\'}
	swampadmin=${swampadmin//\\/\\\\}
	echo "INSERT INTO user (user_uid, username, password, first_name, last_name, preferred_name, email, address, phone, affiliation, admin, enabled_flag) VALUES ('80835e30-d527-11e2-8b8b-0800200c9a66', 'admin-s', '${swampadmin}', 'System', 'Admin', 'admin', null, null, null, null, 1, 1);" | mysql $opt project

    if [ -r /opt/swamp/thirdparty/codedx/vendor/codedx.war ]; then
        echo "install Code Dx"
        /opt/swamp/bin/install_codedx
    fi
}

function upgrade_data() {
	echo "upgrade data"
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
	echo "upgrade prescript"
	mysql $opt < /opt/swamp/sql/swamp_in_a_box_upgrade_prescript.sql

	echo "upgrade scripts"
	if [ -r /opt/swamp/sql/upgrades_data/upgrade_script.sql ]
	then
		echo 'Running SQL upgrade script(s) against database...'
		cd /opt/swamp/sql/upgrades_data
		mysql $opt < upgrade_script.sql
	fi
	echo "upgrade stored procedures"
	mysql $opt < /opt/swamp/sql/platform_store_procs.sql
	mysql $opt < /opt/swamp/sql/tool_shed_procs.sql
	mysql $opt < /opt/swamp/sql/package_store_procs.sql
	mysql $opt < /opt/swamp/sql/assessment_procs.sql
	mysql $opt < /opt/swamp/sql/viewer_store_procs.sql
	mysql $opt < /opt/swamp/sql/metric_procs.sql

    echo "upgrade viewer database"
    if [ ! -e /opt/swamp/thirdparty/codedx/vendor/codedx.war ]
    then
        echo "Removing Code Dx viewer records (codedx.war not found)"
        mysql $opt < /opt/swamp/sql/uninstall_codedx.sql
    fi

	echo "upgrade postscript"
	mysql $opt < /opt/swamp/sql/swamp_in_a_box_upgrade_postscript.sql
}

function setup_dbroot_defaults_file() {
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
	# chmod ASAP
    chmod 400 /opt/swamp/sql/sql.cnf
    echo "password='$dbroot'" >> /opt/swamp/sql/sql.cnf
    echo "user='root'" >> /opt/swamp/sql/sql.cnf
}

if [ -r /etc/.mysql_root ]
then
	# write defaults-file for mysql database root password
	setup_dbroot_defaults_file
	# install directory, data
	if [ "$MODE" == "-install" ]; then
		echo "install mysql init"
		# mysql_init.pl starts mysql daemon and leaves it running
		/opt/swamp/sql/mysql_init.pl
		if [ $? -ne 0 ]; then
			echo "mysql_init.pl failed with exit code: $?"
			exit_with_error
		fi
		install_directory
		install_data
		echo "install stop mysql"
		service mysql stop
	# upgrade directory, data
	else
		echo "upgrade start mysql"
		service mysql start
		echo "backup mysql database"
		/opt/swamp/sql/backup_db
		if [ $? -ne 0 ]; then
			echo "backup_db failed with exit code: $?"
			exit_with_error
		fi
		upgrade_directory
		upgrade_data
		echo "upgrade stop mysql"
		service mysql stop
	fi
	# remove defaults-file for mysql database root password
    /bin/rm -f /opt/swamp/sql/sql.cnf
else
    echo "mysql root password is unavailable"
	exit_with_error
fi

exit 0
