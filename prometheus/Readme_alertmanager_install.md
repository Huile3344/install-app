# alertmanger 安装部署配置

- GitHub
  - [prometheus](https://github.com/prometheus/prometheus)
  - **[example](https://github.com/prometheus/prometheus/tree/main/documentation/examples)**
- **[官网](https://prometheus.io/)**

## [下载](https://prometheus.io/download/)
按需下载相应的版本，以 `0.24.0` 为例
```shell
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
```

## [安装 & 运行](https://prometheus.io/docs/alerting/latest/configuration/)
### 解压缩
```shell
tar xvfz alertmanager-*.tar.gz
cd alertmanager-*
```
### 修改配置文件 alertmanager.yml
完整配置选项可查看 [configuration documentation](https://prometheus.io/docs/alerting/latest/configuration/)
```shell
global:
  # The default SMTP From header field.
  [ smtp_from: <tmpl_string> ]
  # The default SMTP smarthost used for sending emails, including port number.
  # Port number usually is 25, or 587 for SMTP over TLS (sometimes referred to as STARTTLS).
  # Example: smtp.example.org:587
  [ smtp_smarthost: <string> ]
  # The default hostname to identify to the SMTP server.
  [ smtp_hello: <string> | default = "localhost" ]
  # SMTP Auth using CRAM-MD5, LOGIN and PLAIN. If empty, Alertmanager doesn't authenticate to the SMTP server.
  [ smtp_auth_username: <string> ]
  # SMTP Auth using LOGIN and PLAIN.
  [ smtp_auth_password: <secret> ]
  # SMTP Auth using PLAIN.
  [ smtp_auth_identity: <string> ]
  # SMTP Auth using CRAM-MD5.
  [ smtp_auth_secret: <secret> ]
  # The default SMTP TLS requirement.
  # Note that Go does not support unencrypted connections to remote SMTP endpoints.
  [ smtp_require_tls: <bool> | default = true ]

  # The API URL to use for Slack notifications.
  [ slack_api_url: <secret> ]
  [ slack_api_url_file: <filepath> ]
  [ victorops_api_key: <secret> ]
  [ victorops_api_url: <string> | default = "https://alert.victorops.com/integrations/generic/20131114/alert/" ]
  [ pagerduty_url: <string> | default = "https://events.pagerduty.com/v2/enqueue" ]
  [ opsgenie_api_key: <secret> ]
  [ opsgenie_api_key_file: <filepath> ]
  [ opsgenie_api_url: <string> | default = "https://api.opsgenie.com/" ]
  [ wechat_api_url: <string> | default = "https://qyapi.weixin.qq.com/cgi-bin/" ]
  [ wechat_api_secret: <secret> ]
  [ wechat_api_corp_id: <string> ]
  [ telegram_api_url: <string> | default = "https://api.telegram.org" ]
  # The default HTTP client configuration
  [ http_config: <http_config> ]

  # ResolveTimeout is the default value used by alertmanager if the alert does
  # not include EndsAt, after this time passes it can declare the alert as resolved if it has not been updated.
  # This has no impact on alerts from Prometheus, as they always include EndsAt.
  [ resolve_timeout: <duration> | default = 5m ]

# Files from which custom notification template definitions are read.
# The last component may use a wildcard matcher, e.g. 'templates/*.tmpl'.
templates:
  [ - <filepath> ... ]

# The root node of the routing tree.
route: <route>

# A list of notification receivers.
receivers:
  - <receiver> ...

# A list of inhibition rules.
inhibit_rules:
  [ - <inhibit_rule> ... ]

# DEPRECATED: use time_intervals below.
# A list of mute time intervals for muting routes.
mute_time_intervals:
  [ - <mute_time_interval> ... ]

# A list of time intervals for muting/activating routes.
time_intervals:
  [ - <time_interval> ... ]
```

### 启动 alertmanager
```shell
# Start alertmanager.
./alertmanager --config.file=alertmanager.yml
```
### 浏览器查看 alertmanager
访问: [http://localhost:9093](http://localhost:9093)

## alertmanager 优化项
### alertmanager 启动项
- --config.file: 指定使用的 alertmanager.yml
- --storage.path: 存储的基本路径，默认: "data/"
- --web.external-url: 指定完整url。针对需要使用nginx做反向代理时会用到
- --web.listen-address: 监听端口，默认值：":9093"
- --cluster.listen-address: 集群监听端口，默认值："0.0.0.0:9094"
- --cluster.advertise-address
- --cluster.peer

启动后web方式的 `/-/reload` 可在运行时重新加载配置文件（`SIGHUP` 方式重新加载配置文件也可用）

常用脚本示例：
```shell
nohup /usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml --storage.path=/data/alertmanager/data/ --web.external-url=http://localhost:9093/alertmanager > /dev/null 2>&1 &
```
### alertmanager 杀死进程
```shell
kill `ps -ef|grep alertmanager|grep -v grep|awk '{print $2}'`
```
### alertmanager 重新加载配置文件
```shell
kill -s SIGHUP `ps -ef|grep alertmanager|grep -v grep|awk '{print $2}'`
```
### 建立软连接
```shell
ln -s /usr/local/alertmanager/alertmanager /usr/sbin/alertmanager
ln -s /usr/local/alertmanager/amtool /usr/sbin/amtool

```
### amtool 工具
使用 amtool 检查 alertmanager.yml 语法是否正常
```shell
./amtool check-config /usr/local/alertmanager/alertmanager.yml
```
