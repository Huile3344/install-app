#!/bin/bash
source /opt/shell/log.sh

## 升级系统内核为 4.4 以上版本
### CentOS 8 系统自带的 4.x.x 内核.

### 查看当前系统使用的内核
echo_exec 'uname -a'
# Linux node1 4.18.0-331.el8.x86_64 #1 SMP Thu Aug 19 16:49:03 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

### 查看当前默认启动内核
echo_exec 'grub2-editenv list'
# 返回： saved_entry=8637c32b6bfa441e80037b948deaba55-4.18.0-331.el8.x86_64

### 安装新内核，若需要
#### 安装ELRepo
echo_exec 'yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm'
#### 升级Kernel，在 ELRepo 中有两个内核选项，一个是 kernel-lt(长期支持版本)，一个是 kernel-ml(主线最新版本)，采用长期支持版本(kernel-lt)，更稳定一些
echo_exec 'yum --enablerepo=elrepo-kernel install -y kernel-lt'

### 确认改动的结果
echo_exec 'grub2-editenv list'
# 返回： saved_entry=8637c32b6bfa441e80037b948deaba55-5.4.142-1.el8.elrepo.x86_64

### 重启系统
#reboot
### 查看当前系统使用的内核
#uname -a
# 返回：Linux node2 5.4.142-1.el8.elrepo.x86_64 #1 SMP Tue Aug 17 10:25:03 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux
### 内核升级完成
