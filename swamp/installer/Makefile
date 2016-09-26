# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

DIRS=SOURCES RPMS SPECS SRPMS BUILD TEMPSOURCES
RELEASE_NUMBER ?= 0.10
BUILD_NUMBER ?= dev
TAP=results.tap
C_ASSESS_VERSION=1.0.8
JAVA_ASSESS_VERSION=2.4.0
PYTHON_ASSESS_VERSION=1.0.7
RUBY_ASSESS_VERSION=0.9.9
RESULTPARSER_VERSION=2.2.4
CODEDX_WAR_VERSION=1.8.3
THREADFIX_WAR_VERSION=2.3

AGENTFILES= \
	AgentMonitor.pl \
	DomainMonitor.pl \
	LaunchPad.pl \
	ViewerMonitor.pl \
	arun \
	assessmentTask.pl \
	assessmentlauncher \
	calldorun.pl \
	csa_HTCondorAgent.pl \
	csa_HTCondorAgent_launcher \
	csa_agent.pl \
	csa_agent_launcher \
	launchviewer.pl \
	killrun.pl \
	notifyuser.pl \
	swamp_config \
	swamp_monitor \
	vrunlauncher \
	vrunTask.pl 

AGENTPKGS= \
	lib/SWAMP/HTCondorDefines.pm \
	lib/SWAMP/RPCUtils.pm \
	lib/SWAMP/AgentMonitorCommon.pm \
	lib/SWAMP/AssessmentTools.pm \
	lib/SWAMP/Client/AgentClient.pm \
	lib/SWAMP/Client/ViewerMonitorClient.pm \
	lib/SWAMP/Client/ExecuteRecordCollectorClient.pm \
	lib/SWAMP/Client/GatorClient.pm \
	lib/SWAMP/Client/LaunchPadClient.pm \
	lib/SWAMP/Client/LogCollectorClient.pm \
	lib/SWAMP/Client/ResultCollectorClient.pm \
	lib/SWAMP/Client/RunControllerClient.pm \
	lib/SWAMP/FrameworkUtils.pm \
	lib/SWAMP/Floodlight.pm \
	lib/SWAMP/SWAMPUtils.pm \
	lib/SWAMP/ToolLicense.pm \
	lib/SWAMP/VMPrimitives.pm \
	lib/SWAMP/VMToolsX.pm \
	lib/SWAMP/SysUtils.pm \
	lib/SWAMP/Locking.pm \
	lib/SWAMP/VRunTools.pm \
	lib/SWAMP/PackageTypes.pm \
	lib/SWAMP/Notification.pm \
	lib/SWAMP/CodeDX.pm \
	lib/SWAMP/ThreadFix.pm \
	lib/SWAMP/SysVirtEvents.pm

VMTOOLFILES=masterify_vm vm_output vm_cleanup templ.xml start_vm
VMTOOLPKGS=VMTools.pm VMConstants.pm

VMAPPFILES=swamp_watchdog

CONFIG=log4j.properties \
	log4perl.conf \
	dsmonitor.conf \
	execmonitor.conf \
	submonitor.conf \
	pmd.xslt \
	findbugs.xslt \
	cppcheck.xslt \
	clang-sa.xslt \
	pmd_common.xslt \
	findbugs_common.xslt \
	archie_common.xslt \
	gcc_common.xslt \
	clang-sa_common.xslt \
	cppcheck_common.xslt \
	no-build.xslt \
	dawn_common.xslt \
	reveal_common.xslt \
	generic_common.xslt

SCRIPTS= \
	swampd \
	swampd-ds \
	swampd-exec \
	swamp.sh \
	arun.bash \
	swamp \
	cloc-1.60.pl \
	\
	execute_execution_record \
	launch_viewer \
	kill_run \
	notify_user \
	\
	create_mysql_root_cnf \
	execute_sql_script \
	\
	install_codedx

MSOURCES=$(AGENTFILES) $(AGENTPKGS) $(VMTOOLFILES) $(VMTOOLPKGS) $(CONFIG) $(SCRIPTS) $(VMAPPFILES)

CP=/bin/cp -p
TAR=tar
TOP=../../..

destfiles:=$(AGENTFILES:%=TEMPSOURCES/%)  $(AGENTPKGS:%=TEMPSOURCES/%) $(VMTOOLFILES:%=TEMPSOURCES/%) $(VMTOOLPKGS:%=TEMPSOURCES/%) $(CONFIG:%=TEMPSOURCES/%) $(SCRIPTS:%=TEMPSOURCES/%) $(SQLSCRIPTS:%=TEMPSOURCES/%) $(VMAPPFILES:%=TEMPSOURCES/%)

TARBALL=SOURCES/swamp-1.tar.gz
SWAMPONABOXCONF::
	(cat ../config/swamp.conf.swampinabox; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/swamp.conf

# put swamp.conf.swampinabox in place as swamp.conf
# include threadfix for singleserver
singleserver: dirs SOURCES TEMPSOURCES $(destfiles) jars javalib SWAMPONABOXCONF TEMPSOURCES/mysql_global_settings.cnf toolchain codedx codedx.war threadfix threadfix.war TEMPSOURCES/scripts.tar 
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	$(TAR) -C TEMPSOURCES -czvf $@ .
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS singleserver
	
# put swamp.conf.swampinabox in place as swamp.conf
# do not include threadfix for swamponabox
swamponabox: dirs SOURCES TEMPSOURCES $(destfiles) jars javalib SWAMPONABOXCONF TEMPSOURCES/mysql_global_settings.cnf toolchain codedx swampinabox-doc TEMPSOURCES/scripts.tar 
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	/bin/rmdir TEMPSOURCES/threadfix
	$(TAR) -C TEMPSOURCES -czvf $(TARBALL) .
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS swamponabox
	
rpm: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

dirserver: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS dirserver

dataserver: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS dataserver

exec: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS exec

submit: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS submit

prep: dirs $(TARBALL) 

.PHONY dirs:

list:
	@echo "MSOURCES: $(MSOURCES)"
	@echo ""
	@echo "destfiles: $(destfiles)"

$(TARBALL): SOURCES TEMPSOURCES $(destfiles) jars javalib TEMPSOURCES/swamp.conf TEMPSOURCES/mysql_global_settings.cnf toolchain codedx codedx.war threadfix threadfix.war TEMPSOURCES/scripts.tar 
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	$(TAR) -C TEMPSOURCES -czvf $@ .

dirs: $(DIRS)

TEMPSOURCES/mysql_global_settings.cnf:
	cp ../config/permissions_svr/mysql_global_settings.cnf TEMPSOURCES

TEMPSOURCES/swamp.conf::
	(cat ../config/swamp.conf; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/swamp.conf

jars:
	cp -r ../../../services/java/out/production/jar TEMPSOURCES
	(cat ../config/swamp.conf; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/jar/swamp.conf

javalib:
	cp -r ../../../services/java/out/production/lib TEMPSOURCES

# Here we map the current version of assessment tools to the single version installed
toolchain:
	cp ../../UWTeam/java-assess-$(JAVA_ASSESS_VERSION).tar.gz TEMPSOURCES/java-assess.tar.gz
	cp ../../UWTeam/python-assess-$(PYTHON_ASSESS_VERSION)-with-python.tar.gz TEMPSOURCES/python-assess.tar.gz
	cp ../../UWTeam/c-assess-$(C_ASSESS_VERSION).tar.gz TEMPSOURCES/c-assess.tar.gz
	cp ../../UWTeam/ruby-assess-$(RUBY_ASSESS_VERSION).tar.gz TEMPSOURCES/ruby-assess.tar.gz
	cp ../../UWTeam/resultparser-noncomm-$(RESULTPARSER_VERSION).tar TEMPSOURCES/resultparser.tar
	cp ../../UWTeam/dependencies.tar TEMPSOURCES/dependencies.tar
	cp ../../UWTeam/dependencykeys.txt TEMPSOURCES/dependencykeys.txt
	echo SWAMP:$(RELEASE_NUMBER).$(BUILD_NUMBER) > TEMPSOURCES/versions.txt
	echo ruby-assess:$(RUBY_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo c-assess:$(C_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo java-assess:$(JAVA_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo python-assess:$(PYTHON_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo resultparser:$(RESULTPARSER_VERSION) >> TEMPSOURCES/versions.txt

codedx:
	cp ../../SecDec/vrun.sh TEMPSOURCES/codedx/vrun.sh
	cp ../../SecDec/vrunchecktimeout TEMPSOURCES/codedx/vrunchecktimeout
	cp ../../SecDec/checktimeout.pl TEMPSOURCES/codedx/checktimeout.pl
	cp ../../SecDec/codedx_viewerdb.sh TEMPSOURCES/codedx/codedx_viewerdb.sh
	cp ../../SecDec/emptydb-mysql.sql TEMPSOURCES/codedx/emptydb-mysql.sql
	cp ../../SecDec/emptydb-codedx-$(CODEDX_WAR_VERSION).sql TEMPSOURCES/codedx/emptydb-codedx.sql
	cp ../../SecDec/swamp-codedx-service TEMPSOURCES/codedx/swamp-codedx-service
	cp ../../SecDec/logback.xml TEMPSOURCES/codedx/logback.xml
	cp ../../SecDec/codedx.props TEMPSOURCES/codedx/codedx.props

codedx.war:
	cp ../../../proprietary/SecDec/codedx-$(CODEDX_WAR_VERSION).war TEMPSOURCES/codedx/codedx.war

threadfix:
	cp ../../DenimGroup/vrun.sh TEMPSOURCES/threadfix/vrun.sh
	cp ../../DenimGroup/vrunchecktimeout TEMPSOURCES/threadfix/vrunchecktimeout
	cp ../../DenimGroup/checktimeout.pl TEMPSOURCES/threadfix/checktimeout.pl
	cp ../../DenimGroup/threadfix_viewerdb.sh TEMPSOURCES/threadfix/threadfix_viewerdb.sh
	cp ../../DenimGroup/emptydb-mysql-threadfix.sql TEMPSOURCES/threadfix/emptydb-mysql-threadfix.sql
	cp ../../DenimGroup/emptydb-threadfix-$(THREADFIX_WAR_VERSION).sql TEMPSOURCES/threadfix/emptydb-threadfix.sql
	cp ../../DenimGroup/swamp-threadfix-service TEMPSOURCES/threadfix/swamp-threadfix-service
	cp ../../DenimGroup/threadfix.jdbc.properties TEMPSOURCES/threadfix/threadfix.jdbc.properties
	cp ../../DenimGroup/flushprivs.sql TEMPSOURCES/threadfix/flushprivs.sql
	cp ../../DenimGroup/resetdb-threadfix.sql TEMPSOURCES/threadfix/resetdb-threadfix.sql

threadfix.war:
	cp ../../../proprietary/DenimGroup/threadfix-$(THREADFIX_WAR_VERSION).war TEMPSOURCES/threadfix/threadfix.war

swampinabox-doc:
	cp ../../swamponabox/distribution/doc/* TEMPSOURCES/doc/SWAMP-in-a-Box

SOURCES:
	mkdir -p $@
RPMS:
	mkdir -p $@
SPECS:
	mkdir -p $@
SRPMS:
	mkdir -p $@
BUILD:
	mkdir -p $@
TEMPSOURCES:
	mkdir -p $@
	mkdir -p $@/codedx
	mkdir -p $@/threadfix
	mkdir -p $@/doc/SWAMP-in-a-Box

$(SCRIPTS:%=TEMPSOURCES/%): ../scripts/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(CONFIG:%=TEMPSOURCES/%): ../config/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(AGENTPKGS:%=TEMPSOURCES/%): $(TOP)/services/perl/agents/
	mkdir -p $(@D)
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(AGENTFILES:%=TEMPSOURCES/%): $(TOP)/services/perl/agents/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(VMTOOLFILES:%=TEMPSOURCES/%): $(TOP)/services/perl/vmtools/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(VMTOOLPKGS:%=TEMPSOURCES/%): $(TOP)/services/perl/vmtools/lib/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(SQLSCRIPTS:%=TEMPSOURCES/%): TEMPSOURCES/scripts.tar

$(VMAPPFILES:%=TEMPSOURCES/%): $(TOP)/services/perl/vmapps/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@


TEMPSOURCES/scripts.tar:
	find $(TOP)/db -name "*.sql" -o -name "*.pl" -o -name "backup_db" | tar --xform='s/ /_/g' -cvf TEMPSOURCES/scripts.tar -T -
	$(TAR) --strip-components=1 -C TEMPSOURCES -xvf TEMPSOURCES/scripts.tar 
	# rm -f TEMPSOURCES/scripts.tar

clean:
	/bin/rm -rf BUILD BUILDROOT RPMS SOURCES SRPMS TEMPSOURCES

tests:
	# /usr/local/bin/bats --tap testdataserver   > dataserver.tap
	/usr/local/bin/bats --tap testexec  > exec.tap
	# /usr/local/bin/bats --tap testsubmit  > submit.tap
	/usr/local/bin/bats --tap testdirectory  > directory.tap
