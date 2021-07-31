#!/bin/bash
PATH=/opt/pkg/prometheus/mysqld_exporter
pid=$(ps aux | grep mysqld_exporter | grep -v grep | awk '{print $2}')
[[ -n $pid ]] && kill -15 $pid
# 针对非本机的mysql，需要 DATA_SOURCE_NAME 环境变量，注意末尾的/
# 创建数据库用户
#CREATE USER 'exporter'@'%' IDENTIFIED BY '123456' WITH MAX_USER_CONNECTIONS 2;
# 授权用户
#GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
# 刷新权限
#FLUSH PRIVILEGES;
# 针对非本机的mysql，需要 DATA_SOURCE_NAME 环境变量，注意末尾的/
#export DATA_SOURCE_NAME="user:password@(hostname:port)/"
export DATA_SOURCE_NAME="exporter:123456@(10.181.4.88:3306)/"
nohup $PATH/mysqld_exporter --config.my-cnf="$PATH/.my.cnf" > $PATH/mysqld_exporter.log 2>&1 &

# Dashboard from Percona Monitoring and Management project.  https://github.com/percona/grafana-dashboards
# 需要从Grafana的存储库中填写仪表板的URL。https://grafana.com/grafana/dashboards/7362 即：mysql-overview_rev5.json