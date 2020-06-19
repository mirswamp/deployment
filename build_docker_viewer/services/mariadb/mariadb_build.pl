#!/usr/bin/env perl

# This script is only used during the bulding of the container or VM.
#
system("systemctl start mariadb");
sleep 5;
sub secure_mysql { my ($password) = @_ ;
        # secure mysql installation
        print "\nSecure mysql installation\n";
        if (open my $fh, "|-", "mysql_secure_installation") {
                print $fh <<EOF;

y
$password
$password
y
y
y
y
EOF
                close $fh;
        }
}

my $passwordfile = '/root/.mariadb.pw';
$mypass = `cat $passwordfile`; 
chomp $mypass;
secure_mysql($mypass);

system("mysql --user='root' --password=\"$mypass\" mysql < /root/emptydb-mysql-codedx.sql");

# reset root password
system("mysqladmin --user='root' --password=\"$mypass\" flush-privileges");
system("mysqladmin --user='root' --password='m\@r1ad8l3tm31n' password $mypass");
system("mysqladmin --user='root' --password=\"$mypass\" flush-privileges");

# flush privileges
system("mysql --user='root' --password=\"$mypass\" mysql < /root/flushprivs.sql");

# drop and create viewer database
system("mysql --user='root' --password=\"$mypass\" < /root/resetdb-codedx.sql");

# load empty database
system("mysql --user='root' --password=\"$mypass\" codedx < /root/emptydb-codedx.sql");

system("systemctl stop mariadb");
