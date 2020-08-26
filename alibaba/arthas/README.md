# arthas 安装使用

## 安装

### 下载 arthas
```shell script
$ curl -O https://arthas.aliyun.com/arthas-boot.jar
```

   - 如果下载速度比较慢，可以使用aliyun的镜像
   
    $ java -jar arthas-boot.jar --repo-mirror aliyun --use-http

### 查看 arthas 帮助信息
```shell script
$ java -jar arthas-boot.jar -h
``` 

### 运行 arthas
```shell script
$ java -jar arthas-boot.jar
```

### 其他安装方式

- 使用as.sh

  Arthas 支持在 Linux/Unix/Mac 等平台上一键安装，请复制以下内容，并粘贴到命令行中，敲 回车 执行即可：

      curl -L https://arthas.aliyun.com/install.sh | sh
  执行 ./as.sh
  
- 通过rpm/deb来安装

  - 安装deb
  
        sudo dpkg -i arthas*.deb
    
  -  安装rpm
  
        sudo rpm -i arthas*.rpm
        
  - deb/rpm 安装后，可以直接执行
    
        as.sh

## arthas 使用案例

### 热更新代码

- 1 在arthas控制台中，使用jad获取class的源码

    **--source-only** 参数用于剔除非java代码的内容
    ```
    $ jad --source-only com.example.demo.arthas.user.UserController > /tmp/UserController.java
    ```

- 2 在外部终端编辑 /tmp/UserController.java 源码文件

- 3 sc查找加载UserController的ClassLoader

    ```
    $ sc -d *UserController | grep classLoaderHash
    classLoaderHash   1be6f5c3
    ```

- 4 mc(Memory Compiler)命令编译

    使用如下命令指定编译器编译类
    ```
    $ mc -c <classLoaderHash> /tmp/UserController.java -d /tmp
    ```
    
    完整编译命令，及执行结果如下如下
    ```shell script
    $ mc -c 1be6f5c3 /tmp/UserController.java -d /tmp
    Memory compiler output:
    /tmp/com/example/demo/arthas/user/UserController.class
    Affect(row-cnt:1) cost in 346 ms
    ```

- 5 redefine 命令重新加载类

    再使用redefine命令重新加载新编译好的UserController.class：
    ```shell script
    $ redefine /tmp/com/example/demo/arthas/user/UserController.class
    redefine success, size: 1
    ```


### 动态更新应用Logger Level

- 1 查找UserController的ClassLoader

    ```shell script
    $ sc -d *UserController | grep classLoaderHash
    classLoaderHash   1be6f5c3
    ```

- 2 用ognl获取UserController的日志对象logger或log

    ```shell script
    $ ognl -c 1be6f5c3 @com.example.demo.arthas.user.UserController@logger
    @Logger[
        serialVersionUID=@Long[5454405123156820674],
        FQCN=@String[ch.qos.logback.classic.Logger],
        name=@String[com.example.demo.arthas.user.UserController],
        level=null,
        effectiveLevelInt=@Integer[20000],
        parent=@Logger[Logger[com.example.demo.arthas.user]],
        childrenList=null,
        aai=null,
        additive=@Boolean[true],
        loggerContext=@LoggerContext[ch.qos.logback.classic.LoggerContext[default]],
    ]
    ```
    可以知道UserController@logger实际使用的是logback。可以看到level=null，则说明实际最终的level是从root logger里来的。
    
- 3 用ognl查看logback的全局logger level

    ```shell script
    $ ognl -c 1be6f5c3 '@org.slf4j.LoggerFactory@getLogger("root")'
    @Logger[
        serialVersionUID=@Long[5454405123156820674],
        FQCN=@String[ch.qos.logback.classic.Logger],
        name=@String[ROOT],
        level=@Level[INFO],
        effectiveLevelInt=@Integer[20000],
        parent=null,
        childrenList=@CopyOnWriteArrayList[isEmpty=false;size=5],
        aai=@AppenderAttachableImpl[ch.qos.logback.core.spi.AppenderAttachableImpl@403af1b],
        additive=@Boolean[true],
        loggerContext=@LoggerContext[ch.qos.logback.classic.LoggerContext[default]],
    ]
    ```
    可以知道logback的全局logger level是INFO。

- 4 修改logback的全局logger level

    通过获取root logger，可以修改全局的logger level：
    ```shell script
    $ ognl -c 1be6f5c3 '@org.slf4j.LoggerFactory@getLogger("root").setLevel(@ch.qos.logback.classic.Level@DEBUG)'
    ```

- 5 单独设置UserController的logger level
    ```shell script
    $ ognl -c 18b4aac2 '@com.example.demo.arthas.user.UserController@logger.setLevel(@ch.qos.logback.classic.Level@DEBUG)'
    ```
    再次获取UserController@logger，可以发现已经是DEBUG了：
    ```shell script
    $ ognl -c 1be6f5c3 @com.example.demo.arthas.user.UserController@logger
    @Logger[
        serialVersionUID=@Long[5454405123156820674],
        FQCN=@String[ch.qos.logback.classic.Logger],
        name=@String[com.example.demo.arthas.user.UserController],
        level=@Level[DEBUG],
        effectiveLevelInt=@Integer[20000],
        parent=@Logger[Logger[com.example.demo.arthas.user]],
        childrenList=null,
        aai=null,
        additive=@Boolean[true],
        loggerContext=@LoggerContext[ch.qos.logback.classic.LoggerContext[default]],
    ]
    ```

## 容器镜像使用 arthas 

    docker pull hengyunabc/arthas
    docker run --name arthas-demo -it hengyunabc/arthas /bin/sh -c "java -jar /opt/arthas/arthas-demo.jar"
    docker exec -it arthas-demo /bin/sh -c "java -jar /opt/arthas/arthas-boot.jar"

### 常见问题

#### com.sun.tools.attach.AttachNotSupportedException: Unable to get pid of LinuxThreads manager thread

**参考**: *[k8s 集群容器中集成arthas、netstat即时诊断分析工具](https://blog.51cto.com/daisywei/2427434)*

**原因**: Dokcerfile 中需要的openjdk，如果是jre的，会缺少dt.jar,tools.jar arthas工具会使用到；
否则需要安装tini工具，因为默认java 应用跑在容器中会是1 pid号，arthas会无法调用

