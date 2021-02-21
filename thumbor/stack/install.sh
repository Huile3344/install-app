#!/bin/bash

# 安装脚本方法
function install () {
  INSTALL_ROOT=$1
  note "INSTALLER_ROOT: $INSTALL_ROOT"
  h1 "install $STACK_NAME of docker"

  # 特定安装路径，根据安装需要填写
  echo_exec "mkdir -pv /opt/thumbor/{logs,data}"
}

