# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

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
%include common-install-submit.txt
%include swamp-install-submit.txt

%clean
rm -rf $RPM_BUILD_ROOT

%pre
%include common-pre.txt

%post
%include common-post.txt
%include swamp-post-common.txt

# Floodlight
iam=`hostname -s`
floodlight=""
if [ "$iam" = "swa-csasub-dd-01" ];then
    floodlight=http://swa-flood-dt-01.mirsam.org:8080
elif [ "$iam" = "swa-csasub-dt-01" -o "$iam" = "swa-build-1" ];then
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

# htcondor bridge selection
bridge="br-ext.2786"
if [ "$iam" = "swa-csasub-pd-01" ]; then
	bridge="br-ext.2789"
fi
/bin/sed -i "s|SED_BRIDGE_INTERFACE|$bridge|" /opt/swamp/etc/vmu_htcondor_submit

# Arguments to post are {1=>new, 2=>upgrade}
if [ "$1" = "2" ]
then
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

# set file permissions on swamp.conf
chmod 400 /opt/swamp/etc/swamp.conf

# During an install/upgrade the system is intended to be idle, clean out
# these state files before starting
/bin/rm -f /opt/swamp/run/.viewerinfo /opt/swamp/run/.agentstate
service swamp start

%files
%defattr(-,swa-daemon, swa-daemon)
%include common-files-submit.txt
%include swamp-files-submit.txt

%preun
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
