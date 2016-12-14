#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;
# use Regexp::Common qw(net);
use FindBin;
use lib "$FindBin::Bin";
use mysql;

my $conffile = File::Spec->catfile($FindBin::Bin, 'db_create.conf');

# NOT USED
sub set_mysql_root_password { my ($password) = @_ ;
	# set mysql server root password
	print "\nSet mysql server root password\n";
	my $result = `mysqladmin --defaults-file=$conffile password $password 2>&1`;
	print "mysqladmin --defaults-file=$conffile password $password: $result\n";
	if ($result) {
		print "mysqladmin -u root -p password $password - error - exiting ...\n";
		exit 1;
	}
}

sub set_mysql_remote_root_password { my ($host, $password) = @_ ;
	# set mysql server root user and password for remote host
	print "\nSet mysql server root password for $host\n";
	my $result = `mysql --defaults-file=$conffile -e "CREATE USER \'root\'@\'$host\' IDENTIFIED BY \'$password\'" 2>&1`;
	print "mysql CREATE USER: $result\n";
	if ($result) {
		print "mysql CREATE USER - error - exiting ...\n";
		exit 1;
	}
}

sub grant_mysql_remote_root_permissions { my ($host) = @_ ;
	# grant permmissions for root at remote host
	print "\nGrant permissions for root @ $host\n";
	my $result = `mysql --defaults-file=$conffile -e "GRANT ALL PRIVILEGES ON *.* TO \'root\'@\'$host\'" 2>&1`;
	print "mysql GRANT ALL: $result\n";
	if ($result) {
		print "mysql GRANT ALL - error - exiting ...\n";
		exit 1;
	}
}

sub usage {
	print "usage: $0 [-help -verbose -debug -name <host name | ip address> -host <host name to look up> -password <string> -mysql mysql|mariadb]\n";
	exit;
}

my $mysql;
my $host;
my $name;
my $password;

my $help = 0;
my $verbose = 0;
my $debug = 0;
my $result = GetOptions(
	'help'		=> \$help,
	'verbose'	=> \$verbose,
	'debug'		=> \$debug,
	'host=s'	=> \$host,
	'name=s'	=> \$name,
	'password=s'=> \$password,
	'mysql=s'	=> \$mysql,
);
usage if (! $result || $help);
usage if (! $host && ! $name);
$mysql = 'mysql' if (! defined($mysql));
$password = 'swamponabox' if (! defined($password));

mysql::start_service($mysql, $verbose);
if ($host) {
	my $ip = `host $host | cut -f4 -d ' '`;
	chomp $ip;
	# if ($ip =~ $RE{net}{IPv4}) {
		set_mysql_remote_root_password($ip, $password);
		grant_mysql_remote_root_permissions($ip);
	# }
	# else {
		# print "Error - $host ip address lookup failed\n";
		# usage();
	# }
}
elsif ($name) {
	set_mysql_remote_root_password($name, $password);
	grant_mysql_remote_root_permissions($name);
}
print "Hello World!\n";
