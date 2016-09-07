#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use POSIX qw(strftime);

my $mysqldump = '/usr/bin/mysqldump';
my $conffile = 'db_dump.conf';
my $timestamp = POSIX::strftime('%Y%m%d_%H%M%S', localtime());
my $dumpfile = "db_dump_tool_shed_$timestamp.sql";

my $sql = '--flush-privileges --skip-extended-insert --no-tablespaces --skip-comments --skip-disable-keys --skip-set-charset';

my $database = 'tool_shed';
my $tables = 'tool tool_version specialized_tool_version tool_language tool_platform tool_viewer_incompatibility';

my @tool_uuids = (
  '9289b560-8f8b-11e4-829b-001a4a81450b',  # Android lint
  '7fbfa454-8f9f-11e4-829b-001a4a81450b',  # Bandit
  '5cd726a5-4053-11e5-83f1-001a4a81450b',  # Brakeman
  'f212557c-3050-11e3-9a3e-001a4a81450b',  # Clang Static Analyzer
  # '5540d2be-72b2-11e5-865f-001a4a81450b',  # CodeSonar
  'b9560648-4057-11e5-83f1-001a4a81450b',  # Dawn
  '163d56a7-156e-11e3-a239-001a4a81450b',  # Findbugs
  '63695cd8-a73e-11e4-a335-001a4a81450b',  # Flake8
  '7A08B82D-3A3B-45CA-8644-105088741AF6',  # GCC
  '163f2b01-156e-11e3-a239-001a4a81450b',  # PMD
  # '4bb2644d-6440-11e4-a282-001a4a81450b',  # Parasoft C/C++test
  # '6197a593-6440-11e4-a282-001a4a81450b',  # Parasoft Jtest
  '0f668fb0-4421-11e4-a4f3-001a4a81450b',  # Pylint
  '8157e489-1fbc-11e5-b6a7-001a4a81450b',  # Reek
  '738b81f0-a828-11e5-865f-001a4a81450b',  # RevealDroid
  'ebcab7f6-0935-11e5-b6a7-001a4a81450b',  # RuboCop
  '992A48A5-62EC-4EE9-8429-45BB94275A41',  # checkstyle
  '163e5d8c-156e-11e3-a239-001a4a81450b',  # cppcheck
  '56872C2E-1D78-4DB0-B976-83ACF5424C52',  # error-prone
  '59612f24-0946-11e5-b6a7-001a4a81450b'   # ruby-lint
);
my $tool_uuids = join ',', map {"'$_'"} @tool_uuids;

my $where = "tool_uuid in ($tool_uuids)";

my $result = `echo "USE \\\`$database\\\`;" > $dumpfile`;
$result = `$mysqldump --defaults-file=$conffile $sql $database $tables --where="$where" >> $dumpfile`;
print "result: $result\n";
print "Hello World!\n";
