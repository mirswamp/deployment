Upgrading SWAMP-in-a-Box
------------------------


Significant Changes Introduced by Upgrading
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Changes that users of the SWAMP will see in this release of SWAMP-in-a-Box,
such as new features and significant bug fixes, can be found in
`/opt/swamp/doc/CHANGELOG.txt` on the SWAMP-in-a-Box host after the upgrade
has completed.

Changes and "gotchas" that are more relevant to the administrators of the
SWAMP and SWAMP-in-a-Box host are listed below by the release they were
introduced in.

.Changes Introduced in 1.29:

  - The configuration settings in `/var/www/html/scripts/config/config.js`
    will not be preserved. Any customizations, e.g., to enable outgoing
    email, will need to be made in `/var/www/html/config/config.json` after
    the upgrade completes.

.Changes Introduced in 1.28.*:

  - Minimum hardware requirements have increased to 4 CPU cores and 16 GB of
    RAM.

  - The configuration settings in `/var/www/html/scripts/config.js` will not
    be preserved. Any customizations, e.g., to enable outgoing email, will
    need to be made in `/var/www/html/config/config.json` after the upgrade
    completes.

  - All existing platforms will be removed and replaced with Ubuntu 16.04.
    Existing assessments will be modified to use Ubuntu 16.04.

.Changes Introduced in 1.27.2:

  - The Code Dx viewer that was included with earlier releases of
    SWAMP-in-a-Box will be removed because it is no longer included with
    SWAMP-in-a-Box.


Before You Begin
~~~~~~~~~~~~~~~~

- You will need `root` access to the SWAMP-in-a-Box host.

- You will need `root` access to the SWAMP-in-a-Box database.

- The SWAMP-in-a-Box host must currently have version 1.27.1 or later of
  SWAMP-in-a-Box installed. Upgrades from earlier versions are not supported
  and will likely result in a non-working system.


Obtain the SWAMP-in-a-Box Installer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Visit https://github.com/mirswamp/deployment for instructions on how to
download SWAMP-in-a-Box as a pre-packaged installer, which is what the
instructions below assume you are working with.


Extract the Installer
~~~~~~~~~~~~~~~~~~~~~

On the SWAMP-in-a-Box host, move or copy the following files into the same
directory (any user's home directory is sufficient, for example):

  - `extract-installer.bash`
  - `swampinabox-<version>-installer.tar.gz`
  - `swampinabox-<version>-platforms.tar.gz`
  - `swampinabox-<version>-tools.tar.gz`

Then run `extract-installer.bash`:

----
$ cd <the directory where you put the files above>
$ bash extract-installer.bash
----

When the script completes successfully, it will display the location of the
SWAMP-in-a-Box installer. The instructions below will use `<installer-dir>`
to refer to that directory.


Install SWAMP-in-a-Box's Dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The directory `<installer-dir>/repos` contains set up scripts that will

  - configure package repositories,
  - install dependencies,
  - enable required services, and
  - create required user accounts.

Even if you have gone through this step on the SWAMP-in-a-Box host for
a previous release of SWAMP-in-a-Box, it is important to run the scripts for
the current release as they will ensure that the correct versions of
SWAMP-in-a-Box's dependencies are installed.

If your host has unrestricted access to the internet, as `root` (or using
`sudo`), run the `install-all.bash` script corresponding to you host's OS:

----
$ <installer-dir>/repos/CentOS-6/install-all.bash

    ...or...

$ <installer-dir>/repos/CentOS-7/install-all.bash
----

If your host has restricted access to the internet, see
README-DEPENDENCIES.md for a list of SWAMP-in-a-Box's dependencies so that
you can determine how best to install them on the host.


Run the Main SWAMP-in-a-Box Upgrade Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As `root` (or using `sudo`), run `upgrade_swampinabox.bash`:

----
$ <installer-dir>/bin/upgrade_swampinabox.bash
----

The script will prompt you for the database's `root` user's password and
create a backup of the SWAMP's database before making any modifications to
it. Specifically, the following files will be created in the directory from
which you run the upgrade:

  - `bkup_all_databases.<YYYY_MM_DD>.sql`
  - `bkup_information_schema.<YYYY_MM_DD>.sql`

The script's output will be saved to a file in `<installer-dir>/log`, the
exact name of which will be listed at the end of the install. If the install
is unsuccessful, the log will be helpful in determining the cause.


Verify that the Upgrade Was Successful
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. In a web browser, navigate to +https://<SWAMP-in-a-Box hostname>+.

2. Sign in with the administrator account/user:

  - Username: admin-s
  - Password: <the one entered during the install>

3. Upload a package, create and run a new assessment of it, and view the
   results. Sample packages can be found in `<installer-dir>/sample_packages`;
   see the `README.txt` file in that directory for more information.


Install and configure additional components
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Additional documentation for SWAMP-in-a-Box can be found on the
SWAMP-in-a-Box host in `/opt/swamp/doc/SWAMP-in-a-Box`. The documentation
includes instructions for:

  - Installing add ons (additional assessment platforms, Code Dx, Code Sonar)
  - Configuring assessments to run without internet access
  - Configuring outgoing email
  - Configuring properly-signed SSL certifications
