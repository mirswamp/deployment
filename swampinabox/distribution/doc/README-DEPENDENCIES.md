Software that SWAMP-in-a-Box depends on
=======================================

The software that SWAMP-in-a-Box depends on can be divided into four
categories, all of which must be installed for SWAMP-in-a-Box to function
correctly.


HTCondor 8.4.11
---------------

The set up scripts configure and download HTCondor from the repository
hosted by the University of Wisconsin-Madison, generally following the
instructions provided on the project's home page:

    https://research.cs.wisc.edu/htcondor/index.html

The specific packages installed are 'condor-all' and its dependencies.

The following OS-dependent scripts will install HTCondor using the process
described above:

  - {installer-dir}/repos/CentOS-6/install-htcondor.bash
  - {installer-dir}/repos/CentOS-7/install-htcondor.bash


MariaDB 5.5.*
-------------

Under CentOS 6, the set up scripts configure and download MariaDB from the
repository hosted by the MariaDB Foundation, using the configuration file
produced by the "repository configuration" tool at

    https://downloads.mariadb.org/mariadb/repositories/

The specific packages installed are 'MariaDB-server', 'MariaDB-client',
and their dependencies.

Under CentOS 7, the set up scripts download MariaDB from CentOS's default
repositories.

The following OS-dependent scripts will install MariaDB using the process
described above:

  - {installer-dir}/repos/CentOS-6/install-mariadb.bash
  - {installer-dir}/repos/CentOS-7/install-mariadb.bash


PHP 7.0.*
---------

The set up scripts configure and download PHP from Remi's RPM Repository,
using the instructions produced by the "configuration wizard" at

    http://rpms.famillecollet.com/

The specific packages installed are 'php', 'php-mbstring', 'php-mcrypt',
'php-mysqlnd', 'php-pecl-zip', 'php-xml', and their dependencies.

The following OS-dependent scripts will install PHP using the process
described above:

  - {installer-dir}/repos/CentOS-6/install-php.bash
  - {installer-dir}/repos/CentOS-7/install-php.bash


Other assorted utilities
------------------------

Various software packages that can be found in CentOS's default repositories
(and their dependencies):

  - ant
  - bind-utils
  - git
  - httpd
  - libguestfs
  - libguestfs-tools
  - libguestfs-tools-c
  - libvirt
  - mod_ssl
  - ncompress
  - patch
  - perl
  - zip

he following script will install these packages and perform additional,
necessary configuration of the host. It must be run after HTCondor, MariaDB,
and PHP are installed, as described above.

  - {installer-dir}/repos/common/install-and-configure-deps.bash
