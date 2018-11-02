#!/bin/bash
#
# 安装shadowsocks-python并启用chacha20加密
# 参考: https://blog.phpgao.com/shadowsocks_chacha20.html
# 深入阅读参考: https://github.com/shadowsocks/shadowsocks/wiki/Shadowsocks-%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E

# 输出命令，并且执行该命令
function echo_exec () {
  echo "\$ $@"
  eval $@
  ok=$?
  echo
  return $ok
}

BASH_DIR=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec cd $BASH_DIR

echo "==================安装 shadowsocks=================="
echo_exec yum -y install epel-release
echo_exec yum -y install python-pip
echo_exec pip install --upgrade pip
echo_exec yum -y install m2crypto
echo_exec pip install shadowsocks



echo_exec "gcc --version"
if [ 0 -ne $? ]; then
  echo "==================安装 C 编译器=================="
  echo_exec "yum -y install gcc"
  echo_exec "gcc --version"
fi


echo_exec cd $BASH_DIR
echo "==================安装 shadowsocks 依赖的 libsodium 模块=================="
if [ ! -d $BASH_DIR/libsodium-stable ]; then
  #echo_exec "curl -O https://download.libsodium.org/libsodium/releases/LATEST.tar.gz"
  #echo_exec "tar -zxf lLATEST.tar.gz"
  if [ ! -e libsodium-stable ]; then
    echo_exec "curl -L https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -o libsodium-stable.tar.gz"
  fi
  echo_exec "tar -zxf libsodium-stable.tar.gz"
  echo_exec "cd $BASH_DIR/libsodium*"
  echo_exec "./configure"
  echo_exec "make && make install"
  echo "==================修复关联=================="
  echo_exec "echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf"
  echo_exec "ldconfig"
fi



echo "==================开机启动 shadowsocks=================="
#echo_exec "echo '/usr/bin/ssserver -p 9000 -k www.phpgao.com -m chacha20 --user nobody' >> /etc/rc.local"
echo_exec "echo '/usr/bin/sslocal -c $BASH_DIR/shadowsocks.json -d start' >> /etc/rc.local"


echo_exec cd $BASH_DIR
echo_exec "privoxy --version"
if [ 0 -ne $? ]; then
  echo "==================安装 privoxy=================="
  echo_exec "yum -y install privoxy"
#   # 源码安装
#  if [ ! -d $BASH_DIR/privoxy-3.0.26-stable ]; then
#    if [ ! -e $BASH_DIR/privoxy-3.0.26-stable-src.tar.gz ]; then
#      echo_exec "curl -O http://www.privoxy.org/sf-download-mirror/Sources/3.0.26%20%28stable%29/privoxy-3.0.26-stable-src.tar.gz"
#	fi
#    echo_exec "tar -zxf privoxy-3.0.26-stable-src.tar.gz"
#    echo_exec "cd $BASH_DIR/privoxy*"
#    echo_exec "useradd privoxy"
#    echo_exec "autoheader && autoconf"
#    echo_exec "./configure"
#    echo_exec "make && make install"
#  fi
fi

# 备份初始配置文件
mv  /etc/privoxy/config /etc/privoxy/config.bak
cp $BASH_DIR/privoxy.config /etc/privoxy/config

echo_exec 'echo "export http_proxy=http://127.0.0.1:8118" >> /etc/profile'
echo_exec 'echo "export https_proxy=http://127.0.0.1:8118" >> /etc/profile'
echo_exec 'echo "export ftp_proxy=http://127.0.0.1:8118" >> /etc/profile'
echo_exec "source /etc/profile"
echo "==================开机启动 shadowsocks=================="
echo_exec "systemctl enable privoxy"



echo "==================运行 shadowsocks=================="
echo_exec "$BASH_DIR/shadowsocks.sh file"
echo_exec "$BASH_DIR/shadowsocks.sh start"



echo "==================运行 privoxy=================="
echo_exec "systemctl start privoxy"
