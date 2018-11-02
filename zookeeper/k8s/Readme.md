# 基于 k8s 的 zk 3节点集群部署

* 1、创建 zk 3节点数据存放目录

      mkdir -p /data/zookeeper/{data1,data2,data3}
      
* 2、启动 zk 集群

      kubectl apply -f zookeeper2.yaml
      或 kubectl apply -f zookeeper.yaml

* 3、查看集群各节点状态

      for i in 0 1 2; do kubectl exec zookeeper-$i zkServer.sh status; done

* 4、删除(关闭)集群
      
      kubectl delete -f zookeeper2.yaml

完全删除加上一下部分命令

    kubectl delete pvc datadir-zookeeper-0 datadir-zookeeper-1 datadir-zookeeper-2
    rm -rf {data1,data2,data3}/*

* 5、启动已有数据的集群

      kubectl apply -f zookeeper2.yaml