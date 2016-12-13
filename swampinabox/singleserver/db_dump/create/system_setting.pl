#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use Sys::Hostname;
use FindBin;
use lib "$FindBin::Bin";
use mysql;

my $conffile = File::Spec->catfile($FindBin::Bin, 'db_create.conf');

sub set_system_setting { my ($outgoing, $codedx) = @_ ;
	print "\nSet system_setting for OUTGOING_BASE_URL: $outgoing\n";
	my $result = `mysql --defaults-file=$conffile -e "INSERT INTO assessment.system_setting (system_setting_code, system_setting_value) VALUES ('OUTGOING_BASE_URL', \'$outgoing\')" 2>&1`;
	print "mysql system_setting OUTGOING_BASE_URL: $result\n";
	if ($result) {
		print "mysql system_setting OUTGOING_BASE_URL - error - exiting ...\n";
		exit 1;
	}
	print "\nSet system_setting for CODEDX_BASE_URL: $codedx\n";
	$result = `mysql --defaults-file=$conffile -e "INSERT INTO assessment.system_setting (system_setting_code, system_setting_value) VALUES ('CODEDX_BASE_URL', \'$codedx\')" 2>&1`;
	print "mysql system_setting CODEDX_BASE_URL: $result\n";
	if ($result) {
		print "mysql system_setting CODEDX_BASE_URL - error - exiting ...\n";
		exit 1;
	}
}

sub usage {
	print "usage: $0 [-help -verbose -debug -mysql mysql|mariadb -webhost <string>]\n";
	exit;
}

my $mysql;
my $webhost;

my $help = 0;
my $verbose = 0;
my $debug = 0;
my $result = GetOptions(
	'help'		=> \$help,
	'verbose'	=> \$verbose,
	'debug'		=> \$debug,
	'mysql=s'	=> \$mysql,
	'webhost=s'	=> \$webhost,
);
usage if (! $result || $help);
$mysql = 'mysql' if (! defined($mysql));
$webhost = hostname() if (! defined($webhost));

my $outgoing = "https://$webhost/results/";
my $codedx = "https://$webhost/";
mysql::start_service($mysql, $verbose);
set_system_setting($outgoing, $codedx);

print "Hello World!\n";
