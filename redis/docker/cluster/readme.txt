1.安装并启动docker
2.获取redis(4.0.9)，ruby镜像
	
	docker pull redis
	docker pull ruby	

3.创建6个节点的配置文件 port为（7000/17000--7005/17005）
	如 redis.conf；

4.创建6个节点的数据存储目录 data

5.创建redis网络  
	docker network create redis-net

6.创建6个redis容器
	使用cluster.sh创建6个容器，注意修改其中挂载文件及目录

7.使用ruby实现集群
	trib.sh

8.完成