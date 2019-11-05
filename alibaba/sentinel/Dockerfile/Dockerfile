FROM openjdk:8u111-jre
VOLUME ["/tmp","/logs","/root/logs","/heap_dump"]
COPY sentinel-dashboard.jar /sentinel-dashboard.jar

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT [\
            "sh",\
            "-c",\
            "java -Xms2048M -Xmx2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/heap_dump \
            -Djava.security.egd=file:/dev/./urandom -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dproject.name=sentinel-dashboard \
            -jar /sentinel-dashboard.jar"\
            ]
EXPOSE 8080

# HEALTHCHECK --interval=10s --timeout=3s --start-period=5m --retries=3 CMD curl -f http://localhost:8080/info || exit 1