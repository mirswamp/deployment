# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

# Bootstrap the environment by testing location of run-params.sh
# docker universe has $_CONDOR_SCRATCH_DIR
source $_CONDOR_SCRATCH_DIR/run-params.sh

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
echo `date +%s` > $VIEWER_STARTEPOCH_FILE

# start in the viewer machine input directory
cd $JOB_INPUT_DIR

# check for ip connectivity
for i in {1..10}
do
	VMIP=$(ip route get 1 | awk '{print $7; exit}')
done
echo $VMIP > $IP_ADDR_FILE
record_event WROTEIPADDR "Wrote $VMIP to $IP_ADDR_FILE" 

# check mysql service status
record_event MYSQLSTART "checking mysql service status"
supervisorctl status mariadb >> $SWAMP_LOG_FILE 2>&1
if [ $? -ne 0 ]
then
	record_event MYSQLFAIL "Service mysql failed to start"
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

# if a previously saved user database exists load it
if [ -r codedx.sql ]
then
	read -r mysqlpw < $MYSQLPWFILE

	record_event MYSQLDROP "Dropping and creating $VIEWER database"
	mysql --user='root' --password="$mysqlpw" < /root/resetdb-codedx.sql >> $SWAMP_LOG_FILE 2>&1  

	record_event USERDB "Restoring $VIEWER user database from codedx.sql"
	mysql --user='root' --password="$mysqlpw" codedx < codedx.sql >> $SWAMP_LOG_FILE 2>&1
	echo "" >> $SWAMP_LOG_FILE 2>&1
fi

# rename /var/lib/codedx/PROJECT to /var/lib/codedx/$PROJECT
mv -v /var/lib/codedx/PROJECT /var/lib/codedx/$PROJECT >> $SWAMP_LOG_FILE 2>&1

# unbundle codedx_config if extant to new location outside of webapps
# setup codedx.props and logback.xml in new location outside of webapps
record_event CREATEPROXY "Extracting /var/lib/codedx/$PROJECT/config"
if [ -r codedx_config.tar ]
then
	record_event CONFIG "Restoring $VIEWER config from codedx_config.tar"
    tar -C /var/lib/codedx/$PROJECT -xf codedx_config.tar
fi
record_event PROPERTIES "Setting system-key in codedx.props"
echo "swa.admin.system-key=$APIKEY" >> /var/lib/codedx/$PROJECT/config/codedx.props

# link /opt/codedx $TOMCATDIR/webapps/$PROJECT
cd $TOMCATDIR/webapps >> $SWAMP_LOG_FILE 2>&1
ln -s /opt/codedx $PROJECT >> $SWAMP_LOG_FILE 2>&1
cd $JOB_INPUT_DIR >> $SWAMP_LOG_FILE 2>&1

# tell tomcat where codedx.props resides
echo "codedx.appdata=\/var\/lib\/codedx\/$PROJECT\/config\/" >> $TOMCATDIR/conf/catalina.properties

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
echo "*/$CHECKTIMEOUT_FREQUENCY * * * * /usr/local/libexec/checktimeout" >> /usr/local/etc/crontab
supervisorctl start supercronic

# viewer is up
echo "" >> $SWAMP_LOG_FILE 2>&1
record_event VIEWERUP "$VIEWER viewer is UP"

# Tell anyone listening our ipaddress
echo BEGIN ifconfig >> $SWAMP_LOG_FILE 2>&1
ip -o -4 address show dev eth0 >> $SWAMP_LOG_FILE 2>&1
echo END ifconfig >> $SWAMP_LOG_FILE 2>&1
