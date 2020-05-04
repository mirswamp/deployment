#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Configuring the File System for the SWAMP"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/runtime/bin/swamp_utility.functions

swamp_context=$1

############################################################################

make_dir() {
    local mode=$1
    local owner=$2
    local target=$3

    echo "Creating $target"
    if [ ! -d "$target" ]; then
        mkdir -p "$target"
    fi
    chmod "$mode"  "$target"
    chown "$owner" "$target"
}

create_user swa-daemon
create_group swa-results mysql swa-daemon

make_dir  u=rwx,g=rx,o=rx    root:root          /swamp
make_dir  u=rwx,g=rx,o=rx    apache:apache      /swamp/incoming
make_dir  u=rwx,g=rx,o=rx    root:root          /swamp/working
make_dir  u=rwx,g=rx,o=rx    root:root          /swamp/working/project
make_dir  u=rwx,g=rx,o=rx    root:root          /swamp/platforms
make_dir  u=rwx,g=rx,o=rx    root:root          /swamp/store

make_dir  u=rwx,g=rwxs,o=rx  mysql:apache       /swamp/outgoing
make_dir  u=rwx,g=rwxs,o=rx  mysql:swa-results  /swamp/working/results
make_dir  u=rwx,g=rwxs,o=rx  mysql:swa-results  /swamp/SCAProjects
make_dir  u=rwx,g=rwxs,o=rx  mysql:swa-results  /swamp/store/SCAPackages

#
# Add 'g+ws' bits to files and directories created in earlier releases.
#
for dir in \
        /swamp/working/results \
        /swamp/SCAProjects \
        /swamp/store/SCAPackages \
        ; do
    echo "Updating permissions in $dir"
    chmod -R g+w "$dir"
    chgrp -R swa-results "$dir"
    find "$dir" -type d -exec chmod g+s '{}' ';'
done

#
# Remove unnecessary symlinks created in earlier releases.
#
if [ -h /var/lib/libvirt/images ]; then
    rm -f /var/lib/libvirt/images
fi

############################################################################

if [ ! -h /var/www/html/results ]; then
    ln -s /swamp/outgoing /var/www/html/results
fi
if [ ! -h /var/www/html/wwwresults ]; then
    ln -s /var/www/html/results /var/www/html/wwwresults
fi
if [ ! -h /var/www/html/swamp-web-server/public/downloads ]; then
    ln -s /swamp/outgoing /var/www/html/swamp-web-server/public/downloads
fi
if [ ! -h /var/www/html/swamp-web-server/public/uploads ]; then
    ln -s /swamp/incoming /var/www/html/swamp-web-server/public/uploads
fi
if [ ! -h /var/www/html/swamp-web-server/public/results ]; then
    ln -s /var/www/html/results /var/www/html/swamp-web-server/public/results
fi

############################################################################

#
# By default, platform images and tool archives are stored "locally".
#
if [ "$swamp_context" != "-singleserver" ]; then
    make_dir  u=rwx,g=rx,o=rx  root:root    /swamp/platforms/images
    make_dir  u=rwx,g=rx,o=rx  mysql:mysql  /swamp/store/SCATools
    make_dir  u=rwx,g=rx,o=rx  mysql:mysql  /swamp/store/SCATools/add_on
    make_dir  u=rwx,g=rx,o=rx  mysql:mysql  /swamp/store/SCATools/bundled
fi

#
# If this is a "singleserver" install, link to the directories on Gluster.
#
if [ "$swamp_context" = "-singleserver" ]; then
    if [ ! -h /swamp/platforms/images ]; then
        if [ -e /swamp/platforms/images ]; then
            echo "Error: Already exists: /swamp/platforms/images" 1>&2
            encountered_error=1
        else
            ln -s /everglades/platforms/images /swamp/platforms/images
        fi
    fi
    if [ ! -h /swamp/store/SCATools ]; then
        if [ -e /swamp/store/SCATools ]; then
            echo "Error: Already exists: /swamp/store/SCATools" 1>&2
            encountered_error=1
        else
            ln -s /everglades/store/SCATools /swamp/store/SCATools
        fi
    fi
fi

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished configuring the file system for the SWAMP"
else
    echo
    echo "Finished configuring the file system for the SWAMP, but with errors" 1>&2
fi
exit $encountered_error
