# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

%define _target_os Linux
%define _arch      noarch

Summary:   Hypervisor, submit server, and database applications Software Assurance Marketplace (SWAMP)
Name:      swampinabox-backend
Version:   %(echo $RELEASE_NUMBER)
Release:   %(echo $BUILD_NUMBER)
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Requires:  libguestfs-tools,swamp-rt-perl
Obsoletes: swamponabox-backend
Source:    %{name}-%{version}.tar
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains SWAMP's hypervisor, submit server, and database applications.

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
%config %attr(0600,swa-daemon,swa-daemon) /opt/swamp/etc/services.conf
%config %attr(0660,swa-daemon,mysql) /opt/swamp/etc/swamp.conf
%doc /opt/swamp/doc
%attr (0755,swa-daemon,root) /opt/swamp/run

/etc/init.d/swamp
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

service_script="/opt/swamp/sbin/swamp_manage_service"
if [ "$1" = "2" ]; then
    echo "Stopping service: swamp"
    if [ -x "$service_script" ]; then
        "$service_script" swamp stop
    else
        service swamp stop
    fi
fi

%include %{_specdir}/common-pre-finished.txt

#
# Arguments to post are {1=>new, 2=>upgrade}
#
%post
%include %{_specdir}/common-post.txt
%include %{_specdir}/swampinabox-post-general.txt
%include %{_specdir}/swampinabox-post-data.txt
%include %{_specdir}/swampinabox-post-submit.txt
%include %{_specdir}/swampinabox-post-exec.txt

if [ "$1" = "1" ]; then
    chkconfig --add swamp
fi
chkconfig swamp on

service_script="/opt/swamp/sbin/swamp_manage_service"
echo "Starting service: swamp"
if [ -x "$service_script" ]; then
    "$service_script" swamp start
else
    service swamp start
fi

echo "Finished running post script"

#
# Arguments to preun are {0=>uninstall, 1=>upgrade}
#
%preun
%include %{_specdir}/common-preun.txt

if [ "$1" = "0" ]; then
    codedx_emptydb_link="/opt/swamp/thirdparty/codedx/swamp/emptydb-codedx.sql"
    if [ -h "$codedx_emptydb_link" ]; then
        echo "Removing '$codedx_emptydb_link'"
        rm -f "$codedx_emptydb_link"
    fi
fi

echo "Finished running pre-uninstall script"
