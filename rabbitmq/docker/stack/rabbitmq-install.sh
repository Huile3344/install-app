#!/bin/bash

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
STACK_SHELL=stack.sh
# docker stack 使用的 STACK 名称
STACK_NAME=rabbit

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
  echo_exec "mkdir -pv $INSTALL_ROOT/{rabbit,rabbit2,rabbit3}/{config,ssl}"
  echo_exec "mkdir -pv $INSTALL_ROOT/{rabbit,rabbit2,rabbit3}/data/mnesia"

#  echo_exec "cp enabled_plugins $INSTALL_ROOT/enabled_plugins"
  echo_exec "cp $STACK_SHELL $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "cp $STACK_YML $INSTALL_ROOT/$STACK_YML"

  if $darwin; then
      echo_exec "sed -i '' 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
  else
      echo_exec "sed -i 's|/opt/x|$INSTALL_ROOT|g' $INSTALL_ROOT/$STACK_YML"
  fi

  echo_exec "chmod +x $INSTALL_ROOT/$STACK_SHELL"
  echo_exec "docker stack deploy -c $INSTALL_ROOT/$STACK_YML $STACK_NAME"
  echo_exec "sleep 10"
  echo_exec "docker stack services $STACK_NAME"
  success $"install docker stack [$STACK_NAME] successfully!"
  echo_exec "sleep 20"
  # 等待服务大致启动完成后，执行以下内容才不会出错，否则即使服务正常也会出错
  cluster rabbit@rabbit rabbit2 rabbit3
  success $"You Know, Time to You!"
}

function cluster () {
    CLUSTER=$1
    NODES=$(($#-1))
    shift
    for RABBIT in $*; do
        while [ 1 ]; do
            echo_exec "sleep 1"
            echo_exec "docker service ps rabbit_$RABBIT -f desired-state=Running"
            if [ $? -eq 0 ]; then
                break
            fi
            # 不截取错误信息
            echo_exec "docker service ps rabbit_$RABBIT --no-trunc -f desired-state=Shutdown --format='{{.Error}}'"
            if [ $? -eq 0 ]; then
                error "rabbit_$RABBIT service 相关容器启动失败"
                break
            fi
            if [ $? -eq 0 ]; then
                echo_exec "docker service ps rabbit_$RABBIT -f desired-state=Ready"
                info "rabbit_$RABBIT service 启动中..."
            fi
        done
        NODES=$((NODES--))
        # 最后一个节点设置为内存节点
        [ $NODES -eq 0 ] && RAM="--ram"
        # echo_exec "docker exec -it \$(docker ps | grep $RABBIT | awk '{ print \$1 }') bash -c \"\
        echo_exec "docker exec -it \$(docker ps -q -f name=$RABBIT) bash -c \"\
                rabbitmqctl stop_app;\
                rabbitmqctl reset;\
                rabbitmqctl join_cluster $CLUSTER $RAM;\
                rabbitmqctl start_app\""
    done

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
