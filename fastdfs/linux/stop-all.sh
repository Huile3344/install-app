#!/bin/bash

source /opt/shell/log.sh

INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
note "INSTALLER_ROOT: $INSTALL_ROOT"

echo_exec "source $INSTALL_ROOT/fastdfs.properties"

function stop () {
	process=$1
	for i in `seq 1 10`;
	do
		pid=$(ps aux | grep $process | grep -v grep | awk '{print $2}')
		[ -z $pid ] && break
		kill $pid
		echo "."
		sleep 1;
	done
	if [ -z $pid ]; then
		echo "$1 stopped successfully!";
	fi

	if [ -n "$pid" ]; then
		kill -9 $pid
		echo "$process force stopped successfully!";
	fi
}

function stop_command () {
	process=$1
	for i in `seq 1 10`;
	do
		pid=$(ps aux | grep $process | grep -v grep | awk '{print $2}')
		[ -z $pid ] && break
		$2
		echo "."
		sleep 1;
	done
	if [ -z $pid ]; then
		echo "$1 stopped successfully!";
	fi

	if [ -n "$pid" ]; then
		kill -9 $pid
		echo "$process force stopped successfully!";
	fi
}

h1 "停止fastdfs HA"
info "停止 fastdfs tracker"
#stop fdfs_trackerd
stop_command fdfs_trackerd "fdfs_trackerd /etc/fdfs/tracker.conf stop"

info "停止 fastdfs storage"
#stop fdfs_storaged
stop_command fdfs_storaged "fdfs_storaged /etc/fdfs/storage.conf stop"

info "停止 nginx"
#stop nginx
stop_command nginx "nginx -s stop"

info "停止 keepalived"
stop keepalived

success $"----fastdfs ha has been started successfully.----"







