#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/nginx.properties"

h1 "nginx安装"
h2 "安装nginx前置环境"

echo_exec "yum -y install make zlib zlib-devel gcc-c++ libtool  openssl openssl-devel"
echo_exec "yum -y install libnl libnl-devel libnl3 libnl3-devel libnfnetlink-devel"

if ! pcre-config --version &> /dev/null; then
	if [ ! -d pcre-${pcre_version} ]; then
		if [ ! -e pcre-${pcre_version}.tar.gz ]; then
			echo_exec "wget https://nchc.dl.sourceforge.net/project/pcre/pcre/${pcre_version}/pcre-${pcre_version}.tar.gz"
			if [ 0 -ne $? ]; then
				rm "-rf pcre-${pcre_version}.tar.gz"
				error "download pcre failed!"
				exit 1
			fi
		fi
		echo_exec "tar xf pcre-${pcre_version}.tar.gz"
	fi
	echo_exec cd pcre-${pcre_version}
	echo_exec ./configure
	if [ 0 -ne $? ]; then
		error "./configure of pcre failed!"
		exit 1
	fi
	echo_exec "make && make install"
	if [ 0 -ne $? ]; then
		error "make && make install of pcre failed!"
		exit 1
	fi
fi
echo_exec "pcre-config --version"
echo_exec "cd $INSTALL_ROOT"


# ngx_cache_purge是nginx模块，它增加了从FastCGI，代理，SCGI和uWSGI缓存中清除内容的功能。
h2 "添加 ngx_cache_purge 模块"
if [ ! -d ngx_cache_purge-${ngx_cache_purge_version} ]; then
	if [ ! -e ${ngx_cache_purge_version}.tar.gz ]; then
		echo_exec "wget https://github.com/FRiCKLE/ngx_cache_purge/archive/${ngx_cache_purge_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf ${ngx_cache_purge_version}.tar.gz"
			error "download ngx_cache_purge failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf ${ngx_cache_purge_version}.tar.gz"
fi
echo_exec "cd $INSTALL_ROOT"


h2 "安装nginx"
if [ ! -d nginx-${nginx_version} ]; then
	if [ ! -e nginx-${nginx_version}.tar.gz ]; then
		echo_exec "wget http://nginx.org/download/nginx-${nginx_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf nginx-${nginx_version}.tar.gz"
			error "download nginx failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf nginx-${nginx_version}.tar.gz"
fi
echo_exec "cd nginx-${nginx_version}"
ngx_configure_prefix=${ngx_configure_prefix-$INSTALL_ROOT/nginx}
echo_exec "./configure --prefix=${ngx_configure_prefix} ${ngx_configure_with} ${ngx_configure_add_module}"
if [ 0 -ne $? ]; then
	error "./configure of nginx failed!"
	exit 1
fi
echo_exec "make && make install"
if [ 0 -ne $? ]; then
	error "make && make install of nginx failed!"
	exit 1
fi
echo_exec "ln -sf ${ngx_configure_prefix}/sbin/nginx /usr/sbin/nginx"
echo_exec "nginx -v"
echo_exec "cd $INSTALL_ROOT"



h2 "安装 keepalived"
if [ ! -d keepalived-${keepalived_version} ]; then
	if [ ! -e keepalived-${keepalived_version}.tar.gz ]; then
		echo_exec "wget http://www.keepalived.org/software/keepalived-${keepalived_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf keepalived-${keepalived_version}.tar.gz"
			error "download keepalived failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf keepalived-${keepalived_version}.tar.gz"
fi
echo_exec "cd keepalived-${keepalived_version}"
kpd_configure_prefix=${ngx_configure_prefix-$INSTALL_ROOT/keepalived}
echo_exec "./configure --prefix=$INSTALL_ROOT/keepalived"
if [ 0 -ne $? ]; then
	error "./configure of keepalived failed!"
	exit 1
fi
echo_exec "make && make install"
if [ 0 -ne $? ]; then
	error "make && make install of keepalived failed!"
	exit 1
fi
echo_exec "ln -sf ${kpd_configure_prefix}/sbin/nginx /usr/sbin/keepalived"
echo_exec "keepalived -v"

echo_exec "mkdir -pv /etc/keepalived"
echo_exec "cp $INSTALL_ROOT/keepalived.conf $INSTALL_ROOT/nginx_check.sh /etc/keepalived"
echo_exec "/opt/shell/purge-win-shell.sh /etc/keepalived/nginx_check.sh"

success $"----nginx-ha has been installed and started successfully.----

Now you should be able to edit $INSTALL_ROOT/nginx/conf/nginx.conf, then execute nginx. 
For more details, please visit http://nginx.org/en/ .
"







