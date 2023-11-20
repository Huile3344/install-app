#!/bin/bash
source /opt/shell/log.sh

set +e

# k8s 辅助脚本工具
# 使用方式: ./k8s-assist.sh <执行的操作> <必要的参数1> ... <必要的参数N>
#          示例: ./k8s-assist.sh change-master-ip <旧IP> <新IP>



function help () {
    echo "usage: $1 <执行的操作> <必要的参数1> ... <必要的参数N>"
    echo "    just-fetch-images <镜像列表>                        -- 从镜像源拉取指定的镜像列表，替换成目标镜像源"
    echo "    fetch-images <镜像源> <目标替换镜像源> <镜像列表>       -- 从镜像源拉取指定的镜像列表，替换成目标镜像源"
    echo "    fetch-master-images [可选的k8s版本]                  -- 拉取 k8s master 节点指定版本需要的镜像，不传版本将获取最新版本"
    echo "    fetch-worker-images [可选的k8s版本]                  -- 拉取 k8s node 节点指定版本需要的镜像，不传版本将获取最新版本"
    echo "    ca <证书生成目录> <证书名称> <组织:默认值，k8s>          -- 生成自签名证书"
    echo "    ingress-ca <命名空间> <证书生成目录> <证书名称> <组织:默认值，k8s>"
    echo "                                                       -- 生成指定命名空间的 ingress 使用的自签名证书"
    echo "    dashboard-token <sa>                               -- 获取访问 dashboard 的指定 serviceaccount 的 token"
    echo "    join-worker-token                                  -- 生成 worker 加入集群的token"
    echo "    join-master-token                                  -- 生成 master 加入集群的token"
    echo "    change-master-ip  <旧IP> <新IP>                     -- 更新 master 节点 ip，并更新 master 和 其内部 etcd 证书"
    echo "    install-helm  <Helm版本>                            -- 安装指定版本的 helm"
    echo "    install-metallb  <模式> <版本>                       -- 安装metallb，模式支持helm和yaml，版本对应指定模式的版本"
    echo "    install-operator-sdk  <版本>                        -- 安装指定版本的 operator-sdk"
    echo "    install-istio  <版本> <k8s命名空间>                  -- 安装指定版本的 istio ，并在指定k8s命名空间启用istio-injection"
    echo "    help                                               -- 展示当前帮助信息"
    echo ""
    echo "examples:"
    echo "    $1 just-fetch-images k8s.gcr.io/pause:3.4.1 k8s.gcr.io/kube-proxy:v1.20.5"
    echo "    $1 fetch-images registry.cn-hangzhou.aliyuncs.com/google_containers  k8s.gcr.io pause:3.4.1 kube-proxy:v1.20.5"
    echo "    $1 fetch-master-images "
    echo "    $1 fetch-worker-images"
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
  #images=$(kubeadm config images list --kubernetes-version=$1 | sed 's#^registry.k8s.io/##')
  #fetchImages registry.cn-hangzhou.aliyuncs.com/google_containers registry.k8s.io ${images[*]}
  #使用新方式拉取k8s镜像
  kubeadm config images list --v=5 --kubernetes-version=$1 --image-repository=$2
  kubeadm config images pull --v=5 --kubernetes-version=$1 --image-repository=$2 --cri-socket unix:///run/cri-dockerd.sock
}

# 获取k8s worker 节点镜像
function fetchK8sWorkerImages() {
  #master使用新方式拉取k8s镜像，此处不需要执行了

  #images=$(kubeadm config images list --kubernetes-version=$1 | grep -v kube-apiserver | grep -v kube-controller-manager | grep -v kube-scheduler | grep -v etcd | sed 's#^registry.k8s.io/##')
  #fetchImages $2 registry.k8s.io ${images[*]}
  echo "nothing to do"
}

# 获取节点加入集群的命令
function joinWorkerToken() {
##  controlPlaneHost=`kubectl get nodes -o wide | grep control-plane | awk 'NR==1 {print $6}'`
#  controlPlaneHostPort=`kubectl -n kube-system get pod $(kubectl -n kube-system get pod | grep kube-apiserver | awk '{print $1}') -o yaml | grep advertise-address.endpoint | awk 'NR==1 {print $2}'`
#  token=`kubeadm token create`
#  hash=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
##  echo "kubeadm join $controlPlaneHost:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash"
#  echo "kubeadm join $controlPlaneHostPort --token $token --discovery-token-ca-cert-hash sha256:$hash"
  # 该 token 的有效时间为 2 个小时，2小时内，您可以使用此 token 初始化任意数量的 worker 节点。
  kubeadm token create --print-join-command
#  kubeadm token create --ttl 0 --print-join-command #创建个永不过期的令牌
}

# 获取节点加入集群的命令
function joinMasterToken() {
##  controlPlaneHost=`kubectl get nodes -o wide | grep control-plane | awk 'NR==1 {print $6}'`
#  controlPlaneHostPort=`kubectl -n kube-system get pod $(kubectl -n kube-system get pod | grep kube-apiserver | awk '{print $1}') -o yaml | grep advertise-address.endpoint | awk 'NR==1 {print $2}'`
#  token=`kubeadm token create`
#  hash=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
##  echo "kubeadm join $controlPlaneHost:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash"
#  echo "kubeadm join $controlPlaneHostPort --token $token --discovery-token-ca-cert-hash sha256:$hash"
  # 该 token 的有效时间为 2 个小时，2小时内，您可以使用此 token 初始化任意数量的 worker 节点。
  workerToken=$(kubeadm token create --print-join-command)
#  kubeadm token create --ttl 0 --print-join-command #创建个永不过期的令牌
  # 获得 certificate key
  certificateKey=$(kubeadm init phase upload-certs --upload-certs | awk 'END{print}')
  echo "$workerToken --control-plane --certificate-key $certificateKey"
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

# 安装 helm
function installHelm() {
  # github releases: https://github.com/helm/helm/releases
  # helm 官网: https://helm.sh/zh/
  HELM_VERSION=$1
  helm version | grep Version:\"${HELM_VERSION}\" > /dev/null
  if [ 0 -ne $? ]; then
    info "安装 helm 版本: ${HELM_VERSION}"
    if [[ ! -e "helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz" ]]; then
      curl -OL https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz
    fi
    tar -zxf helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz
    mv ${OS}-${ARCH}/helm /opt/bin/
    rm -rf ${OS}-${ARCH}
  fi
  info "已安装 helm 版本: ${HELM_VERSION}"
}

# 安装 metallb
function installMetallb() {
  MODE=$1
  METALLB_VERSION=$2
  info "安装 metallb 模式: ${MODE} ，版本: ${METALLB_VERSION}"
  if [[ "helm" == $MODE ]]; then
    # 安装 bitnami metallb
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    helm install metallb bitnami/metallb --version $METALLB_VERSION
  else
    # metallb 官网: https://metallb.universe.tf/installation/
    if [[ ! -e "metallb-native.yaml" ]]; then
      wget https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
    fi
    kubectl apply -f metallb-native.yaml
  fi
  info "已安装 metallb 模式: ${MODE} ，版本: ${METALLB_VERSION}"
}

# 安装 operator-sdk
function installOperatorSdk() {
  # github releases: https://github.com/operator-framework/operator-sdk/releases
  OPERATOR_SDK_VERSION=$1
  echo_exec 'operator-sdk version | grep "version: \"'${OPERATOR_SDK_VERSION}'\""  > /dev/null'
  if [ 0 -ne $? ]; then
    info "安装 operator-sdk 版本: ${OPERATOR_SDK_VERSION}"
    OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/${OPERATOR_SDK_VERSION}
    curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
    gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E
    curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt
    curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc
    gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc
    if [ 0 -ne $? ]; then
      error "operator-sdk verify the signature failed"
      exit 1
    fi
    grep operator-sdk_${OS}_${ARCH} checksums.txt | sha256sum -c -
    if [ 0 -ne $? ]; then
      error "operator-sdk checksum failed"
      exit 1
    fi
    chmod +x operator-sdk_${OS}_${ARCH} && mv operator-sdk_${OS}_${ARCH} /opt/bin/operator-sdk
  fi
  info "已安装 operator-sdk 版本: ${OPERATOR_SDK_VERSION}"
  echo_exec "operator-sdk olm install"
  echo_exec "kubectl get packagemanifest -n olm"
}

# 安装 istio
function installIstio() {
  ISTIO_VERSION=$1
  NAMESPACE=$2
  if [ "${ISTIO_VERSION}" = "" ] ; then
    ISTIO_VERSION="$(curl -sL https://github.com/istio/istio/releases | \
                    grep -o 'releases/[0-9]*.[0-9]*.[0-9]*/' | sort -V | \
                    tail -1 | awk -F'/' '{ print $2}')"
    ISTIO_VERSION="${ISTIO_VERSION##*/}"
  fi
  istioctl version | grep -E ${ISTIO_VERSION}$ > /dev/null
  if [ 0 -ne $? ]; then
    info "安装 istio 版本: ${ISTIO_VERSION}"
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
    cp istio-${ISTIO_VERSION}/bin/istioctl /opt/bin/
    istioctl verison
  else
    info "已安装 istio 版本: ${ISTIO_VERSION}"
  fi
  istioctl install --set profile=demo -y
  kubectl label namespace $NAMESPACE istio-injection=enabled
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
    just-fetch-images)
        shift
        for imageName in $@ ; do
          echo_exec "docker pull $imageName"
        done
    ;;
    fetch-master-images)
        fetchK8sMasterImages $2 $3
    ;;
    fetch-worker-images)
        fetchK8sWorkerImages $2 $3
    ;;
    join-worker-token)
        joinWorkerToken
    ;;
    join-master-token)
        joinMasterToken
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
    install-helm)
        installHelm $2
    ;;
    install-metallb)
        installMetallb $2 $3
    ;;
    install-operator-sdk)
        installOperatorSdk $2
    ;;
    install-istio)
        installIstio $2 $3
    ;;
    help|*)
        help $0
    ;;
esac



