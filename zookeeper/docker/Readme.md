# 基于 docker 的 zk 3节点集群部署

* 1、创建 zk 3节点数据存放目录

      mkdir -p /data/zookeeper/{data1,data2,data3}

* 2、初始化泳道（docker 集群）
      
      docker swarm join 

* 3、启动 zk 集群

      docker stack deploy -c zookeeper.yaml zookeeper

* 4、查看集群各节点状态

      for i in 0 1 2; do docker exec $(docker ps | grep zoo$i | awk '{ print $1 }') zkServer.sh status; done

* 5、删除(关闭)集群

      docker stack rm zookeeper

* 6、启动已有数据的集群

      docker stack deploy -c zookeeper.yaml zookeeper