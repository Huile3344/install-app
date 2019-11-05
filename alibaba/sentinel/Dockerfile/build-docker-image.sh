#!/bin/bash

source /opt/shell/log.sh

IMAGE_VERSION=1.6.3

# 构建 sentinel-dashboard的 docker 镜像
echo_exec "docker build . -t sentinel-dashboard:$IMAGE_VERSION"

success $"image sentinel-dashboard:$IMAGE_VERSION build success!"
