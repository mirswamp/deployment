# Install SiB in a Docker Container image

The `Dockerfile` in this directory, will install SiB into a docker image based on CentOs 7.

Services are controlled using supervisord. The `supervisord.conf` file configures supervisord to control the following via the `supervisorctl` command:

- crond (cronie)
- httpd
- msql (mariadb)
- swamp-condor
- swamp

The `supervisord` directory contains scripts and config files used in conjunction with
supervisord.

- `supervisord.conf` is the conf file that tells supervisrd how to start up and what processes it can control.
- `supervisord_startup.sh` is the main command for the docker image. It runs some initial commands and then starts supervisord
- `supervisord_start_swamp.bash` is the script used by supervisord to control the swamp services.

Docker-in-Docker is achieved by binding to the host docker.sock
It is expected that the `condor-ubuntu-16.04-64-master-2020031801` image be loaded on the host.This should be done prior to running the container so that the SiB backend image list created via `supervisord_startup.sh` will include it. Note that there is work in progress to havehtcondor pull the image from docker hub. When that is completed, the manual load of the image will no longer be needed

Curl command to get the assessment docker image from <https://platform.swampinabox.org>:

`curl -O https://platform.swampinabox.org/platform-images/1.35_and_later/assessment-platforms-docker/condor-ubuntu-16.04-64-master-2020031801_docker.tar.xz`

Command to load the assessment docker image from a .tar.xz file

`docker image load -i [path to tar.xz file]`

Before building the docker image, copy the swampinabox-1.35 install files into the directory containing the Dockerfile.

1. Get the SiB build files
1. Run `extract-installer.bash`
1. Copy the extracted `swampinabox-1.37.installer` directory to the directory containing the DockerFile
1. Copy the tool archive `swampinabox-1.37-tools.tar.gz` to the directory containing the DockerFile

Note that the main install files `install_all.bash` and `install_swampinabox.bash` are called with the option `-docker` for the Docker Image Build.

The `systemctl` directory includes a perl script that can be copied into a container in place of systemctl to allow scripts to start and stop services using the `systemctl` command during a docker build. Note that this must be copied after running yum updates or potential updates to systemd might overwrite it.
<https://github.com/gdraheim/docker-systemctl-replacement>

The `passfiles` directory contains encrypted passwords for the database users (root, web, and java-agent) and for the admin-s swamp account. Under an interactive install of SiB, these would be created as the user answers the password prompts. For the Docker build we are skipping the interactive prompts and just copying the files where they are expected. After that point, any script that needs a database password will get it from the file. At the end of the install script the files are deleted. The passfiles checked in all use the password `swamp`. If another password is needed replace these files before running the docker build command. We should investigate resetting these passwords at runtime.

Note on MariaDB initialization:
The database is initialized as part of its configuration for SiB. Therefore the MariaDB initialization script, `mariadb-prepare-db-dir.bash` no longer needs to be included in `supervisord_startup.sh`

Command to build SiB in a Docker image

`docker build --rm -t sib-in-docker .`

Docker run option to bind to the host docker.sock to use the host docker daemon for docker-in-docker

`-v /var/run/docker.sock:/var/run/docker.sock`

Command to run the SiB Docker container with binding for Docker-in-Docker, port mapping, and binding for the slots directory

`docker run --name sib-in-docker -v /slots:/slots -v /var/run/docker.sock:/var/run/docker.sock -p 80:80 -p 443:443 -p 3306:3306 -it sib-in-docker`