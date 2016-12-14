#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use POSIX qw(strftime);

my $mysql = '/usr/bin/mysql';
my $mysqldump = '/usr/bin/mysqldump';
my $conffile = $Bin . '/db_dump.conf';
my $timestamp = POSIX::strftime('%Y%m%d_%H%M%S', localtime());
my $databases_dumpfile = "db_dump_databases_$timestamp.sql";
my $mysql_dumpfile = "db_dump_mysql_$timestamp.sql";
my $skipdatabases = 'Database|mysql|information_schema|performance_schema';

sub list_databases {
    my $databases = `$mysql --defaults-file=$conffile -e 'show databases'`;
    my @databases = split ' ', $databases;
    @databases = grep(!/$skipdatabases/isxm, @databases);
    $databases = join ' ', @databases;
    return $databases;
}

sub dump_databases { my ($data_only) = @_ ;
	if (! $data_only) {
		print "Dumping mysql schema\n";
    	my $result = `$mysqldump --defaults-file=$conffile --flush-privileges --routines --databases mysql > $mysql_dumpfile`;
	}

    my $databases = list_databases();
	print "Dumping database schemas\n";
	if ($data_only) {
    	my $result = `$mysqldump --defaults-file=$conffile --skip-triggers --compact --no-create-db --no-create-info --databases $databases > $databases_dumpfile`;
	}
	else {
    	my $result = `$mysqldump --defaults-file=$conffile --routines --databases $databases > $databases_dumpfile`;
	}
}

my $data_only = 0;
$data_only = 1 if (defined($ARGV[0]));

dump_databases($data_only);

print "Hello World!\n";
