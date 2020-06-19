#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Configuring HTCondor for the SWAMP"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
. "$BINDIR"/runtime/bin/swamp_utility.functions

############################################################################

htcondor_tar_file=$1
htcondor_installer_dir=""

htcondor_root=/opt/swamp/htcondor
htcondor_local_dir=$htcondor_root/local
htcondor_config_dir=$htcondor_local_dir/config
htcondor_slots_dir=/slots

htcondor_user=condor
htcondor_service=swamp-condor
htcondor_description="SWAMP's HTCondor Instance"

limits_conf=swampinabox_90_concurrency_limits.conf

############################################################################

os_tag=""
os_distribution=$(get_os_distribution)
os_version=$(get_os_version)

echo "Checking OS support ... $os_distribution $os_version"

case "$os_distribution $os_version" in
    "CentOS Linux 6")  os_tag=RedHat6 ;;
    "CentOS Linux 7")  os_tag=RedHat7 ;;
    "Red Hat Linux 6") os_tag=RedHat6 ;;
    "Red Hat Linux 7") os_tag=RedHat7 ;;
    *)
        #
        # This script needs to know what OS this host is running only to
        # install the system service, which is something that the user can
        # do themselves, if need be.
        #
        echo "Warning: Not a recognized OS: $os_distribution $os_version" 1>&2
        ;;
esac

############################################################################

if [ -z "$htcondor_tar_file" ]; then
    htcondor_version=$(grep '^htcondor:' /opt/swamp/etc/dependencies.txt \
                         | head -n 1 \
                         | sed -e 's/^htcondor://')

    for path in "$BINDIR"/../dependencies/htcondor/condor-"${htcondor_version}"*"${os_tag}"*
    do
        if [ -f "$path" ]
        then
            htcondor_tar_file=$path
            break
        fi
    done
fi

if [ -f "$htcondor_tar_file" ]; then
    echo "Found $(basename -- "$htcondor_tar_file")"
else
    echo
    echo "Error: No such file: $htcondor_tar_file" 1>&2
    exit 1
fi

############################################################################

create_user "$htcondor_user"
tell_service --skip-missing "$htcondor_service" stop

if groupmems -g docker -l 1>/dev/null 2>&1
then
    create_group docker "$htcondor_user"
fi

trap 'rm -rf "$htcondor_installer_dir"' EXIT
htcondor_installer_dir=$(mktemp -d /tmp/htcondor_installer.XXXXXXXX)

echo "Extracting the HTCondor installer (this will take some time)"
tar -xz --strip-components 1 \
    -C "$htcondor_installer_dir" \
    -f "$htcondor_tar_file"

echo "Running the HTCondor installer (this will take some time)"
"$htcondor_installer_dir"/condor_install \
    --overwrite \
    --make-personal-condor \
    --prefix    "$htcondor_root" \
    --local-dir "$htcondor_local_dir" \
    --owner     "$htcondor_user"

echo "Removing the HTCondor installer"
rm -rf "$htcondor_installer_dir"

if [ ! -d "$htcondor_slots_dir" ]; then
    echo "Creating the $htcondor_slots_dir directory"
    install \
        -m 755 -o "$htcondor_user" -g "$htcondor_user" \
        -d "$htcondor_slots_dir"
else
    echo "Found the $htcondor_slots_dir directory"
fi

if [ ! -d "$htcondor_config_dir" ]; then
    echo "Creating the $htcondor_config_dir directory"
    install -m 755 -o root -g root -d "$htcondor_config_dir"
else
    echo "Found the $htcondor_config_dir directory"
fi

############################################################################

echo "Updating swamp.conf"
"$BINDIR"/runtime/sbin/swamp_patch_config \
    -i /opt/swamp/etc/swamp.conf \
    --key htcondor_root \
    --val "$htcondor_root"

if [ -f /etc/condor/config.d/"$limits_conf" ]; then
    echo "Moving /etc/condor/config.d/$limits_conf"
    mv /etc/condor/config.d/"$limits_conf" "$htcondor_config_dir"/.
fi

echo "Removing old configuration files"
for old_file in \
        /etc/condor/config.d/swamponabox_debug.conf \
        /etc/condor/config.d/swamponabox_descriptors.conf \
        /etc/condor/config.d/swamponabox_jobcontrol.conf \
        /etc/condor/config.d/swamponabox_main.conf \
        /etc/condor/config.d/swamponabox_network.conf \
        /etc/condor/config.d/swamponabox_slots.conf \
        /etc/condor/config.d/swamponabox_vm.conf \
        \
        /etc/condor/config.d/swampinabox_condor_q.conf \
        /etc/condor/config.d/swampinabox_debug.conf \
        /etc/condor/config.d/swampinabox_descriptors.conf \
        /etc/condor/config.d/swampinabox_jobcontrol.conf \
        /etc/condor/config.d/swampinabox_main.conf \
        /etc/condor/config.d/swampinabox_network.conf \
        /etc/condor/config.d/swampinabox_slots.conf \
        /etc/condor/config.d/swampinabox_vm.conf \
        \
        /etc/condor/config.d/swampinabox_01_debug.conf \
        /etc/condor/config.d/swampinabox_10_main.conf \
        /etc/condor/config.d/swampinabox_10_network.conf \
        /etc/condor/config.d/swampinabox_20_main.conf \
        /etc/condor/config.d/swampinabox_30_jobcontrol.conf \
        /etc/condor/config.d/swampinabox_40_slots.conf \
        /etc/condor/config.d/swampinabox_50_vm_universe.conf \
        /etc/condor/config.d/swampinabox_90_condor_developers.conf \
        /etc/condor/config.d/swampinabox_90_condor_q.conf \
        /etc/condor/config.d/swampinabox_90_descriptors.conf \
        ; do
    if [ -f "$old_file" ]; then
        echo "Removing: $old_file"
        rm -f "$old_file"
    fi
done

for config_file in "$BINDIR"/../config_templates/htcondor/* ; do
    config_file_basename=$(basename -- "$config_file")

    #
    # Overwrite existing configuration files, except for the concurrency
    # limits, because those are configured by the user.
    #
    if    [ "$config_file_basename" != "$limits_conf" ] \
       || [ ! -e "$htcondor_config_dir/$config_file_basename" ]
    then
        echo "Installing $config_file_basename"
        install -m 644 -o root -g root "$config_file" "$htcondor_config_dir"/.
    fi
done

############################################################################

echo "Installing the $htcondor_service system service"
case "$os_tag" in
    RedHat6)
        service_definition=/etc/init.d/$htcondor_service
        sed \
            -e "s|^# condor[[:space:]]\\+|# $htcondor_service - |" \
            -e "s|config: /etc/condor|config: $htcondor_root/etc|" \
            -e "s|pidfile: /var/run/condor|pidfile: $htcondor_local_dir/execute|" \
            -e "s|Provides: condor|Provides: $htcondor_service|" \
            -e "s|lockfile=/var/lock/subsys/condor|lockfile=/var/lock/subsys/$htcondor_service|" \
            -e "s|pidfile=/var/run/condor|pidfile=$htcondor_local_dir/execute|" \
            -e "s|-f /etc/sysconfig/condor|-f $htcondor_root/condor.sh|" \
            -e "s|\\. /etc/sysconfig/condor|. $htcondor_root/condor.sh|" \
            -e "s|-x /usr/sbin/\\\$prog|-x $htcondor_root/sbin/\$prog|" \
            < "$htcondor_root"/etc/examples/condor.init \
            > "$service_definition"
        chmod u=rwx,og=rx "$service_definition"
        chown root:root   "$service_definition"
        ;;
    RedHat7)
        service_definition=/etc/systemd/system/$htcondor_service.service
        sed \
            -e "s|Description=.*|Description=$htcondor_description|" \
            -e "s|EnvironmentFile=.*|Environment=CONDOR_CONFIG=$htcondor_root/etc/condor_config|" \
            -e "s|ExecStart=.*|ExecStart=$htcondor_root/sbin/condor_master -f|" \
            < "$htcondor_root"/etc/examples/condor.service \
            > "$service_definition"
        chmod u=rw,og=r "$service_definition"
        chown root:root "$service_definition"
        ;;
    *)
        echo
        echo "Error: Failed to install the $htcondor_service system service" 1>&2
        encountered_error=1
        ;;
esac
enable_service "$htcondor_service"

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo
    echo "Finished configuring HTCondor for the SWAMP"
else
    echo
    echo "Finished configuring HTCondor for the SWAMP, but with errors" 1>&2
fi
exit $encountered_error
