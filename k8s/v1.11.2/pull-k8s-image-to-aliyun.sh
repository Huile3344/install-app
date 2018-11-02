#!/bin/bash

# 初始参考脚本
#namespace=registry.cn-shenzhen.aliyuncs.com/
#
#images=(kube-proxy-amd64:v1.11.2 kube-scheduler-amd64:v1.11.2 kube-controller-manager-amd64:v1.11.2 kube-apiserver-amd64:v1.11.2)
#
#for imageName in ${images[@]} ; do
#  docker pull $namespace/$imageName
#  docker tag $namespace/$imageName k8s.gcr.io/$imageName
#  docker rmi $namespace/$imageName
#done


# 循环镜像信息
function fetchImages() {
  who=$1
  target=$2
  args=($(echo "$@"))
  count=$[ $# ]
  echo "images count: $((count-2))"
  for (( i = 2; i < $count; i++ )) {
	imagePullTagPushRmi $who $target ${args[$i]}
  }
}

function pushImages() {
  who=$1
  target=$2
  args=($(echo "$@"))
  count=$[ $# ]
  echo "images count: $((count-2))"
  for (( i = 2; i < $count; i++ )) {
	imageTagPushRmi $who $target ${args[$i]}
  }
}

# 拉取镜像并打上指定tag，并删除下载的镜像，保留打上指定tag的镜像
function imagePullTagPushRmi() {
  who=$1
  target=$2
  image=$3
  echo "docker pull $who/$image"
  docker pull $who/$image
  if [ 0 -eq $? ] && [ $who != $target ]; then
    echo "tag $who/$image $target/$image"
	fullImg=registry.cn-shenzhen.aliyuncs.com/$target/$image
    docker tag $who/$image $fullImg
    echo "docker push $fullImg"
	docker push $fullImg
    echo "docker rmi $fullImg"
    docker rmi $fullImg
  fi
  echo -e "=======================================================\n"
}

# 拉取镜像并打上指定tag，并删除下载的镜像，保留打上指定tag的镜像
function imageTagPushRmi() {
  who=$1
  target=$2
  image=$3
  fullImg=registry.cn-shenzhen.aliyuncs.com/$target/$image
  echo "tag $who/$image $fullImg"
  docker tag $who/$image $fullImg
  echo "docker push $fullImg"
  docker push $fullImg
  echo "docker rmi $fullImg"
  docker rmi $fullImg
  echo -e "=======================================================\n"
}
echo "docker login --username=1161115494@qq.com registry.cn-shenzhen.aliyuncs.com"
# 从阿里云的哪个用户名下拉取镜像
#namespace=k8s-io
# Google 镜像
#images='kube-proxy-amd64:v1.11.2 kube-scheduler-amd64:v1.11.2 kube-controller-manager-amd64:v1.11.2 kube-apiserver-amd64:v1.11.2'
#fetchImages k8s.gcr.io $namespace $images 

#namespace=k8s-io
#fetchImages k8s.gcr.io $namespace \
#	'etcd-amd64:3.2.18 coredns:1.1.3 pause:3.1 kubernetes-dashboard-amd64:v1.10.0'


#fetchImages k8s.gcr.io $namespace addon-resizer:1.8.1 metrics-server-amd64:v0.2.1

#fetchImages k8s.gcr.io $namespace 'k8s-dns-sidecar-amd64:1.14.9 k8s-dns-kube-dns-amd64:1.14.9 k8s-dns-dnsmasq-nanny-amd64:1.14.9'


# quay.io/calico 镜像
namespace=quay-calico
calicos='node:v3.1.3 cni:v3.1.3 ctl:v3.1.3 kube-controllers:v3.1.3'
fetchImages quay.io/calico $namespace $calicos 
