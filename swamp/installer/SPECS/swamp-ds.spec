# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# spec file for SWAMP
#
%define _arch noarch

%define __spec_prep_post	%{___build_post}
%define ___build_post	exit 0
%define __spec_prep_cmd /bin/sh
%define __build_cmd /bin/sh
%define __spec_build_cmd %{__build_cmd}
%define __spec_build_template	#!%{__spec_build_shell}
%define _target_os Linux

Summary: Data Server applications for Software Assurance Marketplace (SWAMP)
Name: swamp-dataserver
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swamp-1.tar.gz
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: swamp-rt-perl
Conflicts: swamp-exec,swamp-submit
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the DataServer packages

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
%install
%include common-install-data.txt
%include swamp-install-data.txt
install -m 400 Data_Server/Metric/metric_procs.sql ${RPM_BUILD_ROOT}/opt/swamp/sql

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon, swa-daemon)
%include common-files-data.txt
%include swamp-files-data.txt
/opt/swamp/sql/metric_procs.sql

%pre
%include common-pre.txt

echo "Finished running pre script"

%post
%include common-post.txt
%include swamp-post-common.txt

if [ -r /etc/.mysql ]
then
    pass=`openssl enc -d -aes-256-cbc -in /etc/.mysql  -pass pass:swamp`
    echo '[client]' > /opt/swamp/sql/sql.cnf
    echo password=$pass >> /opt/swamp/sql/sql.cnf
    echo user=root >> /opt/swamp/sql/sql.cnf
    chmod 400 /opt/swamp/sql/sql.cnf
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
    # Are we upgrading?
    if [ "$1" = "2" ]
    then
        if [ -r /opt/swamp/sql/upgrades_data/upgrade_script.sql ]
        then
            echo 'Running SQL upgrades_data script(s) against database...'
            cd /opt/swamp/sql/upgrades_data
            mysql $opt < upgrade_script.sql
        fi
    fi
    # Run the sql scripts against the DS
    echo Running SQL scripts against database...
    echo Assessment
    mysql $opt < /opt/swamp/sql/assessment_procs.sql
    echo Package Store
    mysql $opt < /opt/swamp/sql/package_store_procs.sql
    echo Platform Store
    mysql $opt < /opt/swamp/sql/platform_store_procs.sql
    echo Project
    mysql $opt < /opt/swamp/sql/project_procs.sql
    echo Tool Shed
    mysql $opt < /opt/swamp/sql/tool_shed_procs.sql
    echo Viewer Store
    mysql $opt < /opt/swamp/sql/viewer_store_procs.sql
    echo Metric
    mysql $opt < /opt/swamp/sql/metric_procs.sql
    /bin/rm -f /opt/swamp/sql/sql.cnf
    echo Platforms
    /opt/swamp/sbin/rebuild_platforms_db
    echo Tools
    /opt/swamp/sbin/rebuild_tools_db -mir-swamp
else
    echo Unable to infer the password to mysql, unable to run scripts.
fi
# Set the reporturl name based on which environment we are installing to
iam=`hostname -s`
if [ "$iam" = "swa-csadata-dd-01" ];then
	reporturl="https://swa-csaweb-dd-01.cosalab.org/results"
	ldap="ldaps://swa-dir-dd-01.mirsam.org:636"
elif [ "$iam" = "swa-csaper-dt-01" -o "$iam" = "dbrhel6test" -o "$iam" = "swa-build-1" ];then
	reporturl="https://swa-csaweb-dt-02.cosalab.org/results"
	ldap="ldaps://swa-dir-dt-02.mirsam.org:636"
elif [ "$iam" = "swa-csadata-it-01" ];then
	reporturl="https://swa-csaweb-it-01.cosalab.org/results"
	ldap="ldaps://swa-dir-it-01.mirsam.org:636"
elif [ "$iam" = "swa-csadata-pd-01" ];then
	reporturl="https://swa-csaweb-pd-01.mir-swamp.org/results"
	ldap="ldaps://swa-dir-pd-01.mirsam.org:636"
fi
/bin/sed -i "s|^reporturl\ =\ .*$|reporturl = $reporturl|" /opt/swamp/etc/swamp.conf
/bin/sed -i "s|^ldap.uri\ =\ .*$|ldap.uri = $ldap|" /opt/swamp/etc/swamp.conf

# Arguments to post are {1=>new, 2=>upgrade}

# set group and file permissions on swamp.conf
chmod 440 /opt/swamp/etc/swamp.conf
chgrp mysql /opt/swamp/etc/swamp.conf

%preun
