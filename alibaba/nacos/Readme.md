# Nacos

- GitHub
  - [nacos](https://github.com/alibaba/nacos)
  - [nacos release版本](https://github.com/alibaba/nacos/releases)
  - [数据库初始化脚本](https://github.com/alibaba/nacos/blob/develop/distribution/conf/nacos-mysql.sql)
  - [nacos-k8s](https://github.com/nacos-group/nacos-k8s)
- **[官方中文文档](https://nacos.io/zh-cn/docs/what-is-nacos.html)**

## 安装
### helm 方式安装
#### 自定义 helm 安装
- 创建 pv
    ```
    $ kubectl apply -f nacos.pv.yml --record
    ```
- 创建 servicemoinitor (prometheus 监控nacos)
    ```
    $ kubectl apply -f nacos-servicemonitor.yml --record
    ```
- 创建 helm release
    ```
    $ helm -n dev install nacos ./helm
    ```
- 访问 nacos 的 web 页面: ``http://play.k8s.com:30080/nacos``，
  **注意**: 账号密码都是 `nacos`

#### 官网 helm 安装
参考[Nacos Helm Chart](https://github.com/nacos-group/nacos-k8s/tree/master/helm)
坑点:
- 非内嵌的mysql方式 `nacos.storage.db.port` 和 `nacos.storage.db.password` 值不能是数字，否则部署出错