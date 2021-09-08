#!/bin/bash
PATH=/opt/pkg/prometheus/alertmanager
pid=$(ps aux | grep alertmanager | grep -v grep | awk '{print $2}')
[[ -n $pid ]] && kill -15 $pid
nohup $PATH/alertmanager > $PATH/alertmanager.log 2>&1 &
