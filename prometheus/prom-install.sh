#!/bin/bash

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
STACK_SHELL=stack.sh
# docker stack 使用的 STACK 名称
STACK_NAME=prom

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
Linux*) linux=true;;
esac

function install () {
  INSTALL_ROOT=$1
  note "INSTALLER_ROOT: $INSTALL_ROOT"
  h1 "install $STACK_NAME of docker"
  echo_exec "mkdir -pv $INSTALL_ROOT/prometheus/data"
  echo_exec "mkdir -pv $INSTALL_ROOT/alertmanager/data"
  echo_exec "mkdir -pv $INSTALL_ROOT/node-exporter"
  echo_exec "mkdir -pv $INSTALL_ROOT/grafana/{datasources,dashboards,config,logs}"
  echo_exec "mkdir -pv $INSTALL_ROOT/grafana/data/plugins"

  echo_exec "unzip grafana/plugins/grafana-simple-json-datasource-*.zip -d $INSTALL_ROOT/grafana/data/plugins/"
  echo_exec "mv $INSTALL_ROOT/grafana/data/plugins/grafana-simple-json-datasource-* $INSTALL_ROOT/grafana/data/plugins/grafana-simple-json-datasource"
  echo_exec "unzip grafana/plugins/grafana-clock-panel-*.zip -d $INSTALL_ROOT/grafana/data/plugins/"
  echo_exec "mv $INSTALL_ROOT/grafana/data/plugins/grafana-clock-panel-* $INSTALL_ROOT/grafana/data/plugins/grafana-clock-panel"
  echo_exec "unzip grafana/plugins/grafana-piechart-panel-*.zip -d $INSTALL_ROOT/grafana/data/plugins/"
  echo_exec "mv $INSTALL_ROOT/grafana/data/plugins/grafana-piechart-panel-* $INSTALL_ROOT/grafana/data/plugins/grafana-piechart-panel"

  echo_exec "cp prometheus.yml $INSTALL_ROOT/prometheus/"
  echo_exec "cp alertmanager.yml $INSTALL_ROOT/alertmanager/"
  echo_exec "cp $STACK_SHELL $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "cp $STACK_YML $INSTALL_ROOT/$STACK_YML"

  if [ $darwin ]; then
      echo_exec "sed -i '' 's|/opt/prom|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
      echo_exec "sed -i '' 's|/opt/prom|$INSTALL_ROOT|g' $INSTALL_ROOT/prometheus/prometheus.yml"
  else
      echo_exec "sed -i 's|/opt/prom|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
      echo_exec "sed -i 's|/opt/prom|$INSTALL_ROOT|g' $INSTALL_ROOT/prometheus/prometheus.yml"
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
