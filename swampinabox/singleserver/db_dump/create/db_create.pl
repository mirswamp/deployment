#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use Cwd;
use FindBin;
use lib "$FindBin::Bin";
use mysql;

my $mysql = '/usr/bin/mysql';
my $conffile = File::Spec->catfile($FindBin::Bin, 'db_create_fedora.conf');
my $root;
my $cwd = getcwd();

my @swampinabox_setup_files = (
	# user
	File::Spec->catfile('Swamp_on_a_Box', 'user_setup.sql'),

	# sys_exec
	File::Spec->catfile('Data Server', 'sys_exec.sql'),

	# tables
	File::Spec->catfile('Data Server', 'project_tables.sql'),
	File::Spec->catfile('Swamp_on_a_Box', 'swamp_on_a_box_tables.sql'),
	File::Spec->catfile('Data Server', 'Platform Store', 'platform_store_tables.sql'),
	File::Spec->catfile('Data Server', 'Viewer Store', 'viewer_store_tables.sql'),
	File::Spec->catfile('Data Server', 'Tool Shed', 'tool_shed_tables.sql'),
	File::Spec->catfile('Data Server', 'Package Store', 'package_store_tables.sql'),
	File::Spec->catfile('Data Server', 'Assessment', 'assessment_tables.sql'),

	# stored procedures
	File::Spec->catfile('Data Server', 'project_procs.sql'),
	File::Spec->catfile('Data Server', 'Platform Store', 'platform_store_procs.sql'),
	File::Spec->catfile('Data Server', 'Tool Shed', 'tool_shed_procs.sql'),
	File::Spec->catfile('Data Server', 'Package Store', 'package_store_procs.sql'),
	File::Spec->catfile('Data Server', 'Assessment', 'assessment_procs.sql'),
	File::Spec->catfile('Data Server', 'Viewer Store', 'viewer_store_procs.sql'),

	# system data
	File::Spec->catfile('Data Server', 'Assessment', 'populate assessment.sql'),
	File::Spec->catfile('Data Server', 'Package Store', 'populate package_store.sql'),
	File::Spec->catfile('Data Server', 'Platform Store', 'populate platform_store.sql'),
	File::Spec->catfile('Data Server', 'populate_project.sql'),
	File::Spec->catfile('Data Server', 'Tool Shed', 'populate tool_shed.sql'),
	File::Spec->catfile('Data Server', 'Viewer Store', 'populate viewer_store.sql'),

	# swampinabox user
	File::Spec->catfile('Swamp_on_a_Box', 'populate swamp_on_a_box.sql'),

);

my @swampinabox_upgrade_files = (
	# stored procedures
	File::Spec->catfile('Data Server', 'Assessment', 'assessment_procs.sql'),
	File::Spec->catfile('Data Server', 'Package Store', 'package_store_procs.sql'),
	File::Spec->catfile('Data Server', 'Platform Store', 'platform_store_procs.sql'),
	File::Spec->catfile('Data Server', 'project_procs.sql'),
	File::Spec->catfile('Data Server', 'Tool Shed', 'tool_shed_procs.sql'),
	File::Spec->catfile('Data Server', 'Viewer Store', 'viewer_store_procs.sql'),
);

sub run_sql_script { my ($script) = @_ ;
	if (-r $script) {
		print "Executing: $script\n";
		my $result = `$mysql --defaults-file=$conffile < "$script" 2>&1`;
		print "Result: $result\n";
	}
}

sub swampinabox_setup {
	print "\nSwampInABox Database Setup\n";
	foreach my $file (@swampinabox_setup_files) {
		my $script = File::Spec->catfile($root, $file);
		run_sql_script($script);
	}
}

sub swampinabox_upgrade{
	print "\nSwampInABox Database Upgrade\n";
	my $upgrade_dir = File::Spec->catdir($root, 'Data Server', 'upgrades');
	chdir $upgrade_dir;
	my $upgrade_script = File::Spec->catfile($upgrade_dir, 'upgrade_script.sql');
	run_sql_script($upgrade_script);
	chdir $cwd;
	foreach my $file (@swampinabox_upgrade_files) {
		my $script = File::Spec->catfile($root, $file);
		run_sql_script($script);
	}
}

my $upgrade = 0;
foreach my $arg (@ARGV) {
	if ($arg eq '-upgrade') {
		$upgrade = 1;
	}
	elsif ($arg eq '-install') {
		$upgrade = 0;
	}
	else {
		$root = $arg;
	}
}
$root .= '/db';
if (! -d $root) {
	print "$root is not a valid workspace directory - exiting ...\n";
	exit;
}

mysql::start_service('mysql', 0);
if ($upgrade) {
	swampinabox_upgrade();
}
else {
	swampinabox_setup();
}

print "Hello World!\n";
