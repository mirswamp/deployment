#!/usr/bin/env bash

INCLUDEWAR=$1

DIST=centos
DISTVER=7
BUILDDATE=$(date +%Y%m%d)
BUILDREV=00
BASEOS=${DIST}${DISTVER}
IMAGESIZE=100

CODEDX_WAR_VERSION=$(grep codedx ../inventory/viewers.txt | sed 's/codedx-//' | sed 's/.war//')
TOMCATVER=8.5.49
TOMCATURL="https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCATVER}/bin/apache-tomcat-${TOMCATVER}.tar.gz"

MASTERNAME="condor-codedx-${CODEDX_WAR_VERSION}-viewer-master-${BUILDDATE}${BUILDREV}"

BRIDGE="virbr0"

exit_on_failure=1

GLOBAL_RUNHOST_RESULT=''
function RUNHOST () {
        echo "RUNNING HOST COMMAND: [$1]"
        GLOBAL_RUNHOST_RESULT=$($1 |& tee /dev/tty)
		status=$?
        if [ $status != 0 ]; then
                echo "RUNHOST [$1] failed with status: $status"
				if [ $exit_on_failure == 1 ]; then
                	exit 1
				fi
        fi
        echo ""
}

echo ">>>> INSTALLING OS [${BASEOS}/${IMAGESIZE}GB]"
echo ""

RUNHOST "./kvm-install-vm remove ${MASTERNAME}"
RUNHOST "./kvm-install-vm create -l /opt/kvm-install/virt/images -L /opt/kvm-install/virt/vms -d ${IMAGESIZE} -t ${BASEOS} ${MASTERNAME}"

ssh_user=$(echo $GLOBAL_RUNHOST_RESULT | grep SSH | cut -f 2 -d \' | cut -f 2 -d ' ')
vmip=$(echo $ssh_user | cut -f 2 -d \@)
ssh_command="ssh -o StrictHostKeyChecking=no ${ssh_user}"


function RUN () {
        echo "RUNNING VM COMMAND: [$1]"
        $ssh_command $1
		status=$?
        if [ $status != 0 ]; then
                echo "RUN [$1] failed with status: $status"
				if [ $exit_on_failure == 1 ]; then
                	exit 1
				fi
        fi
        echo ""
}

function POWEROFF () {
        echo "SHUTTING DOWN: [sudo poweroff]"
        $ssh_command "sudo poweroff"
        echo ""
}

function REBOOT () {
        echo "RESTARTING: [sudo reboot]"
        $ssh_command "sudo reboot"
        echo ""
}

function ADD () {
        if [ $# != 4 ]; then
                echo "ADD [$@] failed (missing parameter)"
				if [ $exit_on_failure == 1 ]; then
                	exit 1
				fi
        fi
        if [ -r $3 ]; then
                scp -q -o StrictHostKeyChecking=no $3 ${ssh_user}:~ 
                if [ $? == 0 ]; then
                        FILEBASENAME=$(basename $3)
                        $ssh_command "sudo cp -f ~centos/${FILEBASENAME} $4"
                        $ssh_command "sudo chmod $1 $4"
                        $ssh_command "sudo chown $2 $4"
                        echo "ADDED [$4] successfully"
                else
                        echo "ADD [$3->$4] failed (scp)"
						if [ $exit_on_failure == 1 ]; then
                        	exit 1
						fi
                fi
        else
                echo "ADD [$3->$4] failed ($3: not found)"
				if [ $exit_on_failure == 1 ]; then
                	exit 1
				fi
        fi
        echo ""
}

echo -n "- Waiting for SSH to start "
while true;
do
        portstate=$(nmap -p 22 $vmip | grep open | cut -f 2 -d ' ')
        sleep 1
        echo -n "."
        if [ "$portstate" == "open" ]; then
                break
        fi
done
echo ""

echo "- Using SSH [$ssh_command] to access VM"
echo ""

echo ">>>> UPDATING OS"
echo ""
RUN "sudo yum update -y"

echo ">>>> BEGIN SWAMP CUSTOMIZATION HERE <<<<"
echo ""

# SWAMP does not use cloud-init 
RUN "sudo yum erase -y cloud-init cloud-utils-growpart"

# Add MariaDB.repo
ADD 0644 root:root ../build_docker_viewer/services/mariadb/MariaDB.repo /etc/yum.repos.d/MariaDB.repo

# Install Dependencies
RUN "sudo yum install -y curl tar unzip java-1.8.0-openjdk MariaDB-client MariaDB-common MariaDB-compat MariaDB-server jemalloc galera libzstd perl-Digest-MD5"

# Install and configure FirewallD
RUN "sudo yum install -y firewalld"
RUN "sudo systemctl enable firewalld"
RUN "sudo systemctl start firewalld"
RUN "sudo firewall-cmd --set-default-zone=public"
RUN "sudo firewall-cmd --permanent --zone=public --change-interface=eth0"
RUN "sudo firewall-cmd --permanent --zone=public --add-port=8443/tcp"
RUN "sudo firewall-cmd --reload"
RUN "sudo firewall-cmd --list-services"
RUN "sudo firewall-cmd --list-ports"

# Disable SELINUX
RUN "sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config"

# Install checktimeout
ADD +x root:root ../Common/checktimeout /usr/local/libexec/checktimeout
ADD +x root:root ../Common/checktimeout.pl /usr/local/libexec/checktimeout.pl

# Configure MariaDB
ADD +x root:root ../build_docker_viewer/services/mariadb/mariadb_build.pl /root/mariadb_build.pl
ADD 0600 root:root ../build_docker_viewer/services/mariadb/dot.mariadb.pw /root/.mariadb.pw
ADD 0600 root:root ../Common/flushprivs.sql /root/flushprivs.sql
ADD 0600 root:root ../SecureDecisions/resetdb-codedx.sql /root/resetdb-codedx.sql
ADD 0600 root:root ../SecureDecisions/emptydb-mysql-codedx.sql /root/emptydb-mysql-codedx.sql
ADD 0600 root:root ../SecureDecisions/emptydb-codedx-${CODEDX_WAR_VERSION}.sql /root/emptydb-codedx.sql
RUN "sudo perl /root/mariadb_build.pl"
RUN "sudo chown -R mysql:mysql /var/lib/mysql"
RUN "sudo chown -R root:mysql /etc/my.cnf.d"
RUN "sudo chmod -R g+w /etc/my.cnf.d"

# Enable MariaDB to start at boot
RUN "sudo systemctl enable mariadb"

# Create Apache Tomcat Service user
RUN "sudo useradd tomcat"
RUN "sudo chsh -s /sbin/nologin tomcat"

# Extract Tomcat
RUN "sudo curl -s -S -o /opt/apache-tomcat-${TOMCATVER}.tar.gz ${TOMCATURL}"
RUN "sudo tar -x --exclude='apache-tomcat-${TOMCATVER}/webapps/*' -f /opt/apache-tomcat-${TOMCATVER}.tar.gz -C /opt"

# Configure Tomcat
ADD 0644 tomcat:tomcat ../build_docker_viewer/services/tomcat/catalina.properties.8.5 /opt/apache-tomcat-${TOMCATVER}/conf/catalina.properties
ADD 0755 tomcat:tomcat ../build_docker_viewer/services/tomcat/catalina.sh.8.5 /opt/apache-tomcat-${TOMCATVER}/bin/catalina.sh
ADD 0644 tomcat:tomcat ../build_docker_viewer/services/tomcat/server.xml.8.5 /opt/apache-tomcat-${TOMCATVER}/conf/server.xml
ADD 0644 tomcat:tomcat ../build_docker_viewer/services/tomcat/context.xml.8.5 /opt/apache-tomcat-${TOMCATVER}/conf/context.xml
ADD 0644 tomcat:tomcat ../build_docker_viewer/services/tomcat/setenv.sh /opt/apache-tomcat-${TOMCATVER}/bin/setenv.sh
RUN "sudo chown -R tomcat:tomcat /opt/apache-tomcat*"
RUN "sudo ln -s /opt/apache-tomcat-${TOMCATVER} /opt/tomcat"

# Install SSL Cert Keystore
RUN "sudo mkdir -p /opt/keystore"
ADD 0600 tomcat:tomcat ../build_docker_viewer/services/ssl/viewer.p12 /opt/keystore/viewer.p12

# Install Tomcat Service
ADD 0644 root:root ./etc/tomcat.systemd.service /etc/systemd/system/tomcat.service
RUN "sudo systemctl disable tomcat"

# CodeDX Config
RUN "sudo mkdir -p /var/lib/codedx/PROJECT/config"
ADD 0644 tomcat:tomcat ../SecureDecisions/codedx.props /var/lib/codedx/PROJECT/config/codedx.props
ADD 0644 tomcat:tomcat ../SecureDecisions/logback.xml /var/lib/codedx/PROJECT/config/logback.xml
ADD 0644 tomcat:tomcat ../SecureDecisions/codedx_viewerdb.sh /usr/local/libexec/codedx_viewerdb.sh
RUN "sudo touch /var/lib/codedx/PROJECT/config/.installation"
RUN "sudo chown -R tomcat:tomcat /var/lib/codedx"
RUN "sudo chmod +x /usr/local/libexec/codedx_viewerdb.sh"

# Execution Script
ADD 0755 root:root ../SecureDecisions/vmu_vrun.sh /usr/local/libexec/run.sh
ADD 0644 root:root ./etc/runsh.systemd.service /etc/systemd/system/runsh.service

# CodeDX Backup Service
ADD 0755 root:root ../Common/vmu-codedx-backup /usr/local/libexec/codedx-backup
ADD 0644 root:root ./etc/codedx-backup.systemd.service /etc/systemd/system/codedx-backup.service

# Set root password
RUN "sudo sh -c 'echo 'condortest' | passwd --stdin root'"

# Reboot VM"
REBOOT

echo -n "- Waiting for domain to get an IP address ... "
sleep 5
MAC=$(virsh dumpxml ${MASTERNAME} | awk -F\' '/mac address/ {print $2}')
while true;
do
        IP=$(grep -B1 $MAC /var/lib/libvirt/dnsmasq/$BRIDGE.status | head \
                 -n 1 | awk '{print $2}' | sed -e s/\"//g -e s/,//)
            if [ "$IP" = "" ]
            then
                sleep 1
            else
                echo "$IP"
                break
            fi
done
echo ""

echo "- Updating SSH command"
vmip=$IP
ssh_user="centos@${IP}"
ssh_command="ssh -o StrictHostKeyChecking=no ${ssh_user}"
echo ""

echo -n "- Waiting for SSH to start "
while true;
do
        portstate=$(nmap -p 22 $vmip | grep open | cut -f 2 -d ' ')
        sleep 1
        echo -n "."
        if [ "$portstate" == "open" ]; then
                break
        fi
done
echo ""

echo -n "- Waiting for processes to settle "
for i in {1..20};
do
        echo -n "."
        sleep 6
done
echo ""
echo ""

# Edit /etc/fstab
ADD 0644 root:root ./etc/fstab /root/fstab
RUN "sudo sh -c 'cat /root/fstab >> /etc/fstab'"

# Force use of eth0
ADD 0644 root:root ./etc/grub /etc/default/grub
RUN "sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
RUN "sudo sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0"
RUN "sudo \rm -f /etc/sysconfig/network-scripts/ifcfg-eth0.bak"

# Enable run.sh at boot
RUN "sudo systemctl enable runsh"

# Enable CodeDX Backup at boot
RUN "sudo systemctl enable codedx-backup"

# Poweroff VM"
POWEROFF

echo -n " - Waiting for domain to shut down "
while true;
do
        virsh dominfo ${MASTERNAME} | grep State: | grep 'shut off' > /dev/null
        if [ $? -eq 0 ]; then
                break
        else
                sleep 5
                echo -n "."
        fi
done
echo ""
echo ""

echo ">>>> RUNNING virt-sysprep"
echo ""
RUNHOST "virt-sysprep --enable udev-persistent-net,logfiles,tmp-files -a /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2"

echo ">>>> REMOVING ssh keys"
TMP_DIR="$(mktemp -d "/tmp/$(basename -- "$0").XXXXXXXX")"

RUNHOST "guestmount -a /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2 -m /dev/sda1 -w $TMP_DIR"
RUNHOST "rm -f $TMP_DIR/home/centos/.ssh/authorized_keys"
RUNHOST "rm -f $TMP_DIR/root/.ssh/authorized_keys"
RUNHOST "umount $TMP_DIR"

rmdir "$TMP_DIR"

echo ">>>> RUNNING virt-sparsify"
echo ""
RUNHOST "virt-sparsify /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2 /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}-sparse.qcow2"
rm -f /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2
mv /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}-sparse.qcow2 /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2

echo ">>>> CLEAN UP INTERMEDIATE DOMAIN ${MASTERNAME}"
echo ""
RUNHOST "./kvm-install-vm remove ${MASTERNAME}"

echo "${MASTERNAME}.qcow2 built successfully"
ls -lh /opt/kvm-install/virt/vms/${MASTERNAME}
echo ""

if [ "$INCLUDEWAR" == "-w" ]; then
        RUNHOST "./add-warfile.bash /opt/kvm-install/virt/vms/${MASTERNAME}/${MASTERNAME}.qcow2 ../../proprietary/SecureDecisions/codedx-${CODEDX_WAR_VERSION}.war"
fi
