#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/keepalived.properties"

h1 "keepalived 安装"

h2 "安装 keepalived 前置环境"

echo_exec "yum -y install make cmake gcc gcc-c++"
echo_exec "yum -y install libnl libnl-devel libnl3 libnl3-devel libnfnetlink-devel"

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
echo_exec "cp $INSTALL_ROOT/keepalived.conf /etc/keepalived"

success $"----keepalived has been installed and started successfully.----"







