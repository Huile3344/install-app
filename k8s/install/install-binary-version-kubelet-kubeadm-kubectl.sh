#!/bin/bash

# 参考官网: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

source /opt/shell/log.sh

set +e

RELEASE="$1"
ARCH="amd64"

if [[ -z $RELEASE ]]; then
  RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
fi

# 安装 kubeadm、kubelet、kubectl，使用下面命令下载最新的发行版本：
echo_exec 'curl -OL --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}"'

# 验证可执行文件（可选步骤）：
## 下载 kubeadm,kubelet,kubectl 校验和文件：
echo_exec 'curl -OL --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet,kubectl}.sha256"'

## 使用校验和文件检查 kubeadm,kubelet,kubectl 可执行二进制文件：
echo_exec 'echo "$(<kubectl.sha256) kubectl" | sha256sum --check'
# 如果合法，则输出为：
# kubectl: OK
# 如果检查失败，则 sha256 退出且状态值非 0 并打印类似如下输出：
# kubectl: FAILED
# sha256sum: WARNING: 1 computed checksum did NOT match
echo_exec 'echo "$(<kubeadm.sha256) kubeadm" | sha256sum --check'
echo_exec 'echo "$(<kubelet.sha256) kubelet" | sha256sum --check'

echo_exec 'chmod +x {kubeadm,kubelet,kubectl}'

DOWNLOAD_DIR=/opt/bin
mkdir -p $DOWNLOAD_DIR
echo_exec 'mv kubeadm kubelet kubectl $DOWNLOAD_DIR'

# 测试你所安装的版本是最新的：
echo_exec 'kubeadm version'
echo_exec 'kubelet --version'
echo_exec 'kubectl version --client'

# 添加 kubelet 系统服务：

## 基于网路方式
#RELEASE_VERSION="v0.16.2"
#curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | tee /etc/systemd/system/kubelet.service
#mkdir -p /etc/systemd/system/kubelet.service.d
#curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
## 基于本地配置文件方式
mkdir -p /etc/systemd/system/kubelet.service.d
cp kubelet.service /etc/systemd/system/kubelet.service
sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" /etc/systemd/system/kubelet.service
cp 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# 开机启动 kubelet
echo_exec 'systemctl enable --now kubelet'

echo_exec 'echo_exec "source <(kubectl completion bash)"'
echo "source <(kubectl completion bash)" >> ~/.bashrc

## 安装 CNI 插件（大多数 Pod 网络都需要，基于 yum 方式会自动安装相关网络插件 kubernetes-cni）：
### 安装cni
CNI_VERSION="v1.3.0"
echo_exec 'mkdir -p /opt/cni/bin'
sudo mkdir -p "$DEST"
echo_exec 'curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz"'
echo_exec 'curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz.sha256"'
echo_exec 'echo "$(<cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz.sha256) cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz" | sha256sum --check'
echo_exec 'tar -xzf cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz -C /opt/cni/bin'


### 安装 crictl
#### 定义要下载命令文件的目录。
#### 安装 crictl（kubeadm/kubelet 容器运行时接口（CRI）所需）
CRICTL_VERSION="v1.28.0"
echo_exec 'curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz"'
echo_exec 'tar -xzf crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz -C $DOWNLOAD_DIR'

# 安装 kubeadm,kubelet,kubectl
# 在 /etc/profile 末尾添加
echo_exec 'echo "export PATH=/opt/bin:/opt/cni/bin:\$PATH" >> /etc/profile'
echo_exec 'source /etc/profile'
