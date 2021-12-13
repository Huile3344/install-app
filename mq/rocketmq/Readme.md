# RabbitMQ

- [官网](https://rocketmq.apache.org/)
- [GitHub](https://github.com/apache/rocketmq)
- k8s [rocketmq-operator](https://github.com/apache/rocketmq-operator) 还不太成熟

## rocketmq-operator 方式搭建集群
### 部署 RocketMQ Operator
- Clone the project on your Kubernetes cluster master node:
  ```shell
  $ git clone https://github.com/apache/rocketmq-operator.git
  $ cd rocketmq-operator
  ```
- To deploy the RocketMQ Operator on your Kubernetes cluster, please run the following script:
  ```shell
  $ ./install-operator.sh
  ```
- Use command `kubectl get pods` to check the RocketMQ Operator deploy status like:
  ```shell
  $ kubectl get pods
  NAME                                      READY   STATUS    RESTARTS   AGE
  rocketmq-operator-564b5d75d-jllzk         1/1     Running   0          108s
  ```

### 部署 RocketMQ 集群
**注意**: rocketmq-operator 的 pod 要和 rocketmq cluster 的 pod 在同一命名空间下

拷贝 `hostnet` 文件夹到任意文件夹下，执行如下命令安装:
```shell
$ kubectl apply -R -f ./hostnet --record
```
等待安装完成，访问: `http://192.168.137.128:30000/` 查看集群安装情况

### 卸载 RocketMQ 集群
拷贝 `hostnet` 文件夹到任意文件夹下，执行如下命令安装:
```shell
$ kubectl delete -R -f ./hostnet
$ kubectl delete pvc broker-storage-broker-0-master-0 && kubectl delete pvc broker-storage-broker-0-replica-1-0 && kubectl delete pvc namesrv-storage-name-service-0
```

### 卸载 RocketMQ Operator
```shell
./purge-operator.sh
```