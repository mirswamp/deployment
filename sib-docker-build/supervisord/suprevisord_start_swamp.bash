#!/usr/bin/env bash
SWAMP=/opt/swamp
export PERLLIB=$PERLLIB:$SWAMP/perl5
export PERL5LIB=$PERL5LIB:$SWAMP/perl5
source /etc/profile.d/swamp.sh
# exec /opt/perl5/perls/perl-5.26.1/bin/perl /opt/swamp/bin/vmu_swamp_monitor --nodetached --debug -pidfile /opt/swamp/run/vmu_swamp_monitor.pid -C /opt/swamp/etc/swampmonitor.conf
exec /opt/swamp/bin/vmu_swamp_monitor --nodetached --debug -pidfile /opt/swamp/run/vmu_swamp_monitor.pid -C /opt/swamp/etc/swampmonitor.conf