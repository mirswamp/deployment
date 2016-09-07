#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);

my $mysql = '/usr/bin/mysql';
my $conffile = $Bin . '/db_dump.conf';
my $skipdatabases = 'Database|mysql|information_schema|performance_schema';

sub list_databases {
    my $databases = `$mysql --defaults-file=$conffile -e 'show databases'`;
    my @databases = split ' ', $databases;
    @databases = grep(!/$skipdatabases/isxm, @databases);
    return \@databases;
}

my $databases = list_databases();
foreach my $database (@$databases) {
	print $database, "\n";
}

foreach my $database (@$databases) {
	my $result = `$mysql --defaults-file=$conffile -e \'set foreign_key_checks=0; drop database $database\' 2>&1`;
	print $database, ' delete result: ', $result, "\n";
}

$databases = list_databases();
foreach my $database (@$databases) {
	print $database, "\n";
}

print "Hello World!\n";
