#!/bin/bash
source /opt/shell/log.sh

# k8s 安装前的一些初始化操作
## 安装一些依赖包，方便后面使用
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wgetvimnet-tools git




## 设置防火墙为 Iptables 并设置空规则
systemctl  stop firewalld  &&  systemctl  disable firewalld
yum -y install iptables-services  &&  systemctl  start iptables  &&  systemctl  enable iptables &&  iptables -F  &&  service iptables save




## 关闭 SELINUX
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config




## 升级系统内核为 4.4 以上版本
### CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定.

### 查看当前系统使用的内核
uname -a
# 返回：Linux centos 3.10.0-693.el7.x86_64 #1 SMP Tue Aug 22 21:09:27 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

### 查看当前默认启动内核
grub2-editenv list
# 返回： saved_entry=CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)

### 安装新内核，若需要
#### 安装ELRepo
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
#### 升级Kernel，在 ELRepo 中有两个内核选项，一个是 kernel-lt(长期支持版本)，一个是 kernel-ml(主线最新版本)，采用长期支持版本(kernel-lt)，更稳定一些
yum --enablerepo=elrepo-kernel install -y kernel-lt

### 罗列所有内核，确认新内核已经安装，如：CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)
cat /boot/grub2/grub.cfg | grep menuentry
# 返回：
if [ x"${feature_menuentry_id}" = xy ]; then
  menuentry_id_option="--id"
  menuentry_id_option=""
export menuentry_id_option
menuentry 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
menuentry 'CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
menuentry 'CentOS Linux (0-rescue-5f1fe186a0214fae8c3b96235d409a29) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-5f1fe186a0214fae8c3b96235d409a29-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {

### 设置开机从新内核启动
grub2-set-default 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)'

### 确认改动的结果
grub2-editenv list
# 返回： saved_entry=CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)

### 重启系统
reboot
### 查看当前系统使用的内核
uname -a
# 返回：Linux centos 5.4.108-1.el7.elrepo.x86_64 #1 SMP Mon Mar 22 18:37:08 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux
### 内核升级完成




## 安装和配置的先决条件：
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter


## kube-proxy开启ipvs的前置条件
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules &&lsmod | grep -e ip_vs -e nf_conntrack_ipv4


## 网络问题配置
# Note:
# Disabling SELinux by running setenforce 0 is required to allow containers to access the host filesystem, which is required by pod networks for example. You have to do this until SELinux support is improved in the kubelet.
# Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.
# 2. cat /proc/sys/net/ipv4/ip_forward，该文件内容为0，表示禁止数据包转发，1表示允许，net.ipv4.ip_forward = 1用于修改该值为1
# 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。允许 iptables 检查桥接流量
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
### 应用 sysctl 参数而无需重新启动
sysctl --system
### 添加 iptables 规则，使 k8s 中的pod可连接外部网络, 需要配置 net.ipv4.conf.all.forwarding=1，将 10.1.2.0/24 改成实际网段
iptables -t nat -I POSTROUTING -s 10.1.2.0/24 -j MASQUERADE
iptables -P FORWARD ACCEPT




## 安装 CNI 插件（大多数 Pod 网络都需要）：
### 安装cni
CNI_VERSION="v0.9.1"
mkdir -p /opt/cni/bin
curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz"
curl -LO "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz.sha256"
echo "$(<cni-plugins-linux-amd64-${CNI_VERSION}.tgz.sha256) cni-plugins-linux-amd64-${CNI_VERSION}.tgz" | sha256sum --check
tar -xzf cni-plugins-linux-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin


### 安装 crictl
#### 定义要下载命令文件的目录。
DOWNLOAD_DIR=/opt/bin
mkdir -p $DOWNLOAD_DIR
#### 安装 crictl（kubeadm/kubelet 容器运行时接口（CRI）所需）
CRICTL_VERSION="v1.20.0"
curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
tar -xzf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C $DOWNLOAD_DIR

# 安装 kubeadm,kubelet,kubectl
# 在 /etc/profile 末尾添加
echo "export PATH=/opt/bin:/opt/cni/bin:\$PATH" >> /etc/profile
source /etc/profile




