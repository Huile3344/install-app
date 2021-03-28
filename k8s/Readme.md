
# kubernetes 安装


## k8s 安装前的一些初始化操作

### 安装一些依赖包，方便后面使用
可按需调整安装的依赖包
```shell
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wgetvimnet-tools git
```

### 设置防火墙为 Iptables
```shell
systemctl  stop firewalld  &&  systemctl  disable firewalld
yum -y install iptables-services  &&  systemctl  start iptables  &&  systemctl  enable iptables &&  service iptables save
```

### 关闭 SELINUX
```shell
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### 升级系统内核版本
**注意：** CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定.
 
-  查看当前系统使用的内核
    ```
    [root@centos ~]# uname -a
    Linux centos 3.10.0-693.el7.x86_64 #1 SMP Tue Aug 22 21:09:27 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
    ```
-  查看当前默认启动内核
    ```
    [root@centos ~]# grub2-editenv list
    saved_entry=CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)
    ```
- 若查看到系统使用内核版本过低（如示例），则需要升级系统内核，执行后续步骤
- 安装ELRepo，升级Kernel

    在 ELRepo 中有两个内核选项，一个是 kernel-lt(长期支持版本)，一个是 kernel-ml(主线最新版本)，采用长期支持版本(kernel-lt)，更稳定一些
    ```
    # 安装ELRepo
    yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
    # 升级Kernel
    yum --enablerepo=elrepo-kernel install -y kernel-lt
    ```
- 罗列所有内核，确认新内核已经安装
 
    示例如：CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)
    ```
    [root@centos ~]# grub2-editenv list
    if [ x"${feature_menuentry_id}" = xy ]; then
      menuentry_id_option="--id"
      menuentry_id_option=""
    export menuentry_id_option
    menuentry 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
    menuentry 'CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
    menuentry 'CentOS Linux (0-rescue-5f1fe186a0214fae8c3b96235d409a29) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-5f1fe186a0214fae8c3b96235d409a29-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
    ```
-  设置开机从新内核启动
    ```
    grub2-set-default 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)'
    ```
- 确认改动的结果
    ```
    [root@centos ~]# grub2-editenv list
    saved_entry=CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)
    ```
- 重启系统
    ```
    reboot
    ```
- 查看当前系统使用的内核
    ```
     [root@centos ~]# uname -a
     Linux centos 5.4.108-1.el7.elrepo.x86_64 #1 SMP Mon Mar 22 18:37:08 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux
    ```
    内核升级完成

### 安装和配置的先决条件
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
```

### kube-proxy开启ipvs的前置条件
```
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

### 网络问题配置
```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1 # 启用IP转发功能，做NAT服务或者路由时才会用到，允许数据包转发，本机需要做路由转发，若是ipv6，则添加 net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.forwarding        = 1 # 不转发源路由帧，如果做NAT建议开启
net.ipv4.tcp_tw_recycle             = 0 # 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭。
vm.swappiness                       = 0 # 禁止使用 swap 空间，只有当系统 OOM 时才允许使用它
vm.overcommit_memory                = 1 # 不检查物理内存是否够用
vm.panic_on_oom                     = 0 # 开启 OOM
fs.inotify.max_user_instances       = 8192
fs.inotify.max_user_watches         = 1048576
fs.file-max                         = 52706963
fs.nr_open                          = 52706963
net.netfilter.nf_conntrack_max      = 2310720
EOF
sysctl --system
```
应用 sysctl 参数而无需重新启动

###添加 iptables 规则，使 k8s 中的pod可连接外部网络, 需要配置 net.ipv4.conf.all.forwarding=1，将 10.244.0.0/16 改成实际网段
```
iptables -t nat -I POSTROUTING -s 10.244.0.0/16 -j MASQUERADE
iptables -P FORWARD ACCEPT
```

### 安装 CNI 插件（大多数 Pod 网络都需要）：
```
CNI_VERSION="v0.9.1"
mkdir -p /opt/cni/bin
curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz"
curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz.sha256"
echo "$(<cni-plugins-linux-amd64-${CNI_VERSION}.tgz.sha256) cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sha256sum --check
tar -xzf cni-plugins-linux-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin
echo "export PATH=/opt/cni/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile
```

### 安装 crictl
```
# 定义要下载命令文件的目录。
DOWNLOAD_DIR=/opt/bin
mkdir -p $DOWNLOAD_DIR
# 安装 crictl（kubeadm/kubelet 容器运行时接口（CRI）所需）
CRICTL_VERSION="v1.20.0"
curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
tar -xzf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C $DOWNLOAD_DIR
echo "export PATH=/opt/bin:\$PATH" >> ~/.bash_profile
source ~/.bash_profile
```

## 安装 kubelet kubeadm kubectl
### 使用阿里云yum镜像 （推荐）
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet
```

### 使用google yum镜像（国内不推荐）
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet
```

### 二进制包方式
```
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

# 安装 kubeadm、kubelet、kubectl，使用下面命令下载最新的发行版本：
curl -LO "https://dl.k8s.io/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}"
#curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}

# 验证可执行文件（可选步骤）：
## 下载 kubeadm,kubelet,kubectl 校验和文件：
curl -LO "https://dl.k8s.io/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}.sha256"

# 使用校验和文件检查 kubeadm,kubelet,kubectl 可执行二进制文件：
echo "$(<kubectl.sha256) kubectl" | sha256sum --check
# 如果合法，则输出为：
# kubectl: OK
# 如果检查失败，则 sha256 退出且状态值非 0 并打印类似如下输出：
# kubectl: FAILED
# sha256sum: WARNING: 1 computed checksum did NOT match
echo "$(<kubeadm.sha256) kubeadm" | sha256sum --check
echo "$(<kubelet.sha256) kubelet" | sha256sum --check

DOWNLOAD_DIR="/usr/bin"
chmod +x {kubeadm,kubelet,kubectl}
cp kubeadm kubelet kubectl ${DOWNLOAD_DIR}
#echo "export PATH=${DOWNLOAD_DIR}:\$PATH" >> ~/.bash_profile
#source ~/.bash_profile

# 添加 kubelet 系统服务：
RELEASE_VERSION="v0.4.0"
#curl -LO "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service"
#sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" kubelet.service | tee /etc/systemd/system/kubelet.service
#mkdir -p /etc/systemd/system/kubelet.service.d
#curl -LO "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf"
#sed -i "s:/usr/bin:${DOWNLOAD_DIR}:g" 10-kubeadm.conf | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

## 检测 kubelet kubeadm kubectl 版本
```
# 测试安装的版本：
kubelet --version
kubectl version --client
kubeadm version

# kubectl命令自动补全
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

## 获取 kubernetes 初始化需要的镜像列表
 
可通过 `kubeadm config images list` 查看kubernetes 初始化需要的镜像

使用命令 `kubeadm config images pull` 从Google镜像仓库拉取镜像（需要翻墙，国内一般无法使用此方法）

### 国内镜像源
参考：https://blog.csdn.net/networken/article/details/84571373

部分国外镜像仓库无法访问，但国内有对应镜像源，可以从以下镜像源拉取到本地然后重改tag即可：

#### 阿里云镜像仓库

可以拉取k8s.gcr.io镜像
```
# 只需将 k8s.gcr.io 改为 registry.cn-hangzhou.aliyuncs.com/google_containers

#示例
docker pull k8s.gcr.io/pause:3.2

#改为
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
```


#### dockerhub镜像仓库

可以拉取k8s.gcr.io镜像
```
# 只需将 k8s.gcr.io 改为 googlecontainersmirrors

#示例
docker pull k8s.gcr.io/kube-apiserver:v1.17.3

#改为
docker pull googlecontainersmirrors/kube-apiserver:v1.17.3
```

#### 七牛云镜像仓库
     
可以拉取quay.io镜像
```
# 只需将 quay.io 改为 quay-mirror.qiniu.com

#示例
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0

#改为
docker pull quay-mirror.qiniu.com/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0
```

### 镜像拉取和重命名tag
```
# pull 需要的k8s镜像
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0

# tag 重命名
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5 k8s.gcr.io/kube-apiserver:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5 k8s.gcr.io/kube-controller-manager:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5 k8s.gcr.io/kube-scheduler:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5 k8s.gcr.io/kube-proxy:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0 k8s.gcr.io/etcd:3.4.13-0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0 k8s.gcr.io/coredns:1.7.0

# 移除多余的tag
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0
```

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile