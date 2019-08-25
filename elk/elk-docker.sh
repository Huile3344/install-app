#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install elk of docker"
echo_exec "mkdir -pv /opt/elk/elasticsearch/{data,ik}"
echo_exec "mkdir -pv /opt/elk/logstash/{config,pipeline,build}"
echo_exec "mkdir -pv /opt/elk/grafana/data"
echo_exec "mkdir -pv /opt/elk/grafana/data"
echo_exec "unzip elasticsearch-analysis-ik-7.3.1.zip -d /opt/elk/elasticsearch/ik"
echo_exec "cp logstach.conf /opt/elk/logstash/pipeline"
echo_exec "chown 1000:1000 -R /opt/elk/"

echo_exec "docker stack deploy -c elk-stack.yml elk"
echo_exec "sleep 3"
echo_exec "docker stack services elk"
success $"install elk of docker successfully!"
