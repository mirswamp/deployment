#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);

my $dirs = 0;
$dirs = 1 if (defined($ARGV[0]));

my $mysql = '/usr/bin/mysql';
my $conffile = 'db_dump.conf';

my $sql = "
SELECT t.name, tv.version_string, ifnull(tv.tool_path, stv.tool_path), ifnull(tv.checksum, stv.checksum)
         FROM tool_shed.tool t
        INNER JOIN tool_shed.tool_version tv ON t.tool_uuid = tv.tool_uuid
        LEFT OUTER JOIN tool_shed.specialized_tool_version stv ON tv.tool_version_uuid = stv.tool_version_uuid
WHERE t.tool_uuid IN (
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
   ) ORDER BY t.name
";

my @list = `$mysql --defaults-file=$conffile -e "$sql"`;
if (! $dirs) {
	print @list;
}
else {
	my %dirs = ();
	foreach my $line (@list) {
		# print $line, "\n";
		if ($line =~ m/\/swamp\/store\/SCATools\/(.*)\//) {
			# print '  ', $1, "\n";
			$dirs{$1} = 1;
		}
	}
	foreach my $key (sort keys %dirs) {
		print $key, ' ';
	}
	print "\n";
}
print "Hello World!\n";
