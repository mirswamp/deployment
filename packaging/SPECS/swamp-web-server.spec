# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

%define _target_os Linux
%define _arch      noarch

#
# Leave our files alone.
#
%define __jar_repack 0
%define __os_install_post %{nil}

Summary:   Web application for Software Assurance Marketplace (SWAMP)
Name:      swamp-web-server
Version:   %(echo $RELEASE_NUMBER)
Release:   %(echo $BUILD_NUMBER)
License:   Apache 2.0
Group:     Development/Tools

Vendor:    The Morgridge Institute for Research
Packager:  Support <support@continuousassurance.org>
URL:       http://www.continuousassurance.org

Requires:  httpd,mod_ssl,php
Source:    %{name}-%{version}.tar
BuildArch: noarch
AutoReq:   no
AutoProv:  no

%description
This RPM contains SWAMP's web application front end and back end.

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

%config %attr(0644,root,root) /var/www/html/config/config.json
%config %attr(0600,apache,apache) /var/www/swamp-web-server/.env

%attr(0755,apache,apache) /var/www/swamp-web-server/bootstrap/cache
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/app
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/framework
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/framework/cache
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/framework/sessions
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/framework/views
%attr(0755,apache,apache) /var/www/swamp-web-server/storage/logs

/var/www/html/*
/var/www/html/.[A-Za-z]*
/var/www/swamp-web-server

############################################################################

#
# Arguments to pre are {1=>new, 2=>upgrade}
#
%pre
if [ "$1" = "1" ]; then
    echo "Running RPM pre script for %{name} (mode: install)"
elif [ "$1" = "2" ]; then
    echo "Running RPM pre script for %{name} (mode: upgrade)"
fi
if [ "$1" = "2" ]; then
    #
    # Preserve config.js to assist in manual conversion to configjson
    #
    if [ -f /var/www/html/scripts/config/config.js ]; then
        # Config file from 1.28 or later
        mv /var/www/html/scripts/config/config.js /var/www/html/scripts/config/config.js.swampsave
    elif [ -f /var/www/html/scripts/config.js ]; then
        # Config file from 1.27 or earlier
        mv /var/www/html/scripts/config.js /var/www/html/scripts/config.js.swampsave
    fi

    #
    # Preserve config.json
    #
    if [ -f /var/www/html/config/config.json ]; then
        cp /var/www/html/config/config.json /tmp/.
    fi
fi
echo "Finished running pre script"
echo "Installing the files for %{name} (this will take some time)"

#
# Arguments to post are {1=>new, 2=>upgrade}
#
%post
if [ "$1" = "1" ]; then
    echo "Running RPM post script for %{name} (mode: install)"
elif [ "$1" = "2" ]; then
    echo "Running RPM post script for %{name} (mode: upgrade)"
fi

if [ "$1" = "2" ]; then
    #
    # Restore config.json
    #
    if [ -f /tmp/config.json ]; then
        mv /tmp/config.json /var/www/html/config/config.json
    fi

    #
    # Preserve .env settings
    #
    if [ -r /var/www/swamp-web-server/.env.rpmsave ]; then
        src="/var/www/swamp-web-server/.env.rpmsave"
        dest="/var/www/swamp-web-server/.env"

        conf_keys="$(awk -F= '{print $1}' "$dest" | awk '{print $1}' | grep -E '^[^#]')"

        echo "Updating '$dest' from '$src'"

        while read -r key; do
            if grep "^[[:space:]]*$key[[:space:]]*=" "$src" 1>/dev/null 2>/dev/null ; then
                echo ".. Updating: $key"

                val=$(grep "^[[:space:]]*$key[[:space:]]*=" "$src" | sed "s/^[[:space:]]*$key[[:space:]]*=\(.*\)$/\1/")

                # Escape special characters for sed's 's//'
                val=${val//\\/\\\\}  # escape back slash
                val=${val//\//\\\/}  # escape forward slash
                val=${val//&/\\&}    # escape ampersands

                sed -i "s/^\s*$key\s*=.*$/$key=$val/" "$dest"
            fi
        done <<< "$conf_keys"

        echo "Finished updating '$dest'"

        #
        # CSA-3107: Rename the source file so that future upgrades don't
        # accidentally copy values from it again.
        #
        now="$(date +"%%Y%%m%%d%%H%%M%%S")"
        renamed_src="$src.$now"

        echo "Renaming '$src' to '$renamed_src'"
        mv "$src" "$renamed_src"
    fi
fi

echo "Finished running post script"
