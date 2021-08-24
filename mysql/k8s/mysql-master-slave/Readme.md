mysql 的 master 服务正常启动后

执行一下命令进入容器内部，修改 root 账号的访问限制
```aidl
$ kubectl -n dev exec mysql-master-0 -it -- /bin/bash
# 进入容器后执行以下命令，直接按 Enter 即可进入mysql
$ mysql -uroot -p
# 执行以下命令解除 root 账号访问限制
mysql> ALTER USER 'root'@'%' IDENTIFIED BY '123456';
mysql> FLUSH PRIVILEGES;
```

