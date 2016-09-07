#!/usr/bin/env perl
use strict;
use warnings;
use Socket;

my $hostname = '';
if (defined($ARGV[0])) {
	$hostname = $ARGV[0];
}
else {
	$hostname = $ENV{HOSTNAME};
}
my $address = '';
if ($hostname) {
	my $aton = inet_aton($hostname);
	if ($aton) {
		$address = inet_ntoa($aton);
	}
	else {
		$address = (split ' ', `hostname -I`)[0];
		my $bogus = 0;
	}
}
print $address || '';
