# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

%define _target_os  Linux
%define _arch       noarch

Summary:   Backend applications, modules, and database for Software Assurance Marketplace (SWAMP)
Name:      swampinabox-backend
Version:   %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release:   %(perl -e 'print $ENV{BUILD_NUMBER}')
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Requires:  libguestfs-tools,swamp-rt-perl
Obsoletes: swamponabox-backend
Source:    swampinabox-1.tar.gz
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains SWAMP's backend applications, modules, and database.

SWAMP is a state-of-the-art facility designed to advance our nation's
cybersecurity by improving the security and reliability of open source
software.

%prep
%setup -c

%build
pwd
ls

%install
%include swampinabox-install.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon,swa-daemon)
%include swampinabox-files.txt

#
# Arguments to pre are {1=>new, 2=>upgrade}
#
%pre
%include common-pre.txt

service_script="/opt/swamp/sbin/swamp_manage_service"
if [ "$1" = "2" ]; then
    echo "Stopping service: swamp"
    if [ -x "$service_script" ]; then
        "$service_script" swamp stop
    else
        service swamp stop
    fi
fi

echo "Finished running pre script"

#
# Arguments to post are {1=>new, 2=>upgrade}
#
%post
%include common-post.txt
%include swampinabox-post-general.txt
%include swampinabox-post-directory.txt
%include swampinabox-post-data.txt
%include swampinabox-post-submit.txt
%include swampinabox-post-exec.txt

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
