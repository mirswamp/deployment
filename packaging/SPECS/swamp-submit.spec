# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

%define _target_os Linux
%define _arch      noarch

Summary:   Submit server applications for Software Assurance Marketplace (SWAMP)
Name:      swamp-submit
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
This RPM contains SWAMP's submit server applications.

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
%config %attr(0600,swa-daemon,swa-daemon) /opt/swamp/etc/swamp.conf
%attr (0755,swa-daemon,root) /opt/swamp/run

/etc/init.d/swamp
/etc/profile.d/swamp.sh
/opt/swamp

############################################################################

%pre
%include %{_specdir}/common-pre.txt

# CSA-2837: Prevent jobs from being submitted during an upgrade
if [ "$1" = "2" ]
then
    echo Stopping SWAMP services
    service swamp stop
    agentdispatcherpid=$(ps ax | grep agentdispatcher.jar | grep -v grep |  awk "{print \$1}")
    if [ "$agentdispatcherpid" != "" ]
    then
        echo "Killing leftover agentdispatcher.jar $agentdispatcherpid"
        kill -9 $agentdispatcherpid
    fi
    AgentMonitorpid=$(ps ax | grep vmu_AgentMonitor.pl | grep -v grep |  awk "{print \$1}")
    if [ "$AgentMonitorpid" != "" ]
    then
        echo "Killing leftover vmu_AgentMonitor.pl $AgentMonitorpid"
        kill -9 $AgentMonitorpid
    fi
    LaunchPadpid=$(ps ax | grep vmu_LaunchPad.pl | grep -v grep |  awk "{print \$1}")
    if [ "$LaunchPadpid" != "" ]
    then
        echo "Killing leftover vmu_LaunchPad.pl $LaunchPadpid"
        kill -9 $LaunchPadpid
    fi
fi

%include %{_specdir}/common-pre-finished.txt

%post
%include %{_specdir}/common-post.txt
%include %{_specdir}/swamp-post-common.txt

# Floodlight
iam=`hostname -s`
floodlight=""
if [ "$iam" = "swa-csasub-dd-01" ];then
    floodlight=http://swa-flood-dd-01.mirsam.org:8080
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
echo "Updating vmu_htcondor_submit with $bridge"
/bin/sed -i "s|SED_BRIDGE_INTERFACE|$bridge|" /opt/swamp/etc/vmu_htcondor_submit

# Arguments to post are {1=>new, 2=>upgrade}
if [ "$1" = "1" ]
then
    chkconfig --add swamp
fi

# During an install/upgrade the system is intended to be idle, clean out
# these state files before starting
/bin/rm -f /opt/swamp/run/.viewerinfo /opt/swamp/run/.agentstate
echo Starting SWAMP services
service swamp start

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
