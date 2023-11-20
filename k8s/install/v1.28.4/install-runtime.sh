#!/bin/bash

# 安装在最新版本示例 ./install-runtime.sh

# 和 v1.20.5 的 kubeadm 依赖的版本对应的docker最高版本 19.03.15-3
# 安装指定版本示例 ./install-runtime.sh 19.03.15-3

source /opt/shell/log.sh

set +e

NUM_RELEASE="${1}"

# kubernetes 容器运行时安装 https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/

## 卸载旧版 docker
echo_exec 'yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine'

## 使用存储库安装
### 设置存储库
echo_exec 'yum install -y yum-utils device-mapper-persistent-data lvm2'
echo_exec 'yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo'

## 安装 docker
if [[ -n $NUM_RELEASE ]]; then
  echo_exec 'yum --allowerasing install -y docker-ce-${NUM_RELEASE}.el7.x86_64 docker-ce-cli-${NUM_RELEASE}.el7.x86_64 containerd.io || yum install -y docker-ce-${NUM_RELEASE}.el7.x86_64 docker-ce-cli-${NUM_RELEASE}.el7.x86_64 containerd.io'
else
   echo_exec 'yum --allowerasing install -y docker-ce docker-ce-cli containerd.io || yum install -y docker-ce docker-ce-cli containerd.io'
fi

## 设置开机启动docker，启动并验证docker
echo_exec 'systemctl enable docker && systemctl start docker && docker run hello-world'

## 安装docker后配置
if [[ ! -d '/etc/docker' ]]; then
echo_exec 'mkdir /etc/docker'
fi
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "oom-score-adjust": -1000,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10,
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"],
  "storage-driver": "overlay2"
}
EOF

echo_exec 'systemctl daemon-reload && systemctl restart docker'

## 查看 docker 当前配置
echo_exec 'docker info'