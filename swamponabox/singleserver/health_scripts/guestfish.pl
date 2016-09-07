#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my $debug = 0;
my $verbose = 0;

sub guestfish_display_file { my ($vmname, $file, $preserve) = @_ ;
	print "Fetching: $file from: $vmname with preserve: $preserve\n";
	my $result;
    if ($preserve) {
    	$result = `virt-copy-out -d $vmname -m /dev/sdc:/mnt/out -m /dev/sdb:/mnt/in $file .`;
    }
    else {
    	$result = `guestfish --ro -d $vmname -m /dev/sdc:/mnt/out -m /dev/sdb:/mnt/in -i cat $file 2>&1`;
    }
    print "$result\n";
}

sub usage {
	print "usage: $0 [-help -debug -verbose -runout|-catalina|-mysql|-file <string> -preserve] <vmname>\n"; 
	exit;
}

usage() if (! @ARGV);

my $help = 0;
my $vmname;
my $file;
my $preserve = 0;
my $runout = 0;
my $catalina = 0;
my $mysql = 0;
my $result = GetOptions(
	'help'			=> \$help,
	'debug'			=> \$debug,
	'verbose'		=> \$verbose,
	'file=s'		=> \$file,
	'preserve'		=> \$preserve,
	'runout'		=> \$runout,
	'catalina'		=> \$catalina,
	'mysql'			=> \$mysql,
);
usage() if ($help || ! $result);
$vmname = $ARGV[0] if (defined($ARGV[0]));
usage() if (! $vmname);
$runout = 1 if (! $file && ! $runout && ! $catalina && ! $mysql);

guestfish_display_file($vmname, $file, $preserve) if ($file);
guestfish_display_file($vmname, '/mnt/out/run.out', $preserve) if ($runout);
guestfish_display_file($vmname, '/var/log/tomcat6/catalina.out', $preserve) if ($catalina);
guestfish_display_file($vmname, "/var/lib/mysql/$vmname.err", $preserve) if ($mysql);
