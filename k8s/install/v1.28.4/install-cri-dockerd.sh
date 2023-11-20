#!/bin/bash

# 安装cri-dockerd
# Kubernetes自v1.24移除了对docker-shim的支持，而Docker Engine默认又不支持CRI规范，因而二者将无法直接完成整合。
# 为此，Mirantis和Docker联合创建了cri-dockerd项目，用于为Docker Engine提供一个能够支持到CRI规范的垫片，从而能够让Kubernetes基于CRI控制Docker 。

# 下载rpm包
if [[ ! -e "cri-dockerd-0.3.7.20231027185657.170103f2-0.el7.x86_64.rpm" ]]; then
  echo_exec 'curl -LO "https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.7/cri-dockerd-0.3.7.20231027185657.170103f2-0.el7.x86_64.rpm"'
fi
# 安装rpm包
echo_exec 'yum install -y cri-dockerd-0.3.7.20231027185657.170103f2-0.el7.x86_64.rpm'
# 开机自启动 cri-docker 和启动 cri-docker
echo_exec 'systemctl enable cri-docker.service && systemctl start cri-docker.service'
# 查看 cri-docker 运行情况
echo_exec 'systemctl status cri-docker.service'

# 配置cri-dockerd
# 配置cri-dockerd，确保其能够正确加载到CNI插件。编辑/usr/lib/systemd/system/cri-docker.service文件，
# 确保其[Service]配置段中的ExecStart的值类似如下内容。
# ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
# 需要添加的各配置参数（各参数的值要与系统部署的CNI插件的实际路径相对应）：
  # --network-plugin：指定网络插件规范的类型，这里要使用CNI；
  # --cni-bin-dir：指定CNI插件二进制程序文件的搜索目录；
  # --cni-cache-dir：CNI插件使用的缓存目录；
  # --cni-conf-dir：CNI插件加载配置文件的目录；
# 注释掉 ExecStart= 开头的行，并在其后新启一行，新行拷贝原有行内容并在行末尾添加  --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
sed -i "s:^ExecStart=.*:#&\n& --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d/:" /usr/lib/systemd/system/cri-docker.service
