#!/bin/bash

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
STACK_SHELL=stack.sh
# docker stack 使用的 STACK 名称
STACK_NAME=nginx

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

function install () {
  INSTALL_ROOT=$1
  note "INSTALLER_ROOT: $INSTALL_ROOT"
  h1 "install $STACK_NAME of docker"
  echo_exec "mkdir -pv $INSTALL_ROOT/{html,logs,proxy_cache,http-cache}"
  echo_exec "mkdir -pv $INSTALL_ROOT/proxy_cache/tmp"

  echo_exec "cp $STACK_SHELL $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "cp $STACK_YML $INSTALL_ROOT/$STACK_YML"
#  echo_exec "cp nginx.conf $INSTALL_ROOT/nginx.conf"
  echo_exec "echo 'Hello Nginx!' > $INSTALL_ROOT/html/index.html"

  if $darwin; then
      echo_exec "sed -i '' 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
#      echo_exec "sed -i '' 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/nginx.conf"
  else
      echo_exec "sed -i 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
#      echo_exec "sed -i 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/nginx.conf"
  fi

  echo_exec "chmod +x $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "docker stack deploy -c $INSTALL_ROOT/$STACK_YML $STACK_NAME"
  echo_exec "sleep 3"
  echo_exec "docker stack services $STACK_NAME"
  success $"install docker stack [$STACK_NAME] successfully!"
  success $"You Know, Time to You!"
}

function help () {
    echo "usage: $1 STACK_NAME [install|clean]"
    echo "    install             -- create a enviroment directory and deploy for"
    echo "                           docker stack [STACK_NAME]."
    echo "    clean               -- clean enviroment directory for docker stack [STACK_NAME]."
}


#if $darwin; then
#    BASH_PATH=$(dirname "${BASH_SOURCE}")
#    INSTALL_PATH=`cd $BASH_PATH && pwd`
#else
#    INSTALL_PATH=$(readlink -f $(dirname "${BASH_SOURCE}"))
#fi
INSTALL_PATH=$(cd $2 && pwd)/${STACK_NAME}

case $1 in
    clean)
        echo_exec "docker stack rm $STACK_NAME"
        while [ 1 ]; do
            echo_exec "docker stack ps $STACK_NAME" || break
            sleep 2
        done
        echo_exec "rm -rf $INSTALL_PATH"
        success $"clean $STACK_NAME environment directory successfully!"
    ;;
    install)
        install $INSTALL_PATH
    ;;
    help|*)
        help $0
    ;;
esac
