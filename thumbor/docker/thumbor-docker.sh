#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install thumbor of docker"
echo_exec "mkdir -pv /opt/thumbor/{logs,data}"
echo_exec "docker run --name thumbor -p 8888:80 minimalcompact/thumbor"
success $"install thumbor of docker successfully!"
