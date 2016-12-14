MANIFEST.md			- this list of files included in SWAMPINABOX installation directory
README-INSTALL.md	- instructions for installing, upgrading, and developing swamp using SWAMPINABOX

bin
	install_swampinabox.bash	- install a pristine instance of swamp
	upgrade_swampinabox.bash	- upgrade a swamp installation after pulling new source to git working directory
	upgrade_backend.bash		- upgrade just the swamp backend component (perl and java)
	update_source_files.pl		- update modified source files from git working directory to swamp install
	uninstall_swampinabox.bash	- remove most if not all components installed by the install script

	show_git_branches.pl		- show branch names (master/develop) for git working directory
	git_checkout.pl				- execute git pull on development branch for all swamp projects
	git_clone.bash				- execute git clone for all swamp projects (remember ssh keys)

	collate_vrun_logs.pl		- collate CodeDX viewer performance profile data into one report

db_dump
	backups	- data backups for various instances of swamp database
	create	- scripts used to create an initial swamp database
	scripts	- scripts used to dump and restore a swamp database
	
health_scripts
	guestfish.pl	- pull files from a defined/running virtual machine
	swamphealth.pl	- show health info about services, swamp monitors, swamp tasks, libvirt, and condor
	viewerstate.pl	- show the contents of the .viewerinfo file in /opt/swamp/run

log	- contains logs of install/upgrade script executions

sbin
	getargs.function					- bash functions used in following bash scripts
	yum_install.bash					- install system rpms needed for swamp
	swampinabox_build_rpms.bash			- build rpms in users git working directory
	swampinabox_install_rpms.bash		- install rpms from users git working directory to swamp locations
	swamp_database_install.bash			- initialize swamp database
	swamp_database_upgrade.bash			- run swamp database upgrade scripts
	swampinabox_make_filesystem.bash	- make swamp file system and set ownerships and permissions
	clock_configure.bash				- configure system clock
	condor_install.bash					- install condor for swamp
	hosts_configure.bash				- configure /etc/hosts file
	mail_configure.bash					- configure postfix for email notification
	manage_services.bash				- start,stop,restart,status,list swamp related system services
	open_vswitch.bash					- configure open vswitch for swamp (currently not used)
	sudo_libvirt.bash					- configure sudoers and libvirt for swamp

	find_domainname.pl		- computes domain name of current host
	find_ip_address.pl		- computes ip address of current host
	find_release_number.pl	- computes release number of rpms in the specified git working directory

swampinabox_installer	- post install backend configuration patches and changes peculiar to SWAMPINABOX

swampinabox_web_config	- post install web frontend configuration patches and changes peculiar to SWAMPINABOX
