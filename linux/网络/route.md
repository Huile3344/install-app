# route

## Linux 下命令说明

### 范例

- route

  > 查看路由信息

- route add -net 127.0.0.0

  >加入正常的环回接口项，它使用掩码255.0.0.0(由目标地址决定了它是A类网络)并与设备"lo"相关联(假定该设备先前已由ifconfig(8)正确设置)。

- route add -net 192.56.76.0 netmask 255.255.255.0 dev eth0

  >向"eth0"添加一条指向网络192.56.76.x的路由。其中的C类子网掩码并不必须，因为192.*是个C类的IP地址。在此关键字"dev"可省略。

- route add default gw mango-gw

  > 加入一条缺省路由(如果无法匹配其它路由则用它)。使用此路由的所有分组将通过网关"mango-gw"进行传输。实际使用此路由的设备取决于如何到达"mango-gw" - 先前必须设好到"mango-gw"的静态路由。

- route add ipx4 sl0

  > 向SLIP接口添加一条指向"ipx4"的路由(假定"ipx4"是使用SLIP的主机)。

- route add -net 192.57.66.0 netmask 255.255.255.0 gw ipx4

  > 此命令为先前SLIP接口的网关ipx4添加到网络"192.57.66.x"的路由。

- route add 224.0.0.0 netmask 240.0.0.0 dev eth0

  > 此命令为"eth0"设定所有D类地址(用于组播)的路由。这是用于组播内核的正确配置行。

- route add 10.0.0.0 netmask 255.0.0.0 reject

  > 此命令为私有网络"10.x.x.x."设置一条阻塞路由。



### route命令描述

route程序对内核的IP选路表进行操作。它主要用于通过已用ifconfig(8)程序配置好的接口来指定的主机或网络设置静态路由

```
route - 显示 / 操作IP选路表
```



### route 命令详解

route命令用于显示和操作IP路由表。要实现两个不同的子网之间的通信，需要一台连接两个网络的路由器，或者同时位于两个网络的网关来实现。在Linux系统中，设置路由通常是为了解决以下问题：该Linux系统在一个局域网中，局域网中有一个网关，能够让机器访问Internet，那么就需要将这台机器的IP地址设置为 Linux机器的默认路由。要注意的是，直接在命令行下执行route命令来添加路由，不会永久保存，当网卡重启或者机器重启之后，该路由就失效了；要想永久保存，有如下方法：

1. 在/etc/rc.local里添加
2. 在/etc/sysconfig/network里添加到末尾
3. /etc/sysconfig/static-router: `any net x.x.x.x/24 gw y.y.y.y`



### man route 查看使用手册

#### 描述

```shell
route程序对内核的IP选路表进行操作。它主要用于通过已用ifconfig(8)程序配置好的接口来指定的主机或网络设置静态路由。
```



#### 命令格式总览

```shell
route [-CFvnee]

route   [-v]   [-A family] add [-net|-host] target [netmask Nm] [gw Gw] [metric N] [mss M] [window W] [irtt  I][reject] [mod] [dyn] [reinstate] [[dev] If]

route  [-v]  [-A family]  del [-net|-host] target [gw Gw][netmask Nm] [metric N] [[dev] If]

route  [-V] [--version] [-h] [--help]

```



#### 命令选项

| 参数                | 描述                                                         |
| ------------------- | ------------------------------------------------------------ |
| -v                  | 选用细节操作模式                                             |
| -A family           | 用指定的地址族(如`inet'，`inet6')。                          |
| -n                  | 以数字形式代替解释主机名形式来显示地址。此项对试图检测对域名服务器进行路由发生故障的原因非常有用。 |
| -e                  | 用netstat(8)的格式来显示选路表。-ee将产生包括选路表所有参数在内的大量信息。 |
| -net                | 路由目标为网络。                                             |
| -host               | 路由目标为主机。                                             |
| -F                  | 显示内核的FIB选路表。其格式可以用-e 和 -ee选项改变。         |
| -C                  | 显示内核的路由缓存。                                         |
| del                 | 删除一条路由。                                               |
| add                 | 添加一条路由。                                               |
| target              | 指定目标网络或主机。可以用点分十进制形式的IP地址或主机/网络名。 |
| netmask Nm          | 为添加的路由指定网络掩码。                                   |
| gw Gw               | 为发往目标网络/主机的任何分组指定网关。注意：指定的网关首先必须是可达的。也就是说必须为该网关预先指定一条静态路由。如果你为本地接口<br/>之一指定这个网关地址的话，那么此网关地址将用于决定此接口上的分组将如何进行路由。这是BSD风格所兼容的。 |
| metric M            | 把选路表中的路由值字段(由选路进程使用)设为M。                |
| mss M               | 把基于此路由之上的连接的TCP最大报文段长度设为M字节。这通常只用于优化选路设置。默认值为536。 |
| window W            | 把基于此路由之上的连接的TCP窗口长度设为W字节。这通常只用于AX.25网络和不能处理背对背形式的帧的设备。 |
| irtt I              | 把基于此路由之上的TCP连接的初始往返时间设为I毫秒(1-12000)。这通常也只用于AX.25网络。如果省略此选项，则使用RFC1122的缺省值300ms。 |
| reject              | 设置一条阻塞路由以使一条路由查找失败。这用于在使用缺省路由前先屏蔽掉一些网络。但这并不起到防火墙的作用。 |
| mod, dyn, reinstate | 设置一条动态的或更改过的路由。这些标志通常只由选路进程来设置。这只用于诊断目的， |
| dev If              | 强制使路由与指定的设备关联，因为否则内核会自己来试图检测相应的设备(通常检查已存在的路由和加入路由的设备的规格)。在多数正常的网络上无需使用。<br/>如果dev  If是命令行上最后一个指定的选项，那么可以省略关键字dev，因为它是缺省值。否则路由修改对象(metric - netmask- gw- dev)无关紧要。 |



#### 输出信息 OUTPUT

内核选路表的输出信息由以下栏目组成：

| 列名              | 描述                                                         |
| ----------------- | ------------------------------------------------------------ |
| Destination       | 目标网络或目标主机。                                         |
| Gateway           | 网关地址或'*'(如未设)。                                      |
| Genmask           | 目标网络的子网掩码；'255.255.255.255'为主机，'0.0.0.0'为缺省路由。 |
| Flags             | 可能出现的标志有：<br/>U (route is up) 路由正常<br/> H (target is a host) 主机路由<br/> G (use gateway) 使用网关的间接路由<br/> R (reinstate route for dynamic routing) 为动态选路恢复路由<br/> D (dynamically installed by daemon or redirect) 该路由由选路进程或重定向动态创建 <br/>M (modified from routing daemon or rederict) 该路由已由选路进程或重定向修改<br/>! (reject route) 阻塞路由 |
| Metric            | 通向目标的距离(通常以跳来计算)。新内核不使用此概念，而选路进程可能会用。 |
| Ref               | 使用此路由的活动进程个数(Linux内核并不使用)。                |
| Use               | 查找此路由的次数。根据-F  和 -C的使用，此数值是路由缓存的损失数或采样数。 |
| Iface             | 使用此路由发送分组的接口。                                   |
| MSS               | 基于此路由的TCP连接的缺省最大报文段长度。                    |
| Window            | 基于此路由的TCP连接的缺省窗口长度。                          |
| irtt              | 初始往返时间。内核用它来猜测最佳TCP协议参数而无须等待(可能很慢的)应答。 |
| HH (cached only)  | 为缓存过的路由而访问硬件报头缓存的ARP记录和缓存路由的数量。如果缓存过路由的接口(如lo)无须硬件地址则值为-1。 |
| Arp (cached only) | 无论缓存路由所用的硬件地址情况如何都进行更新。               |



#### 其他内容

文件 FILES

- /proc/net/ipv6_route
- /proc/net/route
- /proc/net/rt_cache

参见 SEE ALSO
       ifconfig(8), netstat(8), arp(8), rarp(8)



## Windows下命令说明

### 范例

- 查看路由帮助信息

  > route -h

- 查看路由状态

  > route print

- 只查看ipv4（ipv6）路由状态

  > route print -4(-6)

- 添加路由: route add 目的网络 mask 子网掩码 网关——重启机器或网卡失效

  > route add 192.168.20.0 mask 255.255.255.0 192.168.10.1

- 添加永久路由: route -p add 目的网络 mask 子网掩码 网关

  > route -p add 192.168.20.0 mask 255.255.255.0 192.168.10.1

- 删除目的网络的一个网关的路由: route delete 目的网络 mask 子网掩码 网关

  > route delete 192.168.20.0 mask 255.255.255.0 192.168.10.1

- 删除目的网络子网掩码的路由: route delete 目的网络 mask 子网掩码

  > route delete 192.168.20.0 mask 255.255.255.0

- 删除目的网络的所有路由: route delete 目的网络

  > route delete 192.168.20.0




### 命令格式总览

```
ROUTE [-f] [-p] [-4|-6] command [destination]
                  [MASK netmask]  [gateway] [METRIC metric]  [IF interface]
```



### 命令参数

| 参数        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| -f          | 清除所有网关项的路由表。如果与某个命令结合使用，在运行该命令前，应清除路由表。 |
| -p          | 与 ADD 命令结合使用时，将路由设置为在系统引导期间保持不变。默认情况下，重新启动系统时，不保存路由。忽略所有其他命令这始终会影响相应的永久路由。 |
| -4          | 强制使用 IPv4。                                              |
| -6          | 强制使用 IPv6。                                              |
| command     | 其中之一:<br/>         PRINT     打印路由<br/>         ADD       添加路由<br/>         DELETE    删除路由<br/>         CHANGE    修改现有路由 |
| destination | 指定主机。                                                   |
| MASK        | 指定下一个参数为“netmask”值。                                |
| netmask     | 指定此路由项的子网掩码值。<br/>    如果未指定，其默认设置为 255.255.255.255。 |
| gateway     | 指定网关。                                                   |
| interface   | 指定路由的接口号码。                                         |
| METRIC      | 指定跃点数，例如目标的成本。                                 |



### 其他说明

用于目标的所有符号名都可以在网络数据库文件 NETWORKS 中进行查找。用于网关的符号名称都可以在主机名称数据库文件 HOSTS 中进行查找。

如果命令为 PRINT 或 DELETE。目标或网关可以为通配符，(通配符指定为星号“*”)，否则可能会忽略网关参数。

如果 Dest 包含一个 * 或 ?，则会将其视为 Shell 模式，并且只、打印匹配目标路由。“*”匹配任意字符串，而“?”匹配任意一个字符。示例: `157.*.1`、`157.*`、`127.*`、`*224*`。

只有在 PRINT 命令中才允许模式匹配。
诊断信息注释:
    无效的 MASK 产生错误，即当 (DEST & MASK) != DEST 时。
    示例: > route ADD 157.0.0.0 MASK 155.0.0.0 157.55.80.1 IF 1
             路由添加失败: 指定的掩码参数无效。(Destination & Mask) != Destination。
