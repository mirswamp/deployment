# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

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

echo "Finished running pre script"

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

# API, Floodlight, and License Servers
iam=`hostname -s`
swamp_api_web_server=""
floodlight=""

parasoft_flowprefix=""
parasoft_server_ip=""
parasoft_dtp_server_ip=""

redlizard_flowprefix=""
redlizard_server_ip=""

grammatech_flowprefix=""
grammatech_server_ip=""

synopsys_flowprefix=""
synopsys_server_ip=""

owaspdc_flowprefix=""
owaspdc_server_ip=""

nameserver=""

if [ $(expr "$iam" : "swa-exec-dd" ) = $(expr length "swa-exec-dd") ];then
    swamp_api_web_server="https://swa-csaweb-dd-01.cosalab.org"
    floodlight=http://swa-flood-dd-01.mirsam.org:8080
	parasoft_flowprefix=ps-dd-license
	parasoft_server_ip=128.104.7.8
	parasoft_dtp_server_ip=128.104.7.8
	redlizard_flowprefix=rl-dd-license
	redlizard_server_ip=128.104.7.11
	grammatech_flowprefix=gt-dd-license
	grammatech_server_ip=128.104.7.9
	synopsys_flowprefix=sy-dd-license
	synopsys_server_ip=128.104.7.15
	owaspdc_flowprefix=od-dd-database
	owaspdc_server_ip=128.104.7.17
	nameserver=128.104.7.5
    /bin/sed -i "s/<ENVIRONMENT>/dt/g" /opt/swamp/etc/services.conf
    /bin/sed -i "s/<DOMAIN>/cosalab/g" /opt/swamp/etc/services.conf
elif [ $(expr "$iam" : "swa-exec-dt" ) = $(expr length "swa-exec-dt") ];then
    swamp_api_web_server="https://swa-csaweb-dt-02.cosalab.org"
    floodlight=http://swa-flood-dt-01.mirsam.org:8080
	parasoft_flowprefix=ps-dt-license
	parasoft_server_ip=128.104.7.8
	parasoft_dtp_server_ip=128.104.7.8
	redlizard_flowprefix=rl-dt-license
	redlizard_server_ip=128.104.7.11
	grammatech_flowprefix=gt-dt-license
	grammatech_server_ip=128.104.7.9
	synopsys_flowprefix=sy-dt-license
	synopsys_server_ip=128.104.7.15
	owaspdc_flowprefix=od-dt-database
	owaspdc_server_ip=128.104.7.17
	nameserver=128.104.7.5
    /bin/sed -i "s/<ENVIRONMENT>/dt/g" /opt/swamp/etc/services.conf
    /bin/sed -i "s/<DOMAIN>/cosalab/g" /opt/swamp/etc/services.conf
elif [ $(expr "$iam" : "swa-exec-it" ) = $(expr length "swa-exec-it") ];then
    swamp_api_web_server="https://swa-csaweb-it-01.cosalab.org"
    floodlight=http://swa-flood-it-01.mirsam.org:8080
	parasoft_flowprefix=ps-it-license
	parasoft_server_ip=128.104.7.7
	parasoft_dtp_server_ip=128.104.7.7
	redlizard_flowprefix=rl-it-license
	redlizard_server_ip=128.104.7.13
	grammatech_flowprefix=gt-it-license
	grammatech_server_ip=128.104.7.10
	synopsys_flowprefix=sy-it-license
	synopsys_server_ip=128.104.7.16
	owaspdc_flowprefix=od-it-database
	owaspdc_server_ip=128.104.7.17
	nameserver=128.104.7.5
    /bin/sed -i "s/<ENVIRONMENT>/it/g" /opt/swamp/etc/services.conf
    /bin/sed -i "s/<DOMAIN>/cosalab/g" /opt/swamp/etc/services.conf
elif [ $(expr "$iam" : "swa-exec-pd" ) = $(expr length "swa-exec-pd") ];then
    swamp_api_web_server="https://swa-csaweb-pd-01.mir-swamp.org"
    floodlight=http://swa-flood-pd-01.mirsam.org:8080
	parasoft_flowprefix=ps-pd-license
	parasoft_server_ip=128.105.64.7
	parasoft_dtp_server_ip=128.105.64.7
	redlizard_flowprefix=rl-pd-license
	redlizard_server_ip=128.105.64.9
	grammatech_flowprefix=gt-pd-license
	grammatech_server_ip=128.105.64.8
	synopsys_flowprefix=sy-pd-license
	synopsys_server_ip=128.105.64.10
	owaspdc_flowprefix=od-pd-database
	owaspdc_server_ip=128.105.64.11
	nameserver=128.105.64.5
    /bin/sed -i "s/<ENVIRONMENT>/pd/g" /opt/swamp/etc/services.conf
    /bin/sed -i "s/<DOMAIN>/mir-swamp/g" /opt/swamp/etc/services.conf
fi

# API Web Server
if [ "$swamp_api_web_server" != "" ]; then
    /opt/swamp/bin/swamp_config -C /opt/swamp/etc/swamp.conf --propset "swamp_api_web_server" "$swamp_api_web_server"
else
    echo Please update the swamp_api_web_server item in /opt/swamp/etc/swamp.conf with the appropriate hostname
fi

# Floodlight
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
