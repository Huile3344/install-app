#!/bin/bash
source /opt/shell/log.sh

#ROLE="master"
#ROLE="node"
ROLE="$1"
#RELEASE="v1.20.5"
RELEASE="$2"

# k8s master/node 安装准备
source k8s-prepare.sh
# 安装 容器运行时
source install-runtime.sh
# 安装 kubelet kubeadm kubectl
source install-repo-version-kubelet-kubeadm-kubectl.sh $RELEASE
# 下载 k8s 镜像需要的镜像
if [[ "master" -eq $ROLE ]]; then
  source k8s-assist.sh fetch-master-images $RELEASE
else
  source k8s-assist.sh fetch-node-images $RELEASE
fi
