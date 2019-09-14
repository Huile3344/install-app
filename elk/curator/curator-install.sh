#!/bin/bash

source /opt/shell/log.sh


case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

function install () {
  IP=$1
  USER_HOME=`cd && pwd`
  note "USER_HOME: $USER_HOME"
  h1 "install elasticsearch-curator"

  echo_exec "mkdir -pv ~/.curator/"
  echo_exec "cp action.yml curator.yml ~/.curator/"

  CURATOR_PATH=$USER_HOME/.curator

  if $darwin; then
      echo_exec "sed -i '' 's|/root|$USER_HOME|g' $CURATOR_PATH/curator.yml"
      echo_exec "sed -i '' 's|elasticsearch|$IP|g' $CURATOR_PATH/curator.yml"
  else
      echo_exec "sed -i 's|/root|$USER_HOME|g' $CURATOR_PATH/curator.yml"
      echo_exec "sed -i 's|elasticsearch|$IP|g' $CURATOR_PATH/curator.yml"
  fi

  info "add a crontab: 5 0 * * * curator $CURATOR_PATH/action.yml "
  echo '5 0 * * * curator $CURATOR_PATH/action.yml' | crontab

  echo_exec "pip3 install elasticsearch-curator"
  echo_exec "curator_cli show_indices" || error "Please reinstall with right ip of elasticsearch, or fix elasticsearch ip for $CURATOR_PATH/curator.yml" && exit 1
  success $"install elasticsearch-curator successfully!"
  success $"Have Fun!"
}

function help () {
    echo "usage: $1 STACK_NAME [install|clean] ES-IP"
    echo "    install             -- create a elasticsearch curator for"
    echo "                           the ip of elasticsearch."
    echo "    clean               -- clean elasticsearch curator crontab."
}

case $1 in
    clean)
        echo_exec "rm -rf ~/.curator"
        note "please input command: crontab -e, to delete target crontab item or curator"
        success $"clean crontab successfully!"
    ;;
    install)
        if [ $# == 2 ]; then
            install $INSTALL_PATH $2 && exit 0
        else
            help $0
        fi
    ;;
    help|*)
        help $0
    ;;
esac
