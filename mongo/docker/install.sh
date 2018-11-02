#!/bin/bash
# install mongo cluster by docker

# 打印命令，再执行命令
function echo_exec () {
  echo "\$ $@"
  eval $@
  ok=$?
  echo
  return $ok
}

function master_shell() {
  file=$1
  type=$2
  repl_name=$3
  svc_name=$4
  port=$5
  
  echo "# $repl_name" >> $file
  #echo "docker exec -it \$(docker ps | grep $svc_name | awk '{ print \$1 }') mongo --port $port  <<EOF" >> $file
  if [ "shard" = "$type" ] || [ "config" = "$type" ]; then
    echo "docker exec -it \$(docker ps | grep $svc_name | awk '{ print \$1 }') mongo --port $port" >> $file
    echo "rs.initiate({_id:'$repl_name',members:[{_id:1,host:'$svc_name:$port'}<members>]})" >> $file
    echo "//rs.conf() //查看配置" >> $file
    echo "//rs.status() //查看副本级状态" >> $file
  elif [ "mongos" = "$type" ]; then
#    if [ "true" = $AUTH ]; then
#      echo "docker exec -it \$(docker ps | grep $svc_name | awk '{ print \$1 }') mongo --port $port -u $MONGOS_ROOT_USERNAME -p $MONGOS_ROOT_PASSWORD">> $file
#	else
      echo "docker exec -it \$(docker ps | grep $svc_name | awk '{ print \$1 }') mongo --port $port" >> $file
#	fi
    echo "# addShard 脚本自动填充" >> $file
    echo "# sharding 脚本自动填充来自sharding.sh中的脚本" >> $file
  fi
  echo "quit()" >> $file
  #echo "EOF" >> $file
  echo "#===================== 以上以等号划分区域脚本为一个脚本批次，请手动拷贝到linux命令行下执行 ========================" >> $file
  echo >> $file
}

function slave_shell() {
  file=$1
  type=$2
  repl_name=$3
  svc_name=$4
  port=$5
  # slave 验证数据 
  echo "docker exec -it \$(docker ps | grep $svc_name | awk '{ print \$1 }') mongo --port $port" >> $file
  echo "rs.slaveOk() //副本集默认仅primary可读写" >> $file
  echo "use test" >> $file
  echo "db.test.find()" >> $file
  echo "quit()" >> $file
}


SHELL_PATH=$(dirname $(readlink -f $0))
cd $SHELL_PATH

step=1
echo -e "\n----------------------step $step 根据配置文件 mongo.properties 生成运行于 docker 上的 stack.yaml 以及对应目录结构和 mongo 配置文件 mongo.conf"

source "mongo.properties"
items_len=${#ITEMS[*]}
#echo "items_len: "$items_len", value: ${ITEMS[*]}"
MONGO_IMAGE=${MONGO_IMAGE:-mongo} # 默认使用最新版本的mongo
DATA_ROOT=${DATA_ROOT:-"/data"}/mongo # 默认使用最新版本的mongo
echo_exec mkdir -p $DATA_ROOT

depends_on=depends_on
rm -rf $depends_on

cluster_sh=$DATA_ROOT/cluster.sh
rm -rf $cluster_sh
echo "#!/bin/bash" > $cluster_sh
echo > $cluster_sh

addShard=addShard
rm -rf $addShard

stack_yaml=$DATA_ROOT/stack.yaml
cp stack.init.yaml $stack_yaml

configdb=
idx=0
while [ $idx -lt $items_len ]
do
  item=(${ITEMS[idx]})
  echo "item: "${item[*]}
  type=${item[0]}
  repl_name=${item[1]}
  num=${item[2]}
  port=${item[3]}
  conf_path=$DATA_ROOT/$repl_name
  i=1
  members=
  shard=
  # 基于模板文件最终生成 docker 需要的 stack.yaml
  while [ $i -le $num ]
  do
	if [ 1 -eq $num ]; then
	  svc_name=$repl_name
	  rs_path=$conf_path
	else
      svc_name=${repl_name}rs$i
	  rs_path=$conf_path/rs$i
	fi
    mkdir -p $rs_path/{db,configdb}
    rs_yaml=$conf_path/$svc_name.yaml
    if [ "shard" = "$type" ]; then
      cp replset.yaml $rs_yaml
	  if [ -z $shard ]; then
	    shard="$repl_name/$svc_name:$port"
	  else
	    shard="$shard,$svc_name:$port"
	  fi
    elif [ "config" = "$type" ]; then
      cp replset.yaml $rs_yaml
	  echo "      - $svc_name" >> $depends_on
	  if [ -z $configdb ]; then
	    configdb="$repl_name/$svc_name:$port"
	  else
	    configdb="$configdb,$svc_name:$port"
	  fi
	elif [ "mongos" = "$type" ]; then
	  rs_yaml=$stack_yaml
	  sed -i "s@<PORT>@$port@g" $rs_yaml
	  sed -i "s@<SVC_NAME>@$svc_name@g" $rs_yaml
	  sed -i "s@<MONGOS_ROOT_USERNAME>@$MONGOS_ROOT_USERNAME@g" $rs_yaml
	  sed -i "s@<MONGOS_ROOT_PASSWORD>@$MONGOS_ROOT_PASSWORD@g" $rs_yaml
	  sed -i "s@<WEB_USERNAME>@$WEB_USERNAME@g" $rs_yaml
	  sed -i "s@<WEB_PASSWORD>@$WEB_PASSWORD@g" $rs_yaml
    fi
    sed -i "s@<SVC_NAME>@$svc_name@g" $rs_yaml
    sed -i "s@<RS_PATH>@$rs_path@g" $rs_yaml
    sed -i "s@<CONF_PATH>@$conf_path@g" $rs_yaml
	if [ "mongos" != "$type" ]; then
      #cat $rs_yaml
	  cat $rs_yaml >> tmp.yaml
	  rm $rs_yaml
	fi
	
	# 生成集群初始化等操作的脚本
	vars=(${item[@]})
	vars[2]=$svc_name
	if [ 1 -eq $i ]; then
	  master_shell $cluster_sh ${vars[@]}
	else
	  #slave_shell $cluster_sh ${vars[@]}
	  members=$members",{_id:$i,host:'$svc_name:$port'}"
	fi
	let i++
  done
  sed -i "s@<members>@$members@g" $cluster_sh
  # 分片信息不为空
  if [ ! -z $shard ]; then # 此时不能使用 -n 作为条件判断
    echo "sh.addShard(\"$shard\")" >> $addShard
  fi
  
  # 基于模板文件生成 mongo 启动配置文件 mongod.conf
  if [ ! -e mongod.conf ]; then
    config=$conf_path/mongod.conf
    cp mongod.conf.yaml $config
    sed -i "s@<DB_PATH>@/data/db@g" $config
    sed -i "s@<PORT>@$port@g" $config
    if [ "shard" = "$type" ]; then
      sed -i "s@<REPL_NAME>@$repl_name@g" $config
      sed -i "s@<CLUSTER_ROLE>@shardsvr@g" $config
      sed -i "s@  configDB:@#  configDB:@g" $config
#	  sed -i "s@security:@#security:@g" $config
#	  sed -i "s@  transitionToAuth:@#  transitionToAuth:@g" $config
    elif [ "config" = "$type" ]; then
      sed -i "s@<REPL_NAME>@$repl_name@g" $config
      sed -i "s@<CLUSTER_ROLE>@configsvr@g" $config
      sed -i "s@  configDB:@#  configDB:@g" $config
#	  sed -i "s@security:@#security:@g" $config
#	  sed -i "s@  transitionToAuth:@#  transitionToAuth:@g" $config
    elif [ "mongos" = "$type" ]; then
	  sed -i "s@storage:@#storage:@g" $config
	  sed -i "s@  dbPath:@#  dbPath:@g" $config
	  sed -i "s@  journal:@#  journal:@g" $config
	  sed -i "s@    enabled:@#    enabled:@g" $config
	  sed -i "s@replication:@#replication:@g" $config
	  sed -i "s@  replSetName:@#  replSetName:@g" $config
      sed -i "s@<REPL_NAME>@@g" $config
      sed -i "s@  clusterRole:@#  clusterRole:@g" $config
      sed -i "s@<CONFIG_DB>@$configdb@g" $config
#	  sed -i "s@<AUTH>@$AUTH@g" $config
    fi
  fi
  let idx++
done
sed -i "/# addShard/r $addShard" $cluster_sh
rm -rf $addShard
sed -i "/# sharding/r sharding.sh" $cluster_sh

#echo_exec cat $stack_yaml
sed -i "/# replication/r tmp.yaml" $stack_yaml
sed -i "/depends_on:/r $depends_on" $stack_yaml
sed -i "s@<MONGO_IMAGE>@$MONGO_IMAGE@g" $stack_yaml
rm tmp.yaml $depends_on
#echo_exec cat $stack_yaml

let step=step+1
echo -e "\n----------------------step $step 根据 stack.yaml 在Manager上启动 docker 中的 mongo"
echo_exec docker stack rm mongo
if [ 0 -ne $? ]; then # 上一句执行报错，表示 swarm 还未初始化
  if [ ! -z $MANAGE_IP ]; then
    echo_exec docker swarm init --advertise-addr $MANAGE_IP
  else
    echo_exec docker swarm init
  fi
  if [ 0 -ne $? ]; then
    echo -e "\n----------------------"
    echo "docker swarm init 失败，当前主机有多个IP 请根据提示IP数据，修改mongo.propertis中的MANAGE_IP值为特定IP，并再次执行该脚本"
    echo "----------------------"
    exit 1
  fi
else
  sleep 5
fi
echo_exec docker stack deploy -c $stack_yaml mongo
if [ 0 -ne $? ]; then
  echo "docker stack deploy 失败，stack.yaml文件部署失败，请再次执行该脚本"
  exit 1
fi
sleep 5
echo_exec docker stack services mongo

let step=step+1
#echo -e "\n----------------------step $step 初始化集群"
#echo "初始化配置副本集群"
#echo_exec source $cluster_sh
echo -e "\n----------------------"
echo "请分批次手动拷贝执行脚本文件$cluster_sh中的脚本"
echo "----------------------"
