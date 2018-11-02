#!/bin/bash

# 初始参考脚本
#namespace=registry.cn-shenzhen.aliyuncs.com/acs
#
#images=(kube-proxy-amd64:v1.11.2 kube-scheduler-amd64:v1.11.2 kube-controller-manager-amd64:v1.11.2 kube-apiserver-amd64:v1.11.2)
#
#for imageName in ${images[@]} ; do
#  docker pull $namespace/$imageName
#  docker tag $namespace/$imageName k8s.gcr.io/$imageName
#  docker rmi $namespace/$imageName
#done


# 循环镜像信息
function pullTagImages() {
  who=$1
  target=$2
  args=($(echo "$@"))
  count=$[ $# ]
  echo "images count: $((count-2))"
  for (( i = 2; i < $count; i++ )) {
	pullTagOneImage $who $target ${args[$i]}
  }
}

# 拉取镜像并打上指定tag，并删除下载的镜像，保留打上指定tag的镜像
function pullTagOneImage() {
  who=$1
  target=$2
  image=$3
  echo "docker pull $who/$image"
  docker pull $who/$image
  if [ 0 -eq $? ] && [ $who != $target ]; then
    fullImg=$target/$image
    echo "tag $who/$image $fullImg"
    docker tag $who/$image $fullImg
    echo "docker rmi $who/$image"
    docker rmi $who/$image
  fi
  echo -e "=======================================================\n"
}


# 从阿里云的哪个用户名下拉取镜像
namespace=registry.cn-shenzhen.aliyuncs.com/k8s-io
# Google 镜像
images='kube-proxy-amd64:v1.11.2 kube-scheduler-amd64:v1.11.2 kube-controller-manager-amd64:v1.11.2 kube-apiserver-amd64:v1.11.2'
pullTagImages $namespace k8s.gcr.io $images 

namespace=registry.cn-shenzhen.aliyuncs.com/k8s-io
pullTagImages $namespace k8s.gcr.io \
	'etcd-amd64:3.2.18 coredns:1.1.3 pause:3.1 pause-amd64:3.1 kubernetes-dashboard-amd64:v1.10.0 metrics-server-amd64:v0.2.1'

namespace=registry.cn-shenzhen.aliyuncs.com/k8s-io
pullTagImages $namespace k8s.gcr.io addon-resizer:1.8.1

namespace=registry.cn-beijing.aliyuncs.com/k8s_images
pullTagImages $namespace k8s.gcr.io 'k8s-dns-sidecar-amd64:1.14.9 k8s-dns-kube-dns-amd64:1.14.9 k8s-dns-dnsmasq-nanny-amd64:1.14.9'

namespace=registry.cn-shenzhen.aliyuncs.com/quay-calico
# calico 镜像
calicos='node:v3.2.1 cni:v3.2.1 kube-controllers:v3.2.1'
pullTagImages $namespace quay.io/calico $calicos 
