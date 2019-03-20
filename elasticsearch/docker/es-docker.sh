#!/bin/bash
source /opt/shell/log.sh
INSTALL_ROOT=$(readlink -f $(dirname "${BASH_SOURCE}"))
echo_exec "cd $INSTALL_ROOT"
note "INSTALLER_ROOT: $INSTALL_ROOT"
h1 "install elasticsearch of docker"
echo_exec "mkdir -pv /data/es/{logs,data}"
echo_exec "chown 1000:1000 -R /data/es"
echo_exec "mkdir -pv /opt/es/ik"
#echo_exec "cp elasticsearch-analysis-ik-6.6.0.zip /opt/es/ik"
#echo_exec "cd opt/es/ik"
echo_exec "unzip elasticsearch-analysis-ik-6.6.0.zip -d /opt/es/ik"
#echo_exec "rm -rf elasticsearch-analysis-ik-6.6.0.zip"
echo_exec "chown 1000:1000 -R /opt/es/ik"

#echo_exec "docker network create esnet"
#echo_exec "docker run --rm -d --name elasticsearch --net esnet -p 9200:9200 -p 9300:9300 \
#-v /data/es/data:/usr/share/elasticsearch/data -v /data/es/logs:/usr/share/elasticsearch/logs \
#-e \"discovery.type=single-node\" -e \"http.cors.enabled=true\" -e \"http.cors.allow-origin=*\" \
#elasticsearch:6.6.0"
#echo_exec "docker run --rm -d --name kibana --net esnet -p 5601:5601 -e \"SERVER_NAME=kibana\" kibana:6.6.0"

echo_exec "docker stack deploy -c stack.yml es"
echo_exec "sleep 3"
echo_exec "docker stack services es"
success $"install elasticsearch and kibana of docker successfully!"
