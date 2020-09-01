# install-app
各种应用部署安装方式汇总，如：纯手动执行说明脚本+半自动shell脚本+docker方式+k8s方式安装应用


# 各种软件源的配置参考
    
    http://mirrors.ustc.edu.cn/help/


**注意**：shell.tar.gz 默认解压缩放在/opt目录下，压缩包shell目录中包含了以下shell文件
  * centos7-alibaba-yum.sh 执行后更新 yum 源为阿里 yum 源
  * close_yum-cron.sh 关闭 CentOS 中 yum 自动更新软件功能
  * **log.sh** shell脚本 source 该文件后，可支持各种级别shell日志输出(日志带色彩)，大部分脚本中都有对该文件的引用
  * **purge-win-shell.sh** 执行 /opt/shell/purge-win-shell.sh filename 剔除从 windows 拷贝到 linux 的脚本文件换行符多余的 ^M 字符

# Linux 服务器同步时间命令

- *ntpdate*立即同步修改服务器时间，与阿里云服务器时间保持同步
```shell script
ntpdate ntp1.aliyun.com
```

- *ntp*平滑同步修改服务器时间
  
# Docker容器指定自定义网段的固定IP/静态IP地址
## 方案一
- 第一步：创建自定义网络

    备注：这里选取了172.172.0.0网段，也可以指定其他任意空闲的网段

        docker network create --subnet=172.172.0.0/16 docker-ice

    注：docker-ice为自定义网桥的名字，可自己任意取名。

- 第二步：在你自定义的网段选取任意IP地址作为你要启动的container的静态IP地址

    备注：这里在第二步中创建的网段中选取了172.172.0.10作为静态IP地址。这里以启动docker-ice为例。

        docker run -d --net docker-ice --ip 172.172.0.10 ubuntu:16.04

## 方案二

  备注1：这里是固定IP地址的一个应用场景的延续，仅作记录用。
  
  备注2：如果需要将指定IP地址的容器出去的请求的源地址改为宿主机上的其他可路由IP地址，可用iptables来实现。比如将静态
  
  **注意**：docker默认网段是 172.17.0.0/16
  
  IP地址 172.18.0.10出去的请求的源地址改成公网IP104.232.36.109(前提是本机存在这个IP地址)，可执行如下命令：

    iptables -t nat -I POSTROUTING -o eth0 -d  0.0.0.0/0 -s 172.18.0.10  -j SNAT --to-source 104.232.36.109
    
      