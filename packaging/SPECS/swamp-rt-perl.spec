# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

%define _target_os Linux
%define _arch      noarch

#
# Leave our files alone.
#
%define debug_package %{nil}
%define __os_install_post %{nil}

Summary:   Perl runtime for Software Assurance Marketplace (SWAMP)
Name:      swamp-rt-perl
Version:   %(echo $RELEASE_NUMBER)
Release:   %(echo $BUILD_NUMBER)
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Obsoletes: swamp-rt,swamp-rt-exec,swamp-rt-java
Source:    %{name}-%{version}.tar.gz
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains SWAMP's Perl runtime.

SWAMP is a state-of-the-art facility designed to advance our nation's
cybersecurity by improving the security and reliability of open source
software.

############################################################################

%prep
%setup -c -q -T
cp %{_topdir}/SOURCES/%{name}-%{version}.tar.gz .

%build
pwd

%install
mkdir -p %{buildroot}/opt
tar -xz -C %{buildroot}/opt -f %{name}-%{version}.tar.gz
chmod -R a-st %{buildroot}

############################################################################

%files
%defattr(-,root,root)

/opt/perl5

############################################################################

%pre
%include %{_specdir}/common-pre.txt
%include %{_specdir}/common-pre-finished.txt
