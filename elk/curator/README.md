# elasticsearch-curator

## 痛点

Elasticsearch集群管理中索引的管理非常重要。
数据量少的时候，一个或者几个索引就能满足问题。
但是一旦数据量每天几TB甚至几十TB的增长时，索引的生命周期管理显得尤为重要。

- 痛点1：

    你是否遇到过磁盘不够，要删除几个月前甚至更早时间数据的情况？
    如果没有基于时间创建索引，单一索引借助delete_by_query结合时间戳，会越删磁盘空间越紧张，
    以至于对自己都产生了怀疑？

- 痛点2：

    你是否还在通过复杂的脚本管理索引？
    - 1个增量rollover动态更新脚本，
    - 1个定期delete脚本，
    - 1个定期force_merge脚本，
    - 1个定期shrink脚本，
    - 1个定期快照脚本。
    索引多了或者集群规模大了，脚本的维护是一笔不菲的开销。
   

## curator 介绍

elasticsearch-curator可以通过以下方式策划或管理elasticsearch索引和快照：

- 从集群里获取全部索引或者快照作为可操作列表
- 迭代用户定义的过滤器列表，根据需要逐步从此可操作列表中删除索引或快照
- 对保留下来的列表执行各种操作

## 功能
   
Curator允许对索引和快照执行许多不同的操作，包括：
   
- 从别名添加或删除索引（或两者！）
- 更改分片路由分配
- 关闭指数
- 创建索引
- 删除索引
- 删除快照
- 打开关闭的索引
- forceMerge指数
- reindex索引，包括来自远程集群的索引
- 更改索引的每个分片的副本数
- 翻滚指数
- 拍摄索引的快照（备份）
- 还原快照

## 安装

curator 安装可参考官网：https://www.elastic.co/guide/en/elasticsearch/client/curator/current/installation.html
   
### 推荐安装方式：

    pip3 install elasticsearch-curator
    
### yum 安装方式：

- 下载并安装公共签名密钥
    
      rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
      
- RHEL/CentOS 7:

      [curator-5]
      name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
      baseurl=https://packages.elastic.co/curator/5/centos/7
      gpgcheck=1
      gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
      enabled=1      

- rpm 二进制包安装

      yum install elasticsearch-curator

## 命令行接口

命令行参数如下：

    curator [--config CONFIG.YML] [--dry-run] ACTION_FILE.YML
   
如果--config和CONFIG.YML没有提供，Curator会在当前用户的家目录~/.curator/curator.yml下查找。
如果--dry-run提供了，curator将尽可能接近地模拟ACTION_FILE.YML配置文件里的动作，而实际上不进行任何更改，
如果未指定日志文件，则日志将位于当前目录或为标准输出

    curator --help
    
## 单例命令行

curator_cli命令允许用户运行一个单个受支持的操作，无需客户端或这个aciton配置文件，但如果需要，也是支持使用客户端配置文件的，有个好处，就是curator_cli允许你通过指定一些参数来覆盖配置文件curator.yml里的配置：

    curator_cli --help

## 配置文件

主要为action(action.yml)和config(curator.yml/config.yml)配置文件，
默认示例(两个文件需要放到/root/.curator/目录下): 

- curator.yml 会主机名为 elasticsearch 的 es 为管理对象，可以数组方式配置es集群
- action.yml 会删除了30天前，以 logstash-*(logstash-%Y.%m.%d格式) 开头的索引。

## 启动

    curator [--config CONFIG.YML] [--dry-run] action.yml
    
## 周期性执行
    
  借助crontab，每天零点5分执行
    
    crontab -e
    
  加上如下的命令：
    
    5 0 * * * curator /root/.curator/action.yml