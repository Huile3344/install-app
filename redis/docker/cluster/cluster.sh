#!/bin/bash

source /opt/shell/log.sh

START_PORT=30001
NODES=6
REPLICAS=1

if [ -a config.sh ]
then
    source "config.sh"
fi

if [ "$1" == "start" ]
then
    # 拉取 redis 镜像
    REDIS_VERSION=5
    #echo_exec "docker pull redis:${REDIS_VERSION}"

    # 创建docker网络redis
    echo_exec "docker network create redis-net"

    HOSTS=""
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
      echo_exec "mkdir -pv /data/redis-cluster/${PORT}/{conf,data}"
      echo_exec "cp redis.conf /data/redis-cluster/${PORT}/conf"
    #  cat <<EOF >  /data/redis-cluster/${PORT}/conf/redis.conf
    #      port 6379
    #      cluster-enabled yes
    #      cluster-config-file nodes.conf
    #      cluster-node-timeout 5000
    #      cluster-announce-port 6379
    #      cluster-announce-bus-port 16379
    #      appendonly yes
    #  EOF

      bus_port=$((${PORT}+10000))
      echo_exec "docker run -d -p ${PORT}:6379 -p ${bus_port}:16379 \
      -v /data/redis-cluster/${PORT}/conf/redis.conf:/etc/redis/redis.conf \
      -v /data/redis-cluster/${PORT}/data:/data \
      --restart always --name redis-${PORT} --net redis-net \
      --sysctl net.core.somaxconn=1024 redis:${REDIS_VERSION} redis-server /etc/redis/redis.conf"

      # 目前发现不支持DNS方式的Redis集群创建，会报IP解析异常
      # HOSTS="$HOSTS redis-${PORT}:6379"

      # 使用IP方式的Redis集群创建
      NODE_IP=$(docker inspect --format '{{ (index .NetworkSettings.Networks "redis-net").IPAddress }}' "redis-${PORT}")
      HOSTS="$HOSTS ${NODE_IP}:6379"

    done

    # 将启动的Redis节点变成Redis集群
    echo_exec "docker exec -it redis-${START_PORT} redis-cli --cluster create $HOSTS --cluster-replicas $REPLICAS"

    exit 0
fi

if [ "$1" == "create" ]
then
    HOSTS=""
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        NODE_IP=$(docker inspect --format '{{ (index .NetworkSettings.Networks "redis-net").IPAddress }}' "redis-${PORT}")
        HOSTS="$HOSTS ${NODE_IP}:6379"
    done
    echo_exec "docker exec -it redis-${START_PORT} redis-cli --cluster create $HOSTS --cluster-replicas $REPLICAS"
    exit 0
fi

if [ "$1" == "stop" ]
then
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        info "Stopping redis-${PORT}"
        echo_exec "docker stop redis-${PORT}"
    done
    exit 0
fi


# 删除docker容器
if [ "$1" == "rm" ]
then
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        info "removing container redis-${PORT}"
        echo_exec "docker rm redis-${PORT}"
    done
    # 删除网络
    docker network rm redis-net
    exit 0
fi

if [ "$1" == "watch" ]
then
    while [ 1 ]; do
        clear
        date
        echo_exec "docker exec -it redis-${START_PORT} redis-cli cluster nodes | head -30"
        sleep 1
    done
    exit 0
fi

if [ "$1" == "tail" ]
then
    INSTANCE=$2
    PORT=$((START_PORT+INSTANCE-1))
    echo_exec "docker logs -f redis-${PORT}"
    exit 0
fi

if [ "$1" == "call" ]
then
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        echo_exec "docker exec -it redis-${PORT} redis-cli $2 $3 $4 $5 $6 $7 $8 $9"
    done
    exit 0
fi

if [ "$1" == "clean" ]
then
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        info "Stopping redis-${PORT}"
        echo_exec "docker stop redis-${PORT}"
        info "removing container redis-${PORT}"
        echo_exec "docker rm redis-${PORT}"
        echo_exec "rm -rf /data/redis-cluster/${PORT}"
        info "------------------------------------"
    done
    # 删除网络
    docker network rm redis-net
    exit 0
fi

# docker 方式没有日志
if [ "$1" == "clean-logs" ]
then
    for PORT in `seq ${START_PORT} $((START_PORT+NODES-1))`; do
        echo_exec "rm -rf /data/redis-cluster/${PORT}/data/*.log"
    done
    exit 0
fi

echo "Usage: $0 [start|create|stop|watch|tail|clean]"
echo "start       -- Launch Redis Cluster instances."
echo "create      -- Create a cluster using redis-cli --cluster create."
echo "stop        -- Stop Redis Cluster instances."
echo "watch       -- Show CLUSTER NODES output (first 30 lines) of first node."
echo "tail <id>   -- Run tail -f of instance at base port + ID."
echo "clean       -- Remove all instances data, logs, configs."
echo "clean-logs  -- Remove just instances logs."