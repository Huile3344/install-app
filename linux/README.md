# linux

## 初始安装后，修改linux
### 关闭图形页面
- 查看当前开机启动的图形化桌面
    ```
    $ systemctl get-default
    graphical.target
    ```
- 修改为开机启动的命令行桌面，重启后生效
    ```
    $ systemctl set-default multi-user.target
    ```
### 修改主机名
- 查看当前主机名: 
    ```
    $ uname -n
    centos
    # 或
    $ hostname
    centos
    ```
- 修改主机名
    ```
    $ vim /etc/hostname
    # 修改成对应主机名，linux主机名在下次重启之后开始生效
    node1
    # 如需立即永久生效，需配合hostname命令即可
    $ hostname node1
    $ hostname
    node1
    ```
### 修改ip信息
- 查看当前主机ip信息，若需要修改则继续后续步骤
    ```
    $ ifconfig
    ```
- 修改网卡 ens33 信息
    ```
    $ vim /etc/sysconfig/network-scripts/ifcfg-ens33
    ```
    * 修改前内容类似如下
        ```
        TYPE=Ethernet
        PROXY_METHOD=none
        BROWSER_ONLY=no
        BOOTPROTO=dhcp
        DEFROUTE=yes
        IPV4_FAILURE_FATAL=no
        IPV6INIT=yes
        IPV6_AUTOCONF=yes
        IPV6_DEFROUTE=yes
        IPV6_FAILURE_FATAL=no
        NAME=ens33
        UUID=84e05055-89c6-425d-a270-2c9896ccfe0e
        DEVICE=ens33
        ONBOOT=no
        ```
    * 使用 dhcp 动态ip方式，修改后内容类似如下
        ```
        TYPE=Ethernet
        PROXY_METHOD=none
        BROWSER_ONLY=no
        # 使用 dhcp 动态ip
        BOOTPROTO=dhcp
        DEFROUTE=yes
        IPV4_FAILURE_FATAL=no
        IPV6INIT=yes
        IPV6_AUTOCONF=yes
        IPV6_DEFROUTE=yes
        IPV6_FAILURE_FATAL=no
        NAME=ens33
        # 若是虚拟机导入的，UUID需要修改
        UUID=84e05055-89c6-425d-a270-2c9896ccfe0e
        DEVICE=ens33
        # 开启启动该网卡
        ONBOOT=yes
        ```
    * 使用 static 静态ip方式，修改后内容类似如下
        ```
        TYPE=Ethernet
        PROXY_METHOD=none
        BROWSER_ONLY=no
        # 使用 static 静态ip
        BOOTPROTO=static
        DEFROUTE=yes
        IPV4_FAILURE_FATAL=no
        IPV6INIT=yes
        IPV6_AUTOCONF=yes
        IPV6_DEFROUTE=yes
        IPV6_FAILURE_FATAL=no
        NAME=ens33
        # 若是虚拟机导入的，UUID需要修改
        UUID=84e05055-89c6-425d-a270-2c9896ccfe0e
        DEVICE=ens33
        # 开启启动该网卡
        ONBOOT=yes
        # 静态ip
        IPADDR=10.181.4.60
        PREFIX=22
        # 默认网关
        GATEWAY=10.181.4.1
        # 子网掩码
        NETMASK=255.255.252.0
        # mac地址，虚拟机->网络适配器->高级->MAC地址 中的值，需要对应
        MACADDR=00:0C:29:C9:A6:30
        # 硬件地址
        HWADDR=00:0C:29:C9:A6:30
        # 多个 DNS，可使用 8.8.8.8
        DNS1=223.5.5.5
        DNS2=223.6.6.6
        ```
- 重启网卡 (针对 centos 7)
    ```
    $ systemctl restart network.service
    ```
- 重启网卡 (针对 centos 8， network.service 在centos8及stram是不推荐使用，而是推荐使用 NetworkManager)
    ```
    $ nmcli c reload
    $ nmcli c up ens33
    ```    
- 校验ip和网络是否正常
    ```
    $ ifconfig
    # 查看网卡ip是否和配置ip一致
    $ ping www.baidu.com
    # 若 ping 本地主机不通，留意是否是防火墙没关
    ```

### 修改 yum 源
- 使用阿里yum源
    - centos 7
        ```
        $ mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.$(date "+%Y-%m-%d#%H:%M:%S").backup
        $ curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        $ yum makecache
        ```
    - centos 8
        ```
        $ mv /etc/yum.repos.d/CentOS-BaseOS.repo /etc/yum.repos.d/CentOS-BaseOS.repo.$(date "+%Y-%m-%d#%H:%M:%S").backup
        $ curl -o /etc/yum.repos.d/CentOS-BaseOS.repo http://mirrors.aliyun.com/repo/Centos-8.repo
        $ yum makecache
        ```
    - centos stream 8
        ```
        $ mv /etc/yum.repos.d/CentOS-Stream-BaseOS.repo /etc/yum.repos.d/CentOS-Stream-BaseOS.repo.$(date "+%Y-%m-%d#%H:%M:%S").backup
        $ curl -o /etc/yum.repos.d/CentOS-Stream-BaseOS.repo http://mirrors.aliyun.com/repo/Centos-8.repo
        $ yum makecache
        ```
- 更新yum相关配置
    ```
    $ yum -y update
    ```
## 磁盘相关命令

### du

df -h 显示磁盘空间满，但实际未占用满——问题分析

- 命令查看各个目录的占用空间，找到占用较多空间的目录,

```aidl
du  -h  / --max-depth=1  | sort -gr
```

- 查看 inode 的使用率

查看 inode 的使用率，怀疑 inode 不够导致此问题

```aidl
du -i
```

- 使用 lsof 检查

使用 lsof 检查，怀疑是不是有可能文件已被删除，但是进程还存活的场景

```aidl
lsof | grep delete
```

