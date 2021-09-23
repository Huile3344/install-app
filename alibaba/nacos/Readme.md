# Nacos

- GitHub
  - [nacos](https://github.com/alibaba/nacos)
  - [nacos release版本](https://github.com/alibaba/nacos/releases)
  - [数据库初始化脚本](https://github.com/alibaba/nacos/blob/develop/distribution/conf/nacos-mysql.sql) 默认使用数据库名 nacos_config
  - [nacos-k8s](https://github.com/nacos-group/nacos-k8s)
- **[官方中文文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)**

**注意**: nacos 作为服务发现组件，只能发现相同命名空间，相同分组的服务

## 安装
### 创建 pv
- 修改 nacos 数据存储依赖的 pv 指定的 nfs 路径
```
$ kubectl apply -f nacos.pv.yml --record
```
### helm 方式安装
#### 自定义 helm 安装
- 创建 helm release
    ```
    $ helm -n dev install nacos ./helm
    ```
- 访问 nacos 的 web 页面: ``http://nacos.k8s.com`` ，
  **注意**: 账号密码都是 `nacos`

#### 官网 helm 安装
参考[Nacos Helm Chart](https://github.com/nacos-group/nacos-k8s/tree/master/helm)
坑点:
- 非内嵌的mysql方式 `nacos.storage.db.port` 和 `nacos.storage.db.password` 值不能是数字，否则部署出错

## 监控
### prometheus 监控 nacos
- 创建 servicemoinitor
    ```
    $ kubectl apply -f nacos-servicemonitor.yml --record
    ```
### 在 grafana 导入应用监控的 dashboard 
#### 操作步骤
- 选择+ -> Import -> 粘贴 `12856`
- 选择创建的 Prometheus 数据源, 即可导入,
- 查看数据库监控图形页面

# Windows 安装
## 下载对应版本的 nacos
## 修改 nacos 配置
- 使用 nacos mysql 脚本创建数据库和表
- 修改 nacos 使用的数据源 （默认是H2），改为 mysql
  - 修改 conf/application.properties 中指定的配置参数
    ```
    # 剃掉相关注释，并修改成类似如下配置
    spring.datasource.platform=mysql
    db.num=1
    db.url.0=jdbc:mysql://10.180.35.6:30006/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
    db.user.0=root
    db.password.0=123456
    ```
- 改为单机方式启动 nacos
  - 修改 bin/startup.cmd 中指定的 nacos 启动方式，
  - 将 set MODE="cluster" 集群方式改为单机方式 set MODE="standalone"
## 启动 nacos
- 双击运行启动脚本 bin/startup.cmd ，等待 nacos 启动完成
- 本地浏览器访问: `http://localhost:8848/nacos` ，使用账号/密码，`nacos/nacos` 登录