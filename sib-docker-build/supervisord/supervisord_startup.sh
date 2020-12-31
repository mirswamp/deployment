#!/bin/bash

# Allow the derived images to run any additional runtime customizations
# 
# Initialize mariadb (if swamp install has configured mariadb, this is not needed)
# /usr/libexec/mariadb-prepare-db-dir

# make the copy of the docker image list for the SWAMP backend
docker images > /opt/swamp/etc/swamp_docker_images.txt

# make docker sock readable by the condor user
chown root:docker /var/run/docker.sock

# make `/slots` writable for the condor user
chown condor:condor /slots
chmod 755 /slots

# Now start the supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf

