#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/fastdfs.properties"

h1 "启动fastdfs HA"
info "启动 fastdfs tracker"
process=fdfs_trackerd
#if ! ps aux | grep $process | grep -v grep &> /dev/null; then
#根据完整命令名获取进程信息
if ! ps -C $process &> /dev/null; then
    echo_exec "$process /etc/fdfs/tracker.conf"
	if ! $?; then 
	    error "$process start failed"
		exit 1
	fi
fi
info "$process started"

info "启动 fastdfs storage"
process=fdfs_storaged
if ! ps -C $process &> /dev/null; then
    echo_exec "$process /etc/fdfs/storage.conf"
	if ! $?; then 
	    error "$process start failed"
		exit 1
	fi
fi
info "$process started"


info "验证 storage 是否已经连接上 tracker"
echo_exec "fdfs_monitor /etc/fdfs/storage.conf"
if ! $?; then 
	error "fdfs_storaged not conneted fdfs_trackerd, fastdfs start failed"
	exit 1
fi
info "fastdfs started"

info "启动 nginx"
process=nginx
if ! ps -C $process &> /dev/null; then
    echo_exec "$process"
	if ! $?; then 
	    error "$process start failed"
		exit 1
	fi
fi
info "$process started"

info "启动 keepalived"
process=keepalived
if ! ps -C $process &> /dev/null; then
    echo_exec "$process"
	if ! $?; then 
	    error "$process start failed"
		exit 1
	fi
fi
info "$process started"



success $"----fastdfs ha has been started successfully.----"







