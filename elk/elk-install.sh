#!/bin/bash

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
STACK_SHELL=stack.sh
# docker stack 使用的 STACK 名称
STACK_NAME=elk

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
  echo_exec "mkdir -pv $INSTALL_ROOT/elasticsearch/{data,ik}"
  echo_exec "mkdir -pv $INSTALL_ROOT/logstash/{config,pipeline,build}"
  echo_exec "mkdir -pv $INSTALL_ROOT/grafana/data"
#  echo_exec "unzip elasticsearch-analysis-ik-7.3.1.zip -d $INSTALL_ROOT/elasticsearch/ik"

  echo_exec "cp logstash.conf $INSTALL_ROOT/logstash/pipeline"
  echo_exec "cp $STACK_SHELL $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "cp $STACK_YML $INSTALL_ROOT/$STACK_YML"

#  echo_exec "chown 1000:1000 -R $INSTALL_ROOT/"

  if $darwin; then
      echo_exec "sed -i '' 's|/opt|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
  else
      echo_exec "sed -i 's|/opt|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
  fi

  echo_exec "chmod +x $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "docker stack deploy -c $STACK_YML $INSTALL_ROOT/$STACK_NAME"
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
