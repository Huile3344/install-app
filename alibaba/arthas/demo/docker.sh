#!/bin/bash
# 使用示例：
# ./docker.sh help
# ./docker.sh build
# ./docker.sh run
# ./docker.sh stop
# ./docker.sh rm

source /opt/shell/log.sh

set +e

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
Linux*) linux=true;;
esac

# 镜像名字
image_name=demo-arthas-spring-boot
# 镜像标签
image_tag=latest
# 容器名字
ctn_name=demo-arthas-spring-boot

function help () {
    echo "usage: $1 [help|build|run|stop|rm]"
    echo "    help                -- print usage"
    echo "    build               -- build docker image"
    echo "    run                 -- run docker container"
    echo "    stop                -- stop docker container"
    echo "    rm                  -- remove docker container"
}

function build () {
  echo_exec "docker build . -t ${image_name}:${image_tag}"
}

function buildIfNotExists () {
  # 镜像不存在则先build
  if ! docker images | grep $image_name | grep $image_tag > /dev/null; then
    build
  fi
}

function run () {
  # 若有相同命名的容器存在，则先删除已存在的容器
  if docker ps --filter name="$ctn_name" | grep -v NAMES > /dev/null; then
    info "容器已经在运行中：$ctn_name"
  elif docker ps -a --filter name="$ctn_name" | grep -v NAMES > /dev/null; then
    info "容器已经存在：$ctn_name"
    echo_exec "docker start $ctn_name"
  else
    buildIfNotExists
    echo_exec "docker run --name \"$ctn_name\" -p 8080:80 -d ${image_name}:${image_tag}"
  fi
}

function stop () {
  echo_exec "docker stop \"$ctn_name\""
}

function rm () {
  # 若有相同命名的容器在运行中，则先停掉运行中的容器
  if docker ps --filter name="$ctn_name" | grep -v NAMES > /dev/null; then stop; fi
  echo_exec "docker rm $ctn_name"
}

case $1 in
    build)
      build
    ;;
    run)
      run
    ;;
    stop)
      stop
    ;;
    rm)
      rm
    ;;
    help|*)
      help $0
    ;;
esac
