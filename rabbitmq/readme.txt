1.拉取镜像docker pull rabbitmq:3.6.16-management;
2.创建网络docker network create rabbitmq-net; 
3.启动三个容器：端口分别为 5672/15672--5674/15674
docker run -d \
-p 5672:5672 \					#5673:5672    5674:5672
-p 15672:15672 \				#15673:15672    15674:15672
-e RABBITMQ_NODENAME=rabbitmq1 \	#rabbitmq2  rabbitmq3
-e RABBITMQ_ERLANG_COOKIE='SELLERPROERP' \
-h rabbitmq1 \      #rabbitmq2  rabbitmq3
--name=rabbitmq1 \		#rabbitmq2  rabbitmq3
--net=rabbitmq-net \
rabbitmq:3.6.16-management

4.分别进入第二个及第三个容器执行
root@rabbitmq2:/# rabbitmqctl -n rabbitmq2@rabbitmq2 -q stop_app
root@rabbitmq2:/# rabbitmqctl -n rabbitmq2@rabbitmq2 -q reset   
root@rabbitmq2:/# rabbitmqctl -n rabbitmq2@rabbitmq2 -q join_cluster rabbitmq1@rabbitmq1
root@rabbitmq2:/# rabbitmqctl -n rabbitmq2@rabbitmq2 -q start_app

root@rabbitmq3:/# rabbitmqctl -n rabbitmq3@rabbitmq3 -q stop_app
root@rabbitmq3:/# rabbitmqctl -n rabbitmq3@rabbitmq3 -q reset   
root@rabbitmq3:/# rabbitmqctl -n rabbitmq3@rabbitmq3 -q join_cluster rabbitmq1@rabbitmq1 --ram    #这里第三个节点设置为内存节点
root@rabbitmq3:/# rabbitmqctl -n rabbitmq3@rabbitmq3 -q start_app

5.完成集群，查看状态；
http://server02:15672/      用户名guest，密码guest