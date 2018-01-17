# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

%define _target_os  Linux
%define _arch       noarch

%define __os_install_post %{nil}
%define debug_package     %{nil}

Summary:   Perl runtime libraries for Software Assurance Marketplace (SWAMP)
Name:      swamp-rt-perl
Version:   %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release:   %(perl -e 'print $ENV{BUILD_NUMBER}')
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Obsoletes: swamp-rt,swamp-rt-exec,swamp-rt-java
Source:    perlbin.tgz
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains the Perl runtime and modules used by SWAMP.

SWAMP is a state-of-the-art facility designed to advance our nation's
cybersecurity by improving the security and reliability of open source
software.

%prep
%setup -c -T
cp ../../SOURCES/perlbin.tgz .

%build
pwd
ls

%install
pwd
ls
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt
tar -C $RPM_BUILD_ROOT/opt -xzf perlbin.tgz
chmod -R g-s $RPM_BUILD_ROOT/opt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon,swa-daemon)
/opt/perl5
