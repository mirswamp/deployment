SWAMP-in-a-Box System Requirements
==================================

- The host must meet the requirements outlined in README-BUILD-SERVER.md.

- The installation script must be run as root.

- The installation script will prompt you for the following:

      - Database root password: SWAMP-in-a-Box uses MariaDB as its database
        backend. This is the password for the database root user's password,
        which can be different from the password for the host OS's root user.

        *** REMEMBER THIS PASSWORD. ***

        Without this password, you will not be able to upgrade SWAMP-in-a-Box
        or reset any of the other passwords used by the various components of
        SWAMP-in-a-Box (see below).

      - Database web password: This is the password used by SWAMP-in-a-Box's
        web server to connect to the database.

      - Database SWAMP services password: This is the password used by several
        of SWAMP-in-a-Box's system daemons to connect to the database.

      - SWAMP-in-a-Box admininistrator account password: This is the
        password for SWAMP-in-a-Box's `admin-s` account, which is created
        during the installation process and can be used to administer the
        SWAMP-in-a-Box application.


Installing SWAMP-in-a-Box
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


3. Run the SWAMP-in-a-Box install script
----------------------------------------

The SWAMP-in-a-Box install script must be run as root with
{installer-dir}/build_swampinabox as the current working directory.

We recommend using tee to save the output from the script into a log file.
If the install is unsuccessful, the log will be helpful in determining the
cause.

  - cd {installer-dir}/build_swampinabox
  - sudo ./bin/install_swampinabox.bash |& tee ../log/install_swampinabox_00.log


4. Verify that installation was successful
------------------------------------------

In a web browser, navigate to https://{SWAMP-in-a-Box hostname}.

Sign in with the admininstrator account/user:

  - Username: admin-s
  - Password: {the one entered during the install}

Sample packages can be found in {installer-dir}/SwampPackages.

Upload a package, run a new assessment against it, and view the results
using the native and CodeDx viewers to verify that SWAMP-in-a-Box has been
installed successfully.


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
