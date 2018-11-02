#!/bin/bash
# install mongo cluster by docker

# 打印命令，再执行命令
function echo_exec () {
  echo "\$ $@"
  eval $@
  ok=$?
  echo
  return $ok
}


SHELL_PATH=$(dirname $(readlink -f $0))
cd $SHELL_PATH

step=1
docker --version &> /dev/null
if [ 0 -ne $? ]; then
  # Docker相关(适用于kubernetes-1.9.0和kubernetes-1.10.1-beta.0)和启动registry:2
  echo -e "\n******** step $step install docker ********"; let step+=1
  # 1. 配置镜像加速器(针对Docker客户端版本大于1.10.0的用户)
  if [ ! -d /etc/docker ]; then
    sudo mkdir -p /etc/docker
  fi
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"]
}
EOF
  # 2. 安装docker
  echo_exec yum install -y docker*.rpm
  echo_exec systemctl daemon-reload
  echo_exec systemctl enable docker
  echo_exec systemctl start docker
fi
echo_exec docker --version
if [ 0 -ne $? ]; then
  echo -e "\n----------------------"
  echo "mongo 集群安装依赖的 docker 安装失败"
  echo "----------------------"
  exit 1
fi
echo_exec docker load < image.tar

docker-compose --version &> /dev/null
if [ 0 -ne $? ]; then
  echo -e "\n******** step $step install docker-compose ********"; let step+=1
  #echo_exec "curl -L \"https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose"
  echo_exec cp docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
  echo_exec chmod +x /usr/local/bin/docker-compose
fi
echo_exec docker-compose --version
if [ 0 -ne $? ]; then
  echo -e "\n----------------------"
  echo "mongo 集群安装依赖的 docker-compose 安装失败"
  echo "----------------------"
  exit 1
fi

echo -e "\n----------------------"
echo "mongo 集群安装依赖的 docker 和 docker-compose 都已成功安装"
echo "----------------------"
