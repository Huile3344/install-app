
# kubernetes 安装


## k8s 安装前的一些初始化操作

### 检查所需端口
| 协议 |	方向 | 端口范围 | 作用 | 使用者 |
| --- | --- | --- | --- | --- |
| TCP |	入站 | 6443 | Kubernetes API 服务器 | 所有组件 |
| TCP | 入站 | 2379-2380 | etcd 服务器客户端 API | kube-apiserver, etcd |
| TCP | 入站 | 10250 | Kubelet API	| Self, Control plane |
| TCP | 入站 | 10251 | kube-scheduler | Self |
| TCP | 入站 | 10252 | kube-controller-manager | Self |

执行命令查询端口占用情况：
```
netstat -tunpl | grep 6443
netstat -tunpl | grep 2379
netstat -tunpl | grep 2380
netstat -tunpl | grep 10250
netstat -tunpl | grep 10251
netstat -tunpl | grep 10252
```
若端口被占用，需要释放端口

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

# 若上述方式无法下载文件，可将 install 目录下的 10-kubeadm.conf 拷贝过来使用（yum 安装 kubelet 时生成的文件）
## 特别提醒：若是没有该文件，kubelet 可能无法作为后台服务运行
mkdir -p /etc/systemd/system/kubelet.service.d
cp 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

## 检测 kubelet kubeadm kubectl 版本
```
# 测试安装的版本：
kubelet --version
kubectl version --client
kubeadm version

# kubeadm 命令自动补全
source <(kubeadm completion bash)
echo "source <(kubeadm completion bash)" >> ~/.bashrc

# kubectl 命令自动补全
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```
### 开机启动 kubelet
```
systemctl enable kubelet
systemctl daemon-reload
systemctl start kubelet
```

## 安装 kubernetes 需要的 container runtime
参考 kubernetes 容器运行时安装: https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/
参考 docker 安装 https://docs.docker.com/engine/install/centos/#install-using-the-repository
### 卸载旧版 docker
```
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```
### 使用存储库安装
#### 设置存储库
```
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```
### 安装 docker
```
sudo yum install -y docker-ce docker-ce-cli containerd.io
```
### 设置开机启动docker，启动并验证docker
```
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run hello-world
```
### 修改 docker 配置
```
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "oom-score-adjust": -1000,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10,
  "registry-mirrors": ["https://c174fa3u.mirror.aliyuncs.com"],
  "storage-driver": "overlay2"
}
EOF
```
### 重新加载配置，重启 docker 和 kubelet
```
systemctl daemon-reload
systemctl restart docker
systemctl restart kubelet
```
### 查看 docker 当前配置
查看并核对docker的配置信息是否正确
```
docker info
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

## kubernetes 初始化安装

### 获取 kubeadm 初始化安装默认配置文件
```
kubeadm config print init-defaults > kubeadm-config.yml
```

### 修改 kubeadm 初始化yml
修改yml部分原有配置，
```
localAPIEndpoint:
  # 修改为 k8s 节点IP
  advertiseAddress: 192.168.0.6
# 修改为安装的 k8s 版本
kubernetesVersion: v1.20.5
networking:
  # 添加 Pod 网段
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
```

#### 1.19 及之前的版本开启 IPVS 方式
在yml后面追加以下内容
```
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
featureGates:
  SupportIPVSProxyMode: true
mode: ipvs
```

#### 对于 1.20 版本开启 IPVS 方式
参考官网 https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md

在yml后面追加以下内容
```
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
```

#### 针对已经运行的 k8s 修改 kube-proxy 开启 IPVS 方式
关于 KubeProxyConfiguration 的简易参数模板可通过以下命名查看运行中的 k8s kube-proxy 配置，或者查看已导出的 kube-proxy-config.yml 文件
```
kubectl -n kube-system get configmaps kube-proxy -o yaml > kube-proxy-config.yml
```
对于已经在运行中的 k8s 可通过在线修改 kube-proxy 的 configmap 来调整
```
kubectl -n kube-system edit cm kube-proxy
```
再讲所有kube-proxy进行重启,查看pod运行情况
```
kubectl -n kube-system get pod
```
查看ipvs模式是否启用成功
```
ipvsadm -Ln
```

### kubeadm init 安装 k8s master
```
kubeadm init --config=kubeadm-config.yml | tee kubeadm-init.log
```

### 开启 kubectl 访问 k8s
#### 非 root 用户可以运行 kubectl，请运行以下命令
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
#### root 用户，则可以运行：
```
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile
```
#### 获取 k8s 集群阶段状态
漏执行上诉脚本会出现如下错误提醒
```
[root@centos ~]# kubectl get nodes
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
正确执行返回结果应该如下
```
[root@centos install]# kubectl get nodes
NAME     STATUS     ROLES                  AGE    VERSION
centos   NotReady   control-plane,master   149m   v1.20.5
```

### 查看 kubelet 默认使用的 cgroupDriver
推荐使用 systemd
```
cat /var/lib/kubelet/config.yaml
```

### 控制平面节点隔离
默认情况下，出于安全原因，你的集群不会在控制平面节点上调度 Pod。 如果你希望能够在控制平面节点上调度 Pod， 例如用于开发的单机 Kubernetes 集群，请运行：
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```


## 安装扩展（Addons）
参考 安装扩展（Addons） https://kubernetes.io/zh/docs/concepts/cluster-administration/addons/

部署 pod network 前节点状态: NotReady
```
[root@centos install]# kubectl get nodes
NAME     STATUS     ROLES                  AGE    VERSION
centos   NotReady   control-plane,master   165m   v1.20.5
```
可按需部署对应的网络和网络策略，以下以 flannel 为示例：
```
# 若执行以下脚本无法下载，可直接访问：https://github.com/flannel-io/flannel/blob/master/Documentation/kube-flannel.yml，手动拷贝获取
curl -LO "https://github.com/flannel-io/flannel/blob/273b36ca57dca3eebcc813ddca7d917955375054/Documentation/kube-flannel.yml"
kubectl apply -f kube-flannel.yml
```
部署 pod network 成功后节点状态: Ready
```
[root@centos install]# kubectl get nodes
NAME     STATUS   ROLES                  AGE    VERSION
centos   Ready    control-plane,master   168m   v1.20.5
```

## 至此单机 k8s 安装完成

## 加入节点 
要将新节点添加到集群，请对每台计算机执行以下操作：
```
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```
如果没有令牌，可以通过在控制平面节点上运行以下命令来获取令牌：
```
kubeadm token list
```
默认情况下，令牌会在24小时后过期。如果要在当前令牌过期后将节点加入集群， 则可以通过在控制平面节点上运行以下命令来创建新令牌：
```
kubeadm token create
```
如果没有 --discovery-token-ca-cert-hash 的值，则可以通过在控制平面节点上执行以下命令链来获取它：
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

## 删除节点 
使用适当的凭证与控制平面节点通信，运行：
```
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
```
在删除节点之前，请重置 kubeadm 安装的状态：
```
kubeadm reset
```
重置过程不会重置或清除 iptables 规则或 IPVS 表。如果你希望重置 iptables，则必须手动进行：
```
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```
如果要重置 IPVS 表，则必须运行以下命令：
```
ipvsadm -C
```
现在删除节点：
```
kubectl delete node <node name>
```

## 安全 -- k8s 认证鉴权准入控制

### 机制说明
Kubernetes 作为一个分布式集群管理工具，保证集群的安全性是其一个重要的任务。
api server 是集群内部各个组件通信的中介，也是外部控制的入口。所以 Kubernetes 的
安全机制基本就是围绕保护 api server 来设计的。 Kubernetes 使用了认证（Authendication）、
鉴权（Authorization）、准入控制（Admission Control） 三步来保证 api server 的安全

### 认证（Authendication）
k8s的有以下三种认证方式
- Http Token 认证：通过一个Token来识别合法用户
- Http Base 认证：通过 用户名+密码 的方式认证
- 最严格的 HTTPS 证书认证：基于CA根证书签名的客户端身份认证方式

#### 证书颁发
- 手动签发：通过k8s集群的根 ca 进行签发 HTTPS 证书
- 自动签发：kubelet 首次访问 api server 时， 使用token认证，通过后， Controller Manager 会为
kubelet 生成一个证书，以后的访问都是用证书做认证了

#### kubeconfig
kubeconfig 文件包含集群参数（CA证书、api server地址)，客户端参数（上面生成的证书和私钥），集群 context 信息
（集群名称、用户名），Kubernetes 组件通过启动时指定不同的 kubeconfig 文件可以切换到不同的集群

### PKI证书和要求
参考官网：[PKI证书和要求](https://kubernetes.io/zh/docs/setup/best-practices/certificates/)

####证书存放的位置 
    
如果你是通过 kubeadm 安装的 Kubernetes，所有证书都存放在 `/etc/kubernetes/pki` 目录下。


#### 为用户帐户配置证书 
```
KUBECONFIG=<filename> 
# 设置集群参数
kubectl config set-cluster default-cluster --server=https://<host ip>:6443 --certificate-authority <path-to-kubernetes-ca> --embed-certs
# 设置客户端认证参数 
kubectl config set-credentials <credential-name> --client-key <path-to-key>.pem --client-certificate <path-to-cert>.pem --embed-certs
# 设置上下文参数
kubectl config set-context default-system --cluster default-cluster --user <credential-name>
# 设置默认上下文
kubectl config use-context default-system
```

### 鉴权（Authorization）
认证过程只是确认通信的双方都是可信的，可以互相通信。而鉴权是确定请求方有哪些资源的权限。
api server 目前支持一下几种鉴权策略（通过 api server 的启动参数“--authorization-mode”设置）
- AlwaysDeny: 表示拒绝所有的请求，一般用于测试
- AlwaysAllow: 允许接收所有请求，如果集群不需要授权流程，则可以采用该策略
- ABAC(Attribute-Based Access Control): 基于属性的访问控制，表示使用用户配置的授权规则对用户请求
进行匹配和控制
- RBAC(Role-Based Access Control): 基于角色的访问控制，现行默认规则

#### RBAC 授权模式
在 Kubernetes 1.5 中引入，现行版本成为默认标准。相对其他访问控制方式，有以下优势：
- 对集群中的资源和非资源均拥有完整的覆盖
- 整个RBAC完全由几个API对象完成，同其他API对象一样，可以用kubectl或API进行操作
- 可以在运行时进行调整，无需重启api server

#### RBAC 的 API 资源对象说明
RBAC 引入了4个新的顶级资源对象: Role、ClusterRole、RoleBinding、ClusterRoleBinding，4中对象类型
均可通过kubectl与api操作。

需要注意的是Kubernetes并不会提供用户管理，那么 User, Group, ServiceAccount 指定的用户又是从哪里来的呢？
Kubernetes组件(kubectl, kube-proxy)或是其他自定义的用户在向CA申请证书时，需要提供给一个证书请求文件
```
{
    "CN": "admin",
    "hosts": [],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "Guangdong",
            "L": "Guangzhou",
            "O": "system:masters",
            "OU": "System"
        }
    ]
}

```
api server 会把客户端证书的 `CN` 字段作为 User，把 `names.O` 字段作为 Group

kubectl 使用 TLS BootStaping 认证是， api server 可以使用 Bootstrap Tokens 或者
Token authorization file 验证 = token，无论哪一种，Kubernetes都会为token绑定一个默认的User和Group

Pod 使用 ServiceAccount 认证时，service-account-token 中的 JWT 会保存 User 信息
有了用户信息，再创建一个角色/角色绑定(集群角色/集群角色绑定)资源对象，就可以完成权限绑定了




## k8s 的 master 更换 IP
参考：[k8s的master更换ip](https://www.cnblogs.com/chaojiyingxiong/p/12106590.html)
已制作成脚本：[k8s辅助脚本](./shell/k8s-assist.sh) 的操作 *change-master-ip*

k8s的master更换ip后，通信问题出现了问题，我们只需要通过kubeadm init phase命令，重新生成config文件和签名文件就可以了。操作如下：
 
- 切换到/etc/kubernetes/manifests， 将etcd.yaml  kube-apiserver.yaml里的ip地址替换为新的ip
  ```
  vim /etc/kubernetes/manifests/etcd.yaml
  vim /etc/kubernetes/manifests/kube-apiserver.yaml
  ```
- 生成新的config文件
  ```
  # 需要先移除该文件，否则k8s无法新生成
  mv /etc/kubernetes/admin.conf /etc/kubernetes/admin.conf.bak
  kubeadm init phase kubeconfig admin --apiserver-advertise-address <新的ip>
  ```
- 删除老证书，生成新证书
  ```
  # 需要先移除证书文件，否则k8s无法新生成
  mv /etc/kubernetes/pki/apiserver.key /etc/kubernetes/pki/apiserver.key.bak
  mv /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.bak
  kubeadm init phase certs apiserver  --apiserver-advertise-address <新的ip>
  ```
- 重启 docker 和 kubelet
  ```
  service docker restart && service kubelet restart
  ```
- 将配置文件config输出
  ```
  kubectl get nodes --kubeconfig=admin.conf  #  此时已经是通信成功了
  ``` 
- 将kubeconfig默认配置文件替换为admin.conf，这样就可以直接使用kubectl get nodes
  ```
  mv admin.conf ~/.kube/config
  ```   