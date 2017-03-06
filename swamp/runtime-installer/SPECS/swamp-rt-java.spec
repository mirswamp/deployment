# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

%define _target_os  Linux
%define _arch       noarch

%define __os_install_post %{nil}
%define debug_package     %{nil}

Summary:   Java runtime libraries for Software Assurance Marketplace (SWAMP)
Name:      swamp-rt-java
Version:   %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release:   %(perl -e 'print $ENV{BUILD_NUMBER}')
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Obsoletes: swamp-rt
Source:    jre.tar
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains the Java runtime used by SWAMP.

SWAMP is a state-of-the-art facility designed to advance our nation's
cybersecurity by improving the security and reliability of open source
software.

%prep
%setup -c -T
cp ../../SOURCES/jre.tar .

%build
pwd
ls

%install
pwd
ls
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt
tar -C $RPM_BUILD_ROOT/opt -xvf jre.tar
chmod -R g-s $RPM_BUILD_ROOT/opt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon,swa-daemon)
/opt/jdk1.8.0_112
