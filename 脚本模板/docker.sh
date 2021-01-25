#!/bin/bash

# 使用示例：
# ./docker.sh grep [CONTAINER PREFIX]
# ./docker.sh arthas [CONTAINER PREFIX]
# ./docker.sh svc [STACK NAME]
# ./docker.sh svc-ps [SERVICE]
# ./docker.sh ps [STACK NAME]

source /opt/shell/log.sh

function help () {
    echo "usage: $1 STACK_NAME [grep|arthas|help] [OPTION]"
    echo "    grep                -- grep docker running containers."
    echo "    arthas              -- grep docker running containers, and attach a running container."
    echo "    svc                 -- show serivices of docker stack [STACK NAME]."
    echo "    svc-ps <service>    -- show services ps of docker stack [STACK NAME]."
    echo "    ps                  -- show ps of docker stack [STACK NAME]."
    echo "    help                -- show this info."
    echo ""
    echo "examples:"
    echo "    $1 grep [CONTAINER PREFIX]."
    echo "    $1 arthas [CONTAINER PREFIX]."
    echo "    $1 svc [STACK NAME]."
    echo "    $1 svc-ps [SERVICE]."
    echo "    $1 ps [STACK NAME]."
}

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

# 查找匹配的运行中的容器
function onlyGrep () {
  # 查找匹配的运行中的容器
  CTN=$(docker ps -f status=running | grep $1)
  if [ 0 -ne $? ]; then
    error "not find any match containers"
    exit 1
  fi
  echo $CTN
}

function installArthas () {
  if [ -d ~/.arthas/lib ]; then
    local version=$(ls ~/.arthas/lib/ | sort | tail -1)
    # 本地已安装arthas
    if [ 0 -eq $? ]; then
      echo $version
      return
    fi
  fi

#  # 以脚本的方式启动
#  echo_exec "curl -L https://arthas.aliyun.com/install.sh | sh"

  # 下载 arthas
  if [ ! -e manual/arthas-packaging-bin.zip ]; then
    if [ ! -d manual ]; then
      echo_exec "mkdir manual"
    fi
    h2 "手动安装 arthas"

    if ! echo_exec "wget https://arthas.aliyun.com/download/latest_version?mirror=aliyun -O manual/arthas-packaging-bin.zip"; then
      echo_exec "rm -rf manual/arthas-packaging-bin.zip"
      error "download arthas failed!"
      exit 1
    fi
    echo_exec "cd manual"
    echo_exec "unzip arthas-packaging-bin.zip"
    echo_exec "rm -rf ~/.arthas/lib/*"
    echo_exec "./install-local.sh"
  fi

  local version=$(ls ~/.arthas/lib/ | sort | tail -1)
  # 本地已安装arthas
  if [ 0 -eq $? ]; then
    echo $version
    return
  fi
  exit 1
}

function arthas () {
  # 查找匹配的运行中的容器
  CTN=$(onlyGrep $1)

  if [ 0 -ne $? ]; then
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
  # 安装arthas
  arthas_version=$(installArthas)
  info $arthas_version
  # 判断 arthas 是否已经安装,执行结果返回：0表示文件已经存在，1表示文件或目录不存在。注意上面的 docker exec 的选项是 -i 而不是 -it，否则结果永远是0
  if ! docker exec -i $ID /bin/sh -c "[ -d ~/.arthas/lib/$arthas_version -a -e ~/.arthas/lib/$arthas_version/arthas/arthas-boot.jar ]"; then
    # 由于无法解析变量和~，因此先将文件放到 /tmp/ 目录下
    docker cp ~/.arthas/lib/$arthas_version $ID:/tmp/
    # 在用户目录下创建 arthas 目录，并将 /tmp/ 目录下的内容还原, 使用 if 方式，而不是[]方式，否则执行到此行返回结果是1，无法继续执行
    docker exec -i $ID /bin/sh -c "mkdir -p ~/.arthas/lib && mv /tmp/$arthas_version ~/.arthas/lib"
  fi
  echo_exec "docker exec -it $ID /bin/sh -c \"java -jar ~/.arthas/lib/$arthas_version/arthas/arthas-boot.jar\""

}

case $1 in
    grep)
      onlyGrep $2
    ;;
    arthas)
        arthas $2
    ;;
    svc)
        echo_exec "docker stack services $2"
    ;;
    svc-ps)
        echo_exec "docker service ps $2"
    ;;
    ps)
        echo_exec "docker stack ps $2"
    ;;
    help|*)
        help $0
    ;;
esac

