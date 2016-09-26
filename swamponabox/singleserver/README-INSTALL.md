Clone Git Working Directory
---------------------------
as <username>, create /home/<username>/swamp directory
cd to /home/<username>/swamp
execute build_swampinabox/bin/git_clone.bash

Install SWAMPINABOX
-------------------
become root (sudo -i), execute install_swampinabox.bash <username>
build_swampinabox/bin/install_swampinabox.bash <username> |& tee build_swampinabox/log/install_swampinabox_`hostname -s`_<dd>.log

Checkout Updated Source to Git Working Directory
------------------------------------------------
as <username>
cd /home/<username>/swamp
build_swampinabox/bin/git_checkout.pl

Upgrading SWAMPINABOX
---------------------
become root (sudo -i), execute upgrade_swampinabox.bash
build_swampinabox/bin/upgrade_swampinabox.bash <username> |& tee build_swampinabox/log/upgrade_swampinabox_`hostname -s`_<dd>.log

Developing SWAMP/SWAMPINABOX
----------------------------
The git working directory is intended to be used as a development repository such that development code can be 
installed into SWAMPINABOX to test before committing to the git working directory or pushing to the GitLab depo.
To this end, make changes in the git working directory, use the update_source_files.pl script to copy changes into
the appropriate SWAMPINABOX directories (such as /opt/swamp/bin), execute SWAMPINABOX to test and iterate as
necessary.  When iterative development is complete, commit changes to git working directory and push to GitLab
depo.

SWAMP Health
------------
The following scripts are available to help determine the health of the SWAMPINABOX installation.
swamphealth.pl	- script has various command line arguments including -h for help.  The -all argument will show the 
the status of all components involved in execution.
guestfish.pl	- script allows for pulling out files from a libvirt vm (arun and vrun).  This is useful for 
obtaining current information pertaining to the execution of the vm.
viewerstate.pl	- script displays the contents of the .viewerinfo file that contains state information about vms.

Miscellaneous
-------------
To just upgrade the perl and java backend code after a git working dir pull
become root, (sudo -i)
build_swampinabox/bin/upgrade_backend.bash <username>

To show branch names in git working dir projects (you should ALWAYS be on the develop branch)
as <username>
cd /home/<username>/swamp
build_swampinabox/bin/show_git_branches.pl
