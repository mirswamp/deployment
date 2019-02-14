#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

use strict;
use warnings;
use Log::Log4perl qw(:easy);
use HTCondorClassAds qw(
	get_condor_collector_host
	show_collector_records
);

my $as_table = 0;

Log::Log4perl->easy_init($OFF);

my $condor_collector_host = get_condor_collector_host();

show_collector_records($condor_collector_host, 'assessment', $as_table);
show_collector_records($condor_collector_host, 'viewer', $as_table);

print "Hello World!\n";
