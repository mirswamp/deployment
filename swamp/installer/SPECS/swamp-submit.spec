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


Summary: Submit server applications for Software Assurance Marketplace (SWAMP) 
Name: swamp-submit
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
Requires: swamp-rt-java,swamp-rt-perl
Conflicts: swamp-exec,swamp-ds
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Server packages.

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
%install
echo rm -rf $RPM_BUILD_ROOT
#echo "At install i am $PWD"
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
chmod 01777 $RPM_BUILD_ROOT/opt/swamp/log
mkdir -p $RPM_BUILD_ROOT/opt/swamp/perl5/SWAMP/Client
mkdir -p $RPM_BUILD_ROOT/etc/profile.d
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mkdir -p $RPM_BUILD_ROOT/etc/bash_completion.d

install -m 755 VMConstants.pm $RPM_BUILD_ROOT/opt/swamp/perl5
install -m 755 VMTools.pm $RPM_BUILD_ROOT/opt/swamp/perl5

# TODO This needs to be istalled as a Perl package via cpanm, not manually
install -m 755 lib/SWAMP/AgentMonitorCommon.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/AgentMonitorCommon.pm 
install -m 755 lib/SWAMP/AssessmentTools.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/AssessmentTools.pm 
install -m 755 lib/SWAMP/PackageTypes.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/PackageTypes.pm 
install -m 755 lib/SWAMP/Client/AgentClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/AgentClient.pm 
install -m 755 lib/SWAMP/Client/ExecuteRecordCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ExecuteRecordCollectorClient.pm 
install -m 755 lib/SWAMP/Client/GatorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/GatorClient.pm 
install -m 755 lib/SWAMP/Client/LaunchPadClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/LaunchPadClient.pm 
install -m 755 lib/SWAMP/Client/ViewerMonitorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ViewerMonitorClient.pm 
install -m 755 lib/SWAMP/Client/LogCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/LogCollectorClient.pm 
install -m 755 lib/SWAMP/Client/ResultCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ResultCollectorClient.pm 
install -m 755 lib/SWAMP/Floodlight.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Floodlight.pm 
install -m 755 lib/SWAMP/HTCondorDefines.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/HTCondorDefines.pm 
install -m 755 lib/SWAMP/RPCUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/RPCUtils.pm
install -m 755 lib/SWAMP/Locking.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Locking.pm 
install -m 755 lib/SWAMP/SysUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SysUtils.pm
install -m 755 lib/SWAMP/SWAMPUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SWAMPUtils.pm 
install -m 755 lib/SWAMP/VMPrimitives.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/VMPrimitives.pm 
install -m 755 lib/SWAMP/VMToolsX.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/VMToolsX.pm 

install -m 755 csa_HTCondorAgent.pl ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 csa_agent_launcher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 assessmentlauncher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 vrunlauncher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_config ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_monitor ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 csa_HTCondorAgent_launcher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 csa_agent.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 arun $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 AgentMonitor.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 LaunchPad.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 644 swamp.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 submonitor.conf $RPM_BUILD_ROOT/opt/swamp/etc
ln -s ../etc/swamp.conf $RPM_BUILD_ROOT/opt/swamp/jar/swamp.conf
sed -e's/log4j.appender.SYSLOG.tag=DummyTag/log4j.appender.SYSLOG.tag=AgentDispatcher/' log4j.properties > tmp.$$ && mv tmp.$$ log4j.properties
install -m 755 log4j.properties $RPM_BUILD_ROOT/opt/swamp/etc
ln -s ../etc/log4j.properties $RPM_BUILD_ROOT/opt/swamp/jar/log4j.properties
install -m 644 log4perl.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 755 swampd $RPM_BUILD_ROOT/etc/init.d/swamp
install -m 755 swamp.sh $RPM_BUILD_ROOT/etc/profile.d

install -m 755 lib/commons-logging-1.1.jar $RPM_BUILD_ROOT/opt/swamp/lib/commons-logging-1.1.jar
install -m 755 lib/guava-19.0.jar $RPM_BUILD_ROOT/opt/swamp/lib/guava-19.0.jar
install -m 755 lib/log4j-1.2.17p.jar $RPM_BUILD_ROOT/opt/swamp/lib/log4j-1.2.17p.jar
install -m 755 lib/mariadb-java-client-1.3.6.jar $RPM_BUILD_ROOT/opt/swamp/lib/mariadb-java-client-1.3.6.jar
install -m 755 lib/ws-commons-util-1.0.2.jar $RPM_BUILD_ROOT/opt/swamp/lib/ws-commons-util-1.0.2.jar
install -m 755 lib/xmlrpc-client-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-client-3.1.3.jar
install -m 755 lib/xmlrpc-common-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-common-3.1.3.jar
install -m 755 lib/xmlrpc-server-3.1.3.jar $RPM_BUILD_ROOT/opt/swamp/lib/xmlrpc-server-3.1.3.jar
install -m 755 jar/agentdispatcher.jar $RPM_BUILD_ROOT/opt/swamp/jar/agentdispatcher.jar
#install -m 755 jar/scheduleprocessor.jar $RPM_BUILD_ROOT/opt/swamp/jar/scheduleprocessor.jar
%clean
rm -rf $RPM_BUILD_ROOT

%post
%if %is_darwin
%else

# Floodlight 
iam=`hostname -s`
floodlight=""
if [ "$iam" = "swa-csasub-dt-01" -o "$iam" = "swa-build-1" ];then
    floodlight=http://swa-flood-dt-01.mirsam.org:8080
elif [ "$iam" = "swa-csasub-it-01" -o "$iam" = "dbrhel6test" ];then
    floodlight=http://swa-flood-it-01.mirsam.org:8080
elif [ "$iam" = "swa-csasub-pd-01" ];then
    floodlight=http://swa-flood-pd-01.mirsam.org:8080
fi
if [ "$floodlight" != "" ];then
    /bin/sed -i "s|^floodlight=.*$|floodlight=$floodlight|" /opt/swamp/etc/swamp.conf
else
    echo Please update the floodlight item in /opt/swamp/etc/swamp.conf with the URL of the appropriate floodlight controller
fi

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
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget quartermasterHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset quartermasterHost $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget agentMonitorHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset agentMonitorHost $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dispatcherHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dispatcherHost $val

        # Must quote items that might not exist during upgrade else getOpts will bark.
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget viewerMonitorHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset viewerMonitorHost "$val"
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget viewerMonitorPort)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset viewerMonitorPort "$val"

        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dbQuartermasterURL)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dbQuartermasterURL $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dbQuartermasterPass)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dbQuartermasterPass $val

        echo Configuration updated from swamp.conf.rpmsave
    fi
    echo Restarting SWAMP services
    service swamp stop
    agentdispatcherpid=$(ps ax | grep agentdispatcher.jar | grep -v grep |  awk "{print \$1}")
    if [ "$agentdispatcherpid" != "" ]
    then
        echo "Killing leftover agentdispatcher.jar $agentdispatcherpid"
        kill -9 $agentdispatcherpid
    fi
    AgentMonitorpid=$(ps ax | grep AgentMonitor.pl | grep -v grep |  awk "{print \$1}")
    if [ "$AgentMonitorpid" != "" ]
    then
        echo "Killing leftover AgentMonitor.pl $AgentMonitorpid"
        kill -9 $AgentMonitorpid
    fi
else
    chkconfig --add swamp
    echo Starting SWAMP services
fi
# During an install/upgrade the system is intended to be idle, clean out
# these state files before starting
/bin/rm -f /opt/swamp/run/.viewerinfo /opt/swamp/run/.agentstate
service swamp start

%endif
%files
%if %is_darwin
%defattr(-,root, root)
%else
%defattr(-,swa-daemon, swa-daemon)
%endif
#%doc README TODO COPYING ChangeLog

%dir /opt/swamp/bin
/opt/swamp/bin/AgentMonitor.pl
/opt/swamp/bin/LaunchPad.pl
/opt/swamp/bin/csa_agent.pl
/opt/swamp/bin/arun
/opt/swamp/bin/csa_HTCondorAgent.pl
/opt/swamp/bin/csa_agent_launcher
/opt/swamp/bin/assessmentlauncher
/opt/swamp/bin/vrunlauncher
/opt/swamp/bin/swamp_config
/opt/swamp/bin/swamp_monitor
/opt/swamp/bin/csa_HTCondorAgent_launcher

/opt/swamp/lib
/opt/swamp/jar

/opt/swamp/perl5

/etc/profile.d/swamp.sh
%dir /opt/swamp/run
%dir /opt/swamp/log
%dir /opt/swamp/etc
%config /opt/swamp/etc/swamp.conf
%config /opt/swamp/etc/submonitor.conf
%config /opt/swamp/etc/log4j.properties
%config /opt/swamp/etc/log4perl.conf
%attr(-, root,root) /etc/init.d/swamp

%preun 
%if %is_darwin
%else
# Only remove things if this is an uninstall
if [ "$1" = "0" ] 
then 
    echo Stopping SWAMP services
    service swamp stop
    chkconfig --del swamp
    agentdispatcherpid=$(ps ax | grep agentdispatcher.jar | grep -v grep |  awk "{print \$1}")
    if [ "$agentdispatcherpid" != "" ]
    then
        echo "Killing leftover agentdispatcher.jar $agentdispatcherpid"
        kill -9 $agentdispatcherpid
    fi
    AgentMonitorpid=$(ps ax | grep AgentMonitor.pl | grep -v grep |  awk "{print \$1}")
    if [ "$AgentMonitorpid" != "" ]
    then
        echo "Killing leftover AgentMonitor.pl $AgentMonitorpid"
        kill -9 $AgentMonitorpid
    fi
fi
%endif

