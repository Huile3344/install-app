#!/bin/bash
PATH=/opt/pkg/prometheus/node_exporter
pid=$(ps aux | grep node_exporter | grep -v grep | awk '{print $2}')
[[ -n $pid ]] && kill -15 $pid
nohup $PATH/node_exporter > $PATH/node_exporter.log 2>&1 &
