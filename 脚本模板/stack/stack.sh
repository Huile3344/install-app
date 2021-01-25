#!/bin/bash

source /opt/shell/log.sh

function help () {
    echo "usage: $1 STACK_NAME [deploy|svc|svc-ps|ps|rm|help] [OPTION]"
    echo "    deploy              -- deploy a docker stack [STACK_NAME]."
    echo "    svc                 -- show serivices of docker stack [STACK_NAME]."
    echo "    svc-ps <service>    -- show serivices ps of docker stack [STACK_NAME]."
    echo "    ps                  -- show ps of docker stack [STACK_NAME]."
    echo "    rm                  -- remove docker stack [STACK_NAME]."
    echo "    help                -- show this info."
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

case $2 in
    svc)
        echo_exec "docker stack services $STACK_NAME"
    ;;
    svc-ps)
        echo_exec "docker service ps $3 $STACK_NAME"
    ;;
    ps)
        echo_exec "docker stack ps $STACK_NAME"
    ;;
    rm)
        echo_exec "docker stack rm $STACK_NAME"
        success $"rm $STACK_NAME of docker successfully!"
    ;;
    deploy)
        echo_exec "docker stack deploy -c $STACK_YML $STACK_NAME"
        success $"deploy $STACK_NAME of docker successfully!"
    ;;
    help|*)
        help $0
    ;;
esac
