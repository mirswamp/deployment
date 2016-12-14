# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

RUNOUT=/mnt/out/run.out
echo "`date`: mysqldump to /mnt/out/threadfix.sql"
echo "`date`: mysqldump to /mnt/out/threadfix.sql" >> $RUNOUT 2>&1
mysqldump --user='threadfix' --password='kEmliabqqXL7SLWWXuny' --databases threadfix > /mnt/out/threadfix.sql 2>> $RUNOUT
dresult=$?
dresultfile=''
if [ "$dresult" != 0 ]; then
	echo "`date`: mysqldump failed: $dresult"
	echo "`date`: mysqldump failed: $dresult" >> $RUNOUT 2>&1
	if [ -r /mnt/out/threadfix.sql ]; then
		echo "`date`: moving /mnt/out/threadfix.sql to /mnt/out/threadfix.sql.error"
		echo "`date`: moving /mnt/out/threadfix.sql to /mnt/out/threadfix.sql.error" >> $RUNOUT 2>&1
		mv /mnt/out/threadfix.sql /mnt/out/threadfix.sql.error
		dresultfile="threadfix.sql.error"
	fi
else
	echo "`date`: mysqldump completed to /mnt/out/threadfix.sql"
	echo "`date`: mysqldump completed to /mnt/out/threadfix.sql" >> $RUNOUT 2>&1
	dresultfile="threadfix.sql"
fi

echo "`date`: bundling threadfix.sql into /mnt/out/threadfix_viewerdb.tar.gz"
echo "`date`: bundling threadfix.sql into /mnt/out/threadfix_viewerdb.tar.gz" >> $RUNOUT 2>&1
if [[ "$dresultfile" == "" ]]; then
	echo "`date`: no results to bundle results: d[$dresult]"
	echo "`date`: no results to bundle results: d[$dresult]" >> $RUNOUT 2>&1
else
	tar --directory=/mnt/out -czf /mnt/out/threadfix_viewerdb.tar.gz $dresultfile
	tresult=$?
	echo "`date`: bundling completed into /mnt/out/threadfix_viewerdb.tar.gz with results: d[$dresult] t[$tresult]"
	echo "`date`: bundling completed into /mnt/out/threadfix_viewerdb.tar.gz with results: d[$dresult] t[$tresult]" >> $RUNOUT 2>&1
fi
