FROM openjdk:8u111-jre
MAINTAINER Yan<178312136@qq.com>
VOLUME ["/tmp","/logs","/locals/heap_dump"]
COPY target/locals-ota-zhenguo-provider.jar /locals-ota-zhenguo-provider.jar
COPY securityJar/local_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/local_policy.jar
COPY securityJar/US_export_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/US_export_policy.jar

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG ACTIVE
ENV ACTIVE $ACTIVE
ENTRYPOINT [\
            "sh",\
            "-c",\
            "java -Xms2048M -Xmx2048M -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/locals/heap_dump -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=$ACTIVE -jar /locals-ota-zhenguo-provider.jar"\
            ]
EXPOSE 8821

HEALTHCHECK --interval=10s --timeout=3s --start-period=5m --retries=3 \
  CMD curl -f http://localhost:8821/info || exit 1