#!/bin/bash
source /opt/shell/log.sh

## 升级系统内核为 4.4 以上版本
### CentOS 7.x 系统自带的 3.10.x 内核存在一些 Bugs，导致运行的 Docker、Kubernetes 不稳定.

### 查看当前系统使用的内核
echo_exec 'uname -a'
# 返回：Linux centos 3.10.0-693.el7.x86_64 #1 SMP Tue Aug 22 21:09:27 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

### 查看当前默认启动内核
echo_exec 'grub2-editenv list'
# 返回： saved_entry=CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)

### 安装新内核，若需要
#### 安装ELRepo
echo_exec 'yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm'
#### 升级Kernel，在 ELRepo 中有两个内核选项，一个是 kernel-lt(长期支持版本)，一个是 kernel-ml(主线最新版本)，采用长期支持版本(kernel-lt)，更稳定一些
echo_exec 'yum --enablerepo=elrepo-kernel install -y kernel-lt'

### 罗列所有内核，确认新内核已经安装，如：CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)
#cat /boot/grub2/grub.cfg | grep menuentry
## 返回：
#if [ x"${feature_menuentry_id}" = xy ]; then
#  menuentry_id_option="--id"
#  menuentry_id_option=""
#export menuentry_id_option
#menuentry 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
#menuentry 'CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-693.el7.x86_64-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {
#menuentry 'CentOS Linux (0-rescue-5f1fe186a0214fae8c3b96235d409a29) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-5f1fe186a0214fae8c3b96235d409a29-advanced-d3b2e9ee-ce17-40cc-8ecc-5e0be5f72414' {

#或
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
## 返回：
#0 : CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)
#1 : CentOS Linux (3.10.0-693.el7.x86_64) 7 (Core)
#2 : CentOS Linux (0-rescue-5f1fe186a0214fae8c3b96235d409a29) 7 (Core)


### 设置开机从新内核启动
echo_exec "grub2-set-default 'CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)'"

### 确认改动的结果
echo_exec 'grub2-editenv list'
# 返回： saved_entry=CentOS Linux (5.4.108-1.el7.elrepo.x86_64) 7 (Core)

### 重启系统
#reboot
### 查看当前系统使用的内核
#uname -a
# 返回：Linux centos 5.4.108-1.el7.elrepo.x86_64 #1 SMP Mon Mar 22 18:37:08 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux
### 内核升级完成
