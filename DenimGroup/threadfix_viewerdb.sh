# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

RUNOUT=/mnt/out/run.out
EVENTOUT="/dev/ttyS1"
echo "VIEWERDBBACKUP" > $EVENTOUT
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to /mnt/out/threadfix.sql"
echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump to /mnt/out/threadfix.sql" >> $RUNOUT 2>&1
mysqldump --user='threadfix' --password='kEmliabqqXL7SLWWXuny' --databases threadfix > /mnt/out/threadfix.sql 2>> $RUNOUT
dresult=$?
dresultfile=''
if [ "$dresult" != 0 ]; then
	echo "VIEWERDBDUMPFAIL" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump failed: $dresult" >> $RUNOUT 2>&1
	if [ -r /mnt/out/threadfix.sql ]; then
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/threadfix.sql to /mnt/out/threadfix.sql.error"
		echo "`date +"%Y/%m/%d %H:%M:%S"`: moving /mnt/out/threadfix.sql to /mnt/out/threadfix.sql.error" >> $RUNOUT 2>&1
		mv /mnt/out/threadfix.sql /mnt/out/threadfix.sql.error
		dresultfile="threadfix.sql.error"
	fi
else
	echo "VIEWERDBDUMPSUCCESS" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to /mnt/out/threadfix.sql"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: mysqldump completed to /mnt/out/threadfix.sql" >> $RUNOUT 2>&1
	dresultfile="threadfix.sql"
fi

echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling threadfix.sql into /mnt/out/threadfix_viewerdb.tar.gz"
echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling threadfix.sql into /mnt/out/threadfix_viewerdb.tar.gz" >> $RUNOUT 2>&1
if [[ "$dresultfile" == "" ]]; then
	echo "VIEWERDBNOBUNDLE" > $EVENTOUT
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: no results to bundle results: d[$dresult]" >> $RUNOUT 2>&1
else
	tar --directory=/mnt/out -czf /mnt/out/threadfix_viewerdb.tar.gz $dresultfile
	tresult=$?
	if [ "$tresult" != 0 ]; then
		echo "VIEWERDBBUNDLEFAIL" > $EVENTOUT
	else
		echo "VIEWERDBBUNDLESUCCESS" > $EVENTOUT
	fi
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into /mnt/out/threadfix_viewerdb.tar.gz with results: d[$dresult] t[$tresult]"
	echo "`date +"%Y/%m/%d %H:%M:%S"`: bundling completed into /mnt/out/threadfix_viewerdb.tar.gz with results: d[$dresult] t[$tresult]" >> $RUNOUT 2>&1
fi
