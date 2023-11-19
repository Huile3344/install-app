#!/bin/bash

# 安装在最新版本示例 ./install-repo-k8s-version-kubelet-kubeadm-kubectl.sh
# 安装指定版本示例 ./install-k8s-repo-version-kubelet-kubeadm-kubectl.sh v1.28.4

source /opt/shell/log.sh

set +e

NUM_RELEASE="${1#*v}"

if [[ ! -e "/etc/yum.repos.d/kubernetes.repo" ]]; then
# 使用k8s镜像仓库下载最新版的 kubernetes，主要是使用期基础配置
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
fi
# 安装kubelet、kubeadm、kubectl
if [[ -n $NUM_RELEASE ]]; then
  echo_exec "yum install -y kubelet-${NUM_RELEASE} kubeadm-${NUM_RELEASE} kubectl-${NUM_RELEASE} --disableexcludes=kubernetes"
else
  echo_exec "yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes"
fi

# 额外说明 kubernetes-cni 会被依赖关联安装，大多数 Pod 网络都需要，对应会创建 /opt/cni/bin ，其中会包含网络相关的二进制文件

# 测试安装的版本是最新的：
echo_exec "kubeadm version"
echo_exec "kubelet --version"
echo_exec "kubectl version --client"

echo_exec "mkdir -pv /etc/sysconfig"

# 配置kubelet，为其指定cri-dockerd在本地打开的Unix Sock文件的路径，该路径一般默认为“/var/run/cri-dockerd.sock“和“/run/cri-dockerd.sock“。
# 编辑文件/etc/sysconfig/kubelet，为其添加如下指定参数
cat >> /etc/sysconfig/kubelet <<EOF
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=/var/run/cri-dockerd.sock"
EOF
# 需要说明的是，该配置也可不进行，而是直接在后面的各kubeadm命令上使用“--cri-socket unix:///var/run/cri-dockerd.sock”选项。

# 开机启动 kubelet
echo_exec "systemctl enable --now kubelet"
# 启动 kubelet
echo_exec "systemctl start --now kubelet"
# 注意：
## 如果此时执行 systemctl status kubelet 命令，将得到 kubelet 启动失败的错误提示，
## 请忽略此错误，因为必须完成后续步骤中 kubeadm init 的操作，kubelet 才能正常启动

# 添加命令行填充提示
echo_exec "source <(kubectl completion bash)"
echo "source <(kubectl completion bash)" >> ~/.bashrc
