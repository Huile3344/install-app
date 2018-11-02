#!/bin/bash
# etcd 单机安装脚本，系统启动时自动运行etcd

# 获取当前包含脚本文件的etcd主目录
SCRIPT_FILE=$(readlink -f $0)
ETCD_ROOT=$(dirname $SCRIPT_FILE)
echo "ETCD_ROOT: $ETCD_ROOT"

echo "etcd install prepare"
echo -e "verify openssl installed ?\nrpm -qa | grep ^openssl"
rpm -qa | grep ^openssl
if [ 0 -ne $? ]; then
  echo "you need install openssl"
  exit 1;
fi
echo -e "verify cfssl installed ?\ncfssl version"
cfssl version
if [ 0 -ne $? ]; then
  echo "you need install cfssl and cfssljson"
  exit 1;
fi

echo -e "=============================================================\n"


source "$ETCD_ROOT/etcd.properties"
ETCD_TLS=${ETCD_TLS:-"true"}
if [ "true" = $ETCD_TLS ]; then
  # 生成etcd证书
  source "$ETCD_ROOT/cfssl-gen-cert.sh"
fi

# 停用已经在跑的etcd
systemctl stop etcd.service

cd $ETCD_ROOT
ETCD_HOME=${ETCD_HOME:-"$ETCD_ROOT/etcd"}
echo "ETCD_HOME: $(readlink -f $ETCD_HOME)"
if [[ ! -d $ETCD_HOME ]] && [[ -e $ETCD_HOME.tar.gz ]]; then
  tar -zxf $ETCD_HOME.tar.gz
fi


if [[ ! -e $ETCD_HOME/etcd ]] || [[ ! -e $ETCD_HOME/etcdctl ]]; then
  echo "请确认脚本目录$(readlink -f $ETCD_HOME)是否有为有效的etcd应用目录"
  exit 1
fi

# 将 etcd 和 etcdctl 拷贝到 /usr/bin 目录
echo "cp $ETCD_HOME/etcd $ETCD_HOME/etcdctl /usr/bin"
cp $ETCD_HOME/etcd $ETCD_HOME/etcdctl /usr/bin

# 创建etcd数据存放目 /data/etcd/data 目录
if [ ! -d "/data/etcd/data" ]; then
  mkdir -p /data/etcd/data
fi

# 创建 /etc/etcd 目录
if [ ! -d "/etc/etcd" ]; then
  mkdir /etc/etcd
fi

CONFIG_YAML=$ETCD_ROOT/conf.yml
# 重新生成etcd启动时需要的配置文件conf.yml
if [ -e $CONFIG_YAML ]; then
  rm -f $CONFIG_YAML
fi
cp $ETCD_ROOT/conf.yml.init $CONFIG_YAML
sed -i "s|<LISTEN_PEER_URLS>|$LISTEN_PEER_URLS|g" $CONFIG_YAML
sed -i "s|<LISTEN_CLIENT_URLS>|$LISTEN_CLIENT_URLS|g" $CONFIG_YAML
sed -i "s|<INITIAL_ADVERTISE_PEER_URLS>|$INITIAL_ADVERTISE_PEER_URLS|g" $CONFIG_YAML
sed -i "s|<ADVERTISE_CLIENT_URLS>|$ADVERTISE_CLIENT_URLS|g" $CONFIG_YAML

# 证书相关参数1
if [ "true" = $ETCD_TLS ]; then
  sed -i "s|<SERVER_CERT_AUTH>|true|g" $CONFIG_YAML
  sed -i "s|<SERVER_AUTO_TLS>|true|g" $CONFIG_YAML
  sed -i "s|<PEER_CERT_AUTH>|true|g" $CONFIG_YAML
  sed -i "s|<PEER_AUTO_TLS>|true|g" $CONFIG_YAML
  CA_PEM=$PKI_PATH/ca.pem
  SERVER_PEM=$PKI_PATH/server.pem
  SERVER_KEY_PEM=$PKI_PATH/server-key.pem
  PEER_PEM=$PKI_PATH/peer.pem
  PEER_KEY_PEM=$PKI_PATH/peer-key.pem
else
  sed -i "s|<SERVER_CERT_AUTH>|false|g" $CONFIG_YAML
  sed -i "s|<SERVER_AUTO_TLS>|false|g" $CONFIG_YAML
  sed -i "s|<PEER_CERT_AUTH>|false|g" $CONFIG_YAML
  sed -i "s|<PEER_AUTO_TLS>|false|g" $CONFIG_YAML
fi
# 证书相关参数2
sed -i "s|<CA_PEM>|$CA_PEM|g" $CONFIG_YAML
sed -i "s|<SERVER_PEM>|$SERVER_PEM|g" $CONFIG_YAML
sed -i "s|<SERVER_KEY_PEM>|$SERVER_KEY_PEM|g" $CONFIG_YAML
sed -i "s|<PEER_PEM>|$PEER_PEM|g" $CONFIG_YAML
sed -i "s|<PEER_KEY_PEM>|$PEER_KEY_PEM|g" $CONFIG_YAML


if [ -e "/etc/etcd/conf.yml" ]; then
  datestr=`date +%Y%m%d%H%M`
  echo "备份旧的 /etc/etcd/conf.yml 为 /etc/etcd/conf-${datestr}.yml"
  mv /etc/etcd/conf.yml /etc/etcd/conf-${datestr}.yml
fi

ln -s $CONFIG_YAML /etc/etcd/
echo "成功建立 /opt/etcd/conf.yml 的软连接文件 /etc/etcd/conf.yml"

# 拷贝启动脚本
cp $ETCD_ROOT/etcd.service /usr/lib/systemd/system/etcd.service

# 启动etcd服务
systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd.service

if [ 0 -eq $? ]; then
  echo "将 etcd 服务加到开启启动中，并成功启动 etcd 服务"
else
  echo "启动 etcd 服务失败"
fi

echo "verify etcd is ok ?"
if [ "true" = $ETCD_TLS ]; then
  echo "curl --cacert $PKI_PATH/ca.pem --cert $PKI_PATH/client.pem --key $PKI_PATH/client-key.pem  -L https://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v"
  curl --cacert $PKI_PATH/ca.pem --cert $PKI_PATH/client.pem --key $PKI_PATH/client-key.pem  -L https://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v
else
  echo "curl -L http://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v"
  curl -L http://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v 
fi
if [ 0 -ne $? ]; then
  echo -e "\nthere is something worry with etcd.\n"
  exit 1;
fi
echo "etcd is ok !"
echo -e "\nHappy use etcd.\n"
