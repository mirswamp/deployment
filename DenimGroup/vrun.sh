# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

VIEWER="ThreadFix"
viewer="threadfix"
MYSQLPWFILE="/root/.mysql.pw"
TOMCATVERSION="/opt/apache-tomcat-7.0.72"
TOMCATSERVICE="tomcat"
TOMCATDIR="/opt/$TOMCATSERVICE"
TOMCATLOG="$TOMCATDIR/logs/catalina.out"
RUNOUT="/mnt/out/run.out"
RUNEPOCH="/mnt/out/run.epoch"
EVENTOUT="/dev/ttyS1"

# function to echo events to RUNOUT and EVENTOUT
sequence=10
record_event () {
	event_name=$VIEWER_$1
	event_message=$2
	echo "`date +"%Y/%m/%d %H:%M:%S"`: $sequence $event_name $event_message" >> $RUNOUT 2>&1
	echo "$event_name" > $EVENTOUT
	((sequence+=1))
}

record_event RUNSHSTART "Starting $VIEWER viewer via run.sh"
echo `date +%s` > $RUNEPOCH

# start in /mnt/in - the viewer VM input directory
cd /mnt/in

# check for ip connectivity
VMIP=$(ip -4 -o address show dev eth0  | awk '{print $4}' | sed -e's/\/.*$//')
echo "$VMIP `hostname`" >> /etc/hosts
ping -c 3 `hostname`
if [ $? != 0 ]
then
    	record_event NOIP "ERROR: NO IP ADDRESS"
		record_event NOIPSHUTDOWN "Shutting down $VIEWER viewer via run.sh"
    	shutdown -h now
		exit
fi

# set viewer database backup as shutdown service
cp /mnt/in/swamp-shutdown-service /etc/init.d/.
chmod +x /etc/init.d/swamp-shutdown-service
chkconfig --add swamp-shutdown-service
service swamp-shutdown-service start
chmod +x /mnt/in/backup_viewerdb.sh

# start the timeout script via cron and check timeout every CHECKTIMEOUT_FREQUENCY minutes
chmod +x /mnt/in/checktimeout
chmod +x /mnt/in/checktimeout.pl
echo "*/$CHECKTIMEOUT_FREQUENCY * * * * root /mnt/in/checktimeout" >> /etc/crontab

# set ownership of mysql
chown -R mysql:mysql /var/lib/mysql/* >> $RUNOUT 2>&1

# start mysql service
record_event MYSQLSTART "Starting mysql service"
service mysql start >> $RUNOUT 2>&1
if [ $? -ne 0 ]
then
	record_event MYQLFAIL "Service mysql failed to start"
	service mysql status >> $RUNOUT 2>&1
	record_event MYSQLSHUTDOWN "Shutting down $VIEWER viewer via run.sh"
	shutdown -h now
	exit
else
	record_event MYSQLRUN "Service mysql running"
	echo "" >> $RUNOUT 2>&1
fi

# restore mysql database from scripts if extant 

read -r mysqlpw < $MYSQLPWFILE
if [ -r emptydb-mysql-${viewer}.sql ]
then
	record_event MYSQLEMPTY "Restoring $VIEWER viewer database from emptydb-mysql-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" mysql < emptydb-mysql-${viewer}.sql >> $RUNOUT 2>&1
	# reset root password
	mysqladmin --user='root' --password="$mysqlpw" flush-privileges
	mysqladmin --user='root' --password='m@r1ad8l3tm31n' password $mysqlpw
	mysqladmin --user='root' --password="$mysqlpw" flush-privileges
	echo "" >> $RUNOUT 2>&1
fi
if [ -r flushprivs.sql ]
then
	record_event MYSQLGRANT "Granting privileges for $VIEWER viewer database from flushprivs.sql"
	mysql --user='root' --password="$mysqlpw" mysql < flushprivs.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r resetdb-${viewer}.sql ]
then
	record_event MYSQLDROP "Dropping $VIEWER viewer database from resetdb-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" < resetdb-${viewer}.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r emptydb-${viewer}.sql ]
then
	record_event EMPTYDB "Restoring $VIEWER viewer database from emptydb-${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" ${viewer} < emptydb-${viewer}.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r ${viewer}.sql ]
then
	record_event USERDB "Restoring $VIEWER viewer database from ${viewer}.sql"
	mysql --user='root' --password="$mysqlpw" ${viewer} < ${viewer}.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi

# enter username and password into database
record_event SWAMPUSER "Inserting tfdbuser, tfdbpassword into $VIEWER.User"
tfdbuser="swampuser"
tfdbpassword=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 32 | tr -d '\n')
tfdbsalt=$(uuidgen)
cryptstring=${tfdbpassword}${tfdbsalt}
tfdbsha256=$(echo -n ${cryptstring} | openssl sha256 | sed -e 's/(stdin)= //')

createDate="now()"
modifiedDate="now()"
failedPasswordAttemptWindowStart="'1970-01-01 00:00:00'"
lastLoginDate="now()"
lastPasswordChangedDate="now()"
mysql --user='root' --password="$mysqlpw" -e "DELETE FROM $VIEWER.User WHERE name='$tfdbuser'"
mysql --user='root' --password="$mysqlpw" -e "DELETE FROM $VIEWER.User WHERE name='user'"
mysql --user='root' --password="$mysqlpw" -e "INSERT INTO $VIEWER.User VALUES (1,'^A',$createDate,$modifiedDate,'^A',NULL,$failedPasswordAttemptWindowStart,0,'\0','^A','\0',$lastLoginDate,$lastPasswordChangedDate,'\0','$tfdbuser','$tfdbsha256','$tfdbsalt','\0',1)"


# enter APIKEY into database
record_event APIKEY "Inserting $APIKEY into ${viewer}.APIKey"
mysql --user='root' --password="$mysqlpw" -e "INSERT INTO ${viewer}.APIKey (createdDate, modifiedDate, active, apiKey) VALUES (now(), now(), '0x01', '$APIKEY')" >> $RUNOUT 2>&1


# enter baseUrl into database
record_event  BASEURL "Inserting https://${VMIP}/${PROJECT} into ${viewer}.DefaultConfiguration"
mysql --user='root' --password="$mysqlpw" -e "UPDATE ${viewer}.DefaultConfiguration set baseUrl='https://${VMIP}/${PROJECT}'" >> $RUNOUT 2>&1

# setup tomcat version
rm -f $TOMCATDIR
ln -s $TOMCATVERSION $TOMCATDIR

# setup VIEWER proxy directory and unzip VIEWER.war
mkdir -p $TOMCATDIR/webapps/$PROJECT >> $RUNOUT 2>&1
record_event WARFILE "Restoring $VIEWER webapp from ${viewer}.war"
unzip -d $TOMCATDIR/webapps/$PROJECT ${viewer}.war

# copy viewer properties
cp -f threadfix.jdbc.properties $TOMCATDIR/webapps/$PROJECT/WEB-INF/classes/jdbc.properties

# setup threadfix username and password
sed -i "s/id=\"username\"/id=\"username\" value=\"${tfdbuser}\"/g" $TOMCATDIR/webapps/$PROJECT/login.jsp
sed -i "s/id=\"password\"/id=\"password\" value=\"${tfdbpassword}\"/g" $TOMCATDIR/webapps/$PROJECT/login.jsp

# hide login page content and submit login form on page load
sed -i "s/^<\/html>$//" $TOMCATDIR/webapps/$PROJECT/login.jsp
cat << EOL >> $TOMCATDIR/webapps/$PROJECT/login.jsp
<script>
	// hide page content
	//
	document.body.style = "display:none";

	// submit form on page load
	//
	document.addEventListener("DOMContentLoaded", function() {
		document.forms[0].submit();
	});
</script>
</html>
EOL

# adjust file system permissions
chown -R tomcat:tomcat $TOMCATDIR >> $RUNOUT 2>&1

# clear tomcat log file
/bin/rm -f $TOMCATLOG >> $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# start tomcat service
record_event TOMCATSTART "Starting tomcat service"
service $TOMCATSERVICE start >> $RUNOUT 2>&1
if [ $? -ne 0 ] | grep -q 'Tomcat is not running' $RUNOUT
then
	record_event TOMCATFAIL "Service tomcat failed to start"
	service $TOMCATSERVICE status >> $RUNOUT 2>&1
	record_event TOMCATSHUTDOWN "Shutting down $VIEWER viewer via run.sh"
	shutdown -h now
	exit
else
	record_event TOMCATRUN "Service tomcat running"
	echo "" >> $RUNOUT 2>&1
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
echo "`date +"%Y/%m/%d %H:%M:%S"`: Contents of $TOMCATLOG" >> $RUNOUT 2>&1
cat $TOMCATLOG >>  $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# echo contents of VIEWER webapps directory
echo "`date +"%Y/%m/%d %H:%M:%S"`: Contents of $TOMCATDIR/webapps" >> $RUNOUT 2>&1
ls -lart $TOMCATDIR/webapps >> $RUNOUT 2>&1

# viewer is up
echo "" >> $RUNOUT 2>&1
record_event VIEWERUP "$VIEWER viewer is UP"

# Tell anyone listening our ipaddress
echo BEGIN ifconfig >> $RUNOUT 2>&1
ip -o -4 address show dev eth0 >> $RUNOUT 2>&1
echo END ifconfig >> $RUNOUT 2>&1
