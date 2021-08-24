# chaosblade

- GitHub
  - [chaosblade](https://github.com/chaosblade-io/chaosblade)
  - [chaosblade-operator](https://github.com/chaosblade-io/chaosblade-operator)
  - [chaosblade-box](https://github.com/chaosblade-io/chaosblade-box)
  - [awesome-chaosblade](https://github.com/chaosblade-io/awesome-chaosblade) chaosblade 官方混沌工程相关文档
- [新手指南](https://github.com/chaosblade-io/chaosblade/wiki/%E6%96%B0%E6%89%8B%E6%8C%87%E5%8D%97)
- **[官方中文文档](https://chaosblade-io.gitbook.io/chaosblade-help-zh-cn/)**
- [Chaosblade-Box 用户手册](https://www.yuque.com/docs/share/bc9ad412-6f96-463b-b72d-6773b5fb5ea3)
- [chaosblade-box-web 数据库初始化脚本](https://github.com/chaosblade-io/chaosblade-box/blob/main/chaosblade-box-web/src/main/resources/sql/chaos-box-ddl.sql)

## 本地安装 chaosblade
从 chaosblade 的 [Release](https://github.com/chaosblade-io/chaosblade/releases) 页面下载最新 chaosblade 工具包，解压即用
```
# 下载安装包
$ wget https://chaosblade.oss-cn-hangzhou.aliyuncs.com/agent/github/1.3.0/chaosblade-1.3.0-linux-amd64.tar.gz
# 解压
$ tar zxfv chaosblade-1.3.0-linux-amd64.tar.gz
# 移动或创建软连接
$ ln -sf /opt/installer/chaos/chaosblade-1.3.0/blade /opt/bin/blade
# 去到任意目录执行命令，验证 blade 命令正常
$ blade version
# 打印类似如下内容
version: 1.3.0
env: #1 SMP Tue Mar 23 09:27:39 UTC 2021 x86_64
build-time: Wed Aug  4 12:52:28 UTC 2021
```

## k8s helm 安装 
### 安装 chaosblade-operator
从 chaosblade-operator 的 [Release](https://github.com/chaosblade-io/chaosblade-operator/releases) 页面下载最新 chaosblade-operator 包
```
helm --namespace chaosblade install chaosblade-operator chaosblade-operator-1.3.0-v3.tgz
```

### 安装 chaosblade-box
#### 自定义 helm 方式安装
```
helm --namespace chaosblade install chaosblade-box ./chaosblade-box
```
即可外部访问 chaosblade 的 web 演练页面: *http://chaosblade.k8s.com:30080*，
**注意**: 路径必须是/，这是chaosblade-box服务路径和前端文件限制的，否则会报错

#### 官方 helm 方式安装
从 chaosblade-box 的 [Release](https://github.com/chaosblade-io/chaosblade-box/releases) 页面下载最新 chaosblade-box 包
```
helm install chaosblade-box chaosblade-box-0.4.1.tgz --set spring.datasource.password=root123 --namespace chaosblade
```
配置对应的 ingress *chaosblade-box-ingress.yaml*
```
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: chaosblade-ingress
  namespace: chaosblade
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
$ kubectl apply -f chaosblade-box-ingress.yaml --record
```
即可外部访问 chaosblade 的 web 演练页面: *http://chaosblade.k8s.com:30080*，
**注意**: 路径必须是/，这是chaosblade-box服务路径和前端文件限制的，否则会报错
