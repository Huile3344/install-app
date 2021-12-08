# mysql 主从集群搭建

## 安装
### 修改配置信息
- 修改 configmap.yaml 可对应修改数据库配置文件
- 修改 master.yaml 
  - 修改 mysql 主库数据存储依赖的 pv 指定的 nfs 路径
- 修改 secret.yaml 可修改数据库 root 账号密码，默认密码: `123456`
- 修改 service.yaml 可修改暴露的 service 端口
  - 主库 pod 服务 `mysql-single-svc` 暴露: 读写端口名 `mysql` 端口号 `3306`

### 执行 kubectl apply 应用
```
$ kubectl apply -Rf ./single --record
```

### mysql 的 master 服务正常启动后
#### 修改 root 账号的访问限制，创建 exporter 账号
执行一下命令进入容器内部，修改 root 账号的访问限制
```shell
$ kubectl -n dev exec mysql-single-sts-0 -it -- /bin/bash
# 进入容器后执行以下命令，直接按 Enter 即可进入mysql
$ mysql -uroot -p
# 执行以下命令解除 root 账号远程登录限制
mysql> GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '123456';
# 刷新权限
mysql> FLUSH PRIVILEGES;
```
