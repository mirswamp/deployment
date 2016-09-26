# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

VIEWER=threadfix
TOMCATVERSION=/opt/apache-tomcat-7.0.65
TOMCATDIR=/opt/tomcat
RUNOUT=/mnt/out/run.out
EVENTOUT=/mnt/events

# function to echo events to RUNOUT and EVENTOUT/event_name file
sequence=10
record_event () {
	event_name=$VIEWER_$1
	event_message=$2
	echo "`date`: $event_message" >> $RUNOUT 2>&1
	echo "`date`: $event_message" > $EVENTOUT/${sequence}${event_name}
	((sequence+=1))
	sync
}

# create the event output mount point and mount device
mkdir -p $EVENTOUT
mount /dev/vdd $EVENTOUT

record_event start "Starting $VIEWER viewer via run.sh"

# start in /mnt/in - the $VIEWER viewer VM input directory
cd /mnt/in

# check for ip connectivity
VMIP=$(ip -4 -o address show dev eth0  | awk '{print $4}' | sed -e's/\/.*$//')
echo "$VMIP `hostname`" >> /etc/hosts
ping -c 3 `hostname`
if [ $? != 0 ]
then
    	record_event noip "ERROR: NO IP ADDRESS"
		record_event noipshutdown "Shutting down $VIEWER viewer via run.sh"
    	shutdown -h now
		exit
fi

cp /mnt/in/swamp-threadfix-service /etc/init.d/.
chmod +x /etc/init.d/swamp-threadfix-service
chkconfig --add swamp-threadfix-service
service swamp-threadfix-service start
chmod +x /mnt/in/threadfix_viewerdb.sh

# start the timeout script via cron and check timeout every CHECKTIMEOUT_FREQUENCY minutes
chmod +x /mnt/in/checktimeout
chmod +x /mnt/in/checktimeout.pl
echo "*/$CHECKTIMEOUT_FREQUENCY * * * * root /mnt/in/checktimeout" >> /etc/crontab

chown -R mysql:mysql /var/lib/mysql/* >> $RUNOUT 2>&1

# start mysql service
record_event mysqlstart "Starting mysql service"
service mysql start >> $RUNOUT 2>&1
if [ $? -ne 0 ]
then
	record_event myqlfail "Service mysql failed to start"
	service mysql status >> $RUNOUT 2>&1
	record_event mysqlshutdown "Shutting down $VIEWER viewer via run.sh"
	shutdown -h now
	exit
else
	record_event mysqlrun "Service mysql running"
	echo "" >> $RUNOUT 2>&1
fi

# restore mysql database from scripts if extant 
if [ -r emptydb-mysql-$VIEWER.sql ]
then
	record_event mysqlempty "Restoring $VIEWER viewer database from emptydb-mysql-$VIEWER.sql"
	mysql --user='root' --password='m@r1ad8l3tm31n' mysql < emptydb-mysql-$VIEWER.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r flushprivs.sql ]
then
	record_event mysqlgrant "Granting privileges for $VIEWER viewer database from flushprivs.sql"
	mysql --user='root' --password='m@r1ad8l3tm31n' mysql < flushprivs.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r resetdb-$VIEWER.sql ]
then
	record_event mysqldrop "Dropping $VIEWER viewer database from resetdb-$VIEWER.sql"
	mysql --user='root' --password='m@r1ad8l3tm31n' < resetdb-$VIEWER.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r emptydb-$VIEWER.sql ]
then
	record_event mysqlempty$VIEWER "Restoring $VIEWER viewer database from emptydb-$VIEWER.sql"
	mysql --user='root' --password='m@r1ad8l3tm31n' $VIEWER < emptydb-$VIEWER.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi
if [ -r $VIEWER.sql ]
then
	record_event mysql$VIEWER "Restoring $VIEWER viewer database from $VIEWER.sql"
	mysql --user='root' --password='m@r1ad8l3tm31n' $VIEWER < $VIEWER.sql >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi

# enter username and password into database
record_event swampuser "Inserting tfdbuser, tfdbpassword into $VIEWER.User"
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
mysql --user='root' --password='m@r1ad8l3tm31n' -e "DELETE FROM $VIEWER.User WHERE name='$tfdbuser'"
mysql --user='root' --password='m@r1ad8l3tm31n' -e "DELETE FROM $VIEWER.User WHERE name='user'"
mysql --user='root' --password='m@r1ad8l3tm31n' -e "INSERT INTO $VIEWER.User VALUES (1,'^A',$createDate,$modifiedDate,'^A',NULL,$failedPasswordAttemptWindowStart,0,'\0','^A','\0',$lastLoginDate,$lastPasswordChangedDate,'\0','$tfdbuser','$tfdbsha256','$tfdbsalt','\0',1)"


# enter APIKEY into database
record_event apikey "Inserting $APIKEY into $VIEWER.APIKey"
mysql --user='root' --password='m@r1ad8l3tm31n' -e "INSERT INTO $VIEWER.APIKey (createdDate, modifiedDate, active, apiKey) VALUES (now(), now(), '0x01', '$APIKEY')" >> $RUNOUT 2>&1

# enter baseUrl into database
record_event apikey "Inserting https://${VMIP}/${PROJECT} into $VIEWER.DefaultConfiguration"
mysql --user='root' --password='m@r1ad8l3tm31n' -e "UPDATE $VIEWER.DefaultConfiguration set baseUrl='https://${VMIP}/${PROJECT}'" >> $RUNOUT 2>&1

# setup tomcat version
ln -s $TOMCATVERSION $TOMCATDIR

# setup $VIEWER proxy directory and unzip $VIEWER.war
mkdir -p $TOMCATDIR/webapps/$PROJECT >> $RUNOUT 2>&1
record_event ${VIEWER}war "Restoring $VIEWER webapp from $VIEWER.war"
unzip -d $TOMCATDIR/webapps/$PROJECT $VIEWER.war

# copy viewer properties
# FIXME this is specific to threadfix
cp -f threadfix.jdbc.properties $TOMCATDIR/webapps/$PROJECT/WEB-INF/classes/jdbc.properties

# adjust file system permissions
chown -R tomcat:tomcat $TOMCATDIR/webapps/$PROJECT >> $RUNOUT 2>&1

# clear tomcat log file and start tomcat
/bin/rm -f $TOMCATDIR/logs/catalina.out >> $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# setup threadfix username and password
# FIXME this is specific to threadfix
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


# start tomcat service
record_event tomcatstart "Starting tomcat service"
service tomcat start >> $RUNOUT 2>&1
if [ $? -ne 0 ]
then
	record_event tomcatfail "Service tomcat failed to start"
	service tomcat status >> $RUNOUT 2>&1
	record_event tomcatshutdown "Shutting down $VIEWER viewer via run.sh"
	shutdown -h now
	exit
else
	record_event tomcatrun "Service tomcat running"
	echo "" >> $RUNOUT 2>&1
fi

#
# Block until $VIEWER says it is ready to go.
# Its OK that this script might run forever, if the VM doesn't wake up in 5 mins, it will be
# reaped anyway.
# FIXME this is specific to threadfix
SERVER_READY='The Server is now ready'
SERVER_READY='Server startup in'
grep -q "$SERVER_READY" $TOMCATDIR/logs/catalina.out
RET=$?
while [ $RET -ne 0 ]
do
    sleep 2
    grep -q "$SERVER_READY" $TOMCATDIR/logs/catalina.out
    RET=$?
done

# echo contents of tomcat log file
echo "`date`: Contents of catalina.out" >> $RUNOUT 2>&1
cat $TOMCATDIR/logs/catalina.out >>  $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# echo contents of $VIEWER webapps directory
echo "`date`: Contents of $TOMCATDIR/webapps" >> $RUNOUT 2>&1
ls -lart $TOMCATDIR/webapps >> $RUNOUT 2>&1

# viewer is up
echo "" >> $RUNOUT 2>&1
record_event ${VIEWER}UP "$VIEWER viewer is UP"

# Tell anyone listening our ipaddress
echo BEGIN ifconfig >> $RUNOUT 2>&1
ip -o -4 address show dev eth0 >> $RUNOUT 2>&1
echo END ifconfig >> $RUNOUT 2>&1
