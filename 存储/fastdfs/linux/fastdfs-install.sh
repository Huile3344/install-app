#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/fastdfs.properties"

h1 "fastdfs安装"

h2 "安装fastdfs前置环境"

echo_exec "yum -y install make cmake gcc gcc-c++"

if [ ! -d libfastcommon-${libfastcommon_version}} ]; then
	if [ ! -e V${libfastcommon_version}.tar.gz ]; then
		echo_exec "wget https://github.com/happyfish100/libfastcommon/archive/V${libfastcommon_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf V${libfastcommon_version}.tar.gz"
			error "download libfastcommon failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf V${libfastcommon_version}.tar.gz"
fi
echo_exec "cd libfastcommon-${libfastcommon_version}"
echo_exec "./make.sh && ./make.sh install"
if [ 0 -ne $? ]; then
	error "./make.sh && ./make.sh install of libfastcommon failed!"
	exit 1
fi
echo_exec "cd $INSTALL_ROOT"


h2 "安装fastdfs"
if [ ! -d fastdfs-${fastdfs_version} ]; then
	if [ ! -e V${fastdfs_version}.tar.gz ]; then
		echo_exec "wget https://github.com/happyfish100/fastdfs/archive/V${fastdfs_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf V${fastdfs_version}.tar.gz"
			error "download fastdfs failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf V${fastdfs_version}.tar.gz"
fi
echo_exec "cd fastdfs-${fastdfs_version}"
echo_exec "./make.sh && ./make.sh install"
if [ 0 -ne $? ]; then
	error "./make.sh && ./make.sh install of fastdfs failed!"
	exit 1
fi
echo_exec "cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf"
echo_exec "cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf"
echo_exec "cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf"
echo_exec "cp $INSTALL_ROOT/fastdfs-5.11/conf/http.conf /etc/fdfs/http.conf"
echo_exec "cp $INSTALL_ROOT/fastdfs-5.11/conf/mime.types /etc/fdfs/mime.types"
echo_exec "cd $INSTALL_ROOT"


h2 "添加 fastdfs-nginx-module 模块"
if [ ! -d fastdfs-nginx-module-${fastdfs_nginx_module_version} ]; then
	if [ ! -e V${fastdfs_nginx_module_version}.tar.gz ]; then
		echo_exec "wget https://github.com/happyfish100/fastdfs-nginx-module/archive/V${fastdfs_nginx_module_version}.tar.gz"
		if [ 0 -ne $? ]; then
			echo_exec "rm -rf V${fastdfs_nginx_module_version}.tar.gz"
			error "download fastdfs-nginx-module failed!"
			exit 1
		fi
	fi
	echo_exec "tar xf V${fastdfs_nginx_module_version}.tar.gz"
	config=fastdfs-nginx-module-${fastdfs_nginx_module_version}/src/config
	echo_exec "cp ${config} ${config}.bak"
	echo_exec "cp fastdfs-nginx-module-${fastdfs_nginx_module_version}/src/mod_fastdfs.conf /etc/fdfs/"
	sed -i "s@/usr/local/include@/usr/include/fastdfs /usr/include/fastcommon/@g" $config
fi


h2 "安装nginx前置环境"

echo_exec "yum -y install make zlib zlib-devel gcc-c++ libtool  openssl openssl-devel"

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

success $"----nginx has been installed and started successfully.----

Now you should be able to edit $INSTALL_ROOT/nginx/conf/nginx.conf, then execute nginx. 
For more details, please visit http://nginx.org/en/ .
"







