#!/bin/bash
source /opt/shell/log.sh

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

# 安装 kubeadm、kubelet、kubectl，使用下面命令下载最新的发行版本：
curl -LO "https://dl.k8s.io/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}"
#curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}


# 验证可执行文件（可选步骤）：
## 下载 kubeadm,kubelet,kubectl 校验和文件：
curl -LO "https://dl.k8s.io/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}.sha256"

## 使用校验和文件检查 kubeadm,kubelet,kubectl 可执行二进制文件：
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
# 如果合法，则输出为：
# kubectl: OK
# 如果检查失败，则 sha256 退出且状态值非 0 并打印类似如下输出：
# kubectl: FAILED
# sha256sum: WARNING: 1 computed checksum did NOT match
echo "$(<kubeadm.sha256) kubeadm" | sha256sum --check
echo "$(<kubelet.sha256) kubelet" | sha256sum --check

chmod +x {kubeadm,kubelet,kubectl}
cp kubeadm kubelet kubectl DOWNLOAD_DIR

# 安装 kubeadm,kubelet,kubectl
# 在 /etc/profile 末尾添加，已在 k8s-init.sh 中添加了
#echo "export PATH=/opt/bin:/opt/cni/bin:\$PATH" >> /etc/profile
#source /etc/profile

#ln -sf ${DOWNLOAD_DIR}/kubeadm /usr/sbin/kubeadm
#ln -sf ${DOWNLOAD_DIR}/kubelet /usr/sbin/kubelet
#ln -sf ${DOWNLOAD_DIR}/kubectl /usr/sbin/kubectl

# install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
## 如果你并不拥有目标系统的 root 访问权限，你仍可以将 kubectl 安装到 ~/.local/bin 目录下：
# mkdir -p ~/.local/bin/kubectl
# mv ./kubectl ~/.local/bin/kubectl
# 之后将 ~/.local/bin/kubectl 添加到环境变量 $PATH 中


# 测试你所安装的版本是最新的：
kubeadm version
kubelet --version
kubectl version --client


# 添加 kubelet 系统服务：
RELEASE_VERSION="v0.4.0"
#curl -LO "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service"
#sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" kubelet.service | tee /etc/systemd/system/kubelet.service
#mkdir -p /etc/systemd/system/kubelet.service.d
#curl -LO "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf"
#sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" 10-kubeadm.conf | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

curl -LO "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service"
sed -i "s:/usr/bin:/opt/bin:g" kubelet.service | tee /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -LO "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf"
sed -i  "s:/usr/bin:/opt/bin:g" 10-kubeadm.conf | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable --now kubelet

echo_exec "source <(kubectl completion bash)"
echo "source <(kubectl completion bash)" >> ~/.bashrc