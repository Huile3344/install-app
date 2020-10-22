#!/bin/bash
# 脚本说用：
# 禁用 yum-cron 防止 yum 定时自动更新

echo "# systemctl stop yum-cron && systemctl disable yum-cron"
systemctl stop yum-cron && systemctl disable yum-cron
