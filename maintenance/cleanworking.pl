#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use File::Path qw(remove_tree);
use File::stat;
use Data::Dumper;
use Mail::Sendmail;

my $admin_email = 'jgardner@continuousassurance.org';
my $help = 0;
my $debug = 0;
my $verbose = 0;
my $noexecute = 0;

my $working = '/swamp/working/results';
my $deleteall = 28;
my $deletesuccess = 7;

sub remove_workingdir { my ($dir) = @_ ;
	my $err;
	remove_tree($dir, {error => \$err});
	if (scalar(@$err)) {
		print "Errors for $dir ", Dumper($err) if ($debug);
		my $hostname = `hostname`;
		chomp $hostname;
		my %mail = (
				To => $admin_email,
				Subject => "$hostname $0 failed",
				Message => "Errors for $dir " . Dumper($err),
				From => "root\@$hostname",
				);
		if (! sendmail(%mail)) {
			print "Error in sendmail: $Mail::Sendmail::error\n";
		}
	}
}

sub cleanworking {
	if (! -d $working) {
		print "Error - $working is not a directory\n" if ($debug);
		return;
	}

	# first look for any directory that is older than deleteall days and delete it
	my @faileddirs = `find $working -mindepth 1 -maxdepth 1 -ctime +$deleteall`;
	foreach my $faileddir (@faileddirs) {
		chomp $faileddir;
		if ($verbose) {
			my $date = localtime(stat($faileddir)->ctime);
			print "Deleting $faileddir created on: $date\n";
		}
		remove_workingdir($faileddir) if (! $noexecute);
	}

	# now look for directories that are older than deletesuccess days 
	# delete such directories that have PASS: all in the status.out file
	my @workingdirs = `find $working -mindepth 1 -maxdepth 1 -ctime +$deletesuccess`;
	foreach my $workingdir (@workingdirs) {
		chomp $workingdir;
		my $statusout = File::Spec->catfile($workingdir, 'status.out');
		if (-r $statusout) {
			my $passall = `grep 'PASS: all' $statusout`;
			chomp $passall;
			if ($passall) {
				if ($verbose) {
					my $date = localtime(stat($workingdir)->ctime);
					print "Deleting success $workingdir created on: $date\n";
					print "  $passall <$statusout>\n";
				}
				remove_workingdir($workingdir) if (! $noexecute);
			}
			elsif ($verbose) {
				my $date = localtime(stat($workingdir)->ctime);
				print "Preserving failed $workingdir created on: $date\n";
				print "  $passall <$statusout>\n";
			}
		}
		elsif ($verbose) {
			my $date = localtime(stat($workingdir)->ctime);
			print "Preserving $workingdir created on: $date\n";
			print "$statusout not readable\n";
		}
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose -noexecute]\n";
	exit;
}

# usage() if (! @ARGV);

my $result = GetOptions(
	'help'		=> \$help,
	'debug'		=> \$debug,
	'verbose'	=> \$verbose,
	'noexecute'	=> \$noexecute,
	'admin_email=s'	=> \$admin_email,
);
usage() if ($help || ! $result);
if ($noexecute) {
	$verbose = 1;
}

cleanworking();
