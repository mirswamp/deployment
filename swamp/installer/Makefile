DIRS=SOURCES RPMS SPECS SRPMS BUILD TEMPSOURCES
RELEASE_NUMBER ?= 0.10
BUILD_NUMBER ?= dev
TAP=results.tap
C_ASSESS_VERSION=1.1.0
JAVA_ASSESS_VERSION=2.4.1
PYTHON_ASSESS_VERSION=1.0.8
RUBY_ASSESS_VERSION=1.0.1
SCRIPT_ASSESS_VERSION=0.7.1
RESULTPARSER_VERSION=3.0.0
CODEDX_WAR_VERSION=1.8.3
THREADFIX_WAR_VERSION=2.3

AGENTFILES= \
	arun.sh \
	vmu_PreAssessment.pl \
	vmu_PostAssessment.pl \
	vmu_MonitorAssessment.pl \
	vmu_PreViewer.pl \
	vmu_PostViewer.pl \
	vmu_MonitorViewer.pl \
	vmu_AgentMonitor.pl \
	vmu_csa_agent.pl \
	vmu_launchviewer.pl \
	vmu_PreAssessment_launcher \
	vmu_PostAssessment_launcher \
	vmu_PreViewer_launcher \
	vmu_PostViewer_launcher \
	vmu_LaunchPad.pl \
	vmu_calldorun.pl \
	vmu_csa_agent_launcher \
	vmu_killrun.pl \
	vmu_notifyuser.pl \
	swamp_config \
	vmu_swamp_monitor

AGENTPKGS= \
	lib/SWAMP/vmu_AssessmentSupport.pm \
	lib/SWAMP/vmu_ViewerSupport.pm \
	lib/SWAMP/vmu_Support.pm \
	lib/SWAMP/vmu_FrameworkUtils.pm \
	lib/SWAMP/vmu_Locking.pm \
	lib/SWAMP/vmu_PackageTypes.pm \
	lib/SWAMP/vmu_Notification.pm \
	lib/SWAMP/CodeDX.pm \
	lib/SWAMP/Libvirt.pm \
	lib/SWAMP/ThreadFix.pm \
	lib/SWAMP/ToolLicense.pm

CONFIG= \
	libvirt_swamp_script.awk \
	vmu_swamponabox_htcondor_submit \
	vmu_swamp_htcondor_submit \
	log4j.properties \
	log4perl.conf \
	dsmonitor.conf \
	submonitor.conf \
	swamponaboxmonitor.conf \
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

	

SCRIPTS=swampd-common swamp.sh arun.bash cloc-1.60.pl execute_execution_record launch_viewer kill_run notify_user

MSOURCES=$(AGENTFILES) $(AGENTPKGS) $(CONFIG) $(SCRIPTS)

CP=/bin/cp -p
TAR=tar
TOP=../../..

destfiles:=$(AGENTFILES:%=TEMPSOURCES/%)  $(AGENTPKGS:%=TEMPSOURCES/%) $(CONFIG:%=TEMPSOURCES/%) $(SCRIPTS:%=TEMPSOURCES/%) $(SQLSCRIPTS:%=TEMPSOURCES/%)

# tar file for swamp and singleserver
SWAMPTARBALL=SOURCES/swamp-1.tar.gz
SWAMPSOURCES=SOURCES TEMPSOURCES $(destfiles) jars javalib TEMPSOURCES/swamp.conf TEMPSOURCES/mysql_global_settings.cnf toolchain common codedx threadfix TEMPSOURCES/scripts.tar 

$(SWAMPTARBALL): $(SWAMPSOURCES)
	cp ../../../db/Data\ Server/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	cp ../../../db/backup_db TEMPSOURCES
	$(TAR) -C TEMPSOURCES -czvf $@ .

# tar tile for swampinabox
# exclude threadfix for swampinabox
SWAMPINABOXTARBALL=SOURCES/swamponabox-1.tar.gz
SWAMPINABOXSOURCES=SOURCES TEMPSOURCES $(destfiles) jars javalib TEMPSOURCES/swampinabox.conf TEMPSOURCES/mysql_global_settings.cnf toolchain common codedx TEMPSOURCES/scripts.tar 

$(SWAMPINABOXTARBALL): $(SWAMPINABOXSOURCES)
	cp ../../../db/Data\ Server/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	cp ../../../db/backup_db TEMPSOURCES
	/bin/rmdir TEMPSOURCES/threadfix
	$(TAR) -C TEMPSOURCES -czvf $@ .

swamponabox: dirs $(SWAMPINABOXTARBALL)
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS swamponabox
	
singleserver: dirs $(SWAMPTARBALL)
	mv $(SWAMPTARBALL) $(SWAMPINABOXTARBALL)
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS singleserver
	
rpm: dirs $(SWAMPTARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

dirserver: dirs $(SWAMPTARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS dirserver

dataserver: dirs $(SWAMPTARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS dataserver

exec: dirs $(SWAMPTARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS exec

submit: dirs $(SWAMPTARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS submit

prep: dirs $(SWAMPTARBALL) 


TOOLCHAIN=python-assess.tar.gz java-assess.tar.gz c-assess.tar.gz ruby-assess.tar.gz resultparser.tar dependencies.tar dependencykeys.txt versions.txt

COMMONFILES=common/vrunchecktimeout common/checktimeout.pl common/swamp-shutdown-service common/flushprivs.sql

CODEDXFILES=codedx/vrun.sh codedx/codedx_viewerdb.sh codedx/emptydb-mysql-codedx.sql codedx/emptydb-codedx.sql codedx/logback.xml codedx/codedx.props codedx/codedx.war codedx/resetdb-codedx.sql

THREADFIXFILES=threadfix/vrun.sh threadfix/threadfix_viewerdb.sh threadfix/emptydb-mysql-threadfix.sql threadfix/emptydb-threadfix.sql threadfix/threadfix.jdbc.properties threadfix/threadfix.war threadfix/resetdb-threadfix.sql

.PHONY dirs:

list:
	@echo "MSOURCES: $(MSOURCES)"
	@echo ""
	@echo "destfiles: $(destfiles)"

dirs: $(DIRS)

TEMPSOURCES/mysql_global_settings.cnf:
	cp ../config/permissions_svr/mysql_global_settings.cnf TEMPSOURCES

TEMPSOURCES/swampinabox.conf::
	(cat ../config/swamp.conf.swamponabox; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/swamp.conf

TEMPSOURCES/swamp.conf::
	(cat ../config/swamp.conf; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/swamp.conf

jars:
	cp -r ../../../services/java/out/production/jar TEMPSOURCES
	# (cat ../config/swamp.conf.swamponabox; echo "buildnumber=$(BUILD_NUMBER)") > TEMPSOURCES/jar/swamp.conf

javalib:
	cp -r ../../../services/java/out/production/lib TEMPSOURCES

# Here we map the current version of assessment tools to the single version installed
toolchain:
	cp ../../UWTeam/java-assess-$(JAVA_ASSESS_VERSION).tar.gz TEMPSOURCES/java-assess.tar.gz
	cp ../../UWTeam/python-assess-$(PYTHON_ASSESS_VERSION)-with-python.tar.gz TEMPSOURCES/python-assess.tar.gz
	cp ../../UWTeam/c-assess-$(C_ASSESS_VERSION).tar.gz TEMPSOURCES/c-assess.tar.gz
	cp ../../UWTeam/ruby-assess-$(RUBY_ASSESS_VERSION).tar.gz TEMPSOURCES/ruby-assess.tar.gz
	cp ../../UWTeam/script-assess-$(SCRIPT_ASSESS_VERSION).tar.gz TEMPSOURCES/script-assess.tar.gz
	cp ../../UWTeam/resultparser-$(RESULTPARSER_VERSION).tar TEMPSOURCES/resultparser.tar
	cp ../../UWTeam/dependencies.tar TEMPSOURCES/dependencies.tar
	cp ../../UWTeam/dependencykeys.txt TEMPSOURCES/dependencykeys.txt
	echo SWAMP:$(RELEASE_NUMBER).$(BUILD_NUMBER) > TEMPSOURCES/versions.txt
	echo script-assess:$(SCRIPT_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo ruby-assess:$(RUBY_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo c-assess:$(C_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo java-assess:$(JAVA_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo python-assess:$(PYTHON_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo resultparser:$(RESULTPARSER_VERSION) >> TEMPSOURCES/versions.txt

common:
	cp ../../Common/checktimeout.pl TEMPSOURCES/common/checktimeout.pl
	cp ../../Common/flushprivs.sql TEMPSOURCES/common/flushprivs.sql
	cp ../../Common/swamp-shutdown-service TEMPSOURCES/common/swamp-shutdown-service
	cp ../../Common/vrunchecktimeout TEMPSOURCES/common/vrunchecktimeout

codedx:
	cp ../../SecureDecisions/codedx.props TEMPSOURCES/codedx/codedx.props
	cp ../../SecureDecisions/codedx_viewerdb.sh TEMPSOURCES/codedx/codedx_viewerdb.sh
	cp ../../SecureDecisions/emptydb-codedx-$(CODEDX_WAR_VERSION).sql TEMPSOURCES/codedx/emptydb-codedx.sql
	cp ../../SecureDecisions/emptydb-mysql-codedx.sql TEMPSOURCES/codedx/emptydb-mysql-codedx.sql
	cp ../../SecureDecisions/logback.xml TEMPSOURCES/codedx/logback.xml
	cp ../../SecureDecisions/resetdb-codedx.sql TEMPSOURCES/codedx/resetdb-codedx.sql
	cp ../../SecureDecisions/vrun.sh TEMPSOURCES/codedx/vrun.sh
	cp ../../SecureDecisions/codedx-$(CODEDX_WAR_VERSION).war TEMPSOURCES/codedx/codedx.war

threadfix:
	cp ../../DenimGroup/emptydb-mysql-threadfix.sql TEMPSOURCES/threadfix/emptydb-mysql-threadfix.sql
	cp ../../DenimGroup/emptydb-threadfix-$(THREADFIX_WAR_VERSION).sql TEMPSOURCES/threadfix/emptydb-threadfix.sql
	cp ../../DenimGroup/resetdb-threadfix.sql TEMPSOURCES/threadfix/resetdb-threadfix.sql
	cp ../../DenimGroup/threadfix.jdbc.properties TEMPSOURCES/threadfix/threadfix.jdbc.properties
	cp ../../DenimGroup/threadfix_viewerdb.sh TEMPSOURCES/threadfix/threadfix_viewerdb.sh
	cp ../../DenimGroup/vrun.sh TEMPSOURCES/threadfix/vrun.sh
	cp ../../DenimGroup/threadfix-$(THREADFIX_WAR_VERSION).war TEMPSOURCES/threadfix/threadfix.war

SOURCES:
	mkdir -p $@
RPMS:
	mkdir -p $@
SPECS:
	mkdir -p $@
SRPMS:
	mkdir -p $@
	mkdir -p $@/common
	mkdir -p $@/codedx
	mkdir -p $@/threadfix
BUILD:
	mkdir -p $@
TEMPSOURCES:
	mkdir -p $@
	mkdir -p $@/common
	mkdir -p $@/codedx
	mkdir -p $@/threadfix

$(SCRIPTS:%=TEMPSOURCES/%): ../scripts/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(CONFIG:%=TEMPSOURCES/%): ../config/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(AGENTPKGS:%=TEMPSOURCES/%): $(TOP)/services/perl/agents/
	mkdir -p $(@D)
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(AGENTFILES:%=TEMPSOURCES/%): $(TOP)/services/perl/agents/
	$(CP) $(<)$(@:TEMPSOURCES/%=%)  $@

$(SQLSCRIPTS:%=TEMPSOURCES/%): TEMPSOURCES/scripts.tar

TEMPSOURCES/scripts.tar:
	find $(TOP)/db -name "*.sql" -o -name "*.pl" | tar --xform='s/ /_/g' -cvf TEMPSOURCES/scripts.tar -T -
	$(TAR) --strip-components=1 -C TEMPSOURCES -xvf TEMPSOURCES/scripts.tar

clean:
	/bin/rm -rf BUILD BUILDROOT RPMS SOURCES SRPMS TEMPSOURCES
	/bin/rm -rf SPECS/swamponabox-files.txt SPECS/swamponabox-install.txt

tests:
	# /usr/local/bin/bats --tap testdataserver   > dataserver.tap
	# /usr/local/bin/bats --tap testexec  > exec.tap
	# /usr/local/bin/bats --tap testsubmit  > submit.tap
	# /usr/local/bin/bats --tap testdirectory  > directory.tap
