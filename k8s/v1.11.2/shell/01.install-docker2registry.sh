#!/bin/bash

ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/..)

source "$ROOT/shell/01.install-docker.sh"

step=1
echo -e "\n******** step $step set ip of docker.registry ********"
# 2. 指定docker.registry主机ip
read -p "Enter your host ip of docker.registry to /etc/hosts. : " reply
if [ -z "$reply" ]; then
	reply="127.0.0.1"
fi
echo "your docker.registry host ip is: $reply"



let step=step+1
echo -e "\n******** step $step put ip of docker.registry to /etc/hosts ********"
# 3. 添加主机ip和主机名到hosts中
# echo "192.169.1.6  docker.registry" >>  /etc/hosts
echo "$reply  docker.registry" >>  /etc/hosts
echo "====== start cat /etc/hosts"
cat /etc/hosts
echo "====== end cat /etc/hosts"



let step=step+1
echo -e "\n******** step $step generate /etc/docker/daemon.json ********"
# 4. 配置镜像加速器(针对Docker客户端版本大于1.10.0的用户)
if [ ! -d /etc/docker ]; then
  sudo mkdir -p /etc/docker
fi
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "insecure-registries":["docker.registry:5000"],
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"]
}
EOF
echo_exec sudo systemctl daemon-reload



let step=step+1
echo -e "\n********* step $step start docker ********"
# 5. 将docker加入开机启动进程中，且启动docker
echo_exec systemctl enable docker && systemctl start docker

echo "installed docker to docker.registry"

