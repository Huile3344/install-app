docker run -e PARAMS="--spring.datasource.url=jdbc:mysql://192.168.0.6:3306/xxl_job?Unicode=true&characterEncoding=UTF-8 --spring.datasource.password=123456  --server.context-path=/" \
-p 8090:8080 -v /opt/xxl-job-admin/logs:/data/applogs \
--name xxl-job-admin  -d xuxueli/xxl-job-admin:2.1.0
