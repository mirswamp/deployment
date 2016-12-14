SWAMP-in-a-Box Upgrade Requirements
===================================

- The SWAMP-in-a-Box host must currently have one of the following versions
  of SWAMP-in-a-Box installed:

      - 1.27.1
      - 1.27.2

  Upgrades from earlier versions (e.g., 1.24.0) are not supported.

- The upgrade script must be run as 'root'.

- The upgrade script will prompt you for the database root password.


Significant Changes Introduced by the Upgrade
=============================================

- Configuration settings in /var/www/html/scripts/config.js will NOT be
  preserved by the upgrade script. If you have made any changes to the file,
  e.g., to enable outgoing email, those changes will need to be made to
  /var/www/html/scripts/config/config.js after the upgrade completes.

- All platforms from previous releases of SWAMP-in-a-Box have been
  deprecated. The upgrade script will modify existing assessments to use
  the Ubuntu Linux version 16.04 platform, which is the only platform
  installed with the 1.28.1 release. After the upgrade has completed,
  additional assessment platforms can be installed by following the
  directions below.

- When upgrading from the 1.27.1 release, the Code Dx viewer included with
  that release will be removed during the upgrade because it is no longer
  included with SWAMP-in-a-Box. After the upgrade has completed, the Code Dx
  viewer can be re-installed by following the directions below.

- New features and other changes in the 1.28.1 release can be found in
  /opt/swamp/doc/CHANGELOG.txt on the SWAMP-in-a-Box host after the upgrade
  has completed.


Other Upgrade Notes
===================

- The upgrade script will generate a backup of your database. Specifically,
  the following files will be created in the directory from which you run the
  upgrade:

      - bkup_all_databases.{YYYY_MM_DD}.sql
      - bkup_information_schema.{YYYY_MM_DD}.sql

- Upgrade history and current database version information is stored in the
  database in the XXX.database_version table.


Upgrading SWAMP-in-a-Box
=========================

1. Extract the installer
------------------------

First, move the following files into the same directory (any user's home
directory is sufficient, for example):

  - extract-installer.bash
  - build_swampinabox-src.tar.gz
  - build_swampinabox-tools.tar.gz
  - build_swampinabox-platforms.tar.gz

Second, run extract-installer.bash:

  - cd {the directory where you put the files above}
  - bash extract-installer.bash

When the script completes successfully, it will display the location
of the SWAMP-in-a-Box installer. The remainder of this README will use
{installer-dir} to refer to that directory.


2. Set up the host for SWAMP-in-a-Box
-------------------------------------

The directory {installer-dir}/repos contains scripts that will

  - configure package repositories,
  - install dependencies,
  - enable required services, and
  - create required user accounts

for SWAMP-in-a-Box.

Run the script that corresponds to your SWAMP-in-a-Box host's OS. The
script must be run as 'root'; the commands below use `sudo` to ensure this.

  - sudo {installer-dir}/repos/set-up-CentOS-6.bash
  - sudo {installer-dir}/repos/set-up-CentOS-7.bash


3. Run the SWAMP-in-a-Box upgrade script
----------------------------------------

The directory {installer-dir}/build_swampinabox contains scripts and other
resources for upgrading SWAMP-in-a-Box.

Run the following two commands in order. The upgrade script must be run
with {installer-dir}/build_swampinabox as the current working directory and
as 'root'.

  - cd {installer-dir}/build_swampinabox
  - sudo ./bin/upgrade_swampinabox.bash

The script's output will be saved to a file in {installer-dir}/log, the
exact name of which will be listed at the end of the upgrade. If the
upgrade is unsuccessful, the log will be helpful in determining the cause.


4. Verify that the upgrade was successful
-----------------------------------------

In a web browser, navigate to https://{SWAMP-in-a-Box hostname}.

Sign in with an existing account/user, run an assessment, and view the
results to verify that SWAMP-in-a-Box has been installed successfully.

Sample packages can be found in {installer-dir}/sample_packages.


5. Install and configure additional components
----------------------------------------------

Additional documentation for SWAMP-in-a-Box can be found on the
SWAMP-in-a-Box host in /opt/swamp/doc/SWAMP-in-a-Box. The documentation
includes instructions for:

  - Installing the Code Dx viewer (Install-Code-Dx.txt)
  - Installing additional assessment platforms (Install-additional-platforms.txt)
  - Configuring assessments to run without internet access (Configure-internet-inaccessible-assessments.txt)
  - Configuring outgoing email (Configure-outgoing-email.txt)
  - Configuring properly-signed SSL certifications (Configure-SSL-certificates.txt)


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
