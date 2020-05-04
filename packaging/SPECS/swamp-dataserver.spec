# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

%define _target_os Linux
%define _arch      noarch

Summary:   Database applications for Software Assurance Marketplace (SWAMP)
Name:      swamp-dataserver
Version:   %(echo $RELEASE_NUMBER)
Release:   %(echo $BUILD_NUMBER)
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Requires:  swamp-rt-perl
Source:    %{name}-%{version}.tar
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains SWAMP's database applications.

SWAMP is a state-of-the-art facility designed to advance our nation's
cybersecurity by improving the security and reliability of open source
software.

############################################################################

%prep
%setup -c -q

%build
pwd

%install
mv %{name}-%{version}/* %{buildroot}
%{_specdir}/fix-permissions.bash %{buildroot}

############################################################################

%files
%defattr(-,root,root)

%config /opt/swamp/etc/log4perl.conf
%config %attr(0660,swa-daemon,mysql) /opt/swamp/etc/swamp.conf
%attr (0755,swa-daemon,root) /opt/swamp/run

/etc/my.cnf.d/mysql_global_settings.cnf
/etc/my.cnf.d/mysql_timezone.cnf
/etc/profile.d/swamp.sh

/opt/swamp

/usr/lib64/mysql/plugin/lib_mysqludf_sys.so
/usr/local/bin/execute_execution_record
/usr/local/bin/launch_viewer
/usr/local/bin/kill_run

############################################################################

%pre
%include %{_specdir}/common-pre.txt
%include %{_specdir}/common-pre-finished.txt

%post
%include %{_specdir}/common-post.txt
%include %{_specdir}/swamp-post-common.txt

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

%preun
