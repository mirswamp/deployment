#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use FindBin;
use lib "$FindBin::Bin";
use mysql;

my $conffile = File::Spec->catfile($FindBin::Bin, 'db_create.conf');

sub remove_mysql {
	# remove mysql from filesystem
	print "\nRemove /var/lib/mysql/*\n";
	my $result = `\\rm -rf /var/lib/mysql/* 2>&1`;
	print "rm -rf /var/lib/mysql/*: $result\n";
	if ($result) {
		print "rm -rf /var/lib/mysql/* - error - exiting ...\n";
		exit 1;
	}
}

sub install_mysql {
	# install mysql to filesystem
	print "\nInstall initial mysql db\n";
	my $result = `mysql_install_db --user=mysql 2>&1`;
	print "mysql_install_db --user=mysql: $result\n";
}

sub secure_mysql { my ($password) = @_ ;
	# secure mysql installation
	print "\nSecure mysql installation\n";
	if (open my $fh, "|-", "mysql_secure_installation") {
		print $fh <<EOF;

y
$password
$password
y
n
y
y
EOF
		close $fh;
	}
}

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

sub set_mysql_sys_functions {
	# set mysql sys_exec and sys_eval from lib_mysqludf_sys.so
	print "\nSet sys_exec and sys_eval\n";
	my $result = `mysql --defaults-file=$conffile -e "CREATE FUNCTION sys_exec RETURNS INT SONAME 'lib_mysqludf_sys.so'" 2>&1`;
	print "mysql CREATE FUNCTION sys_exec: $result\n";
	if ($result) {
		print "mysql CREATE FUNCTION sys_exec - error - exiting ...\n";
		exit 1;
	}
	$result = `mysql --defaults-file=$conffile -e "CREATE FUNCTION sys_eval RETURNS STRING SONAME 'lib_mysqludf_sys.so'" 2>&1`;
	print "mysql CREATE FUNCTION sys_eval: $result\n";
	if ($result) {
		print "mysql CREATE FUNCTION sys_eval - error - exiting ...\n";
		exit 1;
	}
}

sub usage {
	print "usage: $0 [-help -verbose -debug -password <string> -mysql mysql|mariadb]\n";
	exit;
}

my $mysql;
my $password;

my $help = 0;
my $verbose = 0;
my $debug = 0;
my $result = GetOptions(
	'help'		=> \$help,
	'verbose'	=> \$verbose,
	'debug'		=> \$debug,
	'password=s'	=> \$password,
	'mysql=s'	=> \$mysql,
);
usage if (! $result || $help);
$mysql = 'mysql' if (! defined($mysql));
$password = 'swamponabox' if (! defined($password));

mysql::stop_service($mysql, $verbose);
remove_mysql();
install_mysql();
mysql::start_service($mysql, $verbose);
secure_mysql($password);
set_mysql_sys_functions();

print "Hello World!\n";
