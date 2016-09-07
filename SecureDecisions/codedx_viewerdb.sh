RUNOUT=/mnt/out/run.out
EVENTOUT="/dev/ttyS1"
echo "VIEWERDBBACKUP" > $EVENTOUT
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to /mnt/out/codedx.sql"
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to /mnt/out/codedx.sql" >> $RUNOUT 2>&1
mysqldump --user='codedx' --password='PA$$w0rd123' --databases codedx > /mnt/out/codedx.sql 2>> $RUNOUT
dresult=$?
dresultfile=''
if [ "$dresult" != 0 ]; then
	echo "VIEWERDBDUMPFAIL" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult" >> $RUNOUT 2>&1
	if [ -r /mnt/out/codedx.sql ]; then
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/codedx.sql to /mnt/out/codedx.sql.error"
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/codedx.sql to /mnt/out/codedx.sql.error" >> $RUNOUT 2>&1
		mv /mnt/out/codedx.sql /mnt/out/codedx.sql.error
		dresultfile="codedx.sql.error"
	fi
else
	echo "VIEWERDBDUMPSUCCESS" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to /mnt/out/codedx.sql"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to /mnt/out/codedx.sql" >> $RUNOUT 2>&1
	dresultfile="codedx.sql"
fi

echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling codedx.sql and codedx_config.tar from /var/lib/codedx/$PROJECT/config into /mnt/out/codedx_viewerdb.tar.gz"
echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling codedx.sql and codedx_config.tar from /var/lib/codedx/$PROJECT/config into /mnt/out/codedx_viewerdb.tar.gz" >> $RUNOUT 2>&1
tar --directory=/var/lib/codedx/$PROJECT -cf /mnt/out/codedx_config.tar config
tar tf /mnt/out/codedx_config.tar > /dev/null 2>> $RUNOUT
cresult=$?
cresultfile=''
if [ "$cresult" != 0 ]; then
	echo "VIEWERDBCONFIGFAIL" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config failed: $cresult"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config failed: $cresult" >> $RUNOUT 2>&1
	if [ -r /mnt/out/codedx_config.tar ]; then
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/codedx_config.tar to /mnt/out/codedx_config.tar.error"
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/codedx_config.tar to /mnt/out/codedx_config.tar.error" >> $RUNOUT 2>&1
		mv /mnt/out/codedx_config.tar /mnt/out/codedx_config.tar.error
		cresultfile="codedx_config.tar.error"
	fi
else
	echo "VIEWERDBCONFIGSUCCESS" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config completed"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config completed" >> $RUNOUT 2>&1
	cresultfile="codedx_config.tar"
fi

if [[ "$dresultfile" == "" && "$cresultfile" == "" ]]; then
	echo "VIEWERDBNOBUNDLE" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult] c[$cresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult] c[$cresult]" >> $RUNOUT 2>&1
else
	tar --directory=/mnt/out -czf /mnt/out/codedx_viewerdb.tar.gz $dresultfile $cresultfile
	tresult=$?
	if [ "$tresult" != 0 ]; then
		echo "VIEWERDBBUNDLEFAIL" > $EVENTOUT
	else
		echo "VIEWERDBBUNDLESUCCESS" > $EVENTOUT
	fi
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into /mnt/out/codedx_viewerdb.tar.gz with results: d[$dresult] c[$cresult] t[$tresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into /mnt/out/codedx_viewerdb.tar.gz with results: d[$dresult] c[$cresult] t[$tresult]" >> $RUNOUT 2>&1
fi
