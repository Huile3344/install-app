# 安装部署Redis

- 1、下载指定版本Redis

      wget http://download.redis.io/releases/redis-5.0.1.tar.gz
      
- 2、解压缩版本包

      tar xf redis-5.0.1.tar.gz
      
- 3、进入源码目录，并编译源码

      cd redis-5.0.1
      make
      # make && make install

*此时已经在源码src目录下生成了Redis的二进制文件，Redis安装完成* 

      
## 单机Redis

- 1、备份源码目录下的redis.conf配置文件，并按需修改redis.conf

      cp redis.conf redis.conf.bak
      
- 2、修改完成后，根据启动redis

      src/redis-server redis.conf
      
      
## 主从+哨兵模式（推荐使用集群模式）

启动哨兵

      src/redis-server sentinel.conf --sentinel


## 集群模式

- 1、找到源码目录下的集群启动部署脚本

      cd utils/create-cluster/

- 2、阅读 README 和脚本文件 create-cluster，按需调整配置集群启动的起始端口和集群规模。

  默认启动的是三主三从的Redis集群，端口从30001-30006
  
    - a、启动6个redis节点
    
          ./create-cluster start

    - b、将启动的redis创建为集群
    
          ./create-cluster create
          
    
      

       