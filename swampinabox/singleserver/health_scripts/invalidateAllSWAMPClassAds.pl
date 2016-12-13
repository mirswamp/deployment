#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

Log::Log4perl->easy_init($INFO);

my $config = getSwampConfig();
my $HTCONDOR_COLLECTOR_HOST = $config->get('htcondor_collector_host');
my ($output, $status) = systemcall("condor_advertise -pool $HTCONDOR_COLLECTOR_HOST INVALIDATE_ADS_GENERIC - <<'EOF'
MyType=\"Query\"
TargetType=\"Generic\"
Requirements = MyType == \"Generic\"
EOF
");
if ($status) {
	print "Error - condor_advertise $HTCONDOR_COLLECTOR_HOST failed - status: $status output: $output\n";
	exit;
}
if (! $output) {
	print "condor_advertise - no output\n";
	exit;
}
print "output: $output\n";
print "Hello World!\n";
