#!/bin/bash
source /opt/shell/log.sh

# kubernetes 容器运行时安装 https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/

## 安装docker后配置
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"],
  "storage-driver": "overlay2"
}
EOF


