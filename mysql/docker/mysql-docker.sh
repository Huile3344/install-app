#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install mysql of docker"
info "mkdir -pv /data/mysql/{logs,data}"
exec_exec "cp docker-my.cnf /data/mysql/"
#exec_exec "docker run -p 3306:3306 --restart always --name mysql -v /data/mysql/logs:/logs -v /data/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7"
exec_exec "docker stack deploy -c stack.yml mysql"
exec_exec "docker stack services mysql"
success $"install mysql of docker successfully!"
