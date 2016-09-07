SWAMP-in-a-Box is designed to be installed on a dedicated host, one that is
not providing other services (including Apache, MySQL/MariaDB, and HTCondor).


Minimum Hardware Requirements
=============================

- Memory: 8G
- Disk:   256G
- Cores:  2


Supported OSes and Configurations
=================================

Centos 6 or 7
-------------

- CentOS Linux 6 and 7 are both supported.  Other similar Linux
  distributions, such as Red Hat Enterprise Linux, might work but are
  untested.

- Put all disks on the / partition.

- Disable SELinux. (Directions are below.)

- Add a non-root user with full `sudo` privelegs. (Directions are below.)


How to Disable SELinux
======================

As root, add or update /etc/selinux/config to include the following:

    SELINUX=disabled

Then reboot the system.


How to Add a Non-root User with `sudo` priveleges
=================================================

As root, run the following commands to create the user account:

- useradd <non-root user>
- passwd <non-root user> <password for non-root user>

As root, run `visudo`, find the line similar to

    root ALL=(ALL) ALL

and add below it

    <non-root user> ALL=(ALL) ALL
