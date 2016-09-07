#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use FindBin;
use File::Basename;
use File::Copy qw(copy);
use File::stat;
use POSIX qw(strftime);
use Term::ANSIColor;

sub update_source_files { my ($srcpath, $dstpath, $diff, $update) = @_ ;
	my $ls = length($srcpath);
	my $ld = length($dstpath);
	my $lm = $ls;
	$lm = $ld if ($ld > $ls);
    print '=' x $lm, "====\n";
    print "= $srcpath", ' ' x ($lm - $ls), " =\n";
    print "= $dstpath", ' ' x ($lm - $ld), " =\n";
    print '=' x $lm, "====\n";
	my @dstfiles = `find $dstpath -type f`;
	chomp @dstfiles;
	foreach my $dstfile (@dstfiles) {
		my $file = basename($dstfile);
		my $dir = dirname($dstfile);
		my @srcfiles = `find $srcpath -name $file`;
		chomp @srcfiles;
		foreach my $srcfile (@srcfiles) {
			my $srctime = stat($srcfile)->mtime;
			my $dsttime = stat($dstfile)->mtime;
			if ($srctime > $dsttime) {
				print '#' x length($file), "####\n";
				print "# $file #\n";
				print '#' x length($file), "####\n";

				my $srcdate = strftime("%Y-%m-%d %H:%M:%S", localtime($srctime));
				print color('green');
				print "$srcfile $srcdate\n";
				my $dstdate = strftime("%Y-%m-%d %H:%M:%S", localtime($dsttime));
				print color('red');
				print "$dstfile $dstdate\n";
				print color('reset');

				print '-' x (length($dstfile) + length($dstdate) + 1), "\n";

				my $result;
				if ($diff) {
					$result = `diff -w $srcfile $dstfile`;
					print $result, "\n\n\n";
				}

				next if (! $update);
				print "Replace $dstfile with $srcfile ";
				my $answer = <STDIN>;
				next if ($answer !~ m/Y|y/);
				$result = copy($srcfile, $dstfile);
				if (! $result) {
					print "Error in $srcfile copy: $!\n";
					next;
				}
				if ($dstfile =~ m/swamp\.conf$/) {
					print "Patching: $dstfile\n"; 
					$result = `diff -wu /opt/swamp/etc/swamp.conf $FindBin::Bin/../swamponabox_web_config/swamp.conf | sed -e "s/SED_HOSTNAME/$ENV{'HOSTNAME'}/" | patch /opt/swamp/etc/swamp.conf`;
					print "Patch result: $result\n";
					$result = `diff -w $srcfile $dstfile`;
					print $result, "\n\n\n";
				}
			}
		}
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose -diff -update] username\n";
	exit;
}

usage() if (! @ARGV);

my $help = 0;
my $debug = 0;
my $verbose = 0;
my $diff = 0;
my $update = 0;
my $result = GetOptions(
	'help'		=> \$help,
	'debug'		=> \$debug,
	'verbose'	=> \$verbose,
	'diff'		=> \$diff,
	'update'	=> \$update,
);
usage() if ($help || ! $result);
my $username = $ARGV[0] if (defined($ARGV[0]));
usage() if (! $username);

# perl backend code
my $srcpath = "/home/$username/swamp/services";
my $dstpath = '/opt/swamp';
update_source_files($srcpath, $dstpath, $diff, $update);

# deployment support code
$srcpath = "/home/$username/swamp/deployment/DenimGroup";
$dstpath = '/opt/swamp/thirdparty/threadfix';
update_source_files($srcpath, $dstpath, $diff, $update);
$srcpath = "/home/$username/swamp/deployment/SecureDecisions";
$dstpath = '/opt/swamp/thirdparty/codedx';
update_source_files($srcpath, $dstpath, $diff, $update);
$srcpath = "/home/$username/swamp/deployment/Common";
$dstpath = '/opt/swamp/thirdparty/common';
update_source_files($srcpath, $dstpath, $diff, $update);

# /usr/local/bin database entry points
$srcpath = "/home/$username/swamp/services";
$dstpath = '/usr/local/bin';
update_source_files($srcpath, $dstpath, $diff, $update);

