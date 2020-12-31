FROM centos:centos7

# Run `yum update` followed by yum install of supervisor (via epel) and cronie
# install `which`
# install `libgomp` because htcondor needs it
# then clean out yum caches to keep the docker container smallish
RUN yum update -y && \
    yum -y install epel-release &&\
    yum -y install supervisor && \
	yum -y install cronie && \
	yum -y install which && \
    yum -y install libgomp && \
    yum clean all && \
    rm -rf /var/cache/yum/

# add the SiB install files
WORKDIR /install-sib
COPY ./swampinabox-1.37-tools.tar.gz ./swampinabox-1.37-tools.tar.gz
COPY ./swampinabox-1.37-installer ./swampinabox-1.37-installer

# install SiB dependencies
RUN ./swampinabox-1.37-installer/repos/install-all.bash -docker && \
    yum clean all && \
    rm -rf /var/cache/yum/

# Replace systemctl
ADD ./systemctl/systemctl.py /usr/bin/systemctl

# Copy password files for install script
COPY ./passfiles/mysql_root /etc/.mysql_root
COPY ./passfiles/mysql_web /etc/.mysql_web
COPY ./passfiles/mysql_java /etc/.mysql_java
COPY ./passfiles/mysql_admin /etc/.mysql_admin

# Add `swa-admin` user and group (so `swa-daemon` doesn't end up getting id 1000,
# which then creates a conflict in the assessment container when creating the `builder` user 
# and group with ids matching `swa-deamon`)
RUN groupadd -g 1000 swa-admin && useradd -u 1000 -g 1000 swa-admin

# Run install script
WORKDIR /install-sib
RUN ./swampinabox-1.37-installer/bin/install_swampinabox.bash -docker

# add the startup script (for the docker cmd) this script mainly runs supervisor,
# but it can do other things too, if we want it to
COPY ./supervisord/supervisord_startup.sh /usr/local/sbin/supervisord_startup.sh

# add the script used by supervisord as the command to start swamp services
COPY ./supervisord/suprevisord_start_swamp.bash /usr/local/sbin/supervisord_start_swamp.bash

# scripts needs to be executable to run
RUN chmod -v +x /usr/local/sbin/supervisord_startup.sh
RUN chmod -v +x /usr/local/sbin/supervisord_start_swamp.bash

# add the config file that tells supervisor how to run and what processes it can control
COPY ./supervisord/supervisord.conf /etc/supervisord.conf

# open port for apache http and SSH
EXPOSE 80 443 3306

# run the startup script which also runs supervisord
CMD ["/usr/local/sbin/supervisord_startup.sh"]