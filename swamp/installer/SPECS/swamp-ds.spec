# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

#
# spec file for SWAMP
#
%define is_darwin %(test -e /Applications && echo 1 || echo 0)
%if %is_darwin
%define _topdir	 	/Users/dboulineau/Projects/cosa/trunk/swamp/src/main/deployment/swamp/installer
%define nil #
%define _rpmfc_magic_path   /usr/share/file/magic
%define __os Linux
%endif
%define _arch noarch

#%define __spec_prep_post	%{___build_post}
#%define ___build_post	exit 0
#%define __spec_prep_cmd /bin/sh
#%define __build_cmd /bin/sh
#%define __spec_build_cmd %{__build_cmd}
#%define __spec_build_template	#!%{__spec_build_shell}
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
Requires: swamp-rt-java,swamp-rt-perl,swamp-dataserver-setup
Conflicts: swamp-exec,swamp-submit, swamp-directory-server
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
echo rm -rf $RPM_BUILD_ROOT
echo "At install i am $PWD"
%if %is_darwin
cd %{name}-%{version}
%endif
echo $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/swamp/bin
mkdir -p $RPM_BUILD_ROOT/opt/swamp/etc
mkdir -p $RPM_BUILD_ROOT/opt/swamp/lib
mkdir -p $RPM_BUILD_ROOT/opt/swamp/jar
mkdir -p $RPM_BUILD_ROOT/opt/swamp/run
mkdir -p $RPM_BUILD_ROOT/opt/swamp/log
mkdir -p $RPM_BUILD_ROOT/opt/swamp/sql/upgrades
chmod 01777 $RPM_BUILD_ROOT/opt/swamp/log
mkdir -p $RPM_BUILD_ROOT/opt/swamp/perl5/SWAMP/Client
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
mkdir -p $RPM_BUILD_ROOT/etc/profile.d
mkdir -p $RPM_BUILD_ROOT/etc/init.d


install -m 400 Data_Server/Assessment/assessment_procs.sql ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Package_Store/package_store_procs.sql  ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Platform_Store/platform_store_procs.sql  ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Project/project_procs.sql  ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Tool_Shed/tool_shed_procs.sql ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Viewer_Store/viewer_store_procs.sql ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/Metric/metric_procs.sql ${RPM_BUILD_ROOT}/opt/swamp/sql
install -m 400 Data_Server/upgrades/* ${RPM_BUILD_ROOT}/opt/swamp/sql/upgrades

install -m 644 lib/SWAMP/Client/RunControllerClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/RunControllerClient.pm 
install -m 755 lib/SWAMP/Client/ExecuteRecordCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ExecuteRecordCollectorClient.pm 
install -m 755 lib/SWAMP/Client/LogCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/LogCollectorClient.pm 
install -m 755 lib/SWAMP/Client/GatorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/GatorClient.pm 
install -m 755 lib/SWAMP/Client/AgentClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/AgentClient.pm 
install -m 644 lib/SWAMP/RPCUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/RPCUtils.pm 
install -m 644 lib/SWAMP/Locking.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Locking.pm 
install -m 644 lib/SWAMP/CodeDX.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/CodeDX.pm 
install -m 644 lib/SWAMP/ThreadFix.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/ThreadFix.pm 
install -m 755 lib/SWAMP/SysUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SysUtils.pm
install -m 755 lib/SWAMP/Notification.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Notification.pm
install -m 644 lib/SWAMP/SWAMPUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SWAMPUtils.pm 
install -m 644 lib/SWAMP/FrameworkUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/FrameworkUtils.pm 
install -m 644 lib/SWAMP/PackageTypes.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/PackageTypes.pm 

install -m 755 lib/commons-logging-1.1.jar $RPM_BUILD_ROOT/opt/swamp/lib/commons-logging-1.1.jar
install -m 755 lib/guava-19.0.jar $RPM_BUILD_ROOT/opt/swamp/lib/guava-19.0.jar
install -m 755 lib/log4j-1.2.17p.jar $RPM_BUILD_ROOT/opt/swamp/lib/log4j-1.2.17p.jar
install -m 755 lib/mariadb-java-client-1.3.6.jar $RPM_BUILD_ROOT/opt/swamp/lib/mariadb-java-client-1.3.6.jar
install -m 755 lib/ws-commons-util-1.0.2.jar $RPM_BUILD_ROOT/opt/swamp/lib/ws-commons-util-1.0.2.jar
install -m 755 lib/xmlrpc-client-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-client-3.1.3.jar
install -m 755 lib/xmlrpc-common-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-common-3.1.3.jar
install -m 755 lib/xmlrpc-server-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-server-3.1.3.jar
install -m 755 jar/quartermaster.jar $RPM_BUILD_ROOT/opt/swamp/jar/quartermaster.jar
install -m 755 execute_execution_record $RPM_BUILD_ROOT/usr/local/bin
install -m 755 launch_viewer $RPM_BUILD_ROOT/usr/local/bin
install -m 755 notify_user $RPM_BUILD_ROOT/usr/local/bin
install -m 755 kill_run $RPM_BUILD_ROOT/usr/local/bin

install -m 755 calldorun.pl ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_config ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_monitor ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 launchviewer.pl ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 notifyuser.pl ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 killrun.pl ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 644 swamp.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 dsmonitor.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 findbugs.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 pmd.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 cppcheck.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 clang-sa.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 clang-sa_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 gcc_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 cppcheck_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 pmd_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 findbugs_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 archie_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 dawn_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 reveal_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 generic_common.xslt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 no-build.xslt $RPM_BUILD_ROOT/opt/swamp/etc
ln -s ../etc/swamp.conf $RPM_BUILD_ROOT/opt/swamp/jar/swamp.conf
sed -e's/log4j.appender.SYSLOG.tag=DummyTag/log4j.appender.SYSLOG.tag=QuarterMaster/' log4j.properties > tmp.$$ && mv tmp.$$ log4j.properties
install -m 755 log4j.properties $RPM_BUILD_ROOT/opt/swamp/etc
ln -s ../etc/log4j.properties $RPM_BUILD_ROOT/opt/swamp/jar/log4j.properties
install -m 644 log4perl.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 755 swamp.sh $RPM_BUILD_ROOT/etc/profile.d
install -m 755 swampd-ds $RPM_BUILD_ROOT/etc/init.d/swamp


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon, swa-daemon)
#%doc README TODO COPYING ChangeLog

%dir /opt/swamp/sql
/opt/swamp/sql/assessment_procs.sql 
/opt/swamp/sql/package_store_procs.sql  
/opt/swamp/sql/platform_store_procs.sql
/opt/swamp/sql/project_procs.sql 
/opt/swamp/sql/tool_shed_procs.sql 
/opt/swamp/sql/viewer_store_procs.sql
/opt/swamp/sql/metric_procs.sql
/opt/swamp/sql/upgrades
%dir /opt/swamp/bin
/opt/swamp/bin/calldorun.pl
/opt/swamp/bin/launchviewer.pl
/opt/swamp/bin/notifyuser.pl
/opt/swamp/bin/killrun.pl
/opt/swamp/bin/swamp_config
/opt/swamp/bin/swamp_monitor

%dir /opt/swamp/perl5/SWAMP/Client
%dir /opt/swamp/perl5/SWAMP
%dir /opt/swamp/perl5
/opt/swamp/perl5/SWAMP/Client/RunControllerClient.pm
/opt/swamp/perl5/SWAMP/Client/ExecuteRecordCollectorClient.pm
/opt/swamp/perl5/SWAMP/Client/AgentClient.pm
/opt/swamp/perl5/SWAMP/Client/GatorClient.pm
/opt/swamp/perl5/SWAMP/Client/LogCollectorClient.pm
/opt/swamp/perl5/SWAMP/RPCUtils.pm
/opt/swamp/perl5/SWAMP/Locking.pm
/opt/swamp/perl5/SWAMP/CodeDX.pm
/opt/swamp/perl5/SWAMP/ThreadFix.pm
/opt/swamp/perl5/SWAMP/Notification.pm
/opt/swamp/perl5/SWAMP/SWAMPUtils.pm
/opt/swamp/perl5/SWAMP/SysUtils.pm
/opt/swamp/perl5/SWAMP/FrameworkUtils.pm
/opt/swamp/perl5/SWAMP/PackageTypes.pm
%dir /opt/swamp/jar
/opt/swamp/jar/quartermaster.jar
%dir /opt/swamp/lib
/opt/swamp/lib/commons-logging-1.1.jar
/opt/swamp/lib/guava-19.0.jar
/opt/swamp/lib/log4j-1.2.17p.jar
/opt/swamp/lib/mariadb-java-client-1.3.6.jar
/opt/swamp/lib/ws-commons-util-1.0.2.jar
/opt/swamp/lib/xmlrpc-client-3.1.3.jar
/opt/swamp/lib/xmlrpc-common-3.1.3.jar
/opt/swamp/lib/xmlrpc-server-3.1.3.jar

/etc/profile.d/swamp.sh
/usr/local/bin/execute_execution_record
/usr/local/bin/launch_viewer
/usr/local/bin/notify_user
/usr/local/bin/kill_run
/opt/swamp/run
/opt/swamp/log
%dir /opt/swamp/etc
/opt/swamp/etc/cppcheck.xslt
/opt/swamp/etc/clang-sa.xslt
/opt/swamp/etc/pmd.xslt
/opt/swamp/etc/findbugs.xslt
/opt/swamp/etc/findbugs_common.xslt
/opt/swamp/etc/archie_common.xslt
/opt/swamp/etc/generic_common.xslt
/opt/swamp/etc/dawn_common.xslt
/opt/swamp/etc/reveal_common.xslt
/opt/swamp/etc/clang-sa_common.xslt
/opt/swamp/etc/pmd_common.xslt
/opt/swamp/etc/cppcheck_common.xslt
/opt/swamp/etc/gcc_common.xslt
/opt/swamp/etc/no-build.xslt
%config /opt/swamp/etc/dsmonitor.conf
%config /opt/swamp/etc/swamp.conf
%config /opt/swamp/etc/log4j.properties
%config /opt/swamp/etc/log4perl.conf
%config /opt/swamp/jar/swamp.conf
%config /opt/swamp/jar/log4j.properties
%attr(-, root,root) /etc/init.d/swamp
%post
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
        if [ -r /opt/swamp/sql/upgrades/upgrade_script.sql ]
        then
            echo 'Running SQL upgrade script(s) against database...'
            cd /opt/swamp/sql/upgrades
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
else
    echo Unable to infer the password to mysql, unable to run scripts.
fi
# Set the reporturl name based on which environment we are installing to
iam=`hostname -s`
if [ "$iam" = "swa-csaper-dt-01" -o "$iam" = "dbrhel6test" -o "$iam" = "swa-build-1" ];then
reporturl="https://swa-csaweb-dt-02.cosalab.org/results/"
ldap="ldaps://swa-dir-dt-02.mirsam.org:636"
elif [ "$iam" = "swa-csadata-it-01" ];then
reporturl="https://swa-csaweb-it-01.cosalab.org/results/"
ldap="ldaps://swa-dir-it-01.mirsam.org:636"
elif [ "$iam" = "swa-csadata-pd-01" ];then
reporturl="https://swa-csaweb-pd-01.mir-swamp.org/results/"
ldap="ldaps://swa-dir-pd-01.mirsam.org:636"
fi
/bin/sed -i "s|^#reporturl=.*$|reporturl=$reporturl|" /opt/swamp/etc/swamp.conf
/bin/sed -i "s|^ldap.uri=.*$|ldap.uri=$ldap|" /opt/swamp/etc/swamp.conf

# Arguments to post are {1=>new, 2=>upgrade}
if [ "$1" = "2" ] 
then 
    if [ -r /opt/swamp/etc/swamp.conf.rpmsave ]
    then
        export PERLBREW_ROOT=/opt/perl5
        source $PERLBREW_ROOT/etc/bashrc
        perlbrew use perl-5.18.1
        export PERLLIB=$PERLLIB:/opt/swamp/perl5
        export PERL5LIB=$PERL5LIB:/opt/swamp/perl5
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget quartermasterPort)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset quartermasterPort $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget quartermasterHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset quartermasterHost $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dispatcherHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dispatcherHost $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget agentMonitorHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset agentMonitorHost $val

        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dbQuartermasterURL)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dbQuartermasterURL $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dbQuartermasterPass)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dbQuartermasterPass $val

        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget ldap.auth)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset ldap.auth $val

        echo Configuration updated from swamp.conf.rpmsave
    fi
    echo Restarting SWAMP services
    quartermasterpid=$(ps ax | grep quartermaster.jar | grep -v grep | awk "{print \$1}")
    if [ "$quartermasterpid" != "" ]
    then
        echo "Killing leftover quartermaster.jar $quartermasterpid"
        kill -9 $quartermasterpid
    fi

    service swamp restart
else
    chkconfig --add swamp
    echo Starting SWAMP services
    service swamp start
fi
%preun
# Only remove things if this is an uninstall
if [ "$1" = "0" ] 
then 
    echo Stopping SWAMP services
    service swamp stop
    chkconfig --del swamp
    quartermasterpid=$(ps ax | grep quartermaster.jar | grep -v grep | awk "{print \$1}") 
    if [ "$quartermasterpid" != "" ]
    then
        echo "Killing leftover quartermaster.jar $quartermasterpid"
        kill -9 $quartermasterpid
    fi
fi
