Installing SWAMP-in-a-Box
-------------------------


Before You Begin
~~~~~~~~~~~~~~~~

- You will need `root` access to the SWAMP-in-a-Box host.

- The install script will prompt for the DNS hostname to use for the host.
  It must match the hostname that users will use to access the SWAMP web
  application *and* the hostname on the SSL certificates for the host's web
  server.

- The install script will prompt for the initial values to use for the
  following passwords, which can then be used to access the SWAMP web
  application and database that are installed as part of SWAMP-in-a-Box:

  * Database `root` password: SWAMP-in-a-Box uses MariaDB as its database
    backend. This is the password for the database's `root` user's password.
    It may be different from the host operating system's `root` user's
    password because the database maintains its own collection of user
    accounts. *This password is required to upgrade SWAMP-in-a-Box and reset
    the passwords below.*

  * Database web password: This is the password used internally by the SWAMP
    web application's backend to connect to the database.

  * Database SWAMP services password: This is the password used by several
    of SWAMP-in-a-Box's system daemons to connect to the database.

  * SWAMP administrator account password: This is the password
    for the SWAMP web application's `admin-s` account, which is created
    during the install process for administering the SWAMP.


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


Run the Main SWAMP-in-a-Box Install Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As `root` (or using `sudo`), run `install_swampinabox.bash`:

----
$ <installer-dir>/bin/install_swampinabox.bash
----

The script will prompt you for the hostname and passwords listed above.

The script's output will be saved to a file in `<installer-dir>/log`, the
exact name of which will be listed at the end of the install. If the install
is unsuccessful, the log will be helpful in determining the cause.


Verify that the Install Was Successful
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
