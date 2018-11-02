#!/usr/bin/env bash
# 下载 calico yaml 文件

source "../../shell/func.sh"

echo_exec "curl -O https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/rbac.yaml"
# 使用rbac.yaml 而不使用rbac-kdd.yaml，前者较后者多添加 clusterrole.rbac.authorization.k8s.io/calico-kube-controllers 和
# clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers ，后者会导致kubernetes-dashboard无法启动，且和coredns无限重启，导致linux负载过高，卡死
# echo_exec "curl -O https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml"

echo_exec "curl -O https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted//calico.yaml"

echo_exec "curl -O https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calicoctl.yaml"