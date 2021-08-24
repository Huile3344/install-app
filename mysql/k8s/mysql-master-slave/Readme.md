mysql 的 master 服务正常启动后

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

