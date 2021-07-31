#!/bin/bash
PATH=/opt/pkg/prometheus/prometheus
pid=$(ps aux | grep prometheus | grep -v grep | awk '{print $2}')
[[ -n $pid ]] && kill -15 $pid
#nohup $PATH/prometheus --config.file=$PATH/prometheus.yml --web.listen-address="0.0.0.0:9090" > ./prometheus.log 2>&1 &
nohup $PATH/prometheus --config.file=$PATH/prometheus.yml > ./prometheus.log 2>&1 &
