package HTCondorClassAds;
use strict;
use warnings;
use parent qw(Exporter);
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

our (@EXPORT_OK);
BEGIN {
	require Exporter;
	@EXPORT_OK = qw(
		get_condor_collector_host
		show_collector_records
	);
}

my @assessment_fields = qw(
	Name 
	SWAMP_vmu_assessment_vmhostname
	SWAMP_vmu_assessment_status
);
my $assessment_constraint = qq{-constraint \"isString(SWAMP_vmu_assessment_status)\"};

my @viewer_fields = qw(
	Name 
	SWAMP_vmu_viewer_vmhostname
	SWAMP_vmu_viewer_name
	SWAMP_vmu_viewer_state 
	SWAMP_vmu_viewer_status 
	SWAMP_vmu_viewer_vmip 
	SWAMP_vmu_viewer_project 
	SWAMP_vmu_viewer_instance_uuid 
	SWAMP_vmu_viewer_apikey 
	SWAMP_vmu_viewer_url_uuid
);
my $viewer_constraint = qq{-constraint \"isString(SWAMP_vmu_viewer_status)\"};

sub get_condor_collector_host {
	my $HTCONDOR_COLLECTOR_HOST;
	my $config = getSwampConfig();
	if ($config) {
		$HTCONDOR_COLLECTOR_HOST = $config->get('htcondor_collector_host');
	}
	return $HTCONDOR_COLLECTOR_HOST;
}

sub show_collector_records { my ($HTCONDOR_COLLECTOR_HOST, $title, $as_table) = @_ ;
	if (! $HTCONDOR_COLLECTOR_HOST) {
		return;
	}
	my ($fields, $constraint, $sortfield);
	if ($title eq 'assessment') {
		$fields = \@assessment_fields;
		$constraint = $assessment_constraint;
	}
	elsif ($title eq 'viewer') {
		$fields = \@viewer_fields;
		$constraint = $viewer_constraint;
	}
	else {
		return;
	}
	$sortfield = "SWAMP_vmu_${title}_vmhostname";
	my $command = qq{condor_status -pool $HTCONDOR_COLLECTOR_HOST -sort $sortfield -any -af:V, };
	foreach my $field (@$fields) {
		$command .= ' ' . $field;
	}
	$command .= ' ' . $constraint if ($constraint);
	my ($output, $status) = systemcall($command);
	if ($status) {
		return;
	}
	my @lines = split "\n", $output;
	print "$title collector: [", scalar(@lines), "] $HTCONDOR_COLLECTOR_HOST\n";
	print "-" x length("$title collector:");
	print "\n";
	if ($as_table && @lines) {
		print "execrunuid\t\t\t";
		foreach my $field (@$fields) {
			next if ($field eq "Name");
			my $field_name = $field;
			$field_name =~ s/^SWAMP_vmu_${title}_//;
			print "\t$field_name";
		}
		print "\n";
	}
	foreach my $line (@lines) {
		my @parts = split ',', $line;
		s/\"//g for @parts;
		s/^\s+//g for @parts;
		s/\s+$//g for @parts;
		print "execrunuid: " if (! $as_table);
		print $parts[0];
		print "\n" if (! $as_table);
		for (my $i = 1; $i < scalar(@parts); $i++) {
			if (! $as_table) {
				my $field_name = $fields->[$i];
				$field_name =~ s/^SWAMP_vmu_${title}_//;
				print "  $field_name: ", $parts[$i], "\n";
			}
			else {
				print "\t", $parts[$i];
			}
		}
		print "\n";
	}
	print "\n";
}

1;
