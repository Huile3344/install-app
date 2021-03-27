
# kubernetes 初始化安装

## 获取 kubernetes 初始化需要的镜像列表
 
可通过 `kubeadm config images list` 查看kubernetes 初始化需要的镜像

使用命令 `kubeadm config images pull` 从Google镜像仓库拉取镜像（需要翻墙，国内一般无法使用此方法）

### 国内镜像源
参考：https://blog.csdn.net/networken/article/details/84571373

部分国外镜像仓库无法访问，但国内有对应镜像源，可以从以下镜像源拉取到本地然后重改tag即可：

#### 阿里云镜像仓库

可以拉取k8s.gcr.io镜像
```
# 只需将 k8s.gcr.io 改为 registry.cn-hangzhou.aliyuncs.com/google_containers

#示例
docker pull k8s.gcr.io/pause:3.2

#改为
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
```


#### dockerhub镜像仓库

可以拉取k8s.gcr.io镜像
```
# 只需将 k8s.gcr.io 改为 googlecontainersmirrors

#示例
docker pull k8s.gcr.io/kube-apiserver:v1.17.3

#改为
docker pull googlecontainersmirrors/kube-apiserver:v1.17.3
```

#### 七牛云镜像仓库
     
可以拉取quay.io镜像
```
# 只需将 quay.io 改为 quay-mirror.qiniu.com

#示例
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0

#改为
docker pull quay-mirror.qiniu.com/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0
```

### 镜像拉取和重命名tag
```
# pull 需要的k8s镜像
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0

# tag 重命名
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5 k8s.gcr.io/kube-apiserver:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5 k8s.gcr.io/kube-controller-manager:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5 k8s.gcr.io/kube-scheduler:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5 k8s.gcr.io/kube-proxy:v1.20.5
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0 k8s.gcr.io/etcd:3.4.13-0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0 k8s.gcr.io/coredns:1.7.0

# 移除多余的tag
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.20.5
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.13-0
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.7.0
```
