#!/bin/bash

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/..)
echo "INSTALLER_ROOT: $INSTALL_ROOT"

source "$INSTALL_ROOT/shell/func.sh"
source "$INSTALL_ROOT/shell/master.properties"

step=1
echo -e "\n******** step $step network 网络相关问题配置 ********"
echo "******** 配置转发相关参数 generate /etc/sysctl.d/k8s.conf ********"
# 网络问题配置
# Note:
# Disabling SELinux by running setenforce 0 is required to allow containers to access the host filesystem, which is required by pod networks for example. You have to do this until SELinux support is improved in the kubelet.
# Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.
# 2. cat /proc/sys/net/ipv4/ip_forward，该文件内容为0，表示禁止数据包转发，1表示允许，net.ipv4.ip_forward = 1用于修改该值为1
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

echo "******** close selinux ********"
# 关闭selinux
echo_exec setenforce 0

echo "******** disable and stop firewalld ********"
# 关闭防火墙
echo_exec "systemctl disable firewalld && systemctl stop firewalld"

echo "******** install socat ********"
# 1. 安装socat
echo_exec "rpm -qa | grep socat"
if [ 0 -ne $? ]; then # 未安装socat，就安装socat
  echo_exec "yum install -y $INSTALL_ROOT/rpms/socat*.rpm"
else
  echo "socat has installed"
fi

echo -e "\n******** install crictl to /usr/bin ********"
if [ ! -e /usr/bin/crictl ]; then
  echo_exec "tar -C /usr/bin -xzf $INSTALL_ROOT/tgz/crictl-*-linux-amd64.tar.gz"
  #rm -f /usr/bin/crictl
else
  echo "crictl has located in /usr/bin"
fi


let step=step+1
echo -e "\n******** step $step load image ********"
# 将镜像加载到docker中
echo_exec docker load -i $INSTALL_ROOT/image/k8s-images.tar
echo_exec docker load -i $INSTALL_ROOT/image/quay-images.tar


let step=step+1
echo -e "\n******** step $step install k8s executable 安装k8s需要用到的二进制执行文件 ********"
echo "******** install kubeadm kubectl kubelet to /usr/bin ********"
# 拷贝kubernetes二进制执行文件
echo_exec chmod +x $INSTALL_ROOT/bin/kube*
echo_exec cp $INSTALL_ROOT/bin/kube* /usr/bin

echo "******** install k8s cni in /opt/cni/bin ********"
if [ ! -d /opt/cni/bin ]; then
  sudo mkdir -p /opt/cni/bin
  echo_exec tar -C /opt/cni/bin -xzf $INSTALL_ROOT/tgz/cni-plugins-amd64-*.tgz
else
  echo "cni plugins has located in /opt/cni/bin/"
fi


let step=step+1
echo -e "\n******** step $step add a kubelet systemd service and kubelet 10-kubeadm.conf ********"
# Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
cp $INSTALL_ROOT/config/kubelet.service /etc/systemd/system/
if [ ! -d /etc/systemd/system/kubelet.service.d ]; then
  sudo mkdir -p /etc/systemd/system/kubelet.service.d
fi
cp $INSTALL_ROOT/config/10-kubeadm.conf /etc/systemd/system/kubelet.service.d


let step=step+1
echo -e "\n******** step $step enable and start kubelet ********"
echo "******** close all swap for start kubelet ********"
# 关闭swap，否则无法启动kubelet
swapoff -a
# node的服务器重启后系统自动启动kubelet服务失败，通过命令(journalctl -exu kubelet)查看到有如下报错信息：
# error: failed to run Kubelet: Running with swap on is not supported, please disable swap! or set --fail-swap-on flag to false
# 编辑kubelet的配置文件/etc/systemd/system/kubelet.service.d/10-kubeadm.conf 
# 在KUBELET_CGROUP_ARGS配置参数末尾加上配置项--fail-swap-on=false
# (当前离线脚本已经按此方式修改参数了)重启服务后，发现kubelet自动跟随系统启动
# ***注意***：正常的k8s集群中，不修改这部分原始数据应该是可以正常访问的。

echo "******** enable and start kubelet ********"
echo_exec "systemctl enable kubelet && systemctl start kubelet"

let step=step+1
echo -e "\n******** step $step kubectl completion bash ********"
# ********kubectl命令自动补全*******
# kubectl这个命令行工具非常重要，与之相关的命令也很多，我们也记不住那么多的命令，而且也会经常写错，所以命令自动补全是非常有必要的，kubectl命令行工具本身就支持complication，只需要简单的设置下就可以了。以下是linux系统的设置命令：
# 
echo_exec "source <(kubectl completion bash)"
echo "source <(kubectl completion bash)" >> ~/.bashrc


let step=step+1
echo -e "\n******** step $step 添加 iptables 规则，使 calico node 中的pod可连接外部网络 ********"
# calico node 加上该段之后，pod可访问外部网络了，如：ping www.baidu.com
echo_exec iptables -t nat -I POSTROUTING -s $POD_SUBNET -j MASQUERADE

echo "init success"
