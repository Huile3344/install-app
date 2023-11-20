#!/bin/bash

function help () {
    echo "usage: $1 [OPTIONS]"
    echo "    -r,--role              -- k8s 节点角色可选值: master, worker，默认值: worker"
    echo "    -a,--action            -- k8s 安装操作可选值: init, join，默认值: join，init 仅适用第一个初始化的 master 节点，会执行 kubeadm init"
    echo "    -v,--version           -- k8s 安装版本."
    echo "    -i,--ip                -- k8s 节点ip，针对多网卡情况尤其重要，必须指定"
    echo "    -p,--podSubnet         -- k8s 初始化第一个 master 节点，指定内部 pod 子网段，默认值：10.244.0.0/16"
    echo "    -v,--version           -- k8s 节点安装版本，用于拉取版本镜像"
    echo "    -h,--help              -- 显示当前帮助信息"
    echo ""
    echo "examples:"
    echo "安装指定版本 master 节点，完整版，方式1:"
    echo "    $1 -r master -i 192.168.1.1 -p 10.244.0.0/16 -v v1.20.5"
    echo "安装指定版本 master 节点，完整版，方式2:"
    echo "    $1 -rmaster -i192.168.1.1 -p10.244.0.0/16 -vv1.20.5"
    echo "安装指定版本 master 节点，完整版，方式3:"
    echo "    $1 --role master --ip 192.168.1.1 --podSubnet 10.244.0.0/16 --version v1.20.5"
    echo "安装指定版本 master 节点，完整版，方式4:"
    echo "    $1 --role=master --ip=192.168.1.1 --podSubnet=10.244.0.0/16 --version=v1.20.5"
    echo "安装指定版本 master 节点，简易版:"
    echo "    $1 --role master --ip 192.168.1.1 --version v1.20.5"
    echo "安装最新版本 master 节点，简易版:"
    echo "    $1 --role master --ip 192.168.1.1"
    echo "安装最新版本 worker 节点，简易版:"
    echo "    $1"
    echo "安装最新版本 join 的 master 节点，简易版:"
    echo "    $1 -r master"
}

source /opt/shell/log.sh
ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
OS=$(uname | awk '{print tolower($0)}')
SHELL_FILE=$0
POD_SUBNET=10.244.0.0/16
ACTION=join

#-o或--options选项后面接可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
#-l或--long选项后面接可接受的长选项，用逗号分开，冒号的意义同短选项。
#-n选项后接选项解析错误时提示的脚本名字
#ARGS=`getopt -o ab:c:: --long along,blong:,clong:: -n 'example.sh' -- "$@"`
# 需要注意的是，像上面的-c/--clong选项，后面是可接可不接参数的，如果需要传递参数给-c/--clong选项，则必须使用如下的方式：-cvalue --clong=value
ARGS=`getopt -o hr:a:i:p:v: --long help,role:,action:,ip:,podSubnet:,version: -n '$SHELL_FILE' -- "$@"`
if [ $? != 0 ]; then
    echo "Terminating..."
    exit 1
fi
echo $ARGS

#echo $ARGS
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"

while true; do
  case "$1" in
    -h|--help)
      help $SHELL_FILE
      exit 1
      ;;
    -r|--role)
      ROLE=$2
      shift 2
      ;;
    -a|--action)
      ACTION=$2
      shift 2
      ;;
    -i|--ip)
      IP=$2
      shift 2
      ;;
    -p|--podSubnet)
      POD_SUBNET=$2
      shift 2
      ;;
    -v|--version)
      RELEASE=$2
      shift 2;
      ;;
#    # 针对可选参数
#    -c|--clong)
#      case "$2" in
#        "")
#          echo "Option c, no argument";
#          shift 2
#          ;;
#        *)
#          echo "Option c, argument $2";
#          shift 2;
#          ;;
#      esac
#      ;;
    --)
      shift
      break
      ;;
  esac
done

#处理剩余的参数
for arg in $@; do
  echo "丢弃的无效参数 $arg"
done

# getopts 仅适用于短选项
#while getopts :r:i:p:v: OPTION; do
#  case ${OPTION} in
#    r) ROLE=${OPTARG}
#      ;;
#    i) IP=${OPTARG}
#      ;;
#    p) POD_SUBNET=${OPTARG}
#      ;;
#    v) RELEASE=${OPTARG}
#      ;;
#    \?|h)
#      help $0
#      exit 1
#  esac
#done

if [[ "master" -eq $ROLE && "init" -eq $ACTION && -z $IP ]]; then
  echo " -i或--ip 参数未指定"
  help $SHELL_FILE
  exit 1
fi

if [[ -z $RELEASE ]]; then
  RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
  info "获取到 k8s 最新版本: $RELEASE"
fi

#info "role=$ROLE ip=$IP podSubnet=$POD_SUBNET version=$RELEASE"

# k8s master/worker 安装准备
source k8s-prepare.sh $POD_SUBNET
# 安装 容器运行时， 参数1:docker安装版本(空字符表示最新版)，参数2:docker HTTP_PROXY，参数3:docker HTTPS_PROXY，参数4:docker NO_PROXY
source install-runtime.sh "" "http://192.168.137.1:7890" "http://192.168.137.1:7890" "localhost,127.0.0.0/8,172.17.0.0/16,10.244.0.0/16,docker.io,192.168.0.0/16,aliyuncs.com"
# 安装cri-docker
source install-cri-dockerd.sh
# 安装 kubelet kubeadm kubectl
source install-repo-k8s-version-kubelet-kubeadm-kubectl.sh $RELEASE
# 下载 k8s 需要的镜像，默认k8s镜像仓库: registry.k8s.io；阿里云k8s镜像仓库: registry.cn-hangzhou.aliyuncs.com/google_containers
imageRepository="registry.k8s.io"
# 这里是预先下载 k8s 需要的镜像，其实这部分下载脚本可不执行，kubeadm 中已经修改了镜像仓库，会包含下载镜像
if [[ "master" -eq $ROLE ]]; then
  source k8s-assist.sh fetch-master-images $RELEASE $imageRepository
  if [ 0 -ne $? ]; then
    info "获取k8s镜像失败，请检查网络"
    exit 1
  fi
  [[ "init" -ne $ACTION ]] && exit 0
else
  source k8s-assist.sh fetch-worker-images $RELEASE $imageRepository
  if [ 0 -ne $? ]; then
    info "获取k8s镜像失败，请检查网络"
    exit 1
  fi
  exit 0
fi

# 第一个 master 节点初始化需要执行一下命令：

# 基于以下命令生成默认配置文件，再对应修改
# kubeadm config print init-defaults > kubeadm-config.yml
echo_exec "cp kubeadm-config.yml used-kubeadm-config.yml"
sed -i 's|10.180.35.6|'$IP'|g' used-kubeadm-config.yml
sed -i 's|10.244.0.0/16|'$POD_SUBNET'|g' used-kubeadm-config.yml
sed -i 's|^kubernetesVersion: .*$|kubernetesVersion: '$RELEASE'|g' used-kubeadm-config.yml
sed -i 's|^imageRepository: .*$|imageRepository: '$imageRepository'|g' used-kubeadm-config.yml
info "初始化 Master 节点"
kubeadm init --config=used-kubeadm-config.yml --upload-certs --v=5 | tee kubeadm-init.log
if [ 0 -ne $? ]; then
  info "kubeadm init 异常"
  exit 1
fi

# 配置 kubectl
rm -rf $HOME/.kube/
mkdir -p $HOME/.kube/
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装网络插件
source k8s-podnetwork.sh calico ${POD_SUBNET}

# 给 master 节点打 taint，允许控制平面节点上调度 Pod
kubectl taint nodes --all node-role.kubernetes.io/master-

# 执行如下命令，等待 3-10 分钟，直到所有的容器组处于 Running 状态
kubectl get pod -n kube-system -o wide -w

# 安装 helm
source k8s-assist.sh install-helm v3.13.2

# 安装 metallb
source k8s-assist.sh install-metallb helm 4.7.14

# 安装 operator-sdk
source k8s-assist.sh install-operator-sdk v1.32.0

# 安装 istio
source k8s-assist.sh install-istio 1.20.0 default