1.解压；
2.创建副本集rs1;
3.创建3套日志目录和数据目录；
4.创建三个配置文件；（注意修改日志目录，数据目录及端口）
5.使用配置文件启动三个实例bin/mongod --config /home/mongodb/db_rs0/config_rs0/rs0.conf
6.进入第一个实例的客户端 bin/mongo --port 27011；
7.初始化primary节点，即本节点：
	rs.initiate({_id:'rs1',members:[{_id:1,host:'ip:27011'}]})；
	rs.conf()；
	rs.add("ip:27012")；  //添加第二个节点；
	rs.addArb("ip:27013")；//添加第三个节点；
	rs.status()；//查看状态
8.退出第一个实例的客户端，完成rs1副本集；

9.重复以上 完成rs2副本集；

10.启动三台配置服务器，使用配置文件；（注意修改端口和目录）
	bin/mongod --config /home/mongodb/cfgserver/cfgserver.conf
11.登录配置服务器bin/mongo --port 27021;
12.初始化配置服务器：
rs.initiate({_id:"cfgset",configsvr:true, members:[{_id:1,host:"ip:27021"},{_id:2,host:"ip:27022"},{_id:3,host:"ip:27023"}]})

13.启动mongos
	bin/mongos --config /home/mongodb/mongos/cfg_mongos.conf;
14.进入mongos，bin/mongo --port 27031
15.添加两个集群分片：27013和27016为仲裁节点无数据不添加
	sh.addShard("rs1/ip:27011,ip:27012")
	sh.addShard("rs2/ip:27014,ip:27015")
16.完成，查看分片状态，sh.status();