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
    my @databases = split ' ', $databases;
    @databases = grep(!/$skipdatabases/isxm, @databases);
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

sub getTableColumns { my ($dbh, $database, $table) = @_ ;
	my $query = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = \'$database\' AND TABLE_NAME = \'$table\'";
	my $columns = $dbh->selectcol_arrayref($query);
	my %columns = map { $_ => 1 } @$columns;
	return \%columns;
}

sub getTableUserUUIDs { my ($dbh, $database, $table) = @_ ;
	my $columns = getTableColumns($dbh, $database, $table);
	if (exists($columns->{'user_uuid'}) || exists($columns->{'user_uid'})) {
		my $query = "SELECT DISTINCT user_uuid FROM $database.$table";
	    if (exists($columns->{'user_uid'})) {
			$query = "SELECT DISTINCT user_uid FROM $database.$table";
		}
		my @user_uuids = grep {defined($_)} @{$dbh->selectcol_arrayref($query)};
		return \@user_uuids;
	}
	return [];
}

my $global_user_uuid = '';
$global_user_uuid = $ARGV[0] if (defined($ARGV[0]));

my $databases = list_databases();
my $dbh = db_connect();
foreach my $database (@$databases) {
	print "$database\n";
	my $tables = list_tables($database);
	foreach my $table (@$tables) {
		my $user_uuids = getTableUserUUIDs($dbh, $database, $table);
		if (scalar(@$user_uuids) > 0) {
			if ($global_user_uuid) {
				my $count = 0;
				foreach my $user_uuid (@$user_uuids) {
					$count += 1 if ($user_uuid eq $global_user_uuid);
				}
				print "  $table [", $count, "]\n" if ($count);
			}
			else {
				print "  $table [", scalar(@$user_uuids), "]\n";
				foreach my $user_uuid (@$user_uuids) {
					print "    $user_uuid\n";
				}
			}
		}
	}
	print "\n";
}
db_disconnect($dbh);

print "Hello World!\n";
