# grafana 安装部署配置

- GitHub
  - [grafana](https://github.com/grafana/grafana)
- **[官网](https://grafana.com//)**
 - [dashboards](https://grafana.com/grafana/dashboards)


## [下载](https://grafana.com/grafana/download)
按需下载相应的版本，以 `2.35.0` 为例
```shell
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-8.5.3.linux-amd64.tar.gz
```

## [安装 & 运行](https://prometheus.io/docs/prometheus/latest/installation/)
### 解压缩并迁移路径
```shell
tar xvfz grafana-enterprise-*.tar.gz
mv grafana-* /usr/local/grafana
cd /usr/local/grafana
```
### 修改配置文件 defaults.ini
进入 conf 目录，修改 defaults.ini 文件以下内容类似如下
```shell
#################################### Paths ###############################
[paths]
# Path to where grafana can store temp files, sessions, and the sqlite3 db (if that is used)
data = /data/grafana/data

# Temporary files in `data` directory older than given duration will be removed
temp_data_lifetime = 24h

# Directory where grafana can store logs
logs = /data/grafana/data/log

# Directory where grafana will automatically scan and look for plugins
plugins = /data/grafana/data/plugins

#################################### Server ##############################
# 需要使用 nginx 反向代理时，把以下内容修改成类似如下示例
# The full public facing url
root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana

# Serve Grafana from subpath specified in `root_url` setting. By default it is set to `false` for compatibility reasons.
serve_from_sub_path = true
```

### 启动 grafana-server
```shell
./grafana-server -homepath /usr/local/grafana
```
### 浏览器查看 grafana
访问: [http://grafana:3000](http://localhost:3000)

## grafana 优化项
### grafana 启动项
常用脚本示例：
```shell
nohup /usr/local/grafana/bin/grafana-server -homepath /usr/local/grafana> /dev/null 2>&1 &
```
### grafana 杀死进程
```shell
kill `ps -ef|grep grafana-server|grep -v grep|awk '{print $2}'`
```
### 建立软连接
```shell
ln -s /usr/local/grafana/bin/grafana-server /usr/sbin/grafana-server
ln -s /usr/local/grafana/bin/grafana-cli /usr/sbin/grafana-cli
```
### grafana-cli 工具
使用 grafana-cli 安装插件

