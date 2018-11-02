#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install redis of docker"
echo_exec "mkdir -pv /data/redis/{logs,data}"
echo_exec "docker run -p 6379:6379 --restart always --name redis -v /data/redis/data:/data -d redis:5"
success $"install mysql of docker successfully!"
