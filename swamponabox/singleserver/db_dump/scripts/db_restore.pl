#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);

my $mysql = '/usr/bin/mysql';
my $conffile = $Bin . '/db_dump.conf';

sub restore_dbfile { my ($dbfile) = @_ ;
	return if (! -r $dbfile);
	print "Restoring: $dbfile\n";
	my $result = `$mysql --defaults-file=$conffile < $dbfile 2>&1`;
	print "Result: $result\n";
}

my $data_only = 0;
$data_only = 1 if (defined($ARGV[0]));

if (! $data_only) {
	my $dbfile = `find . -maxdepth 1 -name 'db_dump_mysql_*.sql'`;
	chomp $dbfile;
	restore_dbfile($dbfile);
}

my $db_path = '.';
$db_path = $ARGV[0] if (defined($ARGV[0]));
if (! -d $db_path) {
	print "Error - $db_path is not a directory - exiting ...\n";
	exit;
}
my @dbfiles = `find $db_path -maxdepth 1 -name 'db_dump_*.sql' | grep -v mysql`;
chomp @dbfiles;
if (! @dbfiles) {
	print "Error - no db_dump_*.sql restore files in: $db_path - exiting ...\n";
	exit;
}
foreach my $dbfile (@dbfiles) {
	restore_dbfile($dbfile);
}

print "Hello World!\n";
