#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use DBI;

my $mysql = '/usr/bin/mysql';
my $conffile = $Bin . '/db_dump.conf';
my $skipdatabases = 'Database|mysql|information_schema|performance_schema';
my $skiptables = 'Tables_in_';

sub list_databases {
    my $databases = `$mysql --defaults-file=$conffile -e 'show databases'`;
    my @databases = sort split ' ', $databases;
    @databases = grep(!/$skipdatabases/isxm, @databases);
	unshift @databases, ('mysql', 'information_schema', 'performance_schema');
    return \@databases;
}

sub list_tables { my ($database) = @_ ;
    my $tables = `$mysql --defaults-file=$conffile -e "use $database; show tables"`;
    my @tables = split ' ', $tables;
    @tables = grep(!/$skiptables/isxm, @tables);
	return \@tables;
}

sub db_connect {
	my $csa_host = 'swamponabox';
	my $user = 'root';
	my $password = 'swamponabox';
	my $csa_port = '3306';
	my $dsn = "DBI:mysql:host=$csa_host;port=$csa_port";
	my $dbh = DBI->connect($dsn, $user, $password);
	return $dbh;
}

sub db_disconnect { my ($dbh) = @_ ;
    $dbh->disconnect();
}

sub getTableRowCounts { my ($dbh, $database, $table) = @_ ;
	my $query = "SELECT COUNT(*) FROM $database.$table";
	(my $count) = $dbh->selectrow_array($query);
	return $count;
}

sub getDatabaseProcedureCounts { my ($dbh, $database) = @_ ;
	my $query = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = \'$database\' AND ROUTINE_TYPE = 'PROCEDURE'";
	(my $count) = $dbh->selectrow_array($query);
	return $count;
}

sub getDatabaseFunctionCounts { my ($dbh, $database) = @_ ;
	my $query = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = \'$database\' AND ROUTINE_TYPE = 'FUNCTION'";
	(my $count) = $dbh->selectrow_array($query);
	return $count;
}

sub getTableTriggerCounts { my ($dbh, $database, $table) = @_ ;
	my $query = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS WHERE EVENT_OBJECT_SCHEMA = \'$database\' AND EVENT_OBJECT_TABLE = \'$table\'";
	(my $count) = $dbh->selectrow_array($query);
	return $count;
}

my $nonzero = 0;
$nonzero = $ARGV[0] if (defined($ARGV[0]));

my $databases = list_databases();
print 'Database count: ', scalar(@$databases), "\n";
my $dbh = db_connect();
foreach my $database (@$databases) {
	my $procedures = getDatabaseProcedureCounts($dbh, $database);
	my $functions = getDatabaseFunctionCounts($dbh, $database);
	my $tables = list_tables($database);
	print "$database ", scalar(@$tables), " $procedures $functions\n";
	foreach my $table (@$tables) {
		my $rows = getTableRowCounts($dbh, $database, $table);
		my $triggers = getTableTriggerCounts($dbh, $database, $table);
		if (! $nonzero || $rows || $triggers) {
			print "  $table";
			print " $rows";
			print " $triggers";
			print "\n";
		}
	}
	print "\n";
}
db_disconnect($dbh);

print "Hello World!\n";
