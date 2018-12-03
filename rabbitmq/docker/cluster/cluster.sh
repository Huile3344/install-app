#!/bin/bash

source /opt/shell/log.sh

START_PORT=5672
NODES=3

if [ -a config.sh ]
then
    source "config.sh"
fi

if [ "$1" == "start" ]
then
    # 拉取 rabbitmq 镜像
    RABBITMQ_VERSION=3.6-management
    #echo_exec "docker pull rabbitmq:${RABBITMQ_VERSION}"

    # 创建docker网络redis
    echo_exec "docker network create rabbitmq-net"

    HOSTS=""
    for SEQ in `seq 0 $((NODES-1))`; do
        PORT=$((${START_PORT}+SEQ))
        echo_exec "mkdir -pv /data/rabbitmq-cluster/${PORT}/{conf,mnesia}"
        echo_exec "cp rabbitmq.conf /data/rabbitmq-cluster/${PORT}/conf"

        bus_port=$((${PORT}+10000))
        #rabbitmq1 rabbitmq2  rabbitmq3

        # RABBITMQ_ERLANG_COOKIE 变量用于指定集群鉴权cookie，集群节点需一致，否则提示如下错误信息
# rabbitmq0@rabbitmq0:
#    * connected to epmd (port 4369) on rabbitmq0
#    * epmd reports node 'rabbitmq0' running on port 25672
#    * TCP connection succeeded but Erlang distribution failed
#
#    * Authentication failed (rejected by the remote node), please check the Erlang cookie

#        -v /data/rabbitmq-cluster/${PORT}/conf/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf \
        echo_exec "docker run -d -p ${PORT}:5672 -p ${bus_port}:15672 \
        -e RABBITMQ_NODENAME=rabbitmq${SEQ} \
        -e RABBITMQ_ERLANG_COOKIE='mfp' \
        -h rabbitmq${SEQ} \
        -v /data/rabbitmq-cluster/${PORT}/mnesia:/var/lib/rabbitmq/mnesia \
        --restart always --name rabbitmq${SEQ} --net rabbitmq-net \
        --sysctl net.core.somaxconn=1024 rabbitmq:${RABBITMQ_VERSION}"

        [ ${SEQ} -eq 0 ] && continue;

        info "睡眠5秒，等待rabbitmq镜像容器正常启动"
        echo_exec "sleep 5"

        info "将rabbitmq${SEQ}容器服务节点[rabbitmq${SEQ}@rabbitmq${SEQ}]加入到rabbitmq0容器服务节点[rabbitmq0@rabbitmq0]集群"

#        echo_exec "docker exec -it rabbitmq${SEQ} rabbitmqctl -n rabbitmq${SEQ}@rabbitmq${SEQ} -q stop_app"
#        echo_exec "docker exec -it rabbitmq${SEQ} rabbitmqctl -n rabbitmq${SEQ}@rabbitmq${SEQ} -q reset"
#        echo_exec "docker exec -it rabbitmq${SEQ} rabbitmqctl -n rabbitmq${SEQ}@rabbitmq${SEQ} -q join_cluster rabbitmq0@rabbitmq0"
#        echo_exec "docker exec -it rabbitmq${SEQ} rabbitmqctl -n rabbitmq${SEQ}@rabbitmq${SEQ} -q start_app"

        # 将第三个节点设置为内存节点
        [ $((NODES-1)) -eq ${SEQ} ] && RAM="--ram"


        echo_exec "docker exec -it rabbitmq${SEQ} bash -c \"\
            rabbitmqctl stop_app;\
            rabbitmqctl reset;\
            rabbitmqctl join_cluster rabbitmq0@rabbitmq0 $RAM;\
            rabbitmqctl start_app\""

    done
    exit 0
fi

if [ "$1" == "stop" ]
then
    for SEQ in `seq 0 $((NODES-1))`; do
        info "Stopping rabbitmq${SEQ}"
        echo_exec "docker stop rabbitmq${SEQ}"
    done
    exit 0
fi


# 删除docker容器
if [ "$1" == "rm" ]
then
    for SEQ in `seq 0 $((NODES-1))`; do
        info "removing container rabbitmq${SEQ}"
        echo_exec "docker rm rabbitmq${SEQ}"
    done
    # 删除网络
    docker network rm rabbitmq-net
    exit 0
fi

if [ "$1" == "watch" ]
then
#    while [ 1 ]; do
        clear
        date
        echo_exec "docker exec -it rabbitmq0 rabbitmqctl status"
        sleep 1
#    done
    exit 0
fi

if [ "$1" == "tail" ]
then
    INSTANCE=$2
    SEQ=$((INSTANCE-1))
    echo_exec "docker logs -f rabbitmq${SEQ}"
    exit 0
fi

if [ "$1" == "clean" ]
then
    for SEQ in `seq 0 $((NODES-1))`; do
        PORT=$((${START_PORT}+SEQ))
        info "Stopping rabbitmq${SEQ}"
        echo_exec "docker stop rabbitmq${SEQ}"
        info "removing container rabbitmq${SEQ}"
        echo_exec "docker rm rabbitmq${SEQ}"
        echo_exec "rm -rf /data/rabbitmq-cluster/${PORT}"
        info "------------------------------------"
    done
    # 删除网络
    docker network rm rabbitmq-net
    exit 0
fi

# docker 方式没有日志
if [ "$1" == "clean-logs" ]
then
    for SEQ in `seq 0 $((NODES-1))`; do
        PORT=$((${START_PORT}+SEQ))
        echo_exec "rm -rf /data/rabbitmq-cluster/${PORT}/data/*.log"
    done
    exit 0
fi

echo "Usage: $0 [start|stop|watch|tail|clean]"
echo "start       -- Create and Launch RabbitMQ Cluster instances."
echo "stop        -- Stop RabbitMQ Cluster instances."
echo "watch       -- Show CLUSTER NODES output (first 30 lines) of first node."
echo "tail <id>   -- Run tail -f of instance at base port + ID."
echo "clean       -- Remove all instances data, logs, configs."
echo "clean-logs  -- Remove just instances logs."