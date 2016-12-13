SWAMP-in-a-Box Upgrade
======================

- The upgrade script must be run as root.

- The upgrade script will prompt you for the database root password.

- The upgrade script will preserve configuration settings in the following:

      - /var/www/swamp-web-server/.env
      - /var/www/html/scripts/config.js
      - /opt/swamp/etc/swamp.conf

- The upgrades script will generate a backup of your database. Specifically,
  the following files will be created in the directory from which you run the
  upgrade:

      - bkup_all_databases.{YYYY_MM_DD}.sql
      - bkup_information_schema.{YYYY_MM_DD}.sql

- The upgrade script preserves your existing data.

- Upgrade history and current database version information is stored in the
  database in the database_version table.

- If your SWAMP-in-a-Box installation included the Code DX viewer provided in
  the 1.27.1 SWAMP-in-a-Box beta release, the Code DX viewer will be removed.
  For instructions on installing Code DX after the upgrade, refer to:
  /opt/swamp/doc/SWAMP-in-a-Box/Install-Code-Dx.txt


Upgrading SWAMP-in-a-Box
=========================

1. Extract the installer
------------------------

First, move the following files into the same directory (a non-root user's
home directory is sufficient):

  - extract-installer.bash
  - build_swampinabox-src.tar.gz
  - build_swampinabox-tools.tar.gz
  - build_swampinabox-platformsA.tar.gz
  - build_swampinabox-platformsB.tar.gz

Second, run extract-installer.bash:

  - cd {the directory where you put the files above}
  - ./extract-installer.bash

When the script completes successfully, it will display the location of the
SWAMP-in-a-Box installer.  The remainder of this README will use
{installer-dir} to refer to that directory.


2. Set up the host for SWAMP-in-a-Box
-------------------------------------

The directory {installer-dir}/repos contains scripts that will

  - configure package repositories,
  - install dependencies,
  - enable required services, and
  - create required user accounts

for SWAMP-in-a-Box.

As root, run the script that corresponds to your SWAMP-in-a-Box host's OS:

  - sudo {installer-dir}/repos/set-up-CentOS-6.bash
  - sudo {installer-dir}/repos/set-up-CentOS-7.bash


3. Run the SWAMP-in-a-Box upgrade script
----------------------------------------

The SWAMP-in-a-Box upgrade script must be run as root with
{installer-dir}/build_swampinabox as the current working directory.

  - cd {installer-dir}/build_swampinabox
  - sudo ./bin/upgrade_swampinabox.bash

The script's output will be saved to a file in {installer-dir}/log, the
exact name of which will be listed at the end of the upgrade.  If the
upgrade is unsuccessful, the log will be helpful in determining the cause.


4. Verify that the upgrade was successful
------------------------------------------

In a web browser, navigate to https://{SWAMP-in-a-Box hostname}.

Sign in with an existing account/user.

Sample packages can be found in {installer-dir}/SwampPackages.

Upload a package, run a new assessment against it, and view the results
to verify that SWAMP-in-a-Box has been installed successfully.


Monitoring the Health of SWAMP-in-a-Box
=======================================

The directory {installer-dir}/build_swampinabox/health_scripts contains Perl
scripts that are helpful in diagnosing certain problems with SWAMP-in-a-Box.
In particular, swamphealth.pl will indicate the status of SWAMP-in-a-Box's
various components.

The scripts must be run using the version of Perl installed with
SWAMP-in-a-Box in /opt/perl5/perls/perl-5.18.1. We recommend adding

    /opt/perl5/perls/perl-5.18.1/bin

to your PATH before running these scripts.
