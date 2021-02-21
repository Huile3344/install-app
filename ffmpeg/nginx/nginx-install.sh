#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/nginx.properties"

h1 "nginx安装"
h2 "安装nginx前置环境"

echo_exec "yum -y install make zlib zlib-devel gcc-c++ libtool  openssl openssl-devel"

if [ ! -d nginx-http-flv-module-master ]; then
    if [ ! -e nginx-http-flv-module-master.zip ]; then
        echo_exec "wget https://codeload.github.com/winshining/nginx-http-flv-module/zip/master -O nginx-http-flv-module-master.zip"
        if [ 0 -ne $? ]; then
            echo_exec "rm -rf nginx-http-flv-module-master.zip"
            error "download nginx-http-flv-module-master failed!"
            exit 1
        fi
    fi
    echo_exec "unzip nginx-http-flv-module-master.zip"
fi

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
echo_exec "mkdir -pv /opt/nginx/data/cache/proxy_cache/tmp"
echo_exec "cp -R $INSTALL_ROOT/video /opt/nginx/data/"
echo_exec "cp $INSTALL_ROOT/nginx.conf ${ngx_configure_prefix}/conf/nginx.conf"
echo_exec "nginx -v"
echo_exec "nginx"

success $"----nginx has been installed and started successfully.----

Now you should be able to edit $INSTALL_ROOT/nginx/conf/nginx.conf, then execute nginx. 
For more details, please visit http://nginx.org/en/ .
"







