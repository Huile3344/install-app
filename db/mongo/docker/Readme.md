使用说明；
    该目录下的所有文件用于安装和初始化mongo集群(shard+configservice+mongos)。
	通常情况只需要参照并修改mongo.propertis中的配置项，指定集群规模，修改mongos中执行的sharding.sh中的分片脚本，
	然后再执行脚本文件install.sh，即可基于 docker 初始安装完成集群。然后再手动执行mongo.propertis中DATA_ROOT指定的
	路径下的mongo目录中的cluster.sh(install.sh脚本生成)脚本，即：将脚本中的所有命令按批次拷贝出来(每个quit()和之前脚本为一个批次)，粘贴到命令行下便可执行脚本，
	完成集群初始化。(mongo不支持以Linux脚本形式直接注入并执行集群初始化脚本)
	
文件说明：
    mongo.properties:	 包含集群基本配置信息，一般第一次需要修改
    sharding.sh：		 包含需要在mongos中执行的分片脚本信息，一般第一次需要修改
	mongod.conf.yaml:	 mongod/mongos 服务启动依赖的配置脚本，一般不需要修改
    replset.yaml:		 sharding/configservice 副本集群 docker 形式定义模板，一般不需要修改
    stack.init.yaml:	 mongos 的 docker 形式定义模板，一般不需要修改
    install.sh:			 集群安装脚本，一般不需要修改。执行完该脚本后，会在mongo.propertis中DATA_ROOT指定的目录路径下新增
	                     如下目录结构的文件：
						 |- mongo 
						    |- cluster.sh	(mongo集群初始化脚本)
							|- stack.xml	(docker创建mongo集群需要的文件)
							|- 分片n 		(分片n目录: 如 shard1)
							   |- mongod.conf (该分片下所有副本启动依赖的配置文件)
							   |- 副本n		(副本n目录: 如 rsn)
							      |- db		(副本n的数据存放目录)
								  |- configdb (副本n元数据存放目录)
							|- 配置服务n 		(配置服务n目录: 如 cfg)
							   |- mongod.conf (该配置服务下所有副本启动依赖的配置文件)
							   |- 副本n		(副本n目录: 如 rsn)
							      |- db		(副本n的数据存放目录)
								  |- configdb (副本n元数据存放目录)
							|- mongos		(mongos目录: 如 mongos)
							   |- mongod.conf (该mongos启动依赖的配置文件)
							   |- db		(数据存放目录)
							   |- configdb  (元数据存放目录)
    stack.yaml:	 		 由install.sh生成，docker 形式定义的安装mongo集群的文件，一般不需要修改
    cluster.sh:	 		 由install.sh生成，包含mongo集群初始化的所有脚本，需手动拷出来执行，一般不需要修改
	
注意：执行mongo的初始化脚本时，注意查看其命令相应返回的信息 "ok" : 1 表示命令正常执行

======================= 以下是需要手动操作部分 =====================================

安装mongo集群运行依赖的环境
1、进入脚本文件目录，执行: ./prepare.sh，确认依赖环境是否已经安装完成。

安装mongo集群步骤说明：
1、了解mongo.propertis文件中的信息，可使用默认配置不修改任何信息（多IP主机需要修改），配置项DATA_ROOT指定mongo集群安装目录，默认指定/data目录下
2、进入脚本文件目录，执行: ./install.sh，进行mongo集群的安装启动，第一次执行这个过程可能需要等待一段时间
3、进入mongo集群安装目录，分批次手动拷贝执行cluster.sh中的脚本。
4、访问web页面：http://ip:8081，确认集群正常配置
	