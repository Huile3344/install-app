# kube-prometheus-stack 

- GitHub
  - [prometheus-community/helm-charts](https://github.com/prometheus-community/helm-charts)
  - [官网使用说明](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
  - [prometheus-operator](https://prometheus-operator.dev/) 了解以下 CRD 规则
    * Prometheus
    * Alertmanager
    * ThanosRuler
    * ServiceMonitor
    * PodMonitor
    * Probe
    * PrometheusRule
    * AlertmanagerConfig


kube-prometheus-stack 是基于 kubernetes 学习 prometheus 的最好示例，可参考其使用和配置


## kube-prometheus-stack

安装 kube-prometheus stack、Kubernetes 清单、Grafana dashboards 和 Prometheus rules 的集合，并结合文档和脚本，使用 Prometheus Operator 提供易于操作的端到端 Kubernetes 集群监控。

有关组件、仪表板和警报的详细信息，请参阅 [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) README。

注意：以前名为 prometheus-operator chart，现在更名以更清楚地反映它安装了 kube-prometheus 项目堆栈，其中 Prometheus Operator 只是一个组件。  

### 前置条件

- Kubernetes 1.16+
- Helm 3+

### 获取仓库(Repo)信息
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 安装图表(Chart)
```
# Helm
$ helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack
```

### 依赖
默认情况下，此图表(chart)会安装其他相关图表(chart)：
- prometheus-community/kube-state-metrics
- prometheus-community/prometheus-node-exporter
- grafana/grafana 

### 卸载图表(Chart)
```
# Helm
$ helm uninstall [RELEASE_NAME]
```
这将删除与图表(chart)关联的所有 Kubernetes 组件并删除发布。

有关命令文档，请参阅 `helm uninstall`。

此图表(chart)创建的 CRD 默认不会删除，应手动清理：
```
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
```

### 更新图表(Chart)
```
# Helm
$ helm upgrade [RELEASE_NAME] prometheus-community/kube-prometheus-stack
```

## 前置配置修改
### 修改 etcd
默认 etcd 仅对 127.0.0.1 暴露 /metrics，因此需要修改
#### 修改 etcd.yaml
进入目录 /etc/kubernetes/manifests 修改 etcd.yaml 文件
```
# 先备份，再修改，且备份文件不需要换目录，否则备份文件也被执行
$ mkdir -pv /etc/kubernetes/manifests.bak
$ cp /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests.bak
$ vim /etc/kubernetes/manifests/etcd.yaml
```
- `--listen-metrics-urls=http://127.0.0.1:2381` 修改为 `--listen-metrics-urls=http://127.0.0.1:2381,http://<hostIp>:2381`
修改成功后，要等一会儿，k8s会自动重新部署这部分 pod (pod模式部署的)
#### 修改 helm values.yaml
找到 kubeEtcd 下的 service，并修改其 port 和 targetPort，否则需要使用https方式，还需要额外的证书配置
- `port: 2379` 修改为 `port: 2381`
- `targetPort: 2379` 修改为 `targetPort: 2381`

### 修改 kube-controller-manager
默认 kube-controller-manager 仅对 127.0.0.1 暴露 /metrics，因此需要修改
#### 修改 kube-controller-manager.yaml
进入目录 /etc/kubernetes/manifests 修改 kube-controller-manager.yaml 文件
```
# 先备份，再修改，且备份文件不需要换目录
$ mkdir -pv /etc/kubernetes/manifests.bak
$ cp /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/manifests.bak
$ vim /etc/kubernetes/manifests/kube-controller-manager.yaml
```
- `--bind-address=127.0.0.1` 修改为 `--bind-address=0.0.0.0`
- 注释掉 `--port=0`
修改成功后，要等一会儿，k8s会自动重新部署这部分 pod (pod模式部署的)

### 修改 kube-scheduler
默认 kube-scheduler 仅对 127.0.0.1 暴露 /metrics，因此需要修改
#### 修改 kube-scheduler.yaml
进入目录 /etc/kubernetes/manifests 修改 kube-scheduler.yaml 文件
```
# 先备份，再修改，且备份文件不需要换目录 
$ mkdir -pv /etc/kubernetes/manifests.bak
$ cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/manifests.bak
$ vim /etc/kubernetes/manifests/kube-scheduler.yaml
```
- `--bind-address=127.0.0.1` 修改为 `--bind-address=0.0.0.0`
- 注释掉 `--port=0`
修改成功后，要等一会儿，k8s会自动重新部署这部分 pod (pod模式部署的)

### 修改 kube-proxy
默认 kube-proxy 仅对 127.0.0.1 暴露 /metrics，因此需要修改
#### 修改 kube-proxy 使用的 ConfigMap
```
$ kubectl -n kube-system edit cm kube-proxy
```
- `metricsBindAddress: "127.0.0.1:10249"` 修改为 `metricsBindAddress: "0.0.0.0:10249"`
  
#### 重启 pod
由于 kube-proxy pod 是被 kube-system 命名空间下的 kube-proxy 这个 daemonset 管理的，可直接删除，让其重启即可
```
$ kubectl -n kube-system delete pod kube-proxy-xxx
```

### 使用 ingress
#### grafana 部分的 values
- `grafana.adminPassword` `prom-operator` 改为 `admin`
- `grafana.ingress.enabled` `false` 改为 `true`
- `grafana.ingress.hosts` `[]` 改为 `["play.k8s.com"]`
- 添加 `grafana.ingress.pathType` 值为 `Prefix`
- 添加 `grafana.service.ClusterIP` 值为 `None`

存在问题的修改
- `grafana.ingress.path` `/` 改为 `/grafana`
- `grafana.env` 添加 `GF_SERVER_ROOT_URL: "%(protocol)s://%(domain)s:%(http_port)s/grafana/"`，与 `grafana.ingress.path` 对应

#### prometheus 部分的 values
- `prometheus.ingress.enabled` `false` 改为 `true`
- `prometheus.ingress.hosts` `[]` 改为 `["play.k8s.com"]`
- `prometheus.ingress.paths` `[]` 改为 `["/prometheus"]`
- 添加 `grafana.ingress.pathType` 值为 `Prefix`
- 添加 `prometheus.service.ClusterIP` 值为 `None`
- `prometheus.prometheusSpec.routePrefix` `/` 改为 `/prometheus`， 与 `prometheus.ingress.paths`对应

#### alertmanager 部分的 values
- `alertmanager.ingress.enabled` `false` 改为 `true`
- `alertmanager.ingress.hosts` `[]` 改为 `["play.k8s.com"]`
- `alertmanager.ingress.paths` `[]` 改为 `["/alertmanager"]`
- 添加 `alertmanager.ingress.pathType` 值为 `Prefix`
- 添加 `alertmanager.service.ClusterIP` 值为 `None`
- `alertmanager.alertmanagerSpec.routePrefix` `/` 改为 `/alertmanager`， 与 `alertmanager.ingress.paths`对应

### 使用 pvc
#### grafana 部分的 values
- `grafana` 添加 `persistence` 执行 pvc
  ```
  persistence:
    type: pvc
    enabled: true
    storageClassName: grafana
    accessModes:
      - ReadWriteOnce
    size: 2Gi
    selectorLabels:
      name: grafana-data-pv
      release: stable
  ```
- 配置目录权限 `grafana` 添加 `securityContext`，如果pv是nfs目录，将目录权限设置为 777
   ```
   securityContext:
     runAsGroup: 1000
     runAsNonRoot: true
     runAsUser: 1000
     fsGroup: 1000
   ```

#### prometheus 部分的 values
- `prometheus.prometheusSpec` 添加 `storageSpec` 执行 pvc
  ```
  storageSpec:
    volumeClaimTemplate:
      spec:
        storageClassName: prometheus
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 2Gi
        selector:
          matchLabels:
            name: prometheus-data-pv
            release: stable
  ```
- 配置目录权限，`prometheusOperator.admissionWebhooks.patch` 添加 `securityContext`， 如果pv是nfs目录，将目录权限设置为 777
   ```
   securityContext:
     runAsGroup: 1000
     runAsNonRoot: true
     runAsUser: 1000
     fsGroup: 1000
   ```

## helm 安装 kube-prometheus-stack
### 安装 Release kube-prometheus-stack
执行如下命令安装(values-v4.yaml 是对应上面内容修改后的 values.yaml):
```
$ helm -n monitoring install kube-prometheus-stack -f values-v4.yaml prometheus-community/kube-prometheus-stack --version 17.2.1
```

### 查看当前 kube-prometheus-stack 的 prometheus 配置信息
- 安装命令行 json 处理器 jq
    ```
    $ yum install -y jq.x86_64
    ```
- 导出当前 prometheus 配置信息
    ```
    $ kubectl -n monitoring get secret prometheus-kube-prometheus-stack-prometheus -ojson | jq -r '.data["prometheus.yaml.gz"]' | base64 -d | gunzip > prometheus.yml
    ```
- 分析查看配置信息，核对自定义的 ServiceMoinitor 规则是否生效和添加

## 监控 ingress
### 开放 ingress 监控端口
- 查询其健康检查的端口
    ```
    $ kubectl -n ingress-nginx describe pod ingress-nginx-controller-xxx
    
    # 获取到类似如下内容，表示其对外暴露的监控接口是 10254， 其监控url是 /metrics，更详细内容可去官网查看
        Liveness:   http-get http://:10254/healthz delay=10s timeout=1s period=10s #success=1 #failure=5
        Readiness:  http-get http://:10254/healthz delay=10s timeout=1s period=10s #success=1 #failure=3
    ```
- 修改 svc 或再添加一个 svc ，暴露监控端口
**注意**: ServiceMonitor 期望使用 Service 上定义的端口名称，若使用不正确的示例（仅端口号） 则 ServiceMonitor 会出现错误提示: `spec.endpoints.port in body must be of type string: "integer"`  
    ```
    $ kubectl -n ingress-nginx edit svc ingress-nginx-controller
    # 在 ports: 下添加如下内容
      - name: http-metrics
        nodePort: 30254
        port: 10254
    ```
- 调用监控接口
    ```
    $ curl http://<svcIp>:30254/metrics
    # 可获取到指标信息
    ```

### 新增监控 ingress svc 的 ServiceMoinitor
- ServiceMoinitor 需要创建在满足 Prometheus 这个 CRD 指定的条件以下条件下，否则不会被监控（其他CRD类似）：
 * serviceAccountName
 * serviceMonitorNamespaceSelector
 * serviceMonitorSelector
   ```
     # 指定的 sa ，若是跨命名空间，需要创建对应命名空间下的 sa
     serviceAccountName: kube-prometheus-stack-prometheus
     # 全部命名空间
     serviceMonitorNamespaceSelector: {}
     serviceMonitorSelector:
       matchLabels:
         # 对应 helm 的 release_name
         release: kube-prometheus-stack
   ```
- ingress 的 servicemoinitor 文件 `ingress-servicemonitor.yml` 内容类似如下
    ```
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
      labels:
        app: ingress-nginx
        # 需要与 prometheuses.monitoring.coreos.com 中的 serviceMonitorSelector 对应，否则 prometheus 不会抓取这个 ServiceMonitor
        release: kube-prometheus-stack
      name: ingress-nginx-metrics
      namespace: monitoring
    spec:
      endpoints:
      - port: http-metrics
      namespaceSelector:
        matchNames:
        - ingress-nginx
      selector:
        matchLabels:
          app.kubernetes.io/instance: ingress-nginx
          app.kubernetes.io/name: ingress-nginx
    ```
- 创建 servicemoinitor
    ```
    $ kubectl apply -f ingress-nginx-sm.yml --record
    ```
### 查看监控情况
- 查看 Prometheus 的 targets 和 configuration 确认已经配置和监控已经生效
- 在 grafana 导入 nginx ingress 的 dashboard 如： `9614` 或 `10187`

## helm 卸载 kube-prometheus-stack
执行如下命令卸载 Release
```
$ helm -n monitoring uninstall kube-prometheus-stack 
```
删除多余的 pvc
```
$ kubectl -n monitoring delete pvc prometheus-kube-prometheus-stack-prometheus-db-prometheus-kube-prometheus-stack-prometheus-0
```
