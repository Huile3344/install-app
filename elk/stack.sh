#!/bin/bash

source /opt/shell/log.sh


function install () {
  INSTALL_ROOT=$1
  echo_exec "cd $INSTALL_ROOT"
  note "INSTALLER_ROOT: $INSTALL_ROOT"
  h1 "install $STACK_NAME of docker"
  echo_exec "mkdir -pv $INSTALL_ROOT/elk/elasticsearch/{data,ik}"
  echo_exec "mkdir -pv $INSTALL_ROOT/elk/logstash/{config,pipeline,build}"
  echo_exec "mkdir -pv $INSTALL_ROOT/elk/grafana/data"
#  echo_exec "unzip elasticsearch-analysis-ik-7.3.1.zip -d $INSTALL_ROOT/elk/elasticsearch/ik"
  echo_exec "cp logstash.conf $INSTALL_ROOT/elk/logstash/pipeline"
#  echo_exec "chown 1000:1000 -R $INSTALL_ROOT/elk/"

  if $darwin; then
      echo_exec "sed -i '' 's|/opt|$INSTALL_ROOT|g' $STACK_YML"
  else
      echo_exec "sed -i 's|/opt|$INSTALL_ROOT|g' $STACK_YML"
  fi

  echo_exec "docker stack deploy -c $STACK_YML $STACK_NAME"
  echo_exec "sleep 3"
  echo_exec "docker stack services $STACK_NAME"
  success $"install docker stack [$STACK_NAME] successfully!"
}

function help () {
    echo "usage: $1 STACK_NAME [install|deploy|svc|svc-ps|ps|rm|clean] [OPTION]"
    echo "    install             -- create a enviroment directory and deploy for docker stack [STACK_NAME]."
    echo "    deploy              -- deploy a docker stack [STACK_NAME]."
    echo "    svc                 -- show serivices of docker stack [STACK_NAME]."
    echo "    svc-ps <service>    -- show serivices ps of docker stack [STACK_NAME]."
    echo "    ps                  -- show ps of docker stack [STACK_NAME]."
    echo "    rm                  -- remove docker stack [STACK_NAME]."
    echo "    clean               -- clean enviroment directory for docker stack [STACK_NAME]."
}

STACK_YML=stack.yml
STACK_NAME=$1

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac


if $darwin; then
    BASH_PATH=$(dirname "${BASH_SOURCE}")
    INSTALL_PATH=`cd $BASH_PATH && pwd`
else
    INSTALL_PATH=$(readlink -f $(dirname "${BASH_SOURCE}"))
fi

case $2 in
    svc)
        echo_exec "docker stack services $STACK_NAME"
    ;;
    svc-ps)
        echo_exec "docker stack services ps $3 $STACK_NAME"
    ;;
    ps)
        echo_exec "docker stack ps $STACK_NAME"
    ;;
    rm)
        echo_exec "docker stack rm $STACK_NAME"
        success $"rm $STACK_NAME of docker successfully!"
    ;;
    rm)
        echo_exec "rm -rf $INSTALL_PATH"
        success $"clean $STACK_NAME environment directory successfully!"
    ;;
    deploy)
        echo_exec "docker stack deploy -c $STACK_YML $STACK_NAME"
        success $"deploy $STACK_NAME of docker successfully!"
    ;;
    install)
        install $INSTALL_PATH
    ;;
    help|*)
        help $0
    ;;
esac
