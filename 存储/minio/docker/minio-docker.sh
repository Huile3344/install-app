#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install minio of docker"
echo_exec "mkdir -pv /opt/minio/{logs,data}"
echo_exec "docker run --name minio -p 9000:9000 -v /opt/minio/data:/data minio/minio server /data"
success $"install mysql of docker successfully!"
