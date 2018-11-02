#!/bin/bash
# 输出命令，并且执行该命令
function echo_exec () {
  echo "\$ $@"
  eval $@
  ok=$?
  echo 
  return $ok
}

echo "Usage: shadowsocks.sh start or shadowsocks.sh stop or shadowsocks.sh file"

BASH_DIR=$(readlink -f $(dirname "${BASH_SOURCE}"))
JSON_FILE=$BASH_DIR/shadowsocks.json

if [ "file" = $1 ]; then
  source "$BASH_DIR/shadowsocks.properties"
  echo "==================生成 shadowsocks 配置文件 shadowsocks.json=================="
  echo_exec "echo 3 > /proc/sys/net/ipv4/tcp_fastopen"
  echo_exec cp $BASH_DIR/shadowsocks.json.init $JSON_FILE
  sed -i "s@<server>@$server@g" $JSON_FILE
  sed -i "s@<server_port>@$server_port@g" $JSON_FILE
  sed -i "s@<password>@$password@g" $JSON_FILE
  sed -i "s@<local_address>@$local_address@g" $JSON_FILE
  sed -i "s@<local_port>@$local_port@g" $JSON_FILE
  sed -i "s@<timeout>@$timeout@g" $JSON_FILE
  sed -i "s@<method>@$method@g" $JSON_FILE
  sed -i "s@<fast_open>@$fast_open@g" $JSON_FILE
  sed -i "s@<workers>@$workers@g" $JSON_FILE
  cat $JSON_FILE
elif [ "status" = $1 ]; then
  echo_exec sslocal -c $JSON_FILE -d status
elif [ "stop" = $1 ]; then
  #echo_exec ssserver -c $JSON_FILE -d stop
  echo_exec sslocal -c $JSON_FILE -d stop
else
  #echo_exec ssserver -c $JSON_FILE -d start
  # 前端命令行方式运行
  #echo_exec "/usr/bin/ssserver -p 9000 -k www.phpgao.com -m chacha20 --user nobody"
  # 前端方式运行
  # ssserver -c $JSON_FILE
  # 后端方式运行
  #echo_exec ssserver -c $JSON_FILE -d start
  echo_exec sslocal -c $JSON_FILE -d start
  echo "查看日志命令： less /var/log/shadowsocks.log"
fi

