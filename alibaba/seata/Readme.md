# Seata

- GitHub
  - [seata](https://github.com/seata/seata)
  - [seata release版本](https://github.com/seata/seata/releases)
  - [mysql 数据库初始化脚本](https://github.com/seata/seata/blob/1.4.2/script/server/db/mysql.sql)) 默认使用数据库名 seata
  - [seata-server 脚本安装](https://github.com/seata/seata/tree/1.4.0/script/server)
- **[官方中文文档](https://seata.io/zh-cn/docs/overview/what-is-seata.html)**

**注意**:使用seata时注意目标表名不要和mysql系统关键字重名，否则会报sql异常，如表名: order，user

## [部署指南](https://seata.io/zh-cn/docs/ops/deploy-guide-beginner.html) 示例版本: seata-server-1.4.2
- 在 [seata release版本](https://github.com/seata/seata/releases) 页面下载需要的版本及源码并解压缩，
源码目录 `script` 包含了各种脚本，如：client/server/config-server/logstash 需要的各种数据库和配置脚本
- 修改 seata 数据存储方式配置文件 `conf/file.conf`
  ```
  1、修改 store 的 mode 值为 db
  2、修改 store 的 db 区域的 mysql 配置
  
  最简化结果类似如下:
  ## transaction log store, only used in seata-server
  store {
    ## store mode: file、db、redis
    mode = "db"
    ## rsa decryption public key
    publicKey = ""
  
    ## database store property
    db {
      ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp)/HikariDataSource(hikari) etc.
      datasource = "druid"
      ## mysql/oracle/postgresql/h2/oceanbase etc.
      dbType = "mysql"
      driverClassName = "com.mysql.jdbc.Driver"
      ## if using mysql to store the data, recommend add rewriteBatchedStatements=true in jdbc connection param
      url = "jdbc:mysql://10.180.35.6:30006/seata-server?rewriteBatchedStatements=true"
      user = "root"
      password = "123456"
      minConn = 5
      maxConn = 100
      globalTable = "global_table"
      branchTable = "branch_table"
      lockTable = "lock_table"
      queryLimit = 100
      maxWait = 5000
    }
  }
  ```
- 修改 seata 注册/配置中心配置文件 `conf/registry.conf`
  ```
  1、修改 registry 的 type 值为 nacos
  2、修改 registry 的 nacos 区域的 mysql 配置
  3、修改 config 的 type 值为 nacos
  4、修改 config 的 nacos 区域的 mysql 配置
  
  最简化结果类似如下:
  registry {
    # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
    type = "nacos"
  
    nacos {
      application = "seata-server"
      # 注意，针对非8848端口必须写入，要不然会默认为8848
      serverAddr = "nacos.k8s.com:80"
      group = "SEATA_GROUP"
      namespace = "dev"
      cluster = "dev"
      username = "nacos"
      password = "nacos"
    }
  }
  config {
    # file、nacos 、apollo、zk、consul、etcd3
    type = "nacos"
  
    nacos {
      # 注意，针对非8848端口必须写入，要不然会默认为8848
      serverAddr = "nacos.k8s.com:80"
      namespace = "dev"
      group = "SEATA_GROUP"
      username = "nacos"
      password = "nacos"
      dataId = "seataServer.properties"
    }
  }
  ```
- 将源码目录 `script` 拷贝到安装目录，修改 `/script/config-center/config.txt`
  - 修改 `service.vgroupMapping.my_test_tx_group=default`，其中 `my_test_tx_group` 是事务分组名称，主要用于异地机房停电容错
    这个值也需要 seata 客户端实例配置文件 `application.yaml` 的 `spring.cloud.alibaba.seata.tx-service-group` 保持一致，
    对应的值 default 要与 `conf/registry.conf` 内部注册中心 `registry.nacos.cluster` 的值对应，默认值是 default，
    同时 `service.default.grouplist=127.0.0.1:8091` 也需要修改 将 default 修改为事务分组名称，地址改为 seata 服务地址
    对应前面的配置修改为: `service.vgroupMapping.guangzhou=dev` 和 `service.guangzhou.grouplist=10.180.35.3:8091` 和下方客户端配置
    ```
    # 旧版本可注释掉这部分
    #spring:
    #  cloud:
    #    alibaba:
    #      seata:
    #        # 事务分组配置，机房位置
    #        tx-service-group: guangzhou
    seata:
      # 项目
      tx-service-group: projectA
      service:
        vgroup-mapping:
          projectA: guangzhou
        grouplist:
          guangzhou: 10.180.35.3:8091
    
    # 有异常是开放日志，查看原因
    logging:
      level:
        root: INFO
        io.seata: DEBUG
    ```
  - 修改 service 和数据库配置  
    ```
    service.vgroupMapping.guangzhou=dev
    service.guangzhou.grouplist=10.180.35.3:8091
    # 其他中间配置 ... 
    store.mode=db
    store.publicKey=
    store.db.datasource=druid
    store.db.dbType=mysql
    store.db.driverClassName=com.mysql.jdbc.Driver
    store.db.url=jdbc:mysql://10.180.35.6:30006/seata-server?rewriteBatchedStatements=true
    store.db.user=root
    store.db.password=123456
    store.db.minConn=5
    store.db.maxConn=30
    store.db.globalTable=global_table
    store.db.branchTable=branch_table
    store.db.queryLimit=100
    store.db.lockTable=lock_table
    store.db.maxWait=5000
    ```
  - 其他配置按需修改
- 在 nacos 创建对应的命名空间 `seata`
- 在 nacos 对应的命名空间下配置seata的配置信息
  本质是将 `/script/config-center/config.txt` 内的信息配置到 nacos
  - 从v1.4.2版本开始，已支持从一个 Nacos dataId中获取所有配置信息,你只需要额外添加一个dataId配置项 `seataServer.properties` 。
  - (v1.4.2以前版本)执行脚本 seata nacos 配置脚本逐行配置
    ```
    # 可能需要翻墙
    sh https://raw.githubusercontent.com/seata/seata/1.4.2/script/config-center/nacos/nacos-config.sh -h nacos.k8s.com -p 80 -g SEATA_GROUP -t dev -u nacos -w nacos
    ```
  - (v1.4.2以前版本)进入到 `/script/config-center/nacos/` 目录执行脚本文件
    ```
    sh nacos-config.sh -h nacos.k8s.com -p 80 -g SEATA_GROUP -t dev -u nacos -w nacos
    ```

## helm 方式安装
官网的方式有点问题，需要自己调整，监控等相关的参考nacos方式调整

## 客户端应用配置
- 引入依赖
  ```
  <dependency>
  	<groupId>com.alibaba.cloud</groupId>
  	<artifactId>spring-cloud-starter-alibaba-seata</artifactId>
  </dependency>
  ```
- 配置 application.yml
  ```
  spring:
    cloud:
      alibaba:
        seata:
          # 事务分组配置，机房位置
          tx-service-group: guangzhou
  seata:
    config:
      nacos:
        namespace: ${spring.profiles.active}
        server-addr: ${spring.cloud.nacos.config.server-addr}
    registry:
      nacos:
        namespace: ${spring.profiles.active}
        server-addr: ${spring.cloud.nacos.config.server-addr}
  ```
- 在方法上添加注解 `@GlobalTransactional` 开启 seata 事务  