FROM openjdk:8u111-jre
VOLUME ["/tmp","/logs","/root/logs","/heap_dump"]
COPY spring-security-demo-simple.jar /spring-security-demo-simple.jar

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


ENTRYPOINT [\
            "sh",\
            "-c",\
            "java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heap_dump \
            -Djava.security.egd=file:/dev/./urandom -Dserver.port=80 -Dproject.name=spring-security-demo-simple \
            -jar /spring-security-demo-simple.jar"\
            ]
EXPOSE 80

# HEALTHCHECK --interval=10s --timeout=3s --start-period=5m --retries=3 CMD curl -f http://localhost:80/health || exit 1
