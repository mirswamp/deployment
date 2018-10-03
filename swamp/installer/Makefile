# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

DIRS=SOURCES RPMS SPECS SRPMS BUILD TEMPSOURCES
RELEASE_NUMBER ?= 0.10
BUILD_NUMBER ?= dev
TAP=results.tap
C_ASSESS_VERSION=$(shell grep c-assess ../../inventory/frameworks.txt | sed 's/c-assess-//' | sed 's/.tar.gz//')
JAVA_ASSESS_VERSION=$(shell grep java-assess ../../inventory/frameworks.txt | sed 's/java-assess-//' | sed 's/.tar//')
RUBY_ASSESS_VERSION=$(shell grep ruby-assess ../../inventory/frameworks.txt | sed 's/ruby-assess-//' | sed 's/.tar//')
SCRIPT_ASSESS_VERSION=$(shell grep script-assess ../../inventory/frameworks.txt | sed 's/script-assess-//' | sed 's/.tar//')
RESULTPARSER_VERSION=$(shell grep resultparser ../../inventory/frameworks.txt | sed 's/resultparser-//' | sed 's/.tar//')
CLOC_VERSION=$(shell grep cloc ../../inventory/tools-metric.txt | sed 's/cloc-//' | sed 's/.tar.gz//')
CODEDX_WAR_VERSION=$(shell grep codedx ../../inventory/viewers.txt | sed 's/codedx-//' | sed 's/.war//')
THREADFIX_WAR_VERSION=$(shell grep threadfix ../../inventory/viewers.txt | sed 's/threadfix-//' | sed 's/.war//')

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
	vmu_killrun.pl \
	swamp_config \
	vmu_swamp_monitor

AGENTPKGS= \
	lib/SWAMP/vmu_AssessmentSupport.pm \
	lib/SWAMP/vmu_ViewerSupport.pm \
	lib/SWAMP/vmu_Support.pm \
	lib/SWAMP/FrameworkUtils.pm \
	lib/SWAMP/Locking.pm \
	lib/SWAMP/PackageTypes.pm \
	lib/SWAMP/CodeDX.pm \
	lib/SWAMP/ThreadFix.pm \
	lib/SWAMP/FloodlightAccess.pm \
	lib/SWAMP/ScarfXmlReader.pm

CONFIG= \
	libvirt_swamp_script.awk \
	vmu_swampinabox_htcondor_submit \
	vmu_swamp_htcondor_submit \
	log4perl.conf \
	services.conf.map \
	submonitor.conf \
	swampinaboxmonitor.conf \
	no-build.xslt \
	Scarf_ToolList.json

SCRIPTS=swampd-common swamp.sh arun.bash execute_execution_record launch_viewer kill_run

MSOURCES=$(AGENTFILES) $(AGENTPKGS) $(CONFIG) $(SCRIPTS)

CP=/bin/cp -p
TOP=../../..

destfiles:=$(AGENTFILES:%=TEMPSOURCES/%) $(AGENTPKGS:%=TEMPSOURCES/%) $(CONFIG:%=TEMPSOURCES/%) $(SCRIPTS:%=TEMPSOURCES/%) $(SQLSCRIPTS:%=TEMPSOURCES/%)

COMMONSOURCES=SOURCES TEMPSOURCES $(destfiles) TEMPSOURCES/mysql_timezone.cnf TEMPSOURCES/mysql_global_settings.cnf versioninfo toolchain TEMPSOURCES/scripts.tar inventory swampinabox-runtime

# tar file for swamp (rpm)
# use swamp.conf
# include common codedx codedx.war
SWAMPTARBALL=SOURCES/swamp-1.tar.gz
SWAMPCONF::
	cp ../config/swamp.conf TEMPSOURCES/swamp.conf
$(SWAMPTARBALL): $(COMMONSOURCES) common resultparser codedx codedx.war SWAMPCONF
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	cp ../../../db/backup_db TEMPSOURCES
	cp ../config/services.conf TEMPSOURCES
	tar -C TEMPSOURCES -czf $@ .

# tar file for singleserver
# use swamp.conf.singleserver
# include common codedx codedx.war
SINGLESERVERTARBALL=SOURCES/singleserver-1.tar.gz
SINGLESERVERCONF::
	cp ../config/swamp.conf.singleserver TEMPSOURCES/swamp.conf
$(SINGLESERVERTARBALL): $(COMMONSOURCES) resultparser common codedx codedx.war SINGLESERVERCONF
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	cp ../../../db/backup_db TEMPSOURCES
	cp ../config/services.conf.singleserver TEMPSOURCES/services.conf
	tar -C TEMPSOURCES -czf $@ .

# tar file for swampinabox
# use swamp.conf.swampinabox
# include common codedx
# exclude codedx.war
SWAMPINABOXTARBALL=SOURCES/swampinabox-1.tar.gz
SWAMPINABOXCONF::
	cp ../config/swamp.conf.swampinabox TEMPSOURCES/swamp.conf
$(SWAMPINABOXTARBALL): $(COMMONSOURCES) resultparser common codedx SWAMPINABOXCONF
	cp ../../lib/lib_mysqludf_sys.so TEMPSOURCES/Data_Server
	cp ../../../db/backup_db TEMPSOURCES
	cp ../config/services.conf.swampinabox TEMPSOURCES/services.conf
	tar -C TEMPSOURCES -czf $@ .

swampinabox: dirs scarfcparsing $(SWAMPINABOXTARBALL)
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS swampinabox

singleserver: dirs scarfcparsing $(SINGLESERVERTARBALL)
	mv $(SINGLESERVERTARBALL) $(SWAMPINABOXTARBALL)
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS singleserver

rpm: dirs scarfcparsing $(SWAMPTARBALL)
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS

scarfcparsing:	
	(cd ../../../services/perl/agents/Scarf_Parsing_C ; make)
	cp ../../../services/perl/agents/Scarf_Parsing_C/yajl/install/lib/libyajl.so.2 TEMPSOURCES
	strip TEMPSOURCES/libyajl.so.2
	cp ../../../services/perl/agents/Scarf_Parsing_C/vmu_Scarf_CParsing TEMPSOURCES 
	strip TEMPSOURCES/vmu_Scarf_CParsing
	cp ../config/Scarf_ToolList.json TEMPSOURCES

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

.PHONY dirs:

list:
	@echo "MSOURCES: $(MSOURCES)"
	@echo ""
	@echo "destfiles: $(destfiles)"

dirs: $(DIRS)

TEMPSOURCES/mysql_timezone.cnf:
	cp ../config/data_svr/mysql_timezone.cnf TEMPSOURCES

TEMPSOURCES/mysql_global_settings.cnf:
	cp ../config/permissions_svr/mysql_global_settings.cnf TEMPSOURCES

# Here we map the current version of assessment tools to the single version installed
toolchain:
	cp /swampcs/releases/c-assess-$(C_ASSESS_VERSION).tar.gz TEMPSOURCES/c-assess.tar.gz
	cp /swampcs/releases/java-assess-$(JAVA_ASSESS_VERSION).tar TEMPSOURCES/java-assess.tar
	cp /swampcs/releases/ruby-assess-$(RUBY_ASSESS_VERSION).tar TEMPSOURCES/ruby-assess.tar
	cp /swampcs/releases/script-assess-$(SCRIPT_ASSESS_VERSION).tar TEMPSOURCES/script-assess.tar
	tar zxOf /swampcs/releases/cloc-$(CLOC_VERSION).tar.gz --strip-components 3 cloc-$(CLOC_VERSION)/noarch/in-files/cloc-$(CLOC_VERSION).tar.gz | tar zx -C TEMPSOURCES --strip-components 1 cloc-$(CLOC_VERSION)/cloc

versioninfo:
	echo buildnumber:$(BUILD_NUMBER) >> TEMPSOURCES/versions.txt
	echo c-assess:$(C_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo java-assess:$(JAVA_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo ruby-assess:$(RUBY_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo script-assess:$(SCRIPT_ASSESS_VERSION) >> TEMPSOURCES/versions.txt
	echo cloc:$(CLOC_VERSION) >> TEMPSOURCES/versions.txt

resultparser:
	cp /swampcs/releases/resultparser-$(RESULTPARSER_VERSION).tar TEMPSOURCES/resultparser.tar
	echo resultparser:$(RESULTPARSER_VERSION) >> TEMPSOURCES/versions.txt

common:
	cp ../../Common/checktimeout.pl TEMPSOURCES/common/checktimeout.pl
	cp ../../Common/flushprivs.sql TEMPSOURCES/common/flushprivs.sql
	cp ../../Common/swamp-shutdown-service TEMPSOURCES/common/swamp-shutdown-service
	cp ../../Common/vrunchecktimeout TEMPSOURCES/common/vrunchecktimeout

codedx:
	cp ../../SecureDecisions/codedx.props TEMPSOURCES/codedx/codedx.props
	cp ../../SecureDecisions/codedx_viewerdb.sh TEMPSOURCES/codedx/codedx_viewerdb.sh
	cp ../../SecureDecisions/emptydb-codedx-*.sql TEMPSOURCES/codedx/.
	cp ../../SecureDecisions/emptydb-mysql-codedx.sql TEMPSOURCES/codedx/emptydb-mysql-codedx.sql
	cp ../../SecureDecisions/logback.xml TEMPSOURCES/codedx/logback.xml
	cp ../../SecureDecisions/resetdb-codedx.sql TEMPSOURCES/codedx/resetdb-codedx.sql
	cp ../../SecureDecisions/vrun.sh TEMPSOURCES/codedx/vrun.sh

codedx.war:
	cp ../../../proprietary/SecureDecisions/codedx-*.war TEMPSOURCES/codedx/.
	ln -s codedx-$(CODEDX_WAR_VERSION).war TEMPSOURCES/codedx/codedx.war
	ln -s emptydb-codedx-$(CODEDX_WAR_VERSION).sql TEMPSOURCES/codedx/emptydb-codedx.sql

threadfix:
	cp ../../DenimGroup/emptydb-mysql-threadfix.sql TEMPSOURCES/threadfix/emptydb-mysql-threadfix.sql
	cp ../../DenimGroup/emptydb-threadfix-$(THREADFIX_WAR_VERSION).sql TEMPSOURCES/threadfix/emptydb-threadfix.sql
	cp ../../DenimGroup/resetdb-threadfix.sql TEMPSOURCES/threadfix/resetdb-threadfix.sql
	cp ../../DenimGroup/threadfix.jdbc.properties TEMPSOURCES/threadfix/threadfix.jdbc.properties
	cp ../../DenimGroup/threadfix_viewerdb.sh TEMPSOURCES/threadfix/threadfix_viewerdb.sh
	cp ../../DenimGroup/vrun.sh TEMPSOURCES/threadfix/vrun.sh

threadfix.war:
	cp ../../../proprietary/DenimGroup/threadfix-$(THREADFIX_WAR_VERSION).war TEMPSOURCES/threadfix/threadfix.war

inventory:
	cp ../../inventory/*.txt TEMPSOURCES/inventory/.

swampinabox-runtime:
	cp -r ../../swampinabox/runtime/*  TEMPSOURCES/swampinabox/.

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
	mkdir -p $@/inventory
	mkdir -p $@/threadfix
	mkdir -p $@/swampinabox/bin
	mkdir -p $@/swampinabox/doc
	mkdir -p $@/swampinabox/sbin

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
	find $(TOP)/db -name "*.sql" -o -name "*.pl" | tar --xform='s/ /_/g' -cf TEMPSOURCES/scripts.tar -T -
	tar --strip-components=1 -C TEMPSOURCES -xf TEMPSOURCES/scripts.tar

clean:
	(cd ../../../services/perl/agents/Scarf_Parsing_C ; make clean)
	/bin/rm -rf BUILD BUILDROOT RPMS SOURCES SRPMS TEMPSOURCES
	/bin/rm -rf SPECS/swampinabox-files.txt SPECS/swampinabox-install.txt

tests:
	# /usr/local/bin/bats --tap testdataserver   > dataserver.tap
	# /usr/local/bin/bats --tap testexec  > exec.tap
	# /usr/local/bin/bats --tap testsubmit  > submit.tap
	# /usr/local/bin/bats --tap testdirectory  > directory.tap

show_versions:
	@echo "C_ASSESS_VERSION: <$(C_ASSESS_VERSION)>"
	@echo "JAVA_ASSESS_VERSION: <$(JAVA_ASSESS_VERSION)>"
	@echo "RUBY_ASSESS_VERSION: <$(RUBY_ASSESS_VERSION)>"
	@echo "SCRIPT_ASSESS_VERSION: <$(SCRIPT_ASSESS_VERSION)>"
	@echo "RESULTPARSER_VERSION: <$(RESULTPARSER_VERSION)>"
	@echo "CLOC_VERSION: <$(CLOC_VERSION)>"
	@echo "CODEDX_WAR_VERSION: <$(CODEDX_WAR_VERSION)>"
	@echo "THREADFIX_WAR_VERSION: <$(THREADFIX_WAR_VERSION)>"
