#!/bin/bash

source /opt/shell/log.sh

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
Linux*) linux=true;;
esac

if [ 1 -ne $# ]; then
  help $0
  exit 1
fi

INSTALL_PATH=$(readlink -f $(dirname "$0"))
cd $INSTALL_PATH
PATTERN=$1

# 查找匹配的运行中的容器
CTN=$(docker ps -f status=running | grep $PATTERN)
if [ 0 -ne $? ]; then
  error "not find any match containers"
  exit 1
fi

# 下载 arthas
if [ ! -e arthas-boot.jar ]; then
  h2 "下载 arthas"
  echo_exec "curl -O https://arthas.aliyun.com/arthas-boot.jar"
  if [ 0 -ne $? ]; then
    echo_exec "rm -rf arthas-boot.jar"
    error "download arthas failed!"
    exit 1
  fi
fi

# 筛选合适的容器，注意 echo $CTN 和 echo "$CTN" 的差异，前者多行结果会合并成一行输出，后者不会
NUM=$(echo "$CTN" | awk 'END {print NR}')
# 多个匹配的容器
if [ 1 -lt $NUM ]; then
  info "存在多个匹配的 docker 容器，请选中一个容器的序号输入，如: 1 再点击 ENTER 。"
  for SEQ in `seq 1 $NUM`; do
    info "[$SEQ]: $(echo "$CTN" | awk 'NR=='$SEQ' {print $0}')"
  done
  read INPUT
  ID=$(echo "$CTN" | awk 'NR=='$INPUT' {print $1}')
else
  ID=$(echo "$CTN" | awk '{print $1}')
fi

echo_exec "docker cp arthas-boot.jar $ID:/arthas-boot.jar"

echo_exec "docker exec -it $ID /bin/sh -c \"java -jar /arthas-boot.jar\""

function help () {
    echo "usage: $1 PATTERN"
    echo "    PATTERN             -- pattern used for grep"
}

