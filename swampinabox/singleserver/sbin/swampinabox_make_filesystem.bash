#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Create the directories needed by the SWAMP's backend.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

############################################################################

function make_dir() {
    mode="$1"
    owner="$2"
    target="$3"

    mkdir  -p        "$target"
    chmod  "$mode"   "$target"
    chown  "$owner"  "$target"
}

make_dir  0755  root:root      /swamp
make_dir  0775  apache:apache  /swamp/incoming
make_dir  2775  mysql:apache   /swamp/outgoing
make_dir  0755  root:root      /swamp/working
make_dir  0755  root:root      /swamp/working/project
make_dir  0755  mysql:mysql    /swamp/working/results
make_dir  0755  root:root      /swamp/platforms
make_dir  0755  root:root      /swamp/store
make_dir  0755  mysql:mysql    /swamp/store/SCAPackages
make_dir  0755  mysql:mysql    /swamp/SCAProjects

rm -rf /swamp/platforms/images
if [ ! -h /swamp/platforms/images ]; then
	ln -s /everglades/platforms/images /swamp/platforms/images
fi

rm -rf /swamp/store/SCATools
if [ ! -h /swamp/store/SCATools ]; then
	ln -s /everglades/store/SCATools /swamp/store/SCATools
fi

# CSA-2955: Clear sticky bits that were unnecessarily set in SWAMP-in-a-Box
# releases prior to 1.30. (The numeric modes above won't clear them.)
chmod ugo-s /swamp/incoming
chmod uo-s /swamp/outgoing

rm -rf /var/lib/libvirt/images
if [ ! -h /var/lib/libvirt/images ]; then
	ln -s /everglades/platforms/images /var/lib/libvirt/images
fi

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

exit $encountered_error
