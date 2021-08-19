# keepalived 

## 介绍
Keepalived软件起初是专为LVS负载均衡软件设计的，用来管理并监控LVS集群系统中各个服务节点的状态，后来又加入了可以实现高可用的VRRP功能。因此，Keepalived除了能够管理LVS软件外，还可以作为其他服务（例如：Nginx、Haproxy、MySQL等）的高可用解决方案软件。

Keepalived软件主要是通过VRRP协议实现高可用功能的。VRRP是Virtual Router Redundancy Protocol（虚拟路由器冗余协议）的缩写，VRRP出现的目的就是为了解决静态路由单点故障问题的，它能够保证当个别节点宕机时，整个网络可以不间断地运行。所以，Keepalived一方面具有配置管理LVS的功能，同时还具有对LVS下面节点进行健康检查的功能，另一方面也可实现系统网络服务的高可用功能。

## Keepalived服务的重要功能

### 管理LVS负载均衡软件
早期的LVS软件，需要通过命令行或脚本实现管理，并且没有针对LVS节点的健康检查功能。为了解决LVS的这些使用不便的问题，Keepalived就诞生了，可以说，Keepalived软件起初是专为解决LVS的问题而诞生的。因此，Keepalived和LVS的感情很深，它们的关系如同夫妻一样，可以紧密地结合，愉快地工作。Keepalived可以通过读取自身的配置文件，实现通过更底层的接口直接管理LVS的配置以及控制服务的启动、停止等功能，这使得LVS的应用更加简单方便了。

### 实现对LVS集群节点健康检查功能（healthcheck）
Keepalived可以通过在自身的keepalived.conf文件里配置LVS的节点IP和相关参数实现对LVS的直接管理；除此之外，当LVS集群中的某一个甚至是几个节点服务器同时发生故障无法提供服务时，Keepalived服务会自动将失效的节点服务器从LVS的正常转发队列中清除出去，并将请求调度到别的正常节点服务器上，从而保证最终用户的访问不受影响；当故障的节点服务器被修复以后，Keepalived服务又会自动地把它们加入到正常转发队列中，对客户提供服务。

### 作为系统网络服务的高可用功能（failover）
Keepalived可以实现任意两台主机之间，例如Master和Backup主机之间的故障转移和自动切换，这个主机可以是普通的不能停机的业务服务器，也可以是LVS负载均衡、Nginx反向代理这样的服务器。

Keepalived高可用功能实现的简单原理为，两台主机同时安装好Keepalived软件并启动服务，开始正常工作时，由角色为Master的主机获得所有资源并对用户提供服务，角色为Backup的主机作为Master主机的热备；当角色为Master的主机失效或出现故障时，角色为Backup的主机将自动接管Master主机的所有工作，包括接管VIP资源及相应资源服务；而当角色为Master的主机故障修复后，又会自动接管回它原来处理的工作，角色为Backup的主机则同时释放Master主机失效时它接管的工作，此时，两台主机将恢复到最初启动时各自的原始角色及工作状态。

## Keepalived高可用故障切换转移原理
Keepalived高可用服务对之间的故障切换转移，是通过VRRP（Virtual Router Redundancy Protocol，虚拟路由器冗余协议）来实现的。

在Keepalived服务正常工作时，主Master节点会不断地向备节点发送（多播的方式）心跳消息，用以告诉备Backup节点自己还活着，当主Master节点发生故障时，就无法发送心跳消息，备节点也就因此无法继续检测到来自主Master节点的心跳了，于是调用自身的接管程序，接管主Master节点的IP资源及服务。而当主Master节点恢复时，备Backup节点又会释放主节点故障时自身接管的IP资源及服务，恢复到原来的备用角色。

 

## keepalived的工作原理
### Keepalived高可用对之间是通过VRRP通信的
- VRRP，全称Virtual Router Redundancy Protocol，中文名为虚拟路由冗余协议，VRRP的出现是为了解决静态路由的单点故障。

- VRRP是通过一种竞选协议机制来将路由任务交给某台VRRP路由器的。

- VRRP用IP多播的方式（默认多播地址（224.0.0.18））实现高可用对之间通信。

- 工作时主节点发包，备节点接包，当备节点接收不到主节点发的数据包的时候，就启动接管程序接管主节点的资源。备节点可以有多个，通过优先级竞选，但一般Keepalived系统运维工作中都是一对。

- VRRP使用了加密协议加密数据，但Keepalived官方目前还是推荐用明文的方式配置认证类型和密码。

### Keepalived服务的工作原理
- Keepalived高可用对之间是通过VRRP进行通信的，VRRP是通过竞选机制来确定主备的，主的优先级高于备，因此，工作时主会优先获得所有的资源，备节点处于等待状态，当主挂了的时候，备节点就会接管主节点的资源，然后顶替主节点对外提供服务。

- 在Keepalived服务对之间，只有作为主的服务器会一直发送VRRP广播包，告诉备它还活着，此时备不会抢占主，当主不可用时，即备监听不到主发送的广播包时，就会启动相关服务接管资源，保证业务的连续性。接管速度最快可以小于1秒。

```
keepalived:
  vrrp协议的软件实现，原生设计目的为了高可用ipvs服务
功能：
  1、vrrp协议完成地址流动
  2、为vip地址所在的节点生成ipvs规则(在配置文件中预先定义)
  3、为ipvs集群的各RS做健康状态检测
  4、基于脚本调用接口通过执行脚本完成脚本中定义的功能，进而影响集群事务，以此支持nginx、haproxy等服务
```

## keepalived配置文件说明

### HA Cluster 配置准备：
- 各节点时间必须同步:ntp, chrony
- 确保iptables及selinux不会成为阻碍
- 各节点之间可通过主机名互相通信（对KA并非必须）:建议使用/etc/hosts文件实现
- 各节点之间的root用户可以基于密钥认证的ssh服务完成互相通信（对KA并非必须）

### keepalived的安装包及程序环境
 keepalived.x86_64 0:1.3.5-16.el7 

程序环境：
```
主配置文件：/etc/keepalived/keepalived.conf
主程序文件：/usr/sbin/keepalived
Unit File：/usr/lib/systemd/system/keepalived.service
Unit File的环境配置文件：/etc/sysconfig/keepalived
```

## 安装
- *[Keepalived安装与配置](https://blog.csdn.net/xyang81/article/details/52554398)*
- *[Keepalived+Nginx实现高可用（HA）](https://blog.csdn.net/xyang81/article/details/52556886)*

### 方案A：脚本安装

* 一、修改 keepalived.properties 指定安装版本
* 二、执行 keepalived-install.sh安装 keepalived


### 方案B：手动安装

* 0、创建 keepalived 主目录

      mkdir -pv /opt/keepalived

* 1、要让 keepalived support IPVS with IPv6 需要安装

      yum -y install libnl libnl-devel libnl3 libnl3-devel libnfnetlink-devel

* 2、进入 keepalived 主目录

      cd /opt/keepalived

* 3、下载 libfatscommon 安装包

      wget http://www.keepalived.org/software/keepalived-2.0.8.tar.gz

* 4、解压安装包:

      tar xf keepalived-2.0.8.tar.gz

* 5、进入安装包目录

      cd keepalived-2.0.8

* 6、编译安装

      ./configure --prefix=/opt/keepalived/keepalived
      make && make install

* 7、创建软连接

      ln -sf /opt/nginx/keepalived/sbin/keepalived /usr/sbin/keepalived

* 8、查看keepalived版本

      keepalived -v

* 9、复制样例配置文件(keepalived 启动时默认读取 /etc/keepalived/keepalived.conf)

      cd ..
      mkdir -pv /etc/keepalived
      
将 keepalived.conf 拷贝到 /etc/keepalived
或者 cp /opt/keepalived/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf

* 10、修改完 keepalived.conf 文件后，启动 keepalived

      keepalived -D
      
说明：-D, --log-detail             Detailed log messages


