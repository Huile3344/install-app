# RabbitMQ 集群安装脚本 cluster.sh 说明

- 1.获取rabbitmq(rabbitmq:3.6-management是默认启用rabbitmq-management的rabbitmq)

	docker pull rabbitmq:3.6-management

- 2.创建rabbitmq网络

      docker network create rabbitmq-net

- 3.创建3个节点目录的包括配置文件(rabbitmq.conf)和数据存放目录(data)

      mkdir -pv /data/rabbitmq-cluster/${port}/{conf,data}
      cp rabbitmq.conf /data/rabbitmq-cluster/${port}/conf
    
- 6.创建3个rabbitmq容器
	使用cluster.sh创建3个容器，注意修改其中挂载文件及目录

**注意**

  RABBITMQ_ERLANG_COOKIE 变量用于指定集群鉴权cookie，集群节点需一致，否则提示如下错误信息
  
    rabbitmq0@rabbitmq0:
        * connected to epmd (port 4369) on rabbitmq0
        * epmd reports node 'rabbitmq0' running on port 25672
        * TCP connection succeeded but Erlang distribution failed
    
        * Authentication failed (rejected by the remote node), please check the Erlang cookie

- 7.将3个启动的rabbitmq容器构建成一个集群

- 8.完成