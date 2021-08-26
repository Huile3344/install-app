#!/bin/bash
# 脚本说用：
# 日期时间做后缀，备份旧的 centos yum源为 alibba 的yum源

mv /etc/yum.repos.d/CentOS-BaseOS.repo /etc/yum.repos.d/CentOS-BaseOS.repo.$(date "+%Y-%m-%d#%H:%M:%S").backup
curl -o /etc/yum.repos.d/CentOS-BaseOS.repo http://mirrors.aliyun.com/repo/Centos-8.repo
yum makecache
