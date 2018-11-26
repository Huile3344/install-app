# mysql 基于docker的集群搭建

- 1.下载镜像

      docker pull mysql:5.7
      
- 2.创建配置文件及数据目录

      mkdir /usr/local/mysql/master/m1/conf -p
      mkdir /usr/local/mysql/master/m1/conf/data -p
      touch master.cnf；
      
- 3.用以上配置文件及目录启动master

      docker run -p 3301:3306 --name mysql-m1 -v /usr/local/mysql/master/m1/conf:/etc/mysql/conf.d -v /usr/local/mysql57/master/m1/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=654321 -d mysql:5.7；

- 4.进入容器
    
      docker exec -it mysql-m1 mysql -p
      
- 5.查看master状态
    
      show master status \G;
      
- 6.创建复制用户：

      CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';和GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

- 7.同上启动slaves节点

      docker run --name mysql-slave \
      -v /home/mysql/etc/slave:/etc/mysql/conf.d \
      -v /home/mysql/data/slave:/var/lib/mysql \
      -e MYSQL_ROOT_PASSWORD=root \
      --link mysql-master:master \
      -d mysql:5.7

- 8.进入从节点容器，配置主从：

      stop slave;
      
      CHANGE MASTER TO \
      MASTER_HOST='master',\
      MASTER_PORT=3306,\
      MASTER_USER='repl',\
      MASTER_PASSWORD='repl',\
      MASTER_LOG_FILE='binlog.000008',\
      MASTER_LOG_POS=595;

      start slave;
      
- 9.完成总从配置

- 10.重复以上完成4主4从；
