#!/bin/bash
#
#this script use for init mongo shard cluster

SCRIPT_FILE=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_FILE)

echo "创建复制集中每个节点存放数据目录："
mkdir -p $SCRIPT_DIR/db_rs01/db01/data

echo "创建复制集中每个节点的日志目录："
mkdir -p $SCRIPT_DIR/db_rs01/db01/logs

echo "创建复制集中每个节点启动时所需的配置文件："
cat <<EOF > $SCRIPT_DIR/db_rs01/db01/mongo.conf
dbpath = $SCRIPT_DIR/db_rs01/db01/data
logpath = $SCRIPT_DIR/db_rs01/db01/logs/mongo.log
logappend = true
journal = true
port = 10001
fork = true
maxConns = 5000
bind_ip = 0.0.0.0
replSet = rs01
shardsvr = true
auth = false
EOF

echo "启动节点对应的mongodb实例" 
/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db01/mongo.conf


echo "创建复制集中每个节点存放数据目录："
mkdir -p $SCRIPT_DIR/db_rs01/db02/data

echo "创建复制集中每个节点的日志目录："
mkdir -p $SCRIPT_DIR/db_rs01/db02/logs

echo "创建复制集中每个节点启动时所需的配置文件："
cat <<EOF > $SCRIPT_DIR/db_rs01/db02/mongo.conf
dbpath = $SCRIPT_DIR/db_rs01/db02/data
logpath = $SCRIPT_DIR/db_rs01/db02/logs/mongo.log
logappend = true
journal = true
port = 10002
fork = true
maxConns = 5000
bind_ip = 0.0.0.0
replSet = rs01
shardsvr = true
auth = false
EOF

echo "启动节点对应的mongodb实例" 
/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db02/mongo.conf



echo "创建复制集中每个节点存放数据目录："
mkdir -p $SCRIPT_DIR/db_rs01/db03/data

echo "创建复制集中每个节点的日志目录："
mkdir -p $SCRIPT_DIR/db_rs01/db03/logs

echo "创建复制集中每个节点启动时所需的配置文件："
cat <<EOF > $SCRIPT_DIR/db_rs01/db03/mongo.conf
dbpath = $SCRIPT_DIR/db_rs01/db03/data
logpath = $SCRIPT_DIR/db_rs01/db03/logs/mongo.log
logappend = true
journal = true
port = 10003
fork = true
maxConns = 5000
bind_ip = 0.0.0.0
replSet = rs01
shardsvr = true
auth = false
EOF

echo "启动节点对应的mongodb实例" 
/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db03/mongo.conf


echo "6、db01下进入mongodb客户端："
/opt/mongodb/bin/mongo --port 10001 <<EOF
echo "7、初始化复制集primary节点、添加second节点和arbiter节点："
echo "1）初始化primary节点："
rs.initiate({_id:'rs01',members:[{_id:1,host:'192.168.1.9:10001'}]}) 
rs.conf()
echo "2）添加second节点和arbiter节点："
rs.add("192.168.1.9:10002")
#或者
#rs.initiate({_id:'rs01',members:[{_id:1,host:'192.168.1.9:10001'},{_id:2,host:'192.168.1.9:10002'}]}) 
rs.addArb("192.168.1.9:10003")
rs.status()
EOF

