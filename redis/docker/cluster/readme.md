# Redis 集群安装脚本 cluster.sh 说明

- 1.获取redis(5)

	docker pull redis:5

- 2.创建redis网络

      docker network create redis-net

- 3.创建6个节点目录的包括配置文件(redis.conf)和数据存放目录(data)

      mkdir -pv /data/redis-cluster/${port}/{conf,data}
      cp redis.conf /data/redis-cluster/${port}/conf
    
- 6.创建6个redis容器
	使用cluster.sh创建6个容器，注意修改其中挂载文件及目录

- 7.将6个启动的redis容器构建成一个集群

- 8.完成