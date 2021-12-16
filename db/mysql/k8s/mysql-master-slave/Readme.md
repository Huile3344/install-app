# mysql 主从集群搭建

## 安装
### 修改配置信息
- 修改 configmap.yaml 可对应修改数据库配置文件
- 修改 master.yaml 
  - 修改 mysql 主库数据存储依赖的 pv 指定的 nfs 路径
  - 修改 mysql 主库的 mysqld-exporter 可调整监控
- 修改 slave.yaml 
  - 修改 mysql 从库数据存储依赖的 pv 指定的 nfs 路径
  - 修改 mysql 从库的 mysqld-exporter 可调整监控
- 修改 secret.yaml 可修改数据库 root 账号密码，默认密码: `123456`
- 修改 service.yaml 可修改暴露的 service 端口
  - 主库 pod 服务 `write-mysql-svc` 暴露: 读写端口名 `mysql` 端口号 `3306`，监控端口名 `exporter` 端口号 `9104`
  - 从库 pod 服务 `read-mysql-svc` 暴露: 只读端口名 `mysql` 端口号 `3306`，监控端口名 `exporter` 端口号 `9104`
- 修改 mysqld_exporter/configmap.yaml 可修改监控使用的数据库账号，默认账号: `exporter`，默认密码: `123456`
- 修改 mysqld_exporter/servicemonitor.yaml 可修改 prometheus 监控规则(需要已经安装了 kube-prometheus-stack)

### 执行 kubectl apply 应用
```
$ kubectl apply -Rf ./mysql-master-slave --record
```

### mysql 的 master 服务正常启动后
#### 修改 root 账号的访问限制，创建 exporter 账号
执行一下命令进入容器内部，修改 root 账号的访问限制
```aidl
$ kubectl -n dev exec mysql-master-0 -it -- /bin/bash
# 进入容器后执行以下命令，直接按 Enter 即可进入mysql
$ mysql -uroot -p
# 执行以下命令解除 root 账号远程登录限制
mysql> GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '123456';
# 创建 exporter 账号，并允许远程登录
mysql> CREATE USER 'exporter'@'%' IDENTIFIED BY '123456' WITH MAX_USER_CONNECTIONS 2;
# 授权用户
mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%'  with grant option;
# 刷新权限
mysql> FLUSH PRIVILEGES;
```

## 监控
### 在 grafana 导入应用监控的 dashboard 
Dashboard from Percona Monitoring and Management project.  https://github.com/percona/grafana-dashboards

需要从Grafana的存储库中填写仪表板的URL。https://grafana.com/grafana/dashboards/7362 即：mysql-overview_rev5.json

#### 操作步骤
- 选择+ -> Import -> 粘贴 `7362`
- 选择创建的 Prometheus 数据源, 即可导入,
- 查看数据库监控图形页面