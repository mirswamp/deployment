#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

use strict;
use warnings;
use lib "/opt/swamp/perl5";
use lib "/home/tbricker/swamp/services/perl/agents/lib";
use SWAMP::vmu_Support qw(HTCondorJobStatus);

my $execrunuid = '';
my $clusterid = $ARGV[0];
my $procid = 0;

my $result = HTCondorJobStatus($execrunuid, $clusterid, $procid);
print "clusterid: ", $clusterid || '', " result: $result\n";
print "Hello World\n";
