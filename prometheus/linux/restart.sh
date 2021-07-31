#!/bin/bash
pid=$(ps aux | grep prometheus | grep -v grep | awk '{print $2}')
[[ -n $pid ]] && kill -15 $pid
#nohup /opt/pkg/prometheus/prometheus/prometheus --config.file=/opt/pkg/prometheus/prometheus/prometheus.yml --web.listen-address="0.0.0.0:9090" > ./prometheus.log 2>&1 &
nohup /opt/pkg/prometheus/prometheus/prometheus --config.file=/opt/pkg/prometheus/prometheus/prometheus.yml --web.listen-address="0.0.0.0:9090" > ./prometheus.log 2>&1 &
