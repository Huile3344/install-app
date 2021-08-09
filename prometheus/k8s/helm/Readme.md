# kube-prometheus-stack 

- GitHub
  - [prometheus-community/helm-charts](https://github.com/prometheus-community/helm-charts)
  - [官网使用说明](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

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
