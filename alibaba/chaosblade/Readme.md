# chaosblade

- GitHub
  - [chaosblade](https://github.com/chaosblade-io/chaosblade)
  - [chaosblade-operator](https://github.com/chaosblade-io/chaosblade-operator)
  - [chaosblade-box](https://github.com/chaosblade-io/chaosblade-box)
  - [awesome-chaosblade](https://github.com/chaosblade-io/awesome-chaosblade) chaosblade 官方混沌工程相关文档
- [新手指南](https://github.com/chaosblade-io/chaosblade/wiki/%E6%96%B0%E6%89%8B%E6%8C%87%E5%8D%97)
- **[官方中文文档](https://chaosblade-io.gitbook.io/chaosblade-help-zh-cn/)**
- [Chaosblade-Box 用户手册](https://www.yuque.com/docs/share/bc9ad412-6f96-463b-b72d-6773b5fb5ea3)
- 

## 本地安装 chaosblade
从 chaosblade 的 [Release](https://github.com/chaosblade-io/chaosblade/releases) 页面下载最新 chaosblade 工具包，解压即用
```
wget https://chaosblade.oss-cn-hangzhou.aliyuncs.com/agent/github/1.2.0/chaosblade-1.2.0-linux-amd64.tar.gz
tar zxfv chaosblade-1.2.0-linux-amd64.tar.gz
```

## k8s helm 安装 
### 安装 chaosblade-operator
从 chaosblade-operator 的 [Release](https://github.com/chaosblade-io/chaosblade-operator/releases) 页面下载最新 chaosblade-operator 包
```
helm install chaosblade-operator chaosblade-operator-1.2.0-v3.tgz --namespace chaosblade
```

### 安装 chaosblade-box
从 chaosblade-box 的 [Release](https://github.com/chaosblade-io/chaosblade-box/releases) 页面下载最新 chaosblade-box 包
```
helm install chaosblade-box chaosblade-box-0.4.1.tgz --set spring.datasource.password=root123 --namespace chaosblade
```
配置对应的 ingress *chaosblade-box-ingress.yaml*
```
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: chaosblade-rewrite
  namespace: chaosblade
  annotations:
#    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: chaosblade.k8s.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: chaosblade-box
              port:
                number: 8080
```
并在k8s集群应用 ingress 
```
kubectl apply -f chaosblade-box-ingress.yaml --record
```
即可外部访问 chaosblade 的 web 演练页面: *http://chaosblade.k8s.com:30080*，
**注意**: 路径必须是/，这是chaosblade-box前端路径问题限制的，否则会报错
