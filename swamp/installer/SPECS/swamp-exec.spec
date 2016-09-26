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


Summary: Hypervisor applications for Software Assurance Marketplace (SWAMP) 
Name: swamp-exec
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
Requires: swamp-rt-perl, libguestfs-tools
Conflicts: swamp-ds,swamp-submit,swamp-directory-server
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Hypervisor (execute node) packages

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
%install
echo rm -rf $RPM_BUILD_ROOT
%if %is_darwin
cd %{name}-%{version}
%endif
mkdir -p $RPM_BUILD_ROOT/opt/swamp/bin
mkdir -p $RPM_BUILD_ROOT/opt/swamp/etc
mkdir -p $RPM_BUILD_ROOT/opt/swamp/lib
mkdir -p $RPM_BUILD_ROOT/opt/swamp/run
mkdir -p $RPM_BUILD_ROOT/opt/swamp/log
mkdir -p $RPM_BUILD_ROOT/opt/swamp/thirdparty
mkdir -p $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/vendor
mkdir -p $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
mkdir -p $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/vendor
mkdir -p $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
chmod 01777 $RPM_BUILD_ROOT/opt/swamp/log
#mkdir -p $RPM_BUILD_ROOT/usr/local/share/man/man1
mkdir -p $RPM_BUILD_ROOT/usr/local/etc/swamp
mkdir -p $RPM_BUILD_ROOT/opt/swamp/perl5/SWAMP/Client
mkdir -p $RPM_BUILD_ROOT/etc/profile.d
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mkdir -p $RPM_BUILD_ROOT/etc/bash_completion.d
mkdir -p $RPM_BUILD_ROOT/usr/local/empty
mkdir -p $RPM_BUILD_ROOT/usr/project

install -m 444 templ.xml $RPM_BUILD_ROOT/usr/local/etc/swamp
install -m 755 VMConstants.pm $RPM_BUILD_ROOT/opt/swamp/perl5
install -m 755 VMTools.pm $RPM_BUILD_ROOT/opt/swamp/perl5
install -m 755 vm_cleanup $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 vm_output $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 masterify_vm $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 start_vm $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 cloc-1.60.pl $RPM_BUILD_ROOT/opt/swamp/bin

install -m 755 lib/SWAMP/AgentMonitorCommon.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/AgentMonitorCommon.pm 
install -m 755 lib/SWAMP/AssessmentTools.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/AssessmentTools.pm 
install -m 755 lib/SWAMP/Client/AgentClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/AgentClient.pm 
install -m 755 lib/SWAMP/Client/ExecuteRecordCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ExecuteRecordCollectorClient.pm 
install -m 755 lib/SWAMP/Client/GatorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/GatorClient.pm 
install -m 755 lib/SWAMP/Client/LogCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/LogCollectorClient.pm 
install -m 755 lib/SWAMP/Client/ResultCollectorClient.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Client/ResultCollectorClient.pm 
install -m 755 lib/SWAMP/HTCondorDefines.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/HTCondorDefines.pm 
install -m 755 lib/SWAMP/Locking.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/Locking.pm 
install -m 755 lib/SWAMP/PackageTypes.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/PackageTypes.pm 
install -m 755 lib/SWAMP/RPCUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/RPCUtils.pm 
install -m 755 lib/SWAMP/SWAMPUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SWAMPUtils.pm 
install -m 755 lib/SWAMP/ToolLicense.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/ToolLicense.pm 
install -m 755 lib/SWAMP/SysVirtEvents.pm ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SysVirtEvents.pm
install -m 755 lib/SWAMP/VMPrimitives.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/VMPrimitives.pm 
install -m 755 lib/SWAMP/SysUtils.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/SysUtils.pm 
install -m 755 lib/SWAMP/VMToolsX.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/VMToolsX.pm 
install -m 755 lib/SWAMP/VRunTools.pm  ${RPM_BUILD_ROOT}/opt/swamp/perl5/SWAMP/VRunTools.pm 

install -m 755 assessmentlauncher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 vrunlauncher ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_config ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 swamp_monitor ${RPM_BUILD_ROOT}/opt/swamp/bin
install -m 755 DomainMonitor.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 assessmentTask.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 755 vrunTask.pl $RPM_BUILD_ROOT/opt/swamp/bin
install -m 644 swamp.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 log4perl.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 versions.txt $RPM_BUILD_ROOT/opt/swamp/etc
install -m 755 swamp_watchdog $RPM_BUILD_ROOT/opt/swamp/etc
install -m 644 execmonitor.conf $RPM_BUILD_ROOT/opt/swamp/etc
install -m 444 java-assess.tar.gz $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 python-assess.tar.gz $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 c-assess.tar.gz $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 ruby-assess.tar.gz $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 resultparser.tar $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 dependencies.tar $RPM_BUILD_ROOT/opt/swamp/thirdparty
install -m 444 dependencykeys.txt $RPM_BUILD_ROOT/opt/swamp/thirdparty

install -m 444 codedx/codedx.war $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/vendor
install -m 444 codedx/codedx.props $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 444 codedx/logback.xml $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 444 codedx/emptydb-mysql.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 444 codedx/emptydb-codedx.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 755 codedx/vrun.sh $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 755 codedx/vrunchecktimeout $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 755 codedx/checktimeout.pl $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 755 codedx/codedx_viewerdb.sh $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp
install -m 755 codedx/swamp-codedx-service $RPM_BUILD_ROOT/opt/swamp/thirdparty/codedx/swamp

install -m 444 threadfix/threadfix.war $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/vendor
install -m 444 threadfix/threadfix.jdbc.properties $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 444 threadfix/emptydb-mysql-threadfix.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 444 threadfix/emptydb-threadfix.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 755 threadfix/vrun.sh $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 755 threadfix/vrunchecktimeout $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 755 threadfix/checktimeout.pl $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 755 threadfix/threadfix_viewerdb.sh $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 755 threadfix/swamp-threadfix-service $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 444 threadfix/flushprivs.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp
install -m 444 threadfix/resetdb-threadfix.sql $RPM_BUILD_ROOT/opt/swamp/thirdparty/threadfix/swamp

install -m 755 swamp.sh $RPM_BUILD_ROOT/etc/profile.d
install -m 755 swampd-exec $RPM_BUILD_ROOT/etc/init.d/swamp


%clean
rm -rf $RPM_BUILD_ROOT

%post
%if %is_darwin
%else

# Set the vmdomain based on our install environment
vmdomain=vm.cosalab.org
# The expected pattern for Production exec nodes
patt=swa-exec-pd
# N.B. There's an implicit ^ in expr REGEX, so patt is /^$patt/
if [ $(expr `hostname -s` : $patt ) = $(expr length "$patt") ];then
    vmdomain=vm.mir-swamp.org
fi
if [ "$vmdomain" != "" ];then
    /bin/sed -i "s|^vmdomain=.*$|vmdomain=$vmdomain|" /opt/swamp/etc/swamp.conf
else
    echo Please update the vmdomain item in /opt/swamp/etc/swamp.conf with the appropriate VM domain.
fi

# Check to see which Open vSwitch bridge we are configured to use
bridge=
ovs-vsctl br-exists br-ext.2789
if [ "$?" = "0" ];then
    bridge=br-ext.2789
fi
ovs-vsctl br-exists br-ext.2786
if [ "$?" = "0" ];then
    bridge=br-ext.2786
fi
if [ -n "$bridge" ];then
    echo Setting Open vSwitch bridge to $bridge
    sed -e"s/bridge='br-ext\.278[0-9]/bridge='$bridge/" /usr/local/etc/swamp/templ.xml > /tmp/fixed && mv /tmp/fixed /usr/local/etc/swamp/templ.xml
fi

# Floodlight and License Servers
iam=`hostname -s`
floodlight=""
parasoft_flowprefix=""
parasoft_server_ip=""
tool_ps_ctest_license_host=""
tool_ps_jtest_license_host=""
grammatech_flowprefix=""
grammatech_server_ip=""
tool_gt_csonar_license_host=""
redlizard_flowprefix=""
redlizard_server_ip=""
tool_rl_goanna_license_host=""
nameserver=""

if [ $(expr "$iam" : "swa-exec-dt" ) = $(expr length "swa-exec-dt") ];then
    floodlight=http://swa-flood-dt-01.mirsam.org:8080
	parasoft_flowprefix=ps-dt-license
	parasoft_server_ip=128.104.7.8
	tool_ps_ctest_license_host=lic-ps-dt-01.cosalab.org
	tool_ps_jtest_license_host=lic-ps-dt-01.cosalab.org
	redlizard_flowprefix=rl-dt-license
	redlizard_server_ip=128.104.7.11
	tool_rl_goanna_license_host=lic-rl-dt-01.cosalab.org
	grammatech_flowprefix=gt-dt-license
	grammatech_server_ip=128.104.7.9
	tool_gt_csonar_license_host=lic-gt-dt-01.cosalab.org
	nameserver=128.104.7.5
elif [ $(expr "$iam" : "swa-exec-it" ) = $(expr length "swa-exec-it") ];then
    floodlight=http://swa-flood-it-01.mirsam.org:8080
	parasoft_flowprefix=ps-it-license
	parasoft_server_ip=128.104.7.7
	tool_ps_ctest_license_host=lic-ps-it-01.cosalab.org
	tool_ps_jtest_license_host=lic-ps-it-01.cosalab.org
	redlizard_flowprefix=rl-it-license
	redlizard_server_ip=128.104.7.13
	tool_rl_goanna_license_host=lic-rl-it-01.cosalab.org
	grammatech_flowprefix=gt-it-license
	grammatech_server_ip=128.104.7.10
	tool_gt_csonar_license_host=lic-gt-it-01.cosalab.org
	nameserver=128.104.7.5
elif [ $(expr "$iam" : "swa-exec-pd" ) = $(expr length "swa-exec-pd") ];then
    floodlight=http://swa-flood-pd-01.mirsam.org:8080
	parasoft_flowprefix=ps-pd-license
	parasoft_server_ip=128.105.64.7
	tool_ps_ctest_license_host=lic-ps-pd-01.mir-swamp.org
	tool_ps_jtest_license_host=lic-ps-pd-01.mir-swamp.org
	redlizard_flowprefix=rl-pd-license
	redlizard_server_ip=128.105.64.9
	tool_rl_goanna_license_host=lic-rl-pd-01.mir-swamp.org
	grammatech_flowprefix=gt-pd-license
	grammatech_server_ip=128.105.64.8
	tool_gt_csonar_license_host=lic-gt-pd-01.mir-swamp.org
	nameserver=128.105.64.5
fi
if [ "$floodlight" != "" ];then
    /bin/sed -i "s|^floodlight=.*$|floodlight=$floodlight|" /opt/swamp/etc/swamp.conf
else
    echo Please update the floodlight item in /opt/swamp/etc/swamp.conf with the URL of the appropriate floodlight controller
fi

# Parasoft License Server
if [ "$parasoft_flowprefix" != "" ];then
    /bin/sed -i "s|^parasoft_flowprefix\ =\ .*$|parasoft_flowprefix=$parasoft_flowprefix|" /opt/swamp/etc/swamp.conf
else
    echo Please update the parasoft_flowprefix item in /opt/swamp/etc/swamp.conf with the appropriate prefix value: ps-*-license
fi
if [ "$parasoft_server_ip" != "" ];then
    /bin/sed -i "s|^parasoft_server_ip\ =\ .*$|parasoft_server_ip=$parasoft_server_ip|" /opt/swamp/etc/swamp.conf
else
    echo Please update the parasoft_server_ip item in /opt/swamp/etc/swamp.conf with the appropriate parasoft license server ip address
fi
if [ "$tool_ps_ctest_license_host" != "" ];then
    /bin/sed -i "s|^tool.ps-ctest.license.host\ =\ .*$|tool.ps-ctest.license.host=$tool_ps_ctest_license_host|" /opt/swamp/etc/swamp.conf
else
    echo Please update the tool.ps-ctest.license.host item in /opt/swamp/etc/swamp.conf with the appropriate parasoft ctest license server hostname
fi
if [ "$tool_ps_jtest_license_host" != "" ];then
    /bin/sed -i "s|^tool.ps-jtest.license.host\ =\ .*$|tool.ps-jtest.license.host=$tool_ps_jtest_license_host|" /opt/swamp/etc/swamp.conf
else
    echo Please update the tool.ps-jtest.license.host item in /opt/swamp/etc/swamp.conf with the appropriate parasoft jtest license server hostname
fi

# RedLizard License Server
if [ "$redlizard_flowprefix" != "" ];then
    /bin/sed -i "s|^redlizard_flowprefix\ =\ .*$|redlizard_flowprefix=$redlizard_flowprefix|" /opt/swamp/etc/swamp.conf
else
    echo Please update the redlizard_flowprefix item in /opt/swamp/etc/swamp.conf with the appropriate prefix value: rl-*-license
fi
if [ "$redlizard_server_ip" != "" ];then
    /bin/sed -i "s|^redlizard_server_ip\ =\ .*$|redlizard_server_ip=$redlizard_server_ip|" /opt/swamp/etc/swamp.conf
else
    echo Please update the redlizard_server_ip item in /opt/swamp/etc/swamp.conf with the appropriate redlizard license server ip address
fi
if [ "$tool_rl_goanna_license_host" != "" ];then
    /bin/sed -i "s|^tool.rl-goanna.license.host\ =\ .*$|tool.rl-goanna.license.host=$tool_rl_goanna_license_host|" /opt/swamp/etc/swamp.conf
else
    echo Please update the tool.rl-goanna.license.host item in /opt/swamp/etc/swamp.conf with the appropriate redlizard goanna license server hostname
fi

# GrammaTech License Server
if [ "$grammatech_flowprefix" != "" ];then
    /bin/sed -i "s|^grammatech_flowprefix\ =\ .*$|grammatech_flowprefix=$grammatech_flowprefix|" /opt/swamp/etc/swamp.conf
else
    echo Please update the grammatech_flowprefix item in /opt/swamp/etc/swamp.conf with the appropriate prefix value: gt-*-license
fi
if [ "$grammatech_server_ip" != "" ];then
    /bin/sed -i "s|^grammatech_server_ip\ =\ .*$|grammatech_server_ip=$grammatech_server_ip|" /opt/swamp/etc/swamp.conf
else
    echo Please update the grammatech_server_ip item in /opt/swamp/etc/swamp.conf with the appropriate grammatech license server ip address
fi
if [ "$tool_gt_csonar_license_host" != "" ];then
    /bin/sed -i "s|^tool.gt-csonar.license.host\ =\ .*$|tool.gt-csonar.license.host=$tool_gt_csonar_license_host|" /opt/swamp/etc/swamp.conf
else
    echo Please update the tool.gt-csonar.license.host item in /opt/swamp/etc/swamp.conf with the appropriate grammatech codesonar license server hostname
fi

if [ "$nameserver" != "" ];then
    /bin/sed -i "s|^nameserver\ =\ .*$|nameserver = $nameserver|" /opt/swamp/etc/swamp.conf
else
    echo Please update the nameserver item in /opt/swamp/etc/swamp.conf with the appropriate vm nameserver ip address 
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
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget agentMonitorHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset agentMonitorHost $val
        val=$(/opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf.rpmsave --propget dispatcherHost)
        /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset dispatcherHost $val
        echo Configuration updated from swamp.conf.rpmsave
    fi
    echo Restarting SWAMP services
    service swamp restart
else
    chkconfig --add swamp
    echo Starting SWAMP services
    service swamp start
fi
%endif

%files
%defattr(-,swa-daemon, swa-daemon)
#%doc README TODO COPYING ChangeLog
%dir /usr/local/empty
%dir /usr/project

%dir /opt/swamp/bin
/opt/swamp/bin/start_vm
/opt/swamp/bin/vm_cleanup
/opt/swamp/bin/vm_output
/opt/swamp/bin/masterify_vm
/opt/swamp/bin/DomainMonitor.pl
/opt/swamp/bin/assessmentlauncher
/opt/swamp/bin/vrunlauncher
/opt/swamp/bin/swamp_config
/opt/swamp/bin/swamp_monitor
/opt/swamp/bin/assessmentTask.pl
/opt/swamp/bin/vrunTask.pl
/opt/swamp/bin/cloc-1.60.pl
%dir /opt/swamp/run
/opt/swamp/perl5

/etc/profile.d/swamp.sh
/etc/init.d/swamp
%dir /opt/swamp/log
%dir /opt/swamp/thirdparty

%dir /opt/swamp/thirdparty/codedx/vendor
%dir /opt/swamp/thirdparty/codedx/swamp

%dir /opt/swamp/thirdparty/threadfix/vendor
%dir /opt/swamp/thirdparty/threadfix/swamp

%dir /opt/swamp/etc
/opt/swamp/thirdparty/python-assess.tar.gz
/opt/swamp/thirdparty/java-assess.tar.gz
/opt/swamp/thirdparty/c-assess.tar.gz
/opt/swamp/thirdparty/ruby-assess.tar.gz
/opt/swamp/thirdparty/resultparser.tar
/opt/swamp/thirdparty/dependencykeys.txt
/opt/swamp/thirdparty/dependencies.tar

/opt/swamp/thirdparty/codedx/vendor/codedx.war
/opt/swamp/thirdparty/codedx/swamp/codedx.props
/opt/swamp/thirdparty/codedx/swamp/logback.xml
/opt/swamp/thirdparty/codedx/swamp/emptydb-mysql.sql 
/opt/swamp/thirdparty/codedx/swamp/emptydb-codedx.sql 
/opt/swamp/thirdparty/codedx/swamp/vrun.sh 
/opt/swamp/thirdparty/codedx/swamp/vrunchecktimeout 
/opt/swamp/thirdparty/codedx/swamp/checktimeout.pl 
/opt/swamp/thirdparty/codedx/swamp/codedx_viewerdb.sh
/opt/swamp/thirdparty/codedx/swamp/swamp-codedx-service 

/opt/swamp/thirdparty/threadfix/vendor/threadfix.war
/opt/swamp/thirdparty/threadfix/swamp/threadfix.jdbc.properties
/opt/swamp/thirdparty/threadfix/swamp/emptydb-mysql-threadfix.sql 
/opt/swamp/thirdparty/threadfix/swamp/emptydb-threadfix.sql 
/opt/swamp/thirdparty/threadfix/swamp/vrun.sh 
/opt/swamp/thirdparty/threadfix/swamp/vrunchecktimeout 
/opt/swamp/thirdparty/threadfix/swamp/checktimeout.pl 
/opt/swamp/thirdparty/threadfix/swamp/threadfix_viewerdb.sh
/opt/swamp/thirdparty/threadfix/swamp/swamp-threadfix-service 
/opt/swamp/thirdparty/threadfix/swamp/flushprivs.sql
/opt/swamp/thirdparty/threadfix/swamp/resetdb-threadfix.sql

%dir /usr/local/etc/swamp
%config /usr/local/etc/swamp/templ.xml
%config /opt/swamp/etc/swamp.conf
%config /opt/swamp/etc/log4perl.conf
/opt/swamp/etc/swamp_watchdog
/opt/swamp/etc/versions.txt
%config /opt/swamp/etc/execmonitor.conf

%preun 
%if %is_darwin
%else
# Only remove things if this is an uninstall
if [ "$1" = "0" ] 
then 
    echo Stopping SWAMP services
    service swamp stop
    chkconfig --del swamp
fi
%endif
