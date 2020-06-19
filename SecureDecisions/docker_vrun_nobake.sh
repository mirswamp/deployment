# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

# Bootstrap the environment by testing location of run-params.sh
# docker universe has $_CONDOR_SCRATCH_DIR
source $_CONDOR_SCRATCH_DIR/run-params.sh

viewer="codedx"
MYSQLPWFILE="/.mariadb.pw"
TOMCATSERVICE="tomcat"
TOMCATDIR="/opt/$TOMCATSERVICE"
TOMCATLOG="$TOMCAT_LOG_DIR/catalina.out"
shutdown_on_error=1

# function to echo events to SWAMP_LOG_FILE and SWAMP_EVENT_FILE
sequence=10
record_event () {
	event_name=$1
	event_message=$2
	echo "`date +"%Y/%m/%d %H:%M:%S"`: $sequence $event_name $event_message" >> $SWAMP_LOG_FILE 2>&1
	echo "$event_name" >> $SWAMP_EVENT_FILE
	((sequence+=1))
}

record_event RUNSHSTART "Starting $VIEWER viewer via run.sh"
echo `date +%s` > $RUNEPOCH

# start in the viewer machine input directory
cd $JOB_INPUT_DIR

# check for ip connectivity
for i in {1..10}
do
	VMIP=$(ip route get 1 | awk '{print $7; exit}')
done
echo $VMIP > $IP_ADDR_FILE
record_event WROTEIPADDR "Wrote $VMIP to $IP_ADDR_FILE" 

chmod +x $JOB_INPUT_DIR/backup_viewerdb.sh

# set ownership of mysql
chown -R nobody:nobody /var/lib/mysql/* >> $SWAMP_LOG_FILE 2>&1
sed -i -e'/\[mysqld\]/c[mysqld]\nlower_case_table_names=2' /etc/my.cnf.d/server.cnf >> $SWAMP_LOG_FILE 2>&1

# start mysql service
record_event MYSQLSTART "Starting mysql service"
supervisorctl start mariadb >> $SWAMP_LOG_FILE 2>&1
if [ $? -ne 0 ]
then
	record_event MYSQLFAIL "Service mysql failed to start"
	supervisorctl status mariadb >> $SWAMP_LOG_FILE 2>&1
	if [ $shutdown_on_error -eq 1 ]
	then
		record_event MYSQLSHUTDOWN "Shutting down $VIEWER viewer via run.sh"
		supervisorctl shutdown
		exit
	fi
else
	record_event MYSQLRUN "Service mysql running"
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi

# restore mysql database from scripts if extant 
read -r mysqlpw < $MYSQLPWFILE
# initialize mysql database
if [ -r emptydb-mysql-${viewer}.sql ]
then
	record_event MYSQLEMPTY "Restoring $VIEWER viewer database from emptydb-mysql-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" mysql < emptydb-mysql-${viewer}.sql >> $SWAMP_LOG_FILE 2>&1
	# reset root password
	mysqladmin --user='root' --password="$mysqlpw" flush-privileges
	mysqladmin --user='root' --password='m@r1ad8l3tm31n' password $mysqlpw
	mysqladmin --user='root' --password="$mysqlpw" flush-privileges
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi
# flush priveleges
if [ -r flushprivs.sql ]
then
	record_event MYSQLGRANT "Granting privileges for $VIEWER viewer database from flushprivs.sql"
	mysql --user='root' --password="$mysqlpw" mysql < flushprivs.sql >> $SWAMP_LOG_FILE 2>&1
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi
# drop and create viewer database
if [ -r resetdb-${viewer}.sql ]
then
	record_event MYSQLDROP "Dropping $VIEWER viewer database from resetdb-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" < resetdb-${viewer}.sql >> $SWAMP_LOG_FILE 2>&1
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi
# if a previously saved user database exists load it, 
if [ -r ${viewer}.sql ]
then
	record_event USERDB "Restoring $VIEWER user database from ${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" ${viewer} < ${viewer}.sql >> $SWAMP_LOG_FILE 2>&1
	echo "" >> $SWAMP_LOG_FILE 2>&1
# otherwise load empty database for this version of viewer
elif [ -r emptydb-${viewer}.sql ]
then
	record_event EMPTYDB "Restoring $VIEWER viewer database from emptydb-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" ${viewer} < emptydb-${viewer}.sql >> $SWAMP_LOG_FILE 2>&1
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi

# unbundle ${viewer}_config if extant to new location outside of webapps
# setup codedx.props and logback.xml in new location outside of webapps
record_event CREATEPROXY "Creating /var/lib/${viewer}/$PROJECT"
mkdir -p /var/lib/${viewer}/$PROJECT >> $SWAMP_LOG_FILE 2>&1
if [ -r ${viewer}_config.tar ]
then
	record_event CONFIG "Restoring $VIEWER config from ${viewer}_config.tar"
    tar -C /var/lib/${viewer}/$PROJECT -xf ${viewer}_config.tar
else
	record_event EMPTYCONFIG "Creating empty $VIEWER config"
	mkdir -p /var/lib/${viewer}/$PROJECT/config >> $SWAMP_LOG_FILE 2>&1
fi
record_event PROPERTIES "Copying ${viewer}.props and logback.xml to $VIEWER config"
cp -f ${viewer}.props /var/lib/${viewer}/$PROJECT/config >> $SWAMP_LOG_FILE 2>&1
cp -f logback.xml /var/lib/${viewer}/$PROJECT/config >> $SWAMP_LOG_FILE 2>&1

# setup VIEWER proxy directory and unzip VIEWER.war
mkdir -p $TOMCATDIR/webapps/$PROJECT >> $SWAMP_LOG_FILE 2>&1
record_event WARFILE "Restoring $VIEWER webapp from ${viewer}.war"
unzip -d $TOMCATDIR/webapps/$PROJECT ${viewer}.war
# copy version file to config directory
cp $TOMCATDIR/webapps/$PROJECT/WEB-INF/classes/version.properties /var/lib/codedx/$PROJECT/config

# indicate that ${viewer} should skip initial installation
touch /var/lib/codedx/$PROJECT/config/.installation >> $SWAMP_LOG_FILE 2>&1

# tell tomcat where ${viewer}.props resides
echo "${viewer}.appdata=/var/lib/${viewer}/$PROJECT/config/" >> $TOMCATDIR/conf/catalina.properties

# clear tomcat log file
/bin/rm -f $TOMCATLOG >> $SWAMP_LOG_FILE 2>&1
echo "" >> $SWAMP_LOG_FILE 2>&1

# start tomcat service
record_event TOMCATSTART "Starting tomcat service"
supervisorctl start $TOMCATSERVICE >> $SWAMP_LOG_FILE 2>&1
tomcat_started=0
for i in {1..10}
do
	result=$(supervisorctl status $TOMCATSERVICE)
	if [[ $result == *"RUNNING"* ]]
	then
		tomcat_started=1
		break
	fi
	sleep 1
done
if [ $tomcat_started -eq 0 ]
then
	record_event TOMCATFAIL "Service tomcat failed to start"
	supervisorctl status $TOMCATSERVICE >> $SWAMP_LOG_FILE 2>&1
	if [ $shutdown_on_error -eq 1 ]
	then
		record_event TOMCATSHUTDOWN "Shutting down $VIEWER viewer via run.sh"
		supervisorctl shutdown
		exit
	fi
else
	record_event TOMCATRUN "Service tomcat running"
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi

# check for server startup
SERVER_READY="Server startup in .* ms"
grep -q "$SERVER_READY" $TOMCATLOG
RET=$?
while [ $RET -ne 0 ]
do
    sleep 2
    grep -q "$SERVER_READY" $TOMCATLOG
    RET=$?
done

# echo contents of tomcat log file
echo "`date +"%Y/%m/%d %H:%M:%S"`: Contents of $TOMCATLOG" >> $SWAMP_LOG_FILE 2>&1
head -20 $TOMCATLOG >>  $SWAMP_LOG_FILE 2>&1
echo "" >> $SWAMP_LOG_FILE 2>&1

# echo contents of VIEWER webapps directory
echo "`date +"%Y/%m/%d %H:%M:%S"`: Contents of $TOMCATDIR/webapps" >> $SWAMP_LOG_FILE 2>&1
ls -lart $TOMCATDIR/webapps >> $SWAMP_LOG_FILE 2>&1

# start the timeout script via cron and check timeout every CHECKTIMEOUT_FREQUENCY minutes
record_event TIMERSTART "Starting checktimeout"
chmod +x $JOB_INPUT_DIR/checktimeout
mv $JOB_INPUT_DIR/checktimeout.pl /usr/local/libexec/checktimeout.pl
chmod +x /usr/local/libexec/checktimeout.pl
echo "*/$CHECKTIMEOUT_FREQUENCY * * * * $JOB_INPUT_DIR/checktimeout" >> /usr/local/etc/crontab
supervisorctl start supercronic

# viewer is up
echo "" >> $SWAMP_LOG_FILE 2>&1
record_event VIEWERUP "$VIEWER viewer is UP"

# Tell anyone listening our ipaddress
echo BEGIN ifconfig >> $SWAMP_LOG_FILE 2>&1
ip -o -4 address show dev eth0 >> $SWAMP_LOG_FILE 2>&1
echo END ifconfig >> $SWAMP_LOG_FILE 2>&1

