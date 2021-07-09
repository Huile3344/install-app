#!/bin/bash
source /opt/shell/log.sh

# k8s 辅助脚本工具
# 使用方式: ./k8s-assist.sh <执行的操作> <必要的参数1> ... <必要的参数N>
#          示例: ./k8s-assist.sh change-master-ip <旧IP> <新IP>



function help () {
    echo "usage: $1 <执行的操作> <必要的参数1> ... <必要的参数N>"
    echo "    fetch-images <镜像源> <目标替换镜像源> <镜像列表>       -- 从镜像源拉取指定的镜像列表，替换成目标镜像源"
    echo "    fetch-master-images                                -- 拉取 k8s master 节点需要的镜像"
    echo "    fetch-node-images                                  -- 拉取 k8s node 节点需要的镜像"
    echo "    ca <证书生成目录> <证书名称> <组织:默认值，k8s>          -- 生成自签名证书"
    echo "    ingress-ca <命名空间> <证书生成目录> <证书名称> <组织:默认值，k8s>"
    echo "                                                       -- 生成指定命名空间的 ingress 使用的自签名证书"
    echo "    dashboard-token <sa>                               -- 获取访问 dashboard 的指定 serviceaccount 的 token"
    echo "    join-token                                         -- 生成 node 加入集群的token"
    echo "    change-master-ip  <旧IP> <新IP>                     -- 更新 master 节点 ip，并更新 master 和 其内部 etcd 证书"
    echo "    help                                               -- 展示当前帮助信息"
    echo ""
    echo "examples:"
    echo "    $1 fetch-images registry.cn-hangzhou.aliyuncs.com/google_containers  k8s.gcr.io pause:3.4.1 kube-proxy:v1.20.5"
    echo "    $1 fetch-master-images"
    echo "    $1 fetch-node-images"
    echo "    $1 ca /opt/k8s/certs dashboard k8s"
    echo "    $1 ingress-ca kubernetes-dashboard /opt/k8s/certs dashboard"
    echo "    $1 dashboard-token dashboard-admin"
    echo "    $1 join-token"
    echo "    $1 change-master-ip 172.16.1.6 10.181.4.88"
}

function changeMasterIp () {
  if [ $# -ge 2 ]; then
    oip=$1
    nip=$2
    k8sbakDir=/etc/kubernetes.bak/$(date '+%Y-%m-%dT%H:%M:%S')/
    mkdir -pv $k8sbakDir
    for file in /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kubelet.conf ; do
      echo_exec "cp $file $k8sbakDir"
      echo_exec "sed -i 's|$oip|$nip|g' $file"
    done
    # /etc/kubernetes/pki/ 目录下的证书文件需要移除，要不然无法生成新的文件
    echo_exec "mv /etc/kubernetes/pki/{apiserver.key,apiserver.crt} $k8sbakDir"
    echo_exec "kubeadm init phase certs apiserver --apiserver-advertise-address $nip"
    # /etc/kubernetes/admin.conf 需要移除，要不然无法生成新的文件
    echo_exec "mv /etc/kubernetes/admin.conf $k8sbakDir"
    echo_exec "kubeadm init phase kubeconfig admin --apiserver-advertise-address $nip"
    echo_exec "service docker restart && service kubelet restart"
    if [ 0 -ne $UID ]; then
      echo_exec "cp /etc/kubernetes/admin.conf $HOME/.kube/config"
      echo_exec "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
      echo_exec "kubectl get nodes --kubeconfig=$HOME/.kube/config"
    else
      echo_exec "kubectl get nodes"
    fi
    success $"successfully!"
    exit
  fi
  echo "usage examples:"
  echo "    <shell-file> change-master-ip 172.16.1.6 10.181.4.88"
  exit 1
}

# 拉取镜像并打上指定tag，并删除下载的镜像，保留打上指定tag的镜像
function imagePullRenameTag() {
  source=$1
  target=$2
  image=$3
  echo_exec "docker pull $source/$image"
  if [ 0 -eq $? ] && [ $source != $target ]; then
    echo_exec "docker tag $source/$image $target/$image"
    echo_exec "docker rmi $source/$image"
  fi
  echo -e "\n"
}

# 循环镜像信息
function fetchImages() {
  source=$1
  target=$2
  args=($(echo "$@"))
  count=$[ $# ]
  echo "images count: $((count-2))"
  for (( i = 2; i < $count; i++ )) {
	  imagePullRenameTag $source $target ${args[$i]}
  }
}

# 获取k8s master 节点镜像
function fetchK8sMasterImages() {
  images=(
    kube-apiserver:v1.20.5
    kube-controller-manager:v1.20.5
    kube-scheduler:v1.20.5
    kube-proxy:v1.20.5
    pause:3.4.1
    etcd:3.4.13-0
    coredns:1.7.0
  )
  fetchImages registry.cn-hangzhou.aliyuncs.com/google_containers k8s.gcr.io ${images[*]}
}

# 获取k8s worker 节点镜像
function fetchK8sNodeImages() {
  images=(
    kube-proxy:v1.20.5
    pause:3.4.1
    coredns:1.7.0
  )
  fetchImages registry.cn-hangzhou.aliyuncs.com/google_containers k8s.gcr.io ${images[*]}
}

# 获取节点加入集群的命令
function joinToken() {
#  controlPlaneHost=`kubectl get nodes -o wide | grep control-plane | awk 'NR==1 {print $6}'`
  controlPlaneHostPort=`kubectl -n kube-system get pod $(kubectl -n kube-system get pod | grep kube-apiserver | awk '{print $1}') -o yaml | grep advertise-address.endpoint | awk 'NR==1 {print $2}'`
  token=`kubeadm token create`
  hash=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
#  echo "kubeadm join $controlPlaneHost:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash"
  echo "kubeadm join $controlPlaneHostPort --token $token --discovery-token-ca-cert-hash sha256:$hash"
}

# 生成自签署的 ca 证书
function ca() {
  DIR=$1
  CN=$2
  O=${3-k8s}
  mkdir -pv $DIR
  echo "生成自签署的证书"
  # 生成公私钥对
  openssl req -x509 -nodes -days 3560 -newkey rsa:2048 -keyout $DIR/$CN.key -out $DIR/$CN.crt -subj '/CN='${CN}'svc/O='${O}

}

# 生成自签署的 ca 证书
function ingressCa() {
  NS=$1
  DIR=$2
  CN=$3
  O=$4
  ca $DIR $CN $O
  echo "生成证书的 secret"
  kubectl create -n $NS secret tls $CN-secret --key $DIR/$CN.key --cert $DIR/$CN.crt
}

# 获取访问 dashboard 的 sa 的 token
function dashboardToken() {
  USER=$1
  kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep $USER | awk '{print $1}')
}

case $1 in
    change-master-ip)
        changeMasterIp $2 $3
    ;;
    fetch-images)
        source=$2
        target=$3
        shift
        shift
        shift
        fetchImages $source $target $@
    ;;
    fetch-master-images)
        fetchK8sMasterImages
    ;;
    fetch-node-images)
        fetchK8sNodeImages
    ;;
    join-token)
        joinToken
    ;;
    ca)
        ca $2 $3 $4
    ;;
    ingress-ca)
        ingressCa $2 $3 $4 $5
    ;;
    dashboard-token)
        dashboardToken $2
    ;;
    help|*)
        help $0
    ;;
esac



