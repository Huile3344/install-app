#!/bin/bash

# 使用示例：
# ./stack-install.sh [STACK NAME] install [INSTALL PATH] [INSTALL SHELL]
# ./stack-install.sh [STACK NAME] install [INSTALL PATH]
# ./stack-install.sh [STACK NAME] clean  [INSTALL PATH]
# ./stack-install.sh [STACK NAME] deploy [STACK YML]
# ./stack-install.sh [STACK NAME] deploy
# ./stack-install.sh [STACK NAME] rm

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
#STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
#STACK_SHELL=stack.sh
# 默认提供使用的 stack 安装脚本文件，方便使用
#INSTALL_SHELL=install.sh

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

function help () {
    echo "usage: $1 [STACK NAME] [install|clean|deploy|rm|help]"
    echo "    install             -- create a enviroment directory and deploy for"
    echo "                           docker stack [STACK NAME]."
    echo "    clean               -- clean enviroment directory for docker stack [STACK NAME]."
    echo "    deploy              -- deploy a docker stack [STACK NAME]."
    echo "    rm                  -- remove docker stack [STACK NAME]."
    echo "    help                -- show this info."
    echo ""
    echo "examples:"
    echo "    $1 [STACK NAME] install [INSTALL PATH] [INSTALL SHELL]."
    echo "    $1 [STACK NAME] install [INSTALL PATH]."
    echo "    $1 [STACK NAME] clean [INSTALL PATH]."
    echo "    $1 [STACK NAME] deploy [STACK YML]."
    echo "    $1 [STACK NAME] deploy."
    echo "    $1 [STACK NAME] rm."
}

#if $darwin; then
#    BASH_PATH=$(dirname "${BASH_SOURCE}")
#    INSTALL_PATH=`cd $BASH_PATH && pwd`
#else
#    INSTALL_PATH=$(readlink -f $(dirname "${BASH_SOURCE}"))
#fi


case $2 in
    clean)
        INSTALL_PATH=$(cd $3 && pwd)/$1
        echo_exec "docker stack rm $1"
        while [ $(docker stack ps $1) ]; do
            #docker stack ps $1 || break
            # 不换行输出
            echo  -e ".\c"
            sleep 1
        done
        echo
        echo_exec "rm -rf $INSTALL_PATH"
        success $"clean $2 environment directory successfully!"
    ;;
    install)
        INSTALL_PATH=$(cd $3 && pwd)/$1
        # 安装脚本: 如:install.sh
        source ${4:-install.sh}
        install $INSTALL_PATH
    ;;
    rm)
        echo_exec "docker stack rm $1"
        success $"rm $1 of docker successfully!"
    ;;
    deploy)
        echo_exec "docker stack deploy -c ${3:-stack.yml} $1"
        success $"deploy $2 of docker successfully!"
    ;;
    help|*)
        help $0
    ;;
esac
