# Activiti

- GitHub
  - [Activiti](https://github.com/Activiti/Activiti)
  - [activiti-cloud-full-chart](https://github.com/Activiti/activiti-cloud-full-chart)
- [Activiti官网](https://www.activiti.org/)



## k8s helm 安装 

参考官网: [**Getting Started - Activiti Cloud**](https://activiti.gitbook.io/activiti-7-developers-guide/getting-started/getting-started-activiti-cloud)



### 逐步部署

### 注册 Activiti Cloud HELM 图表到 HELM

执行以下命令，注册 Activiti Cloud HELM 图表到 HELM

```shell
helm repo add activiti-cloud-helm-charts https://activiti.github.io/activiti-cloud-helm-charts/
helm repo update
```



#### 创建命名空间 `activiti7`

```
kubectl create ns activiti7
```



#### 安装 Activiti Cloud

##### 官方 helm 方式部署图表
```
helm --namespace activiti7 install activiti-cloud-full-example activiti-cloud-helm-charts/activiti-cloud-full-example --set global.gateway.domain=REPLACEME --set global.keycloak.clientSecret=`uuidgen`
```
替换`REPLACEME`为真实域名

如本地k8s暴露的域名或ip，如我使用

```
global.gateway.domain=192.168.0.6
```



### 一键部署 Activiti Cloud

执行以下命令。这个命令是幂等的；若 release `activiti-cloud-helm-charts` 不存在，将会 install ；若已存在，则 upgrade；若 `activiti7` 命名空间不存在，将会创建；但是不会添加仓库 `activiti-cloud-helm-charts`

```shell
helm upgrade --install activiti-cloud-full-example activiti-cloud-full-example \
  --repo https://activiti.github.io/activiti-cloud-helm-charts/ \
  --namespace activiti7 --create-namespace \
  --set global.gateway.domain=REPLACEME --set global.keycloak.clientSecret=`uuidgen`
```

替换`REPLACEME`为真实域名

如本地k8s暴露的域名或ip，如我使用

```
global.gateway.domain=192.168.0.6
```



### 卸载 Activiti Cloud

```
helm -n activiti7 uninstall activiti-cloud-full-example
```



### 访问 modeling

BPMN 2 modelling 应用. 默认用户: modeler/password.

访问 modeling 的 web 演练页面: *http://192.168.0.6/modeling*



### 测试部署的服务

使用postman方式测试部署的服务

使用以下命令从 Activiti Cloud 示例存储库下载 Activiti Cloud Postman 集合：

```shell
curl -o Activiti_v7_REST_API.postman_collection.json https://raw.githubusercontent.com/Activiti/activiti-cloud-examples/develop/Activiti%20v7%20REST%20API.postman_collection.json
```

使用 Import 按钮在 Postman 中导入集合。

然后“Add”一个新环境并为其添加名称。 需要为环境配置变量：“gateway”、“idm”和“realm”
对于网关，需要复制与 Ingress 关联的 url，idm 也是如此，即 SSO 和使用 Keycloak 的 IDM。 对于realm，输入“activiti”。

如果转到 keycloak 目录并选择“getKeycloakToken testuser”，将获得用于验证进一步请求的令牌。 请注意，此令牌是时间敏感的，它将自动失效，因此如果开始收到未经授权的错误，可能需要再次获取它。
获得用户的令牌后，可以与所有用户端点进行交互。 例如，可以创建一个请求以查看在示例运行时包中部署了哪些流程定义。

现在已准备好开始使用这些服务来自动化自己的业务流程。
最后，可以通过将浏览器指向以下位置来访问所有服务 Swagger 文档：

- [http://activiti-cloud-gateway.EXTERNAL-IP.nip.io/rb-my-app/swagger-ui.html](http://activiti-cloud-gateway.external-ip.nip.io/rb-my-app/swagger-ui.html)
- [http://activiti-cloud-gateway.EXTERNAL-IP.nip.io/audit/swagger-ui.html](http://activiti-cloud-gateway.external-ip.nip.io/audit/swagger-ui.html)
- [http://activiti-cloud-gateway.EXTERNAL-IP.nip.io/query/swagger-ui.html](http://activiti-cloud-gateway.external-ip.nip.io/query/swagger-ui.html)