# This makefile creates the swamp-dataserver-init RPM
DIRS=SOURCES RPMS SPECS BUILD
RELEASE_NUMBER ?= 0.10
BUILD_NUMBER ?= dev

SQLSCRIPTS=\
	Directory_Server/user_setup.sql \
	Directory_Server/project_tables.sql \
	Directory_Server/populate_project.sql \
	Data_Server/user_setup.sql \
	Data_Server/sys_exec.sql \
	Data_Server/Platform_Store/platform_store_tables.sql \
	Data_Server/Tool_Shed/tool_shed_tables.sql \
	Data_Server/Package_Store/package_store_tables.sql \
	Data_Server/Viewer_Store/viewer_store_tables.sql \
	Data_Server/Project/project_tables.sql \
	Data_Server/Assessment/assessment_tables.sql \
	Data_Server/Platform_Store/populate_platform_store.sql \
	Data_Server/Tool_Shed/populate_tool_shed.sql \
	Data_Server/Package_Store/populate_package_store.sql \
	Data_Server/Viewer_Store/populate_viewer_store.sql \
	Data_Server/Assessment/populate_assessment.sql

LIBS = \
	lib_mysqludf_sys.so

CONFIG = \
	permissions_svr/mysql-clients.cnf \
	permissions_svr/mysql_replication.cnf \
	permissions_svr/mysql_global_settings.cnf \
	permissions_svr/server.cnf \
	directory_svr/mysql-clients.cnf \
	directory_svr/mysql_replication.cnf \
	directory_svr/server.cnf \
	directory_svr/ldap_files/60eduperson.schema \
	directory_svr/ldap_files/70cosalabswamp_enabled.schema \
	directory_svr/ldap_files/71grouper.schema \
	directory_svr/ldap_files/DB_CONFIG \
	directory_svr/ldap_files/swa_admin.ldif \
	directory_svr/ldap_files/slapd.conf

SOURCES=$(SQLSCRIPTS) $(CONFIG) $(LIBS)
CP=/bin/cp -p
ifeq ($(shell uname), Darwin) 
TAR=gnutar
else
TAR=tar
endif
TOP= ../../..
destfiles:=$(SQLSCRIPTS:%=SOURCES/%)  $(CONFIG:%=SOURCES/%) $(LIBS:%=SOURCES/%) 

TARBALL=SOURCES/swamp-1.tar.gz

rpm: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

.PHONY dirs:

$(TARBALL): $(destfiles)
	$(TAR) -C SOURCES -czvf $@ $(SOURCES) 
	rm SOURCES/scripts.tar

dirs: $(DIRS)

RPMS:
	mkdir -p $@
SPECS:
	mkdir -p $@
SOURCES:
	mkdir -p $@
	touch $@/Makefile
BUILD:
	mkdir -p $@

$(SQLSCRIPTS:%=SOURCES/%): SOURCES/scripts.tar

SOURCES/scripts.tar:
	find $(TOP)/db -name "*.sql" -o -name "*.ldif" | tar --xform='s/ /_/g' -cvf SOURCES/scripts.tar -T -
	$(TAR) --strip-components=1 -C SOURCES -xvf SOURCES/scripts.tar 

#$(SQLSCRIPTS:%=SOURCES/%): $(TOP)/db/
#	mkdir -p $(@D)
#	$(CP) $(<)$(@:SOURCES/%=%) $@

$(LIBS:%=SOURCES/%): ../lib/
	mkdir -p $(@D)
	$(CP) $(<)$(@:SOURCES/%=%) $@

$(CONFIG:%=SOURCES/%): ../config/
	mkdir -p $(@D)
	$(CP) $(<)$(@:SOURCES/%=%) $@

clean:
	rm -rf SOURCES RPMS BUILD 

install: rpm
	sudo yum -y remove MariaDB-server MariaDB-client
	sudo rm -rf /var/lib/mysql
	sudo yum -y install RPMS/noarch/swamp-dataserver-setup-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

install2: rpm
	sudo yum -y remove MariaDB-server MariaDB-client openldap-servers
	sudo rm -rf /var/lib/mysql
	sudo yum -y install RPMS/noarch/swamp-directory-server-setup-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm
