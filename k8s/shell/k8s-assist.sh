#!/bin/bash
source /opt/shell/log.sh

# k8s 辅助脚本工具
# 使用方式: ./k8s-assist.sh <执行的操作> <必要的参数1> ... <必要的参数N>
#          示例: ./k8s-assist.sh change-master-ip <旧IP> <新IP>



function help () {
    echo "usage: $1 <执行的操作> <必要的参数1> ... <必要的参数N>"
    echo "    change-master-ip  <旧IP> <新IP>   -- 更新 master 节点 ip，并更新 master 和 其内部 etcd 证书"
    echo "    help                             -- 展示当前帮助信息"
    echo ""
    echo "examples:"
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
    # /etc/kubernetes/admin.conf 需要移除，要不然无法生成新的文件
    echo_exec "mv /etc/kubernetes/admin.conf $k8sbakDir"
    echo_exec "kubeadm init phase kubeconfig admin --apiserver-advertise-address $nip"
    # /etc/kubernetes/pki/ 目录下的证书文件需要移除，要不然无法生成新的文件
    echo_exec "mv /etc/kubernetes/pki/{apiserver.key,apiserver.crt} $k8sbakDir"
    echo_exec "kubeadm init phase certs apiserver --apiserver-advertise-address $nip"
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

case $1 in
    change-master-ip)
        changeMasterIp $2 $3
    ;;
    help|*)
        help $0
    ;;
esac



