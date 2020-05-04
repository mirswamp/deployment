#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Start, stop, and otherwise manage the system services for SWAMP-in-a-Box.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"

#
# "Import" the 'yum_confirm' function.
#
. "$BINDIR/swampinabox_install_util.functions"

############################################################################

function ignore_error() {
    return 0
}

function show_usage_and_exit() {
    echo "Usage: $0 (start | stop | restart | status | list | help) [service1 service2 ...]" 1>&2
    exit 1
}

if [ $# -eq 0 ]; then
    show_usage_and_exit
fi

#
# Define default lists of services. The ordering is important. Assume that
# the SWAMP-in-a-Box "set up" scripts have been run, so that the only
# possibly-missing service is 'swamp', because it hasn't been installed yet.
#

if yum_confirm swampinabox-backend 1>/dev/null 2>/dev/null ; then
    stopServices=(libvirtd mysql condor httpd swamp)
else
    stopServices=(libvirtd mysql condor httpd)
fi

startServices=(${stopServices[@]})
restartServices=${startServices[@]}

#
# Determine the "service" command to use.
#

if [ -x "$BINDIR/swamp_manage_service" ]; then
    service_cmd="$BINDIR/swamp_manage_service"
else
    service_cmd="service"
fi

#
# Ensure that the systemd manager configuration is up-to-date.
#

if which systemctl 1>/dev/null 2>/dev/null ; then
    systemctl daemon-reload
fi

#
# Determine the command (start, stop, ...) and list of services.
#

args=("$@")
command=${args[0]}

if [ $# -gt 1 ]; then
    services=${args[@]:1}
else
    case $command in
        start)
            services=${stopServices[@]}
            ;;
        stop)
            services=${stopServices[@]}
            ;;
        restart)
            services=${stopServices[@]}
            ;;
        status)
            services=${startServices[@]}
            ;;
    esac
fi

#
# Process the services.
#

case $command in
    start)
        for service in ${services[@]}
        do
            echo "Starting the $service service"
            $service_cmd $service start || ignore_error
        done
        ;;
    stop)
        for service in ${services[@]}
        do
            echo "Stopping the $service service"
            $service_cmd $service stop || ignore_error
        done
        ;;
    restart)
        for service in ${services[@]}
        do
            echo "Restarting the $service service"
            $service_cmd $service restart || ignore_error
        done
        ;;
    status)
        for service in ${services[@]}
        do
            echo -n "Status of the $service service: "
            $service_cmd $service status || ignore_error
        done
        ;;
    list)
        echo "startServices: ${startServices[@]}"
        echo "stopServices: ${stopServices[@]}"
        echo "restartServices: ${restartServices[@]}"
        ;;
    help)
        show_usage_and_exit
        ;;
    *)
        echo "Unknown command: $command" 1>&2
        show_usage_and_exit
        ;;
esac

exit $encountered_error
