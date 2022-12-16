# prometheus 安装部署配置

- GitHub
  - [prometheus](https://github.com/prometheus/prometheus)
  - **[example](https://github.com/prometheus/prometheus/tree/main/documentation/examples)**
- **[官网](https://prometheus.io/)**

## 基于k8s的服务发现机制配置 kubernetes_sd_config
- **[官方文档 kubernetes_sd_config 配置](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config)**
- **[Prometheus之kubernetes_sd_config](https://www.orchome.com/9884)** 可认为是对应官方文档的翻译
- [官方示例: prometheus-kubernetes](https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus-kubernetes.yml)

## [下载](https://prometheus.io/download/)
按需下载相应的版本，以 `2.35.0` 为例
```shell
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
```

## [安装 & 运行](https://prometheus.io/docs/prometheus/latest/installation/)
### 解压缩
```shell
tar xvfz prometheus-*.tar.gz
cd prometheus-*
```
### 修改配置文件 prometheus.yml
完整配置选项可查看 [configuration documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
```shell
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
```

### 启动 prometheus
```shell
# Start Prometheus.
# By default, Prometheus stores its database in ./data (flag --storage.tsdb.path).
./prometheus --config.file=prometheus.yml
```
### 浏览器查看 prometheus
访问: [http://localhost:9090](http://localhost:9090)

## prometheus 优化项
### prometheus 启动项
- --config.file: 指定使用的 prometheus.yml
- --web.listen-address: 监听端口，默认值："0.0.0.0:9090"
- --web.read-timeout: 空闲连接的超时时间
- --web.max-connections: 最大连接数
- --web.external-url: 指定访问上下文，或者完整url。针对需要使用nginx做反向代理时会用到
- --web.enable-lifecycle: 是否启动 prometheus 生命周期，启动后web方式的 `/-/reload` 和 `/-/quit` 便可用，可在运行时重新加载配置文件（`SIGHUP` 方式重新加载配置文件也可用），优雅关闭 prometheus
- --storage.tsdb.path: 指标(数据）存储的基本路径，默认: "data/"
- --storage.tsdb.retention.time: 将数据保留多长时间。默认15天
- --web.console.templates: 模板目录的路径

常用脚本示例：
```shell
nohup /usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/data/prometheus/data --web.external-url=http://localhost:9090/prometheus --web.enable-admin-api --web.enable-lifecycle > /dev/null 2>&1 &
```
### prometheus 杀死进程
```shell
kill `ps -ef|grep prometheus|grep -v grep|awk '{print $2}'`
```
### prometheus 重新加载配置文件
```shell
kill -s SIGHUP `ps -ef|grep prometheus|grep -v grep|awk '{print $2}'`
```
### 建立软连接
```shell
ln -s /usr/local/prometheus/prometheus /usr/sbin/prometheus
ln -s /usr/local/prometheus/promtool /usr/sbin/promtool
```
### promtool 工具
使用 promtool 检查 prometheus.yml 语法是否正常
```shell
./promtool check config /usr/local/prometheus/prometheus.yml
```
