FROM openjdk:8
VOLUME ["/tmp","/logs","/root/logs","/heap_dump"]

COPY demo-arthas-spring-boot.jar /demo-arthas-spring-boot.jar

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 80

ENTRYPOINT [\
            "sh",\
            "-c",\
            "java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heap_dump \
            -Djava.security.egd=file:/dev/./urandom -Dserver.port=80 \
            -jar /demo-arthas-spring-boot.jar"\
            ]
