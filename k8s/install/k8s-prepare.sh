#!/bin/bash
source /opt/shell/log.sh

set +e

# k8s 安装前的一些初始化操作
## 安装一些依赖包，方便后面使用
echo_exec 'yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git'


## 设置防火墙为 Iptables 并设置空规则
echo_exec 'systemctl stop firewalld && systemctl disable firewalld'
echo_exec 'yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save'


## 关闭 SELINUX
echo_exec "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
echo_exec "setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config"


## 安装和配置的先决条件：
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

echo_exec 'modprobe overlay'
echo_exec 'modprobe br_netfilter'


## kube-proxy开启ipvs的前置条件
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
EOF
echo_exec 'chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs'


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
echo_exec 'sysctl --system'
### 添加 iptables 规则，使 k8s 中的pod可连接外部网络, 需要配置 net.ipv4.conf.all.forwarding=1，将 10.244.0.0/16 改成实际网段
echo_exec 'iptables -t nat -I POSTROUTING -s 10.244.0.0/16 -j MASQUERADE'
echo_exec 'iptables -P FORWARD ACCEPT'









