#!/bin/bash
#
#this script use for init mongo shard cluster

HOST=192.168.1.9
PORT=10000
MONGO_PATH=/opt/mongodb

SCRIPT_FILE=$(readlink -f $0)
SCRIPT_DIR=$(dirname $SCRIPT_FILE)

# 
# 基于当前脚本文件的路径，创建mongo运行相关主目录mongodata,
# 并创建data数据子目录，logs日志子目录，以及启动配置文件mongo.conf
# 
function makeMongoInfo(){
#!/bin/bash
PATH=$1
NODE_HOST=$2
NODE_PORT=$3
	
echo "创建节点数据目录和日志目录：$SCRIPT_DIR/mongodata/{data,logs}"
/usr/bin/mkdir -p $PATH/mongodata/{data,logs}

echo "创建节点启动时所需的配置文件："
/usr/bin/cat <<EOF > $PATH/mongodata/mongo.conf
dbpath = $PATH/mongodata/data
logpath = $PATH/mongodata/logs/mongo.log
pidfilepath = $PATH/mongodata/mongo.pid
logappend = true
journal = true
port = $NODE_PORT
fork = true
maxConns = 5000
bind_ip = $NODE_HOST
EOF

#echo "创建节点启动时所需的配置文件："
#/usr/bin/cat $PATH/mongodata/mongo.conf
}

# 
# 生成或拼接启动当前mongo节点的启动脚本
# 如：$MONGO_PATH/bin/mongod -f $PATH/mongodata/mongo.conf
# 
function makeStartSh() {
#!/bin/bash
MONGO_PATH=$1
PATH=$2
if [ ! -e $PATH/start.sh ]; then
/usr/bin/cat <<EOF > $PATH/start.sh
#!/bin/bash
$MONGO_PATH/bin/mongod -f $PATH/mongodata/mongo.conf
echo "启动节点对应的mongodb实例脚本：$MONGO_PATH/bin/mongod -f $SCRIPT_DIR/mongodata/mongo.conf"
EOF
/usr/bin/chmod a+x $PATH/start.sh
else
/usr/bin/cat <<EOF >> $PATH/start.sh
echo "启动节点对应的mongodb实例脚本：$MONGO_PATH/bin/mongod -f $SCRIPT_DIR/mongodata/mongo.conf" 
$MONGO_PATH/bin/mongod -f $PATH/mongodata/mongo.conf
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
# 如：kill 15 \`cat $PATH/mongodata/mongo.pid\`
# 
function makeStopSh() {
#!/bin/bash
PATH=$1
if [ ! -e $PATH/stop.sh ]; then
/usr/bin/cat <<EOF > $PATH/stop.sh
#!/bin/bash
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/mongodata/mongo.pid\`"
kill 15 \`cat $PATH/mongodata/mongo.pid\`
EOF
/usr/bin/chmod a+x $PATH/stop.sh
else
<<EOF >> $PATH/stop.sh
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/mongodata/mongo.pid\`"
kill 15 \`cat $PATH/mongodata/mongo.pid\`
EOF
fi
}

# 
# 生成或拼接启动当前mongo节点的终止、清空数据目录且清除脚本
# 
function makeResetSh() {
#!/bin/bash
PATH=$1
if [ ! -e $PATH/reset.sh ]; then
/usr/bin/cat <<EOF > $PATH/reset.sh
#!/bin/bash
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/mongodata/mongo.pid\`"
kill 15 \`cat $PATH/mongodata/mongo.pid\`
rm -rf $PATH/mongodata $PATH/start.sh $PATH/stop.sh $PATH/connect.sh $PATH/reset.sh
EOF
/usr/bin/chmod a+x $PATH/reset.sh
else
<<EOF >> $PATH/reset.sh
echo "终止节点对应的mongodb实例：kill 15 \`cat $SCRIPT_DIR/mongodata/mongo.pid\`"
kill 15 \`cat $PATH/mongodata/mongo.pid\`
rm -rf $PATH/mongodata $PATH/start.sh $PATH/stop.sh $PATH/connect.sh $PATH/reset.sh
EOF
fi
}


echo "step 1:............................................." 
# 创建运行需要的环境
makeMongoInfo $SCRIPT_DIR $HOST $PORT


echo "step 2:............................................." 
# 生成或拼接启动脚本
makeStartSh $MONGO_PATH $SCRIPT_DIR
echo "step 3:............................................." 
echo "start all mongo nodes!"
$SCRIPT_DIR/start.sh


# 生成连接单mongo节点的连接脚本
makeConnectSh $MONGO_PATH $SCRIPT_DIR $HOST $PORT


echo "step 4:............................................." 
# 生成或拼接终止当前mongo节点的启动脚本
makeStopSh $SCRIPT_DIR


echo "step 5:............................................." 
makeResetSh $SCRIPT_DIR


echo "step 6:............................................." 
echo "进入mongodb客户端：$MONGO_PATH/bin/mongo --host $HOST --port $PORT"
$MONGO_PATH/bin/mongo --host $HOST --port $PORT <<EOF
use myTest
db.users.insert({userid:1, name:"Hui", age:20})
db.users.insert({userid:2, name:"Huile", age:25})
db.users.find()
EOF

