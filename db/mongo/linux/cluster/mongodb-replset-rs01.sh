#!/bin/bash
#
#this script use for init mongo shard cluster


# 
# 基于当前脚本文件的路径，创建mongo运行相关主目录db_rs0$SEQ/db0$SEQ,
# 并创建data数据子目录，logs日志子目录，以及启动配置文件mongo.conf
# 
function makeMongoInfo(){
#!/bin/bash
PATH=$1
NODE_HOST=$2
NODE_PORT=$3
SEQ=$4
	
echo "创建节点数据目录和日志目录：$SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/{data,logs}"
/usr/bin/mkdir -p $PATH/db_rs0$SEQ/db0$SEQ/{data,logs}

/usr/bin/cat <<EOF > $PATH/db_rs0$SEQ/db0$SEQ/mongo.conf
dbpath = $PATH/db_rs0$SEQ/db0$SEQ/data
logpath = $PATH/db_rs0$SEQ/db0$SEQ/logs/mongo.log
pidfilepath = $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid
logappend = true
journal = true
port = $NODE_PORT
fork = true
maxConns = 5000
bind_ip = $NODE_HOST
replSet = rs0$SEQ
auth = false
EOF

echo "创建节点启动时所需的配置文件："
/usr/bin/cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.conf
}

# 
# 生成或拼接启动当前mongo节点的启动脚本
# 如：$MONGO_PATH/bin/mongod -f $PATH/db_rs0$SEQ/db0$SEQ/mongo.conf
# 
function makeStartSh() {
#!/bin/bash
MONGO_PATH=$1
PATH=$2
SEQ=$3
if [ ! -e $PATH/start.sh ]; then
/usr/bin/cat <<EOF > $PATH/start.sh
#!/bin/bash
$MONGO_PATH/bin/mongod -f $PATH/db_rs0$SEQ/db0$SEQ/mongo.conf
echo "启动节点对应的mongodb实例脚本：$MONGO_PATH/bin/mongod -f $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.conf"
EOF
/usr/bin/chmod a+x $PATH/start.sh
else
/usr/bin/cat <<EOF >> $PATH/start.sh
echo "启动节点对应的mongodb实例脚本：$MONGO_PATH/bin/mongod -f $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.conf" 
$MONGO_PATH/bin/mongod -f $PATH/db_rs0$SEQ/db0$SEQ/mongo.conf
EOF
fi
}

# 
# 生成连接单mongo节点的连接脚本
# 如：$MONGO_PATHb/bin/mongo --host $NODE_HOST --port $NODE_PORT
#
function makeConnectSh() {
#!/bin/bash
MONGO_PATH=$1
PATH=$2
NODE_HOST=$3
NODE_PORT=$4
/usr/bin/cat <<EOF > $PATH/connect.sh
#!/bin/bash
$MONGO_PATHb/bin/mongo --host $NODE_HOST --port $NODE_PORT
EOF
/usr/bin/chmod a+x $PATH/connect.sh
}

# 
# 生成或拼接终止当前mongo节点的启动脚本
# 如：kill 15 \`cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid\`
# 
function makeStopSh() {
#!/bin/bash
PATH=$1
SEQ=$2
if [ ! -e $PATH/stop.sh ]; then
/usr/bin/cat <<EOF > $PATH/stop.sh
#!/bin/bash
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.pid\`"
kill 15 \`cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid\`
EOF
/usr/bin/chmod a+x $PATH/stop.sh
else
<<EOF >> $PATH/stop.sh
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.pid\`"
kill 15 \`cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid\`
EOF
fi
}

# 
# 生成或拼接启动当前mongo节点的终止、清空数据目录且清除脚本
# 
function makeResetSh() {
#!/bin/bash
PATH=$1
SEQ=$2
if [ ! -e $PATH/reset.sh ]; then
/usr/bin/cat <<EOF > $PATH/reset.sh
#!/bin/bash
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.pid\`"
kill 15 \`cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid\`
rm -rf $PATH/db_rs0$SEQ/db0$SEQ $PATH/start.sh $PATH/stop.sh $PATH/connect.sh $PATH/reset.sh
EOF
/usr/bin/chmod a+x $PATH/reset.sh
else
<<EOF >> $PATH/reset.sh
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/db_rs0$SEQ/db0$SEQ/mongo.pid\`"
kill 15 \`cat $PATH/db_rs0$SEQ/db0$SEQ/mongo.pid\`
rm -rf $PATH/db_rs0$SEQ/db0$SEQ $PATH/start.sh $PATH/stop.sh $PATH/connect.sh $PATH/reset.sh
EOF
fi
}


#=======================================================================

SCRIPT_FILE=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_FILE)
i=1

read -p "Please input mongo's Host IP, default value [0.0.0.0]: " HOST
if [ -z $HOST ]; then
    HOST=0.0.0.0
fi
#HOST=192.168.1.9

read -p "Please input mongo's Host PORT, default value [10000]: " PORT
if [ -z $PORT ]; then
    PORT=10000
fi
#PORT=10000

read -p "Please input mongo's PATH, default value [\$MONGO_HOME]: " MONGO_PATH
if [ -z $HOST ]; then
    MONGO_PATH=$MONGO_HOME
fi
#MONGO_PATH=/opt/mongodb


echo "step 1:............................................." 
# 创建运行需要的环境
makeMongoInfo $SCRIPT_DIR $HOST $PORT $i


echo "step 2:...........generate start.sh.................................." 
# 生成或拼接启动脚本
makeStartSh $MONGO_PATH $SCRIPT_DIR $i
echo "step 3:...........start all mongo nodes.................................." 
$SCRIPT_DIR/start.sh


# 生成连接单mongo节点的连接脚本
makeConnectSh $MONGO_PATH $SCRIPT_DIR $HOST $PORT $i


echo "step 4:...........generate stop.sh.................................." 
# 生成或拼接终止当前mongo节点的启动脚本
makeStopSh $SCRIPT_DIR $i


echo "step 5:...........generate reset.sh.................................." 
makeResetSh $SCRIPT_DIR $i


echo "step 6:...........connect mongo.................................." 
echo "进入mongodb客户端：$MONGO_PATH/bin/mongo --host $HOST --port $PORT"
$MONGO_PATH/bin/mongo --host $HOST --port $PORT <<EOF
use myTest
db.users.insert({userid:1, name:"Hui", age:20})
db.users.insert({userid:2, name:"Huile", age:25})
db.users.find()
EOF





echo "创建复制集中每个节点启动时所需的配置文件："
cat <<EOF > $SCRIPT_DIR/db_rs01/db01/mongo.conf
dbpath = $SCRIPT_DIR/db_rs0$i/db0$i/data
logpath = $SCRIPT_DIR/db_rs0$i/db0$i/logs/mongo.log
logappend = true
journal = true
port = 10001
fork = true
maxConns = 5000
bind_ip = 0.0.0.0
replSet = rs01
auth = false
EOF

echo "启动节点对应的mongodb实例" 
/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db01/mongo.conf


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
replSet = rs0$i
auth = false
EOF

echo "启动节点对应的mongodb实例" 
/opt/mongodb/bin/mongod -f $SCRIPT_DIR/db_rs01/db02/mongo.conf


echo "6、db01下进入mongodb客户端："
/opt/mongodb/bin/mongo --port 10001

echo "7、初始化复制集primary节点、添加second节点和arbiter节点："
echo "1）初始化primary节点："
rs.initiate({_id:'rs01',members:[{_id:1,host:'192.168.1.9:10001'}]}) 
rs.conf()

echo "2）添加second节点和arbiter节点："
rs.add("192.168.1.9:10002")
rs.addArb("192.168.1.9:10003")
rs.status()

