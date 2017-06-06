System Requirements
-------------------

SWAMP-in-a-Box is designed to be installed on a dedicated host, one that is
not providing other services (including Apache, MySQL/MariaDB, and HTCondor).


Hardware Requirements
~~~~~~~~~~~~~~~~~~~~~

.Minimum:

  - Memory: 16G
  - Disk:   256G
  - Cores:  4

.Recommended:

  - Memory: 64G
  - Disk:   1T
  - Cores:  8

SWAMP-in-a-Box uses virtual machines managed by an HTCondor pool to perform
assessments of packages and to run the optional Code Dx results viewer from
Code Dx, Inc. Each virtual machine is provisioned with 6G of RAM and 1 core.
The minimum requirements above are intended to allow the host machine to run
two virtual machines simultaneously while leaving resources available to run
the web server and database that together provide the SWAMP web application
to users.


Supported Operating Systems
~~~~~~~~~~~~~~~~~~~~~~~~~~~

CentOS 6 and 7 are both supported. Other similar Linux distributions, such
as Red Hat Enterprise Linux, might work but are untested.

If you are installing SWAMP-in-a-Box in a virtual machine, the hypervisor
must support and be configured for nested virtualization because
SWAMP-in-a-Box itself uses virtual machines to perform assessments of
packages and to run the optional Code Dx results viewer from Code Dx, Inc.


Supported Disk Partitioning Schemes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As much space as possible should be allocated to the `/` partition without
deleting or shrinking required system partitions, e.g., `/boot` and `swap`.
For example, if there is a separate partition for `/home`, delete it and
allocate the space to the `/` partition.


Disable SELinux
~~~~~~~~~~~~~~~

SWAMP-in-a-Box will not install or function correctly when SELinux is in
`enforcing` mode, in part because the various software packages that
SWAMP-in-a-Box relies on do not all support SELinux.

To disable SELinux, add or update `/etc/selinux/config` to include the
following line (you will need `root` privileges to edit the file):

----
SELINUX=disabled
----

Then reboot the system.


Create a User Account with Full `sudo` Privileges
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We recommend creating a normal user account with full `sudo` privileges so
that the SWAMP-in-a-Box system can be administered without necessarily being
logged in as `root` all the time. To create such an account (in the steps
below, replace `<username>` with the name of the new account to create):

1. Log in as `root`.

2. Run the following three commands:
+
----
$ useradd <username>
$ passwd <username>
...enter a new password when prompted...
$ visudo
...see next step below...
----

3. The `visudo` command will start a session of the `vi` text editor, where
you can edit the `sudoers` file. Find the line similar to
+
----
root ALL=(ALL) ALL
----
+
Add below it
+
----
<username> ALL=(ALL) ALL
----

Whenever a task requires `root` access to the SWAMP-in-a-Box host, it can be
run while logged in as the user created above by prefixing the relevant
commands with `sudo`. For example:

----
$ sudo <command>
$ sudo vi /opt/swamp/bin/swamp.conf
----


Configure Firewalls
~~~~~~~~~~~~~~~~~~~

With regards to network traffic, the SWAMP-in-a-Box host is expected to:

  - Respond to incoming HTTPS (port 443) network traffic, as it is required
    to access the SWAMP web application and for the web application to
    function correctly.

  - Potentially generate outgoing traffic while performing an assessment of
    a package. Traffic can include updating of the platform's currently
    installed set of packages (this can be disabled, if desired) and
    downloading of user-specified dependencies for the package being
    assessed. The package's build system might also require access to the
    internet.

Any firewall(s) protecting the SWAMP-in-a-Box host must be configured to
allow the above network traffic. The SWAMP-in-a-Box installer will not
modify the host's firewall configuration.


==== `iptables` ====

For systems that use `iptables`, such as CentOS 6 by default, a sample
configuration file can be found in the `config_templates` directory of the
SWAMP-in-a-Box installer. Copy the `iptables` file from that directory to
`/etc/sysconfig`. Then restart the `iptables` service. For example, as
`root` (or using `sudo`):

----
$ cp <installer-dir>/config_templates/iptables /etc/sysconfig
$ service iptables restart
----


==== `firewalld` ====

For systems that use `firewalld`, such as CentOS 7 by default, use
`firewall-cmd` to permanently allow HTTPS traffic. Then restart the
`firewalld` service. For example, as `root` (or using `sudo`):

----
$ firewall-cmd --zone=public --permanent --add-service=https
$ systemctl restart firewalld
----
