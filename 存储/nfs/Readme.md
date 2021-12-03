# nfs 实现集群下文件共享 

## NFS简介
- 什么是NFS
   
   NFS是Network File System的简写，即网络文件系统。NFS最早是由 Sun Microsystems 公司开发，并于1984年推出。
   
   NFS 是一种可分散式的网络文件系统，可以通过网络（一个局域网）使不同的机器、不同的操作系统，能够共享目录和文件，使客户端能通过网络访问并分享文件到位于服务端的磁盘中。
   
   NFS的客户端（一般为应用服务器，例如web）可以通过挂载（mount）的方式将NFS服务器共享的数据目录挂载到NFS客户端本地系统中（就是某一个关在点下）。
   
   从客户端本地看，NFS服务器端共享目录就好像是客户端自己的磁盘分区或者目录一样，而实际上却是远端的NFS服务器的目录。
   
   NFS网络文件系统很像Windows系统的网络共享、安全功能、网络驱动器映射，这也和linux的samba服务类似。
   
   只不过一般情况下，Windows网络共享服务或samba服务用户办公局域网共享，而互联网中小型网站集群架构后端常用NFS进行数据共享。
   
   若是大型网站，那么有可能还会用到更复杂的分布式文件系统Moosefs（mfs）、GlusterFS。NFS在文件传送或信息传送过程中依赖于RPC协议。RPC负责负责信息的传输。

- NFS的常用目录

    | 文件目录 | 用途 |
    | ---- | ---- |
    |  /etc/exports | NFS服务的主要配置文件，系统并没有默认值，是空文件，如这个文件不存在，需要自己创建 |
    |  /usr/sbin/exportfs |	NFS服务的管理命令 |
    |  /usr/sbin/showmount | 客户端的查看命令 |
    |  /var/lib/nfs/etab | 记录NFS分享出来的目录的完整权限设定值，即服务器配置的参数（包含默认的参数） |
    |  /var/lib/nfs/xtab | 记录曾经登录过的客户端信息 |
    
    NFS的配置文件：
    
    /etc/exports：NFS配置文件
    
    /var/lib/nfs/*tab：NFS服务器日志放置路径；etab记录共享出来的目录完整权限设置值；xtab记录曾经连接到此NFS主机的相关客户端数据

## 前置说明
主机1: 10.181.4.88 用作 nfs 服务端  
主机1: 10.181.4.60 用作 nfs 客户端 
主机1: 10.181.4.67 用作 nfs 客户端  

## NFS 服务端配置
### 安装NFS
- 检查并安装NFS
    ```
    $ rpm -qa rpcbind nfs-utils
    rpcbind-0.2.0-42.el7.x86_64
    nfs-utils-1.3.0-0.48.el7.x86_64
    ```
- 不存在的话需要安装NFS需要的包：
    ```
    $ yum install -y nfs-utils rpcbind
    ```
- 更新已存在的版本包:
    ```
    $ yum update -y nfs-utils rpcbind
    ```

### 服务配置
- 首先进入配置文件
    ```
    $ vi /etc/exports 
    ```
- 增加配置，根据需要修改NFS的配置文件 /etc/exports （默认是空文件）
    ```
    /var/lib/nfs/data 10.181.4.0/24(rw,sync,no_root_squash)
    ```
- 重新使配置文件生效，并显示生效内容
    ```
    $ exportfs -arv
    ```
- NFS的主要配置文件 /etc/exports 的内容格式
    ```
    <输出目录> [客户端1 选项（访问权限,用户映射,其他）] [客户端2 选项（访问权限,用户映射,其他）]
    a. 输出目录：
    输出目录是指NFS系统中需要共享给客户机使用的目录；
    
    b. 客户端：
    客户端是指网络中可以访问这个NFS输出目录的计算机
    
    客户端常用的指定方式
        指定ip地址的主机：192.168.0.200
        指定子网中的所有主机：192.168.0.0/24 192.168.0.0/255.255.255.0
        指定域名的主机：david.bsmart.cn
        指定域中的所有主机：*.bsmart.cn
        所有主机：*
    
    c. 选项：
    选项用来设置输出目录的访问权限、用户映射等。
    
    NFS主要有3类选项：
    访问权限选项
        设置输出目录只读：ro
        设置输出目录读写：rw
    
    用户映射选项
        all_squash：将远程访问的所有普通用户及所属组都映射为匿名用户或用户组（nfsnobody）；
        no_all_squash：与all_squash取反（默认设置）；
        root_squash：将root用户及所属组都映射为匿名用户或用户组（默认设置）；
        no_root_squash：与rootsquash取反；
        anonuid=xxx：将远程访问的所有用户都映射为匿名用户，并指定该用户为本地用户（UID=xxx）；
        anongid=xxx：将远程访问的所有用户组都映射为匿名用户组账户，并指定该匿名用户组账户为本地用户组账户（GID=xxx）；
    
    其它选项
        secure：限制客户端只能从小于1024的tcp/ip端口连接nfs服务器（默认设置）；
        insecure：允许客户端从大于1024的tcp/ip端口连接服务器；
        sync：将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性；
        async：将数据先保存在内存缓冲区中，必要时才写入磁盘；
        wdelay：检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率（默认设置）；
        no_wdelay：若有写操作则立即执行，应与sync配合使用；
        subtree：若输出目录是一个子目录，则nfs服务器将检查其父目录的权限(默认设置)；
        no_subtree：即使输出目录是一个子目录，nfs服务器也不检查其父目录的权限，这样可以提高效率；
    ```
- 配置修改重新加载

    若服务器端对 `/etc/exports` 文件进行了修改，可以通过 `exportfs` 命令重新加载服务而不需要重启服务。
    若重启服务需要重新向 `rpcbind` 注册，而且对客户端的影响也很大，所以尽量使用 `exportfs` 命令来使配置文件生效。
    ```
    exportfs：
    exportfs -ar      #重新导出所有的文件系统
    exportfs -r       #导出某个文件系统
    exportfs -au      #关闭导出的所有文件系统
    exportfs -u       #关闭指定的导出的文件系统
    ```
  
###  创建共享目录
```
mkdir /var/lib/nfs/data
chown -R nfsnobody.nfsnobody /var/lib/nfs/data
```

### 配置端口
 - 可修改 `/etc/sysconfig/nfs` 文件，修改 rpc.statd 服务端口
 - 可修改 `/etc/modprobe.d/lockd.conf` 文件，修改 Network Lock Manager (NLM)，对应是 nlockmgr
 
### 启动NFS服务
- 先 rpcbind 后 nfs
    ```
    $ systemctl enable rpcbind.service
    $ systemctl enable nfs-server.service
    $ systemctl start rpcbind.service
    $ systemctl start nfs-server.service
    ```
- 查看服务
    ```
    # 查看rpc是否启动成功
    $ netstat -lntup|grep rpc
    # 查看rpc监控信息
    $ rpcinfo -p
    ```  
- 加载NFS服务并检查
    ```
    $ systemctl reload nfs.service
    # 查看
    $ showmount -e localhost 
    Export list for localhost:
    /var/lib/nfs/data 10.181.4.0/24
    ```
  
## NFS客户端
### 安装NFS
- 检查并安装NFS
    ```
    $ rpm -qa rpcbind nfs-utils
    rpcbind-0.2.0-42.el7.x86_64
    nfs-utils-1.3.0-0.48.el7.x86_64
    ```
- 不存在的话需要安装NFS需要的包：
    ```
    $ yum install -y nfs-utils rpcbind
    ```
- 更新已存在的版本包:
    ```
    $ yum update -y nfs-utils rpcbind
    ```
### 启动rpc服务，并设置为开机自启动
```
$ systemctl start rpcbind.service
$ systemctl enable rpcbind
```
### 检查服务端的NFS
```
$ showmount -e 10.181.4.88
Export list for 10.181.4.88:
/var/lib/nfs/data 10.181.4.0/24
```
### 挂载
```
# 创建挂载目录
$ mkdir -pv /opt/nfs/data
# 挂载
$ mount -t nfs 10.181.4.88:/var/lib/nfs/data /opt/nfs/data   # -t 挂载的类型
# 查看挂载
$ df -h
文件系统                        容量  已用  可用 已用% 挂载点
10.181.4.88:/var/lib/nfs/data    20G  8.9G   12G   45% /opt/nfs/data
```
### 把挂载点写的开机自启动
- 方案一：
    ```
    $ vim /etc/fstab 
    # 设备文件  挂载点  文件系统类型  mount参数  dump参数  fsck顺序
    10.181.4.88:/var/lib/nfs/data /opt/nfs/data nfs defaults,_netdev 0 0
    ```
  _netdev明确说明这是网络文件系统，避免网络启动前挂载出现错误。
  
  编辑保存后，执行命令：
  ```
  $ systemctl daemon-reload
  ```
  重新挂载 `/etc/fstab` 里面的内容。
  
- 方案二：
    ```
    $ echo "mount -t nfs 10.181.4.88:/var/lib/nfs/data /opt/nfs/data" >> /etc/rc.local
    ```

## 相关问题
- **Unable to receive: errno 113**

  nfs与rpcbind都正常启动了，并且已经发布共享目录 `/var/lib/nfs/dat`。
    在客户端查看时，出现如下错误提示:
    ```
    $ showmount -e 10.181.4.88
    clnt_create: RPC: Port mapper failure - Unable to receive: errno 113 (No route to host)
    ```
  解决方法：
  
  关闭被访问的NFS服务器上的防火墙和selinux
    ```
    $ systemctl stop firewalld; iptables -F; setenforce 0
    ```
  在客户端重新查看
    ```
    $ showmount -e 10.181.4.88
    ```

- **clnt_create: RPC: Program not registered**
  
  在客户端 `showmount -e 10.181.4.88` 遇到以下错误提示，`“clnt_create: RPC: Program not registered”`
  
  解决方法：
  
  服务端执行：
    ```
    $ rpc.mountd 
    ```
  客户端查看
    ```
    $ showmount -e 10.181.4.88
    Export list for 10.181.4.88:
    /var/lib/nfs/data 10.181.4.0/24
    ```

- **Permission denied**

  重新设置配置文件 `/etc/exports`，确保文件中的权限是包括客户端的ip地址  