#!/usr/bin/env perl
use strict;
use warnings;
use POSIX qw(strftime);

sub patch_line { my ($file, $key, $value, $which) = @_ ;
	if (open(my $fh, '<', $file)) {
		my @lines = <$fh>;
		close($fh);
		my $date = strftime("%Y%m%d%H%M%S", localtime());
		system('cp', '-p', $file, $file . ".${date}");
		if (open(my $fh, '>>', $file)) {
			truncate($fh, 0);
			seek($fh, 0, 0);
			foreach my $line (@lines) {
				if ($line =~ m/$key/sxm) {
					if ($which eq 'token') {
						$line =~ s/$key/$value/;
					}
					else {
						if ($line =~ m/=\s+/) {
							$line =~ s/=.*/= $value/;
						}
						else {
							$line =~ s/=.*/=$value/;
						}
					}
				}
				print $fh $line;
			}
			close($fh);
		}
	}
}

sub patch_token { my ($file, $key, $value) = @_ ;
	patch_line($file, $key, $value, 'token');
}

sub patch_value { my ($file, $key, $value) = @_ ;
	patch_line($file, $key, $value, 'value');
}

my $patch_token = $ARGV[0];

#
# swamp.conf is interpreted by the java.util.Properties class.
# Therefore, backslashes in the password need to be escaped.
#
# https://docs.oracle.com/javase/7/docs/api/java/util/Properties.html
#
print "Patching swamp.conf dbQuartermasterPass\n";

my $javapassword = `openssl enc -d -aes-256-cbc -in /etc/.mysql_java  -pass pass:swamp`;
chomp $javapassword;
$javapassword =~ s{\\}{\\\\}smg;
patch_value('/opt/swamp/etc/swamp.conf', '^dbQuartermasterPass', $javapassword);


#
# Passwords may be stored as-is in the Laravel environment file.
#
my $webpassword = `openssl enc -d -aes-256-cbc -in /etc/.mysql_web  -pass pass:swamp`;
chomp $webpassword;
if ($patch_token) {
	print "Patching swamp-web-server PATCH_WEBPASSWORD\n";
	patch_token('/var/www/swamp-web-server/.env', 'PATCH_WEBPASSWORD', $webpassword);
}
else {
	print "Patching swamp-web-server *DB_PASSWORD\n";
	patch_value('/var/www/swamp-web-server/.env', '^.*DB_PASSWORD', $webpassword);
}
