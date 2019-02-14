#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo
echo "### Testing System Service"
echo

#
# Intended to verify that system services exit with the expected codes in
# response to various commands, and that the 'swamp_manage_service' script
# correctly interprets those codes.
#

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)

service_to_test=$1
encountered_error=0
swamp_manage_service=$BINDIR/../../runtime/sbin/swamp_manage_service

############################################################################

tell_service() {
    local svc=$1
    local action=$2

    if command -v systemctl 1>/dev/null 2>&1 ; then
        systemctl "$action" "$svc"
    else
        service "$svc" "$action"
    fi
}

test_service() {
    local svc=$1
    local action=$2
    local correct_code=$3
    local correct_status=$4

    printf '%s %-7s ... ' "$svc" "$action"

    case "$action:$svc" in
        status:*condor*) sleep 2 ;;    # give HTCondor time to start up
    esac

    tell_service "$svc" "$action" 1>/dev/null 2>&1
    local code=$?
    local status=$("$swamp_manage_service" "$svc" status 2>&1)

    printf '%s %s ' "$code" "$status"

    if [ "$code" = "$correct_code" ] && [ "$status" = "$correct_status" ]; then
        printf '%s(ok) ' "$(tput setaf 2)"
    fi
    if [ "$code" != "$correct_code" ]; then
        encountered_error=1
        printf '%s(expected %s) ' "$(tput setaf 1)" "$correct_code"
    fi
    if [ "$status" != "$correct_status" ]; then
        encountered_error=1
        printf '%s(expected %s) ' "$(tput setaf 1)" "$correct_status"
    fi
    printf '%s\n' "$(tput sgr0)"
}

run_test_sequence() {
    local svc=$1

    #
    # Ensure that the service is running at the start of the test sequence.
    #
    test_service "$svc" start   0 "running"
    test_service "$svc" status  0 "running"

    #
    # Run through the test sequence.
    #
    test_service "$svc" stop    0 "stopped"
    test_service "$svc" status  3 "stopped"
    test_service "$svc" stop    0 "stopped"
    test_service "$svc" status  3 "stopped"

    test_service "$svc" start   0 "running"
    test_service "$svc" status  0 "running"
    test_service "$svc" start   0 "running"
    test_service "$svc" status  0 "running"

    test_service "$svc" restart 0 "running"
    test_service "$svc" status  0 "running"
    test_service "$svc" stop    0 "stopped"
    test_service "$svc" status  3 "stopped"
    test_service "$svc" restart 0 "running"
    test_service "$svc" status  0 "running"

    #
    # Ensure that the service is running at the end of the test sequence.
    #
    test_service "$svc" start   0 "running"
    test_service "$svc" status  0 "running"
}

############################################################################

if [ -z "$service_to_test" ]; then
    echo "Usage: $0 <service to test>" 1>&2
    exit 1
fi
if [ "$(whoami)" != "root" ]; then
    echo "Error: This utility must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

run_test_sequence "$service_to_test"

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished testing system service"
else
    echo
    echo "Finished testing system service, but with errors" 1>&2
fi
exit $encountered_error
