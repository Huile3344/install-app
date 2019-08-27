# ELK 配置使用场景说明

其他可参考方案：
- docker swarm集群日志管理ELK实战 https://blog.csdn.net/dkfajsldfsdfsd/article/details/79987753
- 使用ELK处理Docker日志 https://segmentfault.com/a/1190000009102612
- docker部署ELK、grafana、zabbix https://blog.51cto.com/zhanghy/2300633

## MAC

- 修改 docker 使用的内存大小，改为4G以上，不然容器很容易运行一段时间后挂掉，并出现以下报错内容：

      Native controller process has stopped - no new native processes can be started

- 调整内核内容，运行以下脚本：

      screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
      sysctl -w vm.max_map_count=655360

## docker 方式配置

- ELK 镜像拉取方式

    - 推荐 (直接使用DockerHub方式拉取，会使用到镜像加速器)

          $ docker pull elasticsearch:7.3.1
          $ docker pull kibana:7.3.1
          $ docker pull elasticsearch:7.3.1

    - 默认 (使用ELK官网方式拉取，连接国外网络不好时，容易网络异常)

          $ docker pull docker.elastic.co/elasticsearch/elasticsearch:7.3.1
          $ docker pull docker.elastic.co/logstash/logstash:7.3.1
          $ docker pull docker.elastic.co/kibana/kibana:7.3.1
 
- 其他镜像拉取

      docker pull grafana/grafana:latest     


### ELK (elasticsearch + kibana + logstash + logspout/filebeat + grafana + zabbix[可选])

### EFK (elasticsearch + kibana + fluentd)
