#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);

my $dirs = 0;
$dirs = 1 if (defined($ARGV[0]));

my $mysql = '/usr/bin/mysql';
my $conffile = 'db_dump.conf';

my $sql = "SELECT platform_path, platform_uuid FROM platform_store.platform_version";

my @list = `$mysql --defaults-file=$conffile -e "$sql"`;
print @list;
print "Hello World!\n";
