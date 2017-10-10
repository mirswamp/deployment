# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

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
%include common-install-exec.txt
%include swamp-install-exec.txt

%clean
rm -rf $RPM_BUILD_ROOT

%pre
%include common-pre.txt

%post
%include common-post.txt
%include swamp-post-common.txt

# Set the vmnetdomain based on our install environment
vmnetdomain=vm.cosalab.org
# The expected pattern for Production exec nodes
patt=swa-exec-pd
# N.B. There's an implicit ^ in expr REGEX, so patt is /^$patt/
if [ $(expr `hostname -s` : $patt ) = $(expr length "$patt") ];then
    vmnetdomain=vm.mir-swamp.org
fi
if [ "$vmnetdomain" != "" ];then
    /bin/sed -i "s|^vmnetdomain\s*=.*$|vmnetdomain=$vmnetdomain|" /opt/swamp/etc/swamp.conf
else
    echo Please update the vmnetdomain item in /opt/swamp/etc/swamp.conf with the appropriate VM domain.
fi

# Floodlight and License Servers
iam=`hostname -s`
floodlight=""

parasoft_flowprefix=""
parasoft_server_ip=""
tool_ps_ctest_license_host=""
tool_ps_jtest_license_host=""

redlizard_flowprefix=""
redlizard_server_ip=""
tool_rl_goanna_license_host=""

grammatech_flowprefix=""
grammatech_server_ip=""
tool_gt_csonar_license_host=""

synopsys_flowprefix=""
synopsys_server_ip=""
tool_sy_coverity_license_host=""

nameserver=""

if [ $(expr "$iam" : "swa-exec-dd" ) = $(expr length "swa-exec-dd") ];then
    floodlight=http://swa-flood-dd-01.mirsam.org:8080
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
	synopsys_flowprefix=sy-dt-license
	synopsys_server_ip=128.104.7.15
	tool_sy_coverity_license_host=lic-sy-dt-01.cosalab.org
	nameserver=128.104.7.5
elif [ $(expr "$iam" : "swa-exec-dt" ) = $(expr length "swa-exec-dt") ];then
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
	synopsys_flowprefix=sy-dt-license
	synopsys_server_ip=128.104.7.15
	tool_sy_coverity_license_host=lic-sy-dt-01.cosalab.org
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
	synopsys_flowprefix=sy-it-license
	synopsys_server_ip=128.104.7.16
	tool_sy_coverity_license_host=lic-sy-it-01.cosalab.org
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
	synopsys_flowprefix=sy-pd-license
	synopsys_server_ip=128.105.64.10
	tool_sy_coverity_license_host=lic-sy-pd-01.mir-swamp.org
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
    echo Please update the tool.gt-csonar.license.host item in /opt/swamp/etc/swamp.conf with the appropriate grammatech license server hostname
fi

# Synopsys License Server
if [ "$synopsys_flowprefix" != "" ];then
    /bin/sed -i "s|^synopsys_flowprefix\ =\ .*$|synopsys_flowprefix=$synopsys_flowprefix|" /opt/swamp/etc/swamp.conf
else
    echo Please update the synopsys_flowprefix item in /opt/swamp/etc/swamp.conf with the appropriate prefix value: sy-*-license
fi
if [ "$synopsys_server_ip" != "" ];then
    /bin/sed -i "s|^synopsys_server_ip\ =\ .*$|synopsys_server_ip=$synopsys_server_ip|" /opt/swamp/etc/swamp.conf
else
    echo Please update the synopsys_server_ip item in /opt/swamp/etc/swamp.conf with the appropriate synopsys license server ip address
fi
if [ "$tool_sy_coverity_license_host" != "" ];then
    /bin/sed -i "s|^tool.sy-coverity.license.host\ =\ .*$|tool.sy-coverity.license.host=$tool_sy_coverity_license_host|" /opt/swamp/etc/swamp.conf
else
    echo Please update the tool.gt-csonar.license.host item in /opt/swamp/etc/swamp.conf with the appropriate synopsys license server hostname
fi

if [ "$nameserver" != "" ];then
    /bin/sed -i "s|^nameserver\ =\ .*$|nameserver = $nameserver|" /opt/swamp/etc/swamp.conf
else
    echo Please update the nameserver item in /opt/swamp/etc/swamp.conf with the appropriate vm nameserver ip address
fi

# set file permissions on swamp.conf
chmod 400 /opt/swamp/etc/swamp.conf

%files
%defattr(-,swa-daemon, swa-daemon)
%include common-files-exec.txt
%include swamp-files-exec.txt

%preun
# Only remove things if this is an uninstall
# if [ "$1" = "0" ]
# then
# fi
