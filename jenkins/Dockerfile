FROM java:8
ADD /erp-product-0.0.1-SNAPSHOT.jar //
EXPOSE 9000
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/erp-product-0.0.1-SNAPSHOT.jar","--server.port=9000"]
