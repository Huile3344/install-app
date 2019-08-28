# ELK 配置使用场景说明

## ELK快速安装使用步骤说明

- 根据需要修改 nginx-install.sh 一下三项
    
      # docker stack 使用的yml文件名称，默认：stack.yml
      STACK_YML=stack.yml
      # 默认提供使用的 stack 辅助脚本文件，方便使用
      STACK_SHELL=stack.sh
      # docker stack 使用的 STACK 名称
      STACK_NAME=elk

- 给 nginx-install.sh 文件添加执行权限

      chmod +x elk-install.sh
      
- 执行安装命令安装

      ./elk-install.sh install <安装目录>

- 执行移除命令，清楚所有安装的文件

      ./elk-install.sh clean <安装目录>
      
- 其他说明

    - 进入安装目录使用使用stack脚本
    
    - elk-install.sh 安装脚本 help 命令
    
          ./elk-install.sh help
          
    - stack.sh stack脚本 help 命令
    
          ./stack.sh help 


#其他可参考方案：

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
