#!/bin/bash

source /opt/shell/log.sh

IMAGE_VERSION=v1

# 构建 sentinel-dashboard的 docker 镜像
echo_exec "docker build . -t spring-security-demo-simple:$IMAGE_VERSION"

success $"image spring-security-demo-simple:$IMAGE_VERSION build success!"
