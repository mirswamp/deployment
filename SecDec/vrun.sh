# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

RUNOUT=/mnt/out/run.out
echo "`date`: Starting CodeDX viewer via run.sh" >> $RUNOUT 2>&1

# start in /mnt/in - the CodeDX viewer VM input directory
cd /mnt/in

# check for ip connectivity
ip -4 -o address show dev eth0  | awk '{print $4}' | sed -e's/\/.*$/ '`hostname`'/'  >> /etc/hosts
ping -c 3 `hostname`
if [ $? != 0 ]
then
    	echo ERROR: NO IP ADDRESS >> $RUNOUT
		echo "`date`: Shutting down CodeDX viewer via run.sh" >> $RUNOUT 2>&1
    	shutdown -h now
fi

cp /mnt/in/swamp-codedx-service /etc/init.d/.
chmod +x /etc/init.d/swamp-codedx-service
chkconfig --add swamp-codedx-service
service swamp-codedx-service start
chmod +x /mnt/in/codedx_viewerdb.sh

# start the timeout script via cron and check timeout every CHECKTIMEOUT_FREQUENCY minutes
chmod +x /mnt/in/checktimeout
chmod +x /mnt/in/checktimeout.pl
echo "*/$CHECKTIMEOUT_FREQUENCY * * * * root /mnt/in/checktimeout" >> /etc/crontab

# untar legacy CodeDX viewer database if extant
# this is legacy and should be done externally
if [ -r viewerdb.tar.gz ]
then
	echo "`date`: Restoring CodeDX viewer database from viewerdb.tar.gz" >> $RUNOUT 2>&1
	tar tzf viewerdb.tar.gz --exclude=*/* >> $RUNOUT 2>&1
    # /bin/rm -rf /var/lib/mysql/* >> $RUNOUT 2>&1
    tar -C /var/lib/mysql -xzf viewerdb.tar.gz
	echo "" >> $RUNOUT 2>&1
fi
chown -R mysql:mysql /var/lib/mysql/* >> $RUNOUT 2>&1
sed -i -e'/\[mysqld\]/c[mysqld]\nlower_case_table_names=2' /etc/my.cnf.d/server.cnf >> $RUNOUT 2>&1

# untar CodeDX viewer database restore script and webapp config bundle if extant
if [ -r codedx_viewerdb.tar.gz ]
then
	echo "`date`: Unbundling CodeDX viewer database restore script and webapp config from codedx_viewerdb.tar.gz" >> $RUNOUT 2>&1
	tar xzf codedx_viewerdb.tar.gz
fi

# start mysql service
echo "`date`: Starting mysql service" >> $RUNOUT 2>&1
service mysql start >> $RUNOUT 2>&1
if [ $? -ne 0 ]
then
	echo "`date`: Service mysql failed to start" >> $RUNOUT 2>&1
	service mysql status >> $RUNOUT 2>&1
	echo "`date`: Shutting down CodeDX viewer via run.sh" >> $RUNOUT 2>&1
	shutdown -h now
else
	echo "`date`: Service mysql running" >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi

# restore mysql database from scripts if extant 
if [ ! -r viewerdb.tar.gz ]
then
	if [ -r emptydb-mysql.sql ]
	then
		echo "`date`: Restoring CodeDX viewer database from emptydb-mysql.sql" >> $RUNOUT 2>&1
		mysql --user='root' --password='m@r1ad8l3tm31n' mysql < emptydb-mysql.sql >> $RUNOUT 2>&1
		echo "" >> $RUNOUT 2>&1
	fi
	if [ -r emptydb-codedx.sql ]
	then
		echo "`date`: Restoring CodeDX viewer database from emptydb-codedx.sql" >> $RUNOUT 2>&1
		mysql --user='root' --password='m@r1ad8l3tm31n' codedx < emptydb-codedx.sql >> $RUNOUT 2>&1
		echo "" >> $RUNOUT 2>&1
	fi
	if [ -r codedx.sql ]
	then
		echo "`date`: Restoring CodeDX viewer database from codedx.sql" >> $RUNOUT 2>&1
		mysql --user='root' --password='m@r1ad8l3tm31n' codedx < codedx.sql >> $RUNOUT 2>&1
		echo "" >> $RUNOUT 2>&1
	fi
fi

# unbundle codedx_config if extant to new location outside of webapps
# setup codedx.props and logback.xml in new location outside of webapps
echo "`date`: Creating /var/lib/codedx/$PROJECT" >> $RUNOUT 2>&1
mkdir -p /var/lib/codedx/$PROJECT >> $RUNOUT 2>&1
if [ -r codedx_config.tar ]
then
	echo "`date`: Restoring CodeDX config from codedx_config.tar" >> $RUNOUT 2>&1
    tar -C /var/lib/codedx/$PROJECT -xf codedx_config.tar
else
	echo "`date`: Creating empty CodeDX config" >> $RUNOUT 2>&1
	mkdir -p /var/lib/codedx/$PROJECT/config >> $RUNOUT 2>&1
fi
echo "`date`: Copying codedx.props and logback.xml to CodeDX config" >> $RUNOUT 2>&1
cp codedx.props /var/lib/codedx/$PROJECT/config >> $RUNOUT 2>&1
cp logback.xml /var/lib/codedx/$PROJECT/config >> $RUNOUT 2>&1

# setup codedx proxy directory and unzip codedx.war
mkdir -p /var/lib/tomcat6/webapps/$PROJECT >> $RUNOUT 2>&1
echo "`date`: Restoring CodeDX webapp from codedx.war" >> $RUNOUT 2>&1
# unzip -d /var/lib/tomcat6/webapps/$PROJECT codedx.war >> $RUNOUT 2>&1
unzip -d /var/lib/tomcat6/webapps/$PROJECT codedx.war
chown -R tomcat:tomcat /var/lib/tomcat6/webapps/$PROJECT >> $RUNOUT 2>&1

# indicate that codedx should skip initial installation
touch /var/lib/codedx/$PROJECT/config/.installation >> $RUNOUT 2>&1
chown -R tomcat:tomcat /var/lib/codedx >> $RUNOUT 2>&1

# tell tomcat where codedx.props resides
sed -i "s/^codedx.appdata=.*$/codedx.appdata=\/var\/lib\/codedx\/$PROJECT\/config/" /etc/tomcat6/catalina.properties >>  $RUNOUT 2>&1

# clear tomcat log file and start tomcat
/bin/rm -f /var/log/tomcat6/catalina.out >> $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# start tomcat service
echo "`date`: Starting tomcat service" >> $RUNOUT 2>&1
service tomcat6 start >> $RUNOUT 2>&1
if [ $? -ne 0 ]
then
	echo "`date`: Service tomcat failed to start" >> $RUNOUT 2>&1
	service tomcat6 status >> $RUNOUT 2>&1
	echo "`date`: Shutting down CodeDX viewer via run.sh" >> $RUNOUT 2>&1
	shutdown -h now
else
	echo "`date`: Service tomcat running" >> $RUNOUT 2>&1
	echo "" >> $RUNOUT 2>&1
fi

#
# Block until CodeDX says it is ready to go.
# Its OK that this script might run forever, if the VM doesn't wake up in 5 mins, it will be
# reaped anyway.
grep -q '# The Server is now ready' /var/log/tomcat6/catalina.out
RET=$?
while [ $RET -ne 0 ]
do
    sleep 2
    grep -q '# The Server is now ready' /var/log/tomcat6/catalina.out
    RET=$?
done

# echo contents of tomcat log file
echo "`date`: Contents of catalina.out" >> $RUNOUT 2>&1
cat /var/log/tomcat6/catalina.out >>  $RUNOUT 2>&1
echo "" >> $RUNOUT 2>&1

# echo contents of CodeDX webapps directory
echo "`date`: Contents of /var/lib/tomcat6/webapps" >> $RUNOUT 2>&1
ls -lart /var/lib/tomcat6/webapps >> $RUNOUT 2>&1
echo "`date`: CodeDX viewer is UP" >> $RUNOUT 
echo "" >> $RUNOUT 2>&1

# Tell anyone listening our ipaddress
echo BEGIN ifconfig >> $RUNOUT 2>&1
ip -o -4 address show dev eth0 >> $RUNOUT 2>&1
echo END ifconfig >> $RUNOUT 2>&1
