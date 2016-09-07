Initial setup instructions for swamponabox

(1)	Obtain a user login with a home directory and access to a root login (via sudo -i) on the swamponabox
	operating system.

(2)	Confirm that git is installed on the swamponabox hardware.  Use yum install git to either confirm or
	perform the install.

(3)	Establish an ssh key for git clone authorization on the GitLab depo.
	ssh-keygen (accept all defaults)
	cat /home/<username>/.ssh/id_rsa.pub
	copy the output produced from above command to paste into GitLab ssh key
	open GitLab in your browser and direct to your user profile settings
	select the SSH Keys tab and then Add SSH Key
	paste the above output into the Key field; the title may or may not be auto filled

At this point the swamponabox git repository (project) contains the installation scripts and README-INSTALL.md with
complete instructions.  It also contains MANIFEST.md which lists the contents of the swamponabox project giving
a description of each script.

#########################
#	Quick Start	#
#########################

There are three steps to installation of swamponabox. 
Determine the hardware target for your installation and log in to that machine as your non-privileged user.

The first step is to clone the installation scripts from GitLab from the swamponabox project as 
your non-privileged user.

(1)     git clone git@swa-scm-1.mirsam.org:swamp/swamponabox.git

The second step is to clone the swamp source code from GitLab from the
six applicable projects, also as your non-privileged user.

(2)     cd
	mkdir swamp
        cd swamp
        . ../swamponabox/build_swampinabox/bin/git_clone.bash

The third step is to install the swamp source code and execute the
necessary patches to convert to swamponabox.  This step is executed as
the root user.

(3)     cd ../swamponabox/build_swampinabox
	mkdir log
	./bin/install_swamponabox.bash <username> |& tee log/install_swamponabox_`hostname -s`_<dd>.log

where <dd> starts with 00 and increments by 1 every time you rerun the install script.

Note that steps (2) and (3) are outlined in README-INSTALL.md which is
attached here and contained in the download from step (1).

#########################
#	Initial Test	#
#########################

(1)	Go to the SWAMP front page in your browser:
	https://<hostname>	(e.g. https://swa-exec-dt-07.mirsam.org)

	You should see the SWAMP front page with the > Sign In button displayed

(2)	Log in to swamponabox as administratior:
	Username: admin-s
	Password: swamp

(3)	Add New Package
	There are some packages available in the swamponabox repository cloned in Quick Start (1) under SwampProjects

(4)	Run an assessment

(5)	Open a viewer

#################
#	Notes	#
#################

(1)	Php manual configuration for large package uploads
	in /etc/php.ini
	change upload_max_filesize to 800M
	change post_max_size to 800M
	service httpd restart
