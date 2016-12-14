SWAMP-in-a-Box Install Requirements
===================================

  - The host must meet the requirements outlined in README-BUILD-SERVER.md.

  - The installation script must be run as 'root'.

  - The installation script will prompt for the initial values to use for
    the following passwords, which can then be used to access the web
    application and backend database that are installed as part of
    SWAMP-in-a-Box:

      - Database root password: SWAMP-in-a-Box uses MariaDB as its database
        backend. This is the password for the database root user's password,
        which can be different from the password for the host's 'root' user.

        *** REMEMBER THIS PASSWORD. ***

        Without this password, you will not be able to upgrade SWAMP-in-a-Box
        or reset any of the other passwords used by the various components of
        SWAMP-in-a-Box (see below).

      - Database web password: This is the password used by SWAMP-in-a-Box's
        web server to connect to the database.

      - Database SWAMP services password: This is the password used by several
        of SWAMP-in-a-Box's system daemons to connect to the database.

      - SWAMP-in-a-Box administrator account password: This is the password
        for SWAMP-in-a-Box's 'admin-s' account, which is created during the
        installation process and can be used to administer the application.


Installing SWAMP-in-a-Box
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


3. Run the SWAMP-in-a-Box install script
----------------------------------------

The directory {installer-dir}/build_swampinabox contains scripts and other
resources for installing SWAMP-in-a-Box.

Run the following two commands in order. The install script must be run
with {installer-dir}/build_swampinabox as the current working directory and
as 'root'.

  - cd {installer-dir}/build_swampinabox
  - sudo ./bin/install_swampinabox.bash

The script's output will be saved to a file in {installer-dir}/log, the
exact name of which will be listed at the end of the install. If the
install is unsuccessful, the log will be helpful in determining the cause.


4. Verify that the install was successful
-----------------------------------------

In a web browser, navigate to https://{SWAMP-in-a-Box hostname}.

Sign in with the administrator account/user:

  - Username: admin-s
  - Password: {the one entered during the install}

Sample packages can be found in {installer-dir}/sample_packages.

Upload a package, run a new assessment against it, and view the results
to verify that SWAMP-in-a-Box has been installed successfully.


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
