Dedicated Host
==============

SWAMP-in-a-Box is designed to be installed on a dedicated host, one that is
not providing other services (including Apache, MySQL/MariaDB, and HTCondor).


Minimum Hardware Requirements
=============================

  - Memory: 16G
  - Disk:   256G
  - Cores:  4


Supported OSes and Configurations
=================================

CentOS 6 or 7
-------------

  - CentOS Linux 6 and 7 are both supported. Other similar Linux
    distributions, such as Red Hat Enterprise Linux, might work but are
    untested.

  - Allocate as much space as possible to the / partition without deleting or
    shrinking system partitions (e.g., /boot and swap). For example, if there
    is a separate partition for /home, delete it and allocate the space to the
    / partition.

  - Disable SELinux. (Directions are below.)

  - Create a user account with full `sudo` privileges. (Directions are below.)


How to Disable SELinux
======================

As root, add or update /etc/selinux/config to include the following:

    SELINUX=disabled

Then reboot the system.


How to Create a User Account with Full `sudo` Privileges
========================================================

As root, run the following commands to create a new user account
(replace "<username>" with the name of the new account to create):

  - useradd <username>
  - passwd <username> <password for username>

As root, run `visudo`, find the line similar to

    root ALL=(ALL) ALL

and add below it

    <username> ALL=(ALL) ALL
