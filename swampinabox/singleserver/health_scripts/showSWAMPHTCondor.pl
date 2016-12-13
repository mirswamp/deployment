#!/usr/bin/env perl
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Getopt::Long;
use HTCondorClassAds qw(
	get_condor_collector_host
	show_collector_records
);
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

my $help	= 0;
my $debug	= 0;
my $verbose	= 0;
my $quiet	= 0;

Log::Log4perl->easy_init($verbose ? ($quiet ? $OFF : $DEBUG) : $OFF);
my $hostname = `hostname`; chomp $hostname;

sub get_condor_submit_node {
	my $command = "condor_status -schedd -af Name";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	chomp $output;
	return $output;
}

sub get_condor_exec_nodes {
	my $command = "condor_status -af Machine -constraint 'SlotType == \"Partitionable\"'";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	my @execnodes = split "\n", $output;
	return \@execnodes;
}

sub get_swamp_data_node {
	my $config = getSwampConfig();                                                                                
	my $data_node = $config->get('quartermasterHost');
	if ($data_node eq 'localhost') {
		$data_node = $hostname;
	}
	return $data_node;
}

sub show_swamp_processes { my ($host) = @_ ;
	return if (! $host);
	my $command = "ps aux | egrep 'PID|vmu_|java' | grep -v grep";
	if ($host ne $hostname) {
		$command = "ssh $host ps aux | egrep 'vmu_|java' | grep -v grep";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	my @lines = split "\n", $output;
	my $fields = "";
	my $vmuA = [];
	my $vmuV = [];
	my $vmu = [];
	my $java = [];
	my $other = [];
	foreach my $line (@lines) {
		if ($line =~ m/PID/) {
			$fields = $line;
		}
		elsif ($line =~ m/vmu_.*Assessment/) {
			push @$vmuA, $line;
		}
		elsif ($line =~ m/vmu_.*Viewer/) {
			push @$vmuV, $line;
		}
		elsif ($line =~ m/vmu_.*.pl/) {
			push @$vmu, $line;
		}
		elsif ($line =~ m/java/) {
			push @$java, $line;
		}
		else {
			push @$other, $line;
		}
	}
	# sort vmuA and vmuV on clusterid at end of COMMAND field
	@$vmuA = sort {
		my @aparts = split ' ', $a; 
		# either clusterid procid or clusterid procid [a|v|m]swamp-clusterid-procid
		# 		 -2        -1        -3        -2     -1
		my $acmp = $aparts[-2];
		$acmp = $aparts[-3] if ($aparts[-1] !~ m/^\d+$/);
		my @bparts = split ' ', $b; 
		my $bcmp = $bparts[-2];
		$bcmp = $bparts[-3] if ($bparts[-1] !~ m/^\d+$/);
		if (($acmp =~ m/^\d+$/) && ($bcmp =~ m/^\d+$/)) {
			return $acmp <=> $bcmp;
		}
		else {
			return $acmp cmp $bcmp;
		}
	} @$vmuA;
	@$vmuV = sort {
		my @aparts = split ' ', $a; 
		# either clusterid procid or clusterid procid [a|v|m]swamp-clusterid-procid
		# 		 -2        -1        -3        -2     -1
		my $acmp = $aparts[-2];
		$acmp = $aparts[-3] if ($aparts[-1] !~ m/^\d+$/);
		my @bparts = split ' ', $b; 
		my $bcmp = $bparts[-2];
		$bcmp = $bparts[-3] if ($bparts[-1] !~ m/^\d+$/);
		if (($acmp =~ m/^\d+$/) && ($bcmp =~ m/^\d+$/)) {
			return $acmp <=> $bcmp;
		}
		else {
			return $acmp cmp $bcmp;
		}
	} @$vmuV;
	my $header = "vmu_ and java processes on $host";
	# discount fields line in count
	$header .= " T:[" . (scalar(@lines)-1) . "]";
	$header .= " A:[" . (scalar(@$vmuA)) . "]";
	$header .= " V:[" . (scalar(@$vmuV)) . "]";
	$header .= " v:[" . (scalar(@$vmu)) . "]";
	$header .= " j:[" . (scalar(@$java)) . "]";
	$header .= " o:[" . (scalar(@$other)) . "]";
	print $header, "\n";
	my $under = "-" x length($header);
	print $under, "\n";
	print $fields, "\n";
	print $_, "\n" foreach (@$vmuA);
	print $_, "\n" foreach (@$vmuV);
	print "\n";
	print $_, "\n" foreach (@$vmu);
	print "\n";
	print $_, "\n" foreach (@$java);
	print "\n";
	print $_, "\n" foreach (@$other);
	print "\n";
}

sub show_condor_queue { my ($submit_node) = @_ ;
	return if (! $submit_node);
	print "Condor Queue\n";
	print "------------";
	my $command = "condor_q -pool $submit_node";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n";
		return;
	}
	if (! $output) {
		print "no condor records\n";
		return;
	}
	print $output, "\n";
}

sub show_virtual_machines { my ($exec_nodes) = @_ ;
	return if (! $exec_nodes);
	print "Virsh List [", scalar(@$exec_nodes), "]\n";
	print "----------\n";
	foreach my $exec_node (@$exec_nodes) {
		my $command = "virsh list --all";
		if ($exec_node ne $hostname) {
			$command = "ssh $exec_node virsh list --all";
		}
		my ($output, $status) = systemcall($command);
		if ($status) {
			print "Error - $command failed - status: $status output: $output\n";
			next;
		}
		my @vms = grep(! m/Id|\-\-/, split "\n", $output);
		# sort vm list on name field with condor clusterid_procid suffix
		@vms = sort {my @aparts = split ' ', $a; my @bparts = split ' ', $b; $aparts[1] cmp $bparts[1];} @vms;
		print $exec_node, " [", scalar(@vms), "]\n";
		foreach my $vm (@vms) {
			print "  ", $vm, "\n";
		}
	}
	print "\n";
}

sub show_submit_job_dirs { my ($submit_node) = @_ ;
	return if (! $submit_node);
	my $command = "ls -lrt /opt/swamp/run";
	if ($submit_node ne $hostname) {
		$command = "ssh $submit_node ls -lrt /opt/swamp/run";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n";
		return;
	}
	if (! $output) {
		print "no contents in /opt/swamp/run\n";
		return;
	}
	my @lines = grep(! m/swamp_monitor|total/, split "\n", $output);
	print "SWAMP Submit Job Directories [", scalar(@lines), "]\n";
	print "----------------------------\n";
	foreach my $line (@lines) {
		my $log = '';
		my $dir = (split ' ', $line)[-1];
		if (opendir(my $dh, "/opt/swamp/run/$dir")) {
			$log = (grep {/^[a|m|v]swamp\-\d+\-\d+\.log$/} readdir($dh))[0];
			closedir($dh);
			$log = '' if (! $log);
			$log =~ s/\.log$//;
		}
		print $line, ' ', $log, "\n";
	}
	print "\n";
}

sub usage {
	print "usage: $0 [-help -debug -verbose -quiet -sleep -condor -collector|[-assess|-viewer] -jobdirs -libvirt -swamp|[-data|-sub|-exec]]\n";
	exit;
}

my ($condor, $collector, $assess, $viewer, $jobdirs, $libvirt, $swamp, $data, $sub, $exec);
my $sleep = 0;
my $result = GetOptions(
	'help'      => \$help,
	'debug'     => \$debug,
	'verbose'   => \$verbose,
	'quiet'		=> \$quiet,
	'sleep=i'	=> \$sleep,
	'condor'	=> \$condor,
	'collector'	=> \$collector,
	'assess'	=> \$assess,
	'viewer'	=> \$viewer,
	'jobdirs'	=> \$jobdirs,
	'libvirt'	=> \$libvirt,
	'swamp'		=> \$swamp,
	'data'		=> \$data,
	'sub'		=> \$sub,
	'exec'		=> \$exec,
);
usage() if ($help || ! $result);    
my $all = ! $condor && ! $collector && ! $assess && ! $viewer && ! $jobdirs && ! $libvirt && ! $swamp && ! $data && ! $sub && !$exec;

my $HTCONDOR_COLLECTOR_HOST;
$HTCONDOR_COLLECTOR_HOST = get_condor_collector_host();
my $submit_node = get_condor_submit_node();
my $exec_nodes = get_condor_exec_nodes();
my $data_node = get_swamp_data_node();
if (! $submit_node || ! @$exec_nodes || ! $data_node) {
	print "Error - submit, exec, data, node(s) not found\n";
	usage();
}

if ($debug) {
	print "collector: ", $HTCONDOR_COLLECTOR_HOST || "", "\n";
	print "submit: ", $submit_node || "", "\n";
	print "exec: ", @$exec_nodes || "", "\n";
	print "data: ", $data_node || "", "\n";
	print "\n";
}

while (1) {
	system("clear") if ($sleep);
	show_condor_queue($submit_node) if ($all || $condor);
	show_collector_records($HTCONDOR_COLLECTOR_HOST, 'assessment', 1) if ($all || $collector || $assess);
	show_collector_records($HTCONDOR_COLLECTOR_HOST, 'viewer', 0) if ($all || $collector || $viewer);
	show_submit_job_dirs($submit_node) if ($all || $jobdirs);
	show_virtual_machines($exec_nodes) if ($all || $libvirt);
	my $seen = {};
	if ($all || $swamp || $sub) {
		show_swamp_processes($submit_node);
		$seen->{$submit_node} = 1;
	}
	if ($all || $swamp || $exec) {
		foreach my $exec_node (@$exec_nodes) {
			if (! $seen->{$exec_node}) {
				show_swamp_processes($exec_node);
				$seen->{$exec_node} = 1;
			}
		}
	}
	if ($all || $swamp || $data) {
		if (! $seen->{$data_node}) {
			show_swamp_processes($data_node) 
		}
	}
	last if (! $sleep);
	sleep $sleep;
}
