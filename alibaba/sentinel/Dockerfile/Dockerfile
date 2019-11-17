FROM openjdk:8u111-jre
VOLUME ["/tmp","/logs","/root/logs","/heap_dump"]
# 这个 sentinel-dashboard.jar 包含了额外的 nacos 部分代码，非官方的jar
COPY sentinel-dashboard.jar /sentinel-dashboard.jar

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Spring程序会按优先级从下面这些路径来加载application.properties配置文件
#
# 当前目录下的/config目录
# 当前目录
# classpath里的/config目录
# classpath 跟目录
# 因此，要外置配置文件就很简单了，在jar所在目录新建config文件夹，然后放入配置文件，或者直接放在配置文件在jar目录
#
# 自定义配置文件
# java -jar myproject.jar --spring.config.location=classpath:/default.properties,classpath:/override.properties
# 或
# java -jar -Dspring.config.location=D:\config\config.properties springbootrestdemo-0.0.1-SNAPSHOT.jar
#
# 指定 sentinel dashboard 使用的 nacos 服务地址配置
# sentinel.dashboard.nacos.config.server-addr=nacos
# 指定 sentinel dashboard 使用的 nacos 服务命名空间配置
# sentinel.dashboard.nacos.config.namespace=4c33f46c-fd59-4c27-b725-14c7af59fed8

ENTRYPOINT [\
            "sh",\
            "-c",\
            "java -Xms2048M -Xmx2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heap_dump \
            -Djava.security.egd=file:/dev/./urandom -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dproject.name=sentinel-dashboard \
            -jar /sentinel-dashboard.jar"\
            ]
EXPOSE 8080

# HEALTHCHECK --interval=10s --timeout=3s --start-period=5m --retries=3 CMD curl -f http://localhost:8080/info || exit 1