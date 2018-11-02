#!/bin/bash


ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/..)
source "$ROOT/shell/01.install-docker.sh"


step=1
echo -e "\n******** step $step load image ********"
# 3. 将registry:2镜像(或本地镜像)load到docker中
echo_exec docker load -i $ROOT/image/image.tar



let step=step+1
echo -e "\n******** step $step extract docker-registry.tar.gz ********"
if [ ! -d /opt/docker-registry ]; then
# 4. 将已有的私服镜像压缩文件(docker-registry.tar.gz)解压的本机的/opt目录下，作为私服初始镜像目录
echo_exec tar -C /opt -zxf $ROOT/registry/docker-registry.tar.gz
fi



let step=step+1
echo -e "\n******** step $step run docker registry ********"
# 5. 将私服镜像目录挂载到registry镜像容器的镜像目录中，当前绑定了主机的5000端口，启动docker私服镜像（后续服务器重启也会自动启动）
echo_exec docker run -d -v /opt/docker-registry/:/var/lib/registry/ -p 5000:5000 --restart always --name registry-v2 registry:2


let step=step+1
echo -e "\n******** step $step set ip of docker.registry ********"
# 6. 指定主机ip
read -p "Enter your docker.registry host ip of docker-registry to /etc/hosts. : " reply
if [ -z "$reply" ]; then
  reply="127.0.0.1"
fi
echo "your docker.registry host ip is: $reply"



let step=step+1
echo -e "\n******** step $step put ip of docker.registry to /etc/hosts ********"
# 7. 添加主机ip和主机名到hosts中
# echo "192.169.1.6  docker.registry" >>  /etc/hosts
echo "$reply  docker.registry" >>  /etc/hosts
echo "====== start cat /etc/hosts"
cat /etc/hosts
echo "====== end cat /etc/hosts"



let step=step+1
echo -e "\n******** step $step generate /etc/docker/daemon.json ********"
# 8. 配置镜像加速器(针对Docker客户端版本大于1.10.0的用户)和私服信息
if [ ! -d /etc/docker ]; then
  sudo mkdir -p /etc/docker
fi
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "insecure-registries":["docker.registry:5000"],
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"]
}
EOF



let step=step+1
echo -e "\n********* step $step daemon-relaod and restart docker ********"
echo_exec sudo systemctl daemon-reload
echo_exec sudo systemctl restart docker

#curl -X GET http://docker.registry:5000/v2/_catalog
#查看仓库镜像数据

echo "installed docker with docker.registry"


