#!/bin/bash
#
#this script use for init mongo shard cluster

SCRIPT_FILE=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_FILE)

echo "创建复制集中每个节点的日志目录："
mkdir -p $SCRIPT_DIR/mongos/logs

echo "创建复制集中每个节点启动时所需的配置文件："
cat <<EOF > $SCRIPT_DIR/mongos/mongo.conf
logpath = $SCRIPT_DIR/mongos/logs/mongo.log
logappend = true
port = 60000
fork = true
maxConns = 5000
bind_ip = 192.168.1.9
configdb = cfgset/192.168.1.9:60001,192.168.1.9:60002,192.168.1.9:60003
EOF

echo "启动节点对应的mongodb实例：/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db01/mongo.conf" 
/opt/mongodb/bin/mongos -f $SCRIPT_DIR/mongos/mongo.conf

echo "6、db01下进入mongodb客户端："
/opt/mongodb/bin/mongo --host "192.168.1.9" --port 60000 <<EOF

#添加副本集分片服务器，需先构建好副本集rs01,rs02，仲裁节点没数据
sh.addShard("rs01/192.168.1.9:10001,192.168.1.9:10002")
sh.addShard("rs02/192.168.1.9:20001,192.168.1.9:20002")

#向集群插入文档：
use chavin
db.users.insert({userid:1,username:"ChavinKing",city:"beijing"})

#MongoDB分片是针对集合的，要想使集合支持分片，首先需要使其数据库支持分片，为数据库chavin启动分片：
sh.enableSharding("chavin")

#为分片字段建立索引，同时为集合指定片键：
db.users.createIndex({city:1}) //创建索引
sh.shardCollection("chavin.users",{city:1}) //启用集合分片，为其指定片键

#再次查看分片集群状态：
sh.status()

#向集群插入测试数据
#for(var i=1;i<1000000;i++) db.users.insert({userid:i,username:"chavin"+i,city:"beijing"})
#for(var i=1;i<1000000;i++) db.users.insert({userid:i,username:"dbking"+i,city:"changsha"})

#再次查看分片集群状态：(确认分片成功）
sh.status()

EOF
