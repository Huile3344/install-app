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

#本地是否有jdk
java -version &> /dev/null && local_jdk=0
arthas_version=

function help () {
    echo "usage: $1 [help|install|grep PATTERN]"
    echo "    help                -- print usage"
    echo "    install             -- download arthas-boot.jar and it's dependencies jar"
    echo "    grep PATTERN        -- pattern used for grep"
    exit 0
}

function download () {
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
}

function install () {
  download
  if [ 0 -eq $local_jdk ]; then
    # 获取 arthas 版本
    arthas_version=$(java -jar arthas-boot.jar -h | grep "version:" | awk '{print $4}')
    arthas_lib_home=~/.arthas/lib/$arthas_version/arthas
    if [ ! -d $arthas_lib_home ]; then
      info "开始下载 arthas ${arthas_version} 版本依赖的jar包，若下载失败请手动删除文件夹: ${arthas_lib_home}"
      echo_exec "java -jar arthas-boot.jar"
      read -p "下载 arthas 依赖的jar包成功？ [y/n] n:表示失败，将删除下载内容 默认:y -> " DEL
      if [[ "n" = $DEL ]]; then
        echo_exec "rm -rf ~/.arthas/lib/$arthas_version"
        exit 1
      fi
      info "完成下载 arthas ${arthas_version} 版本依赖的jar包"
    fi
  fi
}

function grepFunc () {
  PATTERN=$1

  install

  # 查找匹配的运行中的容器
  CTN=$(docker ps -f status=running | grep $PATTERN)
  if [ 0 -ne $? ]; then
    error "not find any match containers"
    exit 1
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

  if [ 0 -eq $local_jdk ]; then
    # 由于无法解析变量和~，因此先将文件放到 /tmp/ 目录下
    echo_exec "docker cp ~/.arthas/lib/$arthas_version $ID:/tmp/"
    # 在用户目录下创建 arthas 目录，并将 /tmp/ 目录下的内容还原, 使用使用 if 方式，而不是[]方式，否则执行到此行返回结果是1，无法继续执行
    echo_exec "docker exec -it $ID /bin/sh -c \"if [ ! -d ~/.arthas/lib/$arthas_version ]; then \
      mkdir -p ~/.arthas/lib && mv /tmp/$arthas_version ~/.arthas/lib; fi\""
    echo_exec "docker exec -it $ID /bin/sh -c \"java -jar ~/.arthas/lib/$arthas_version/arthas/arthas-boot.jar\""
  else
    echo_exec "docker cp arthas-boot.jar $ID:/arthas-boot.jar"
    echo_exec "docker exec -it $ID /bin/sh -c \"java -jar /arthas-boot.jar\""
  fi
}

case $1 in
    install)
      install
    ;;
    grep)
      grepFunc $2
    ;;
    help|*)
      help $0
    ;;
esac
