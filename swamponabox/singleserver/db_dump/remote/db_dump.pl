#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use POSIX qw(strftime);

my $mysql = '/usr/bin/mysql';
my $mysqldump = '/usr/bin/mysqldump';
my $conffile = 'db_dump.conf';
my $timestamp = POSIX::strftime('%Y%m%d_%H%M%S', localtime());
my $mysql_dumpfile = "db_dump_mysql_$timestamp.sql";
my $skipdatabases = 'Database|mysql|information_schema|performance_schema|grouper|piwik|test_move';
my $skiptables = 'Tables_in|_bkup|test_';

sub list_databases {
    my $databases = `$mysql --defaults-file=$conffile -e 'show databases'`;
    my @databases = split ' ', $databases;
    @databases = grep(!/$skipdatabases/isxm, @databases);
    return \@databases;
}

sub list_tables { my ($database) = @_ ;
    my $tables = `$mysql --defaults-file=$conffile -e 'use $database; show tables'`;
    my @tables = split ' ', $tables;
    @tables = grep(!/$skiptables/isxm, @tables);
    $tables = join ' ', @tables;
    return $tables;
}

sub dump_mysql {
	print "Dumping mysql schema\n";
	my $result = `$mysqldump --defaults-file=$conffile --flush-privileges --databases mysql > $mysql_dumpfile`;
}

sub dump_database { my ($database_dumpfile, $database, $tables) = @_ ;
    print "Dumping database schema: $database ";
    print "with $tables " if ($tables);
	print "to $database_dumpfile\n";
	my $result;
	if ($tables) {
    	$result = `$mysqldump --defaults-file=$conffile --routines --triggers $database $tables > $database_dumpfile`;
	}
	else {
    	$result = `$mysqldump --defaults-file=$conffile --routines --triggers --databases $database > $database_dumpfile`;
	}
}

sub show_databases { my ($databases) = @_ ;
    foreach my $database (@$databases) {
        print "$database\n";
        my $tables = list_tables($database);
        print "  $tables\n\n";
    }
}

sub usage {
	print "usage: $0 [-h -l -s {<database> ...} {<table> ...}]\n";
	exit;
}

# initial conditions - dump mysql and all databases into two separate files
my $skip_mysql = 0;
my $databases = list_databases();
my %databases = map { $_ => 1 } @$databases;

# if ARGV contains database names then just dump those databases
my $showlist = 0;
my @databases;
my @tables;
foreach my $arg (@ARGV) {
	print $arg, "\n";
	if ($arg eq '-h') {
		usage();
	}
	elsif ($arg eq '-l') {
		$showlist = 1;
	}
    elsif ($arg eq '-s') {
		$skip_mysql = 1;
    }
	elsif (exists($databases{$arg})) {
		$skip_mysql = 1;
		push @databases, $arg;
	}
	else {
		push @tables, $arg;
	}
}

if ($showlist) {
	$databases = \@databases if (@databases);
   	show_databases($databases);
	exit;
}

if ($skip_mysql) {
	foreach my $database (@databases) {
		my $tables_string;
    	my $database_dumpfile = 'db_dump_' . $database . '_' . $timestamp . '.sql';
		if (@tables) {
    		$database_dumpfile = 'db_dump_' . $database . '_' . (join '_', @tables) . '_' . $timestamp . '.sql';
			$tables_string = join ' ', @tables;
		}
		dump_database($database_dumpfile, $database, $tables_string);
	}
}
else {
	dump_mysql();
	my $databases_string = join ' ', @$databases;
	my $database_dumpfile = "db_dump_databases_$timestamp.sql";
    dump_database($database_dumpfile, $databases_string);
}

print "Hello World!\n";
