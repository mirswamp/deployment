#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

function usage() {
    echo "usage $0 (start | stop | restart | status | status-short | list | help) [service1 service2 ...]"
    exit
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

#
# Define default lists of services. The ordering is important.
#

stopServices=(cgconfig libvirtd mysql condor httpd swamp)
startServices=(iptables ${stopServices[@]})
restartServices=${startServices[@]}

#
# Ensure that the systemd manager configuration is up-to-date.
#

echo -n "Testing for systemctl ... "
which systemctl

if [ $? -eq 0 ]; then
    echo "Calling systemctl daemon-reload"
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
        status|status-short)
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
            service $service start
        done
        ;;
    stop)
        for service in ${services[@]}
        do
            service $service stop
        done
        ;;
    restart)
        for service in ${services[@]}
        do
            service $service restart
        done
        ;;
    status)
        for service in ${services[@]}
        do
            echo -n "Service: $service "
            service $service status
        done
        ;;
    status-short)
        for service in ${services[@]}
        do
            if [[ $(systemctl 2>&1) =~ "command not found" ]]; then
                # No well-defined meaning for "short".
                service $service status
            else
                IFS="=" read ignored raw_status <<< `systemctl show --property=ActiveState ${service}`
                if [[ $raw_status =~ "inactive" ]]; then
                    echo "stopped"
                elif [[ $raw_status =~ "active" ]]; then
                    echo "running"
                else
                    echo $raw_status
                fi
            fi
        done
        ;;
    list)
        echo "startServices: ${startServices[@]}"
        echo "stopServices: ${stopServices[@]}"
        echo "restartServices: ${restartServices[@]}"
        ;;
    help)
        usage
        ;;
    *)
        echo "unknown command: $arg"
        usage
        ;;
esac
