#!/usr/bin/env bash
#

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}")/..)
echo "INSTALLER_ROOT: $INSTALL_ROOT"

source "$INSTALL_ROOT/shell/func.sh"
source "$INSTALL_ROOT/shell/master.properties"

echo_exec "cd $INSTALL_ROOT"

step=1
echo "******** step $step prepare something for k8s kubeadm init ********"
echo "******** close all swap ********"
# 关闭swap，防止kubeadm init失败
echo_exec "swapoff -a"

echo "******** delete all kube resource ********"
KUBEADM_ETCD_LOCAL=${KUBEADM_ETCD_LOCAL:-"false"}
if [ "false" = $KUBEADM_ETCD_LOCAL ]; then
  CALICO_ROOT=$INSTALL_ROOT/out/calico
else
  CALICO_ROOT=$INSTALL_ROOT/out/calico-local
fi
CALICO_APPLY=$CALICO_ROOT/apply
if [ ! -d $CALICO_APPLY ]; then
  mkdir -p $CALICO_APPLY
fi
systemctl status kubelet.service > /dev/null
# kubelet 有正常启动，则删除以前可能存在的资源
if [ 0 -eq $? ]; then
  echo_exec "kubectl delete -f $CALICO_APPLY"
  echo_exec "kubectl delete -R -f $INSTALL_ROOT/out/metrics-server"
  echo_exec "kubectl delete -f $INSTALL_ROOT/out/dashboard"
fi

let step=step+1
echo -e "\n******** step $step kubeadm reset ********"
# kubeadm reset，便于重复执行此文件
echo_exec "kubeadm reset -f"


CONFIG=$INSTALL_ROOT/config/config.yaml
cp $KUBEADM_CONFIG $CONFIG


let step=step+1
echo "******** step $step 生成 $CONFIG 文件 ********"
ETCD_TLS=${ETCD_TLS:-"true"}
if [ "true" = $ETCD_TLS ]; then
  sed -i "s@# keyFile:.*@keyFile: $ETCD_CLIENT_KEY_PEM @g" $CONFIG
  sed -i "s@# certFile:.*@certFile: $ETCD_CLIENT_PEM@g" $CONFIG
  sed -i "s@# caFile:.*@caFile: $ETCD_CA_PEM@g" $CONFIG
fi
sed -i "s@<POD_SUBNET>@'$POD_SUBNET'@g" $CONFIG
echo_exec cat $CONFIG

#let step=step+1
#echo "******** step $step 生成证书到/etc/kubernetes/pki : kubeadm alpha phase certs all --config $CONFIG ********"
#kubeadm alpha phase certs all --config $CONFIG

let step=step+1
echo -e "\n******** step $step kubeadm init ********"
# kubeadm init
echo_exec "kubeadm init --config $CONFIG"

if [ 0 -ne $? ]; then
  echo -e "\n--------------------------------"
  echo "k8s cluster install fail"
  echo "--------------------------------"
  exit 1;
fi

# 生成新的kubeadm join *** 信息
# kubeadm token create --print-join-command



let step=step+1
echo -e "\n******** step $step KUBECONFIG ********"
# if you are not the root user, you could run this:
if [ ! -d $HOME/.kube ]; then
  mkdir -p $HOME/.kube
fi
echo_exec "sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config"
echo_exec "sudo chown $(id -u):$(id -g) $HOME/.kube/config"

# if you are the root user, you could run this:
if [ 0 -eq $UID ]; then
  echo_exec "export KUBECONFIG=/etc/kubernetes/admin.conf"
fi



let step=step+1
echo -e "\n******** step $step install cni $CNI_TYPE ********"
if [ "flannel" = $CNI_TYPE ]; then
  echo_exec kubectl apply -f $INSTALL_ROOT/out/kube-flannel.yml
else
  if [ ! -e $CALICO_ROOT/calico.yaml ]; then
    # 目前发现使用 calico 方式 cni 时 coredns 无法正常启动，导致网络故障，最终由于无线重启pod导致虚拟机挂死。
	# 原因：基于 calico 的 etcd 的两种方式使用的 calico yaml相关文件混了导致
    if [ "false" = $KUBEADM_ETCD_LOCAL ]; then # 使用外部 etcd 方式
      echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calicoctl.yaml -o $CALICO_ROOT/calicoctl.yaml"
      echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/rbac.yaml -o $CALICO_ROOT/rbac.yaml"
      echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calico.yaml -o $CALICO_ROOT/calico.yaml"
	else # 使用 kubernetes 内置 etcd pod 替代外部 etcd 方式
	  echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calicoctl.yaml -o $CALICO_ROOT/calicoctl.yaml"
      echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml -o $CALICO_ROOT/rbac-kdd.yaml"
      echo_exec "curl -L https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml -o $CALICO_ROOT/calico.yaml"
	fi
  fi

  cp $CALICO_ROOT/*.yaml $CALICO_APPLY/
  calico_yaml=$CALICO_APPLY/calico.yaml
  # 修改 calico 内部 IPV4POOL 的默认网段
  CALICO_IPV4POOL_CIDR=${POD_SUBNET:-"192.168.0.0/16"}
  if [ "192.168.0.0/16" != $CALICO_IPV4POOL_CIDR ]; then
    sed -i "s@192.168.0.0/16@$CALICO_IPV4POOL_CIDR@g" $calico_yaml
  fi
  if [ "false" = $KUBEADM_ETCD_LOCAL ]; then
    # 修改 calico.yaml
    sed -i "s@etcd_endpoints: \"http://127.0.0.1:2379\"@etcd_endpoints: \"$ETCD_ENDPOINTS\"@g" $calico_yaml
    # 开启了证书方式
    if [ "true" = $ETCD_TLS ]; then
      # 修改 calico.yaml
      sed -i "s@etcd_ca:.*#@etcd_ca:@g" $calico_yaml
	  sed -i "s@etcd_cert:.*#@etcd_cert:@g" $calico_yaml
	  sed -i "s@etcd_key:.*#@etcd_key:@g" $calico_yaml
	  sed -i "s@# etcd-key: null@etcd-key: $(cat $ETCD_CLIENT_KEY_PEM | base64 | tr -d '\n')@g" $calico_yaml
	  sed -i "s@# etcd-cert: null@etcd-cert: $(cat $ETCD_CLIENT_PEM | base64 | tr -d '\n')@g" $calico_yaml
	  sed -i "s@# etcd-ca: null@etcd-ca: $(cat $ETCD_CA_PEM | base64 | tr -d '\n')@g" $calico_yaml
	  # 修改 calicoctl.yaml
	  calicoctl_yaml=$CALICO_APPLY/calicoctl.yaml
	  # 开启关于 tls 的配置
	  sed -i "s@ # volumeMounts:@ volumeMounts:@g" $calicoctl_yaml
	  sed -i "s@ # -@ -@g" $calicoctl_yaml
	  sed -i "s@ #   @   @g" $calicoctl_yaml
	  sed -i "s@ #     @     @g" $calicoctl_yaml
	  sed -i "s@ #       @       @g" $calicoctl_yaml
    fi
  fi
  echo "******** apply calico ********"
  # install calico
  echo_exec "sleep 5"
  #echo_exec "kubectl apply -f $INSTALL_ROOT/out/net/calico.yaml"
  echo_exec "kubectl apply -f $CALICO_APPLY"
fi
  
echo "******** taint nodes ********"
# untaint 
echo_exec "kubectl taint nodes --all node-role.kubernetes.io/master-"



let step=step+1
echo -e "\n******** step $step apply other app ********"
echo "******** apply metrics-server ********"
# install metrics-server
#echo_exec "kubectl apply -R -f $INSTALL_ROOT/out/metrics-server"

echo "******** apply dashboard ********"
# install dashboard
echo_exec "kubectl apply -f $INSTALL_ROOT/out/dashboard"
echo "请先在一个窗口执行：kubectl proxy，在浏览器访问： http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
echo "或者访问：https://masterip:32000"
echo "获取dashboard 登录 TOKEN 脚本命令"
echo_exec "kubectl describe -n kube-system secret \$(kubectl get secrets -n kube-system | grep kubernetes-dashboard-token | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d \" \""
#默认cluster-admin是拥有全部权限的，将admin和cluster-admin bind这样admin就有cluster-admin的权限。
echo_exec kubectl create clusterrolebinding login-on-dashboard-with-cluster-admin --clusterrole=cluster-admin --user=admin



let step=step+1;
echo -e "\n******** step $step 添加 iptables 规则，使 node 中的pod可连接外部网络 ********"
# 加上该段之后，pod可访问外部网络了，如：ping www.baidu.com
echo_exec iptables -t nat -I POSTROUTING -s $POD_SUBNET -j MASQUERADE



echo k8s cluster installed success

