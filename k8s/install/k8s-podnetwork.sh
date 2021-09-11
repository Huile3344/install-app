#!/bin/bash
source /opt/shell/log.sh
# 安装网络插件
#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

set +e

POD_SUBNET=$2

# 下载yaml文件，并修改 POD 的子网段
if [[ "calico" -eq $1 ]]; then
  # 下载 yaml
  wget https://docs.projectcalico.org/manifests/calico.yaml
  sed -i "s|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|" calico.yaml
  sed -i "s|#   value: "192.168.0.0/16"|  value: "${POD_SUBNET}"|" calico.yaml
  kubectl apply -f calico.yaml
else
  # 下载 yaml，由于网络原因无法直接下载，需翻墙，提前下载好
  #wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  cp kube-flannel.yaml flannel.yaml
  sed -i "s|10.244.0.0/16|${POD_SUBNET}|" flannel.yaml
  kubectl apply -f flannel
fi

