# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

# Bootstrap the environment by testing location of run-params.sh
# vm universe has /mnt/in
# docker universe has _$_CONDOR_SCRATCH_DIR
if [ -r "/mnt/in/run-params.sh" ]
then
    source /mnt/in/run-params.sh
else
    source $_CONDOR_SCRATCH_DIR/run-params.sh
fi

if ! grep 'viewer is UP' $SWAMP_LOG_FILE
then
	echo "VIEWERDBBUNDLESKIP" > $SWAMP_EVENT_FILE
	touch $SKIPPED_BUNDLE
	exit
fi

echo "VIEWERDBBACKUP" > $SWAMP_EVENT_FILE
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to $JOB_OUTPUT_DIR/codedx.sql"
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to $JOB_OUTPUT_DIR/codedx.sql" >> $SWAMP_LOG_FILE 2>&1
mysqldump --user='codedx' --password='PA$$w0rd123' --databases codedx > $JOB_OUTPUT_DIR/codedx.sql 2>> $SWAMP_LOG_FILE
dresult=$?
dresultfile=''
if [ "$dresult" != 0 ]; then
	echo "VIEWERDBDUMPFAIL" > $SWAMP_EVENT_FILE
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult" >> $SWAMP_LOG_FILE 2>&1
	if [ -r $JOB_OUTPUT_DIR/codedx.sql ]; then
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving $JOB_OUTPUT_DIR/codedx.sql to $JOB_OUTPUT_DIR/codedx.sql.error"
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving $JOB_OUTPUT_DIR/codedx.sql to $JOB_OUTPUT_DIR/codedx.sql.error" >> $SWAMP_LOG_FILE 2>&1
		mv $JOB_OUTPUT_DIR/codedx.sql $JOB_OUTPUT_DIR/codedx.sql.error
		dresultfile="codedx.sql.error"
	fi
else
	echo "VIEWERDBDUMPSUCCESS" > $SWAMP_EVENT_FILE
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to $JOB_OUTPUT_DIR/codedx.sql"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to $JOB_OUTPUT_DIR/codedx.sql" >> $SWAMP_LOG_FILE 2>&1
	dresultfile="codedx.sql"
fi

echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling codedx.sql and codedx_config.tar from /var/lib/codedx/$PROJECT/config into $JOB_OUTPUT_DIR/codedx_viewerdb.tar.gz"
echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling codedx.sql and codedx_config.tar from /var/lib/codedx/$PROJECT/config into $JOB_OUTPUT_DIR/codedx_viewerdb.tar.gz" >> $SWAMP_LOG_FILE 2>&1
tar --directory=/var/lib/codedx/$PROJECT -cf $JOB_OUTPUT_DIR/codedx_config.tar config
tar tf $JOB_OUTPUT_DIR/codedx_config.tar > /dev/null 2>> $SWAMP_LOG_FILE
cresult=$?
cresultfile=''
if [ "$cresult" != 0 ]; then
	echo "VIEWERDBCONFIGFAIL" > $SWAMP_EVENT_FILE
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config failed: $cresult"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config failed: $cresult" >> $SWAMP_LOG_FILE 2>&1
	if [ -r $JOB_OUTPUT_DIR/codedx_config.tar ]; then
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving $JOB_OUTPUT_DIR/codedx_config.tar to $JOB_OUTPUT_DIR/codedx_config.tar.error"
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving $JOB_OUTPUT_DIR/codedx_config.tar to $JOB_OUTPUT_DIR/codedx_config.tar.error" >> $SWAMP_LOG_FILE 2>&1
		mv $JOB_OUTPUT_DIR/codedx_config.tar $JOB_OUTPUT_DIR/codedx_config.tar.error
		cresultfile="codedx_config.tar.error"
	fi
else
	echo "VIEWERDBCONFIGSUCCESS" > $SWAMP_EVENT_FILE
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config completed"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: tar /var/lib/codedx/$PROJECT/config completed" >> $SWAMP_LOG_FILE 2>&1
	cresultfile="codedx_config.tar"
fi

if [[ "$dresultfile" == "" && "$cresultfile" == "" ]]; then
	echo "VIEWERDBNOBUNDLE" > $SWAMP_EVENT_FILE
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult] c[$cresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult] c[$cresult]" >> $SWAMP_LOG_FILE 2>&1
else
	tar --directory=$JOB_OUTPUT_DIR -czf $JOB_OUTPUT_DIR/codedx_viewerdb.tar.gz $dresultfile $cresultfile
	tresult=$?
	if [ "$tresult" != 0 ]; then
		echo "VIEWERDBBUNDLEFAIL" > $SWAMP_EVENT_FILE
	else
		echo "VIEWERDBBUNDLESUCCESS" > $SWAMP_EVENT_FILE
	fi
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into $JOB_OUTPUT_DIR/codedx_viewerdb.tar.gz with results: d[$dresult] c[$cresult] t[$tresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into $JOB_OUTPUT_DIR/codedx_viewerdb.tar.gz with results: d[$dresult] c[$cresult] t[$tresult]" >> $SWAMP_LOG_FILE 2>&1
fi
