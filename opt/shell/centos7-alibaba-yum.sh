#!/bin/bash
# 脚本说用：
# 日期时间做后缀，备份旧的 centos yum源为 alibba 的yum源

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.$(date "+%Y-%m-%d#%H:%M:%S").backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache
