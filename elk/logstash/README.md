# Logstash

logstash 安装使用说明

## Logstash配置文件

Logstash有两种类型的配置文件：管道配置文件，用于定义Logstash处理管道;以及设置文件，用于指定控制Logstash启动和执行的选项。

### 管道配置文件

在定义Logstash处理管道的各个阶段时，可以创建管道配置文件。在deb和rpm上，将管道配置文件放在/etc/logstash/conf.d目录中。在docker中，管道配置文件放在/usr/share/logstash/pipeline/目录中。 Logstash尝试仅加载目录中具有.conf扩展名的文件，并忽略所有其他文件。

### 服务配置文件

服务配置文件已在Logstash安装中定义。在docker中，配置文件放在/usr/share/logstash/config/目录中。Logstash包括以下设置文件

- logstash.yml

  包含Logstash配置标志。您可以在此文件中设置标志，而不是在命令行传递标志。您在命令行中设置的任何标志都会覆盖logstash.yml文件中的相应设置。有关详细信息，请参阅logstash.yml。

- pipelines.yml

  包含在单个Logstash实例中运行多个管道的框架和说明。有关详细信息，请参阅多个管道。

- jvm.options

  包含JVM配置标志。使用此文件设置总堆空间的初始值和最大值。您还可以使用此文件为Logstash设置区域设置。在单独的行上指定每个标志。此文件中的所有其他设置均被视为专家设置。

- log4j2.properties

  包含log4j 2库的默认设置。有关详细信息，请参阅Log4j2配置。
  
- startup.options（Linux）

  包含/ usr / share / logstash / bin中系统安装脚本使用的选项，以便为系统构建适当的启动脚本。安装Logstash软件包时，系统安装脚本将在安装过程结束时执行，并使用startup.options中指定的设置来设置用户，组，服务名称和服务描述等选项。默认情况下，Logstash服务安装在用户logstash下。 startup.options文件使您可以更轻松地安装Logstash服务的多个实例。您可以复制文件并更改特定设置的值。请注意，启动时不会读取startup.options文件。如果要更改Logstash启动脚本（例如，要更改Logstash用户或从其他配置路径读取），则必须重新运行系统安装脚本（以root用户身份）以传入新设置。

## tagz 方式安装测试使用

    wget https://artifacts.elastic.co/downloads/logstash/logstash-7.3.1.tar.gz
    tar -zxvf logstash-7.3.1

### 运行/测试logstash

    cd logstash-7.3.1
    bin/logstash -e 'input { stdin { } } output { stdout {} }'
    
### 其他说明

- 校验管道配置文件是否合法

      bin/logstash -f pipeline.conf --config.test_and_exit
      
  --config.test_and_exit选项会解析配置文件并报告任何错误。
  
  返回结果：
  
      [INFO ][logstash.runner          ] Using config.test_and_exit mode. Config Validation Result: OK. Exiting Logstash
  
- 自动配置重新加载

      bin/logstash -f pipeline.conf --config.reload.automatic
      
  --config.reload.automatic选项启用自动配置重新加载，这样就不必在每次修改配置文件时停止并重新启动Logstash。

## docker 方式

### 拉取镜像

- 推荐方式

      docker pull logstash:7.3.1
      
- 官网方式
      
      docker pull docker.elastic.co/logstash/logstash:7.3.1
    

###  环境变量配置说明

### 运行/测试logstash

  使用 test.conf 以命令行交互方式测试 logstash ，在命令行输入内容，服务会打印对应信息, 使用 CTRL+C 退出运行，并删除容器
  
    docker run --rm -it -e XPACK_MONITORING_ENABLED=false -v /opt/elk/config/pipeline/:/usr/share/logstash/pipeline/ logstash:7.3.1
  
  注意：其中 XPACK_MONITORING_ENABLED=false 表示不会启动elasticsearch的监听，不然服务时会一直尝试连接elasticsearch，导致服务无法使用

  命令行输入：hello
  
    hello
    {
          "@version" => "1",
           "message" => "hello",
        "@timestamp" => 2019-08-25T12:06:40.657Z,
              "host" => "96aa414b7756"
    }

### 其他说明

- 校验管道配置文件是否合法

      docker run --rm -it -e XPACK_MONITORING_ENABLED=false -v /opt/elk/config/pipeline/:/usr/share/logstash/pipeline/ logstash:7.3.1 --config.test_and_exit
      
  --config.test_and_exit选项会解析配置文件并报告任何错误。
  
- 自动配置重新加载

      docker run --rm -it -e XPACK_MONITORING_ENABLED=false -v /opt/elk/config/pipeline/:/usr/share/logstash/pipeline/ logstash:7.3.1 --config.reload.automatic
      
  --config.reload.automatic选项启用自动配置重新加载，这样就不必在每次修改配置文件时停止并重新启动Logstash。

