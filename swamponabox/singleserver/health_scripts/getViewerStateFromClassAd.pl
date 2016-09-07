#!/usr/bin/env perl
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib '/opt/swamp/perl5';
use SWAMP::vmu_ViewerSupport qw(getViewerStateFromClassAd);

Log::Log4perl->easy_init($INFO);

my $project_name = $ARGV[0];
if (! $project_name) {
	print "Error - no project name\n";
	exit(0);
}
my $viewer_name = $ARGV[1];
$viewer_name = 'CodeDX' if (! $viewer_name);
my $result = getViewerStateFromClassAd($project_name, $viewer_name);
print "project_name: $project_name viewer_name: $viewer_name\nresult: ", Dumper($result), "\n";

print "Hello World!\n";
