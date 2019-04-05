#!/bin/bash
#
# 安装docker，并配置阿里云docker镜像加速器

source /opt/shell/log.sh

ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/..)
h2 "INSTALLER_ROOT: $ROOT"

step=1
# 卸载已经安装的旧版本docker 
echo "******** step $step uninstall old docker ********"
echo_exec yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine \
                  docker-ce    # 比较新版本的docker是docker-ce

				  
let step=step+1
# 一、Docker相关(适用于kubernetes-1.9.0和kubernetes-1.10.1-beta.0)和启动registry:2
echo -e "\n******** step $step install docker ********"
# 1. 安装docker
echo_exec yum install -y docker*.rpm



let step=step+1
echo -e "\n******** step $step generate /etc/docker/daemon.json ********"
# 2. 配置镜像加速器(针对Docker客户端版本大于1.10.0的用户)
if [ ! -d /etc/docker ]; then
  sudo mkdir -p /etc/docker
fi
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"]
}
EOF
echo_exec sudo systemctl daemon-reload



let step=step+1
echo -e "\n********* step $step start docker ********"
# 3. 将docker加入开机启动进程中，且启动docker
echo_exec systemctl enable docker && systemctl start docker

echo "installed docker"

