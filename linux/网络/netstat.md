# netstat

## Linux 下命令说明

### 范例

- 以数字的形式查看 tcp udp 监听中的网络端口号和进程id

  > netstat -tunpl

- 查看路由信息

  >netstat -r

- 显示使用指定端口的应用程序的进程 id

  >netstat -nap | grep port

- 显示包括 TCP 和 UDP 的所有连接

  > netstat -a or netstat –all

- 显示 TCP 连接

  > netstat –tcp or netstat –t

- 显示 UDP 连接

  > netstat –udp or netstat –u

- 显示该主机订阅的所有多播网络

  > netstat -g



### netstat命令描述

Netstat 程序显示Linux网络子系统的信息。 输出信息的类型是由第一个参数控制的



### man netstat 查看使用手册

#### 描述

```shell
netstat程序对内核的IP选路表进行操作。它主要用于通过已用ifconfig(8)程序配置好的接口来指定的主机或网络设置静态路由。
```

#### 命令格式

```shell
netstat - 显示网络连接，路由表，接口状态，伪装连接，网络链路信息和组播成员组。
```

#### 命令选项总览

```shell
netstat   [address_family_options]   [--tcp|-t]   [--udp|-u]   [--raw|-w]   [--listening|-l]   [--all|-a]   [--numeric|-n]  [--numeric-
hosts][--numeric-ports][--numeric-ports] [--symbolic|-N] [--extend|-e[--extend|-e]] [--timers|-o] [--program|-p] [--verbose|-v] [--con‐
tinuous|-c] [delay]

netstat  {--route|-r}  [address_family_options]  [--extend|-e[--extend|-e]]  [--verbose|-v] [--numeric|-n] [--numeric-hosts][--numeric-
ports][--numeric-ports] [--continuous|-c] [delay]

netstat {--interfaces|-i}  [iface]  [--all|-a]  [--extend|-e[--extend|-e]]  [--verbose|-v]  [--program|-p]  [--numeric|-n]  [--numeric-
hosts][--numeric-ports][--numeric-ports] [--continuous|-c] [delay]

netstat {--groups|-g} [--numeric|-n] [--numeric-hosts][--numeric-ports][--numeric-ports] [--continuous|-c] [delay]

netstat {--masquerade|-M} [--extend|-e] [--numeric|-n] [--numeric-hosts][--numeric-ports][--numeric-ports] [--continuous|-c] [delay]

netstat {--statistics|-s} [--tcp|-t] [--udp|-u] [--raw|-w] [delay]

netstat {--version|-V}

netstat {--help|-h}

address_family_options:

[--protocol={inet,unix,ipx,ax25,netrom,ddp}[,...]]  [--unix|-x] [--inet|--ip] [--ax25] [--ipx] [--netrom] [--ddp]


```

#### 命令第一个参数

| 选项                   | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| (none)                 | 无选项时, netstat 显示打开的套接字.  如果不指定任何地址族，那么打印出所有已配置地址族的有效套接字 |
| --route , -r           | 显示内核路由表。等价直接使用 route 命令                      |
| --groups , -g          | 显示IPv4 和 IPv6的IGMP组播组成员关系信息                     |
| --interface=iface , -i | 显示所有网络接口列表或者是指定的 iface                       |
| --masquerade , -M      | 显示一份所有经伪装的会话列表                                 |
| --statistics , -s      | 显示每种协议的统计信息                                       |




#### 命令选项

| 选项                   | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| --verbose , -v         | 详细模式运行。特别是打印一些关于未配置地址族的有用信息       |
| --numeric , -n         | 显示数字形式地址而不是去解析主机、端口或用户名               |
| --numeric-hosts        | 显示数字形式的主机但是不影响端口或用户名的解析               |
| --numeric-ports        | 显示数字端口号，但是不影响主机或用户名的解析                 |
| --numeric-users        | 显示数字的用户ID，但是不影响主机和端口名的解析               |
| --protocol=family , -A | 指定要显示哪些连接的地址族(也许在底层协议中可以更好地描述)。  family  以逗号分隔的地址族列表，比如  inet,  unix,  ipx, ax25, netrom, 和ddp。 这样和使用 --inet, --unix (-x), --ipx, --ax25, --netrom, 和 --ddp 选项效果相同<br/>地址族 inet 包括raw, udp 和tcp 协议套接字。 |
| -c, --continuous       | 将使 netstat 不断地每秒输出所选的信息                        |
| -e, --extend           | 显示附加信息。使用这个选项两次来获得所有细节                 |
| -o, --timers           | 包含与网络定时器有关的信息                                   |
| -p, --program          | 显示套接字所属进程的PID和名称                                |
| -l, --listening        | 只显示正在侦听的套接字(这是默认的选项)                       |
| -a, --all              | 显示所有正在或不在侦听的套接字。加上 --interfaces 选项将显示没有标记的接口 |
| -F                     | 显示FIB中的路由信息。(这是默认的选项)                        |
| -C                     | 显示路由缓冲中的路由信息                                     |
| delay                  | netstat将循环输出统计信息，每隔 delay 秒                     |



#### 输出信息

##### 活动的Internet网络连接 (TCP, UDP, raw)

| 列               | 描述                                                         |
| ---------------- | ------------------------------------------------------------ |
| Proto            | 套接字使用的协议。                                           |
| Recv-Q           | 连接此套接字的用户程序未拷贝的字节数                         |
| Send-Q           | 远程主机未确认的字节数                                       |
| Local Address    | 套接字的本地地址(本地主机名)和端口号。除非给定 -n --numeric(-n)选项，否则套接字地址按标准主机名(FQDN)进行解析，而端口号则转换到相应的服务名。 |
| Foreign Address  | 套接字的远程地址(远程主机名)和端口号。 Analogous to "Local Address." |
| State            | 套接字的状态。因为在RAW协议中没有状态，而且UDP也不用状态信息，所以此行留空。通常它为以下几个值之一：<br/>       ESTABLISHED<br/>              套接字有一个有效连接。<br/><br/>       SYN_SENT<br/>              套接字尝试建立一个连接。<br/><br/>       SYN_RECV<br/>              从网络上收到一个连接请求。<br/><br/>       FIN_WAIT1<br/>              套接字已关闭，连接正在断开。<br/><br/>       FIN_WAIT2<br/>              连接已关闭，套接字等待远程方中止。<br/><br/>       TIME_WAIT<br/>              在关闭之后，套接字等待处理仍然在网络中的分组<br/><br/>       CLOSED 套接字未用。<br/><br/>       CLOSE_WAIT<br/>              远程方已关闭，等待套接字关闭。<br/><br/>       LAST_ACK<br/>              远程方中止，套接字已关闭。等待确认。<br/><br/>       LISTEN 套接字监听进来的连接。如果不设置 --listening (-l) 或者 --all (-a) 选项，将不显示出来这些连接。<br/><br/>       CLOSING<br/>              套接字都已关闭，而还未把所有数据发出。<br/><br/>       UNKNOWN<br/>              套接字状态未知。 |
| User             | 套接字属主的名称或UID                                        |
| PID/Program name | 以斜线分隔的处理套接字程序的PID及进程名。 --program 使此栏目被显示。你需要 superuser 权限来查看不是你拥有的套接字的信息。对IPX套接字还无法获得此信息 |
| Timer            | (this needs to be written)                                   |



##### 活动的UNIX域套接字

| 列                     | 描述                                                         |
| ---------------------- | ------------------------------------------------------------ |
| Proto                  | 套接字所用的协议(通常是unix)                                 |
| RefCnt                 | 使用数量(也就是通过此套接字连接的进程数)                     |
| Flags                  | 显示的标志为SO_ACCEPTON(显示为   ACC),   SO_WAITDATA   (W)   或   SO_NOSPACE    (N)。    如果相应的进程等待一个连接请求，那么SO_ACCECP‐TON用于未连接的套接字。其它标志通常并不重要 |
| Type                   | 套接字使用的一些类型：<br/><br/>       SOCK_DGRAM<br/>              此套接字用于数据报(无连接)模式。<br/><br/>       SOCK_STREAM<br/>              流模式(连接)套接字<br/><br/>       SOCK_RAW<br/>              此套接字用于RAW模式。<br/><br/>       SOCK_RDM<br/>              一种服务可靠性传递信息。<br/><br/>       SOCK_SEQPACKET<br/>              连续分组套接字。<br/><br/>       SOCK_PACKET<br/>              RAW接口使用套接字。<br/><br/>       UNKNOWN<br/>              将来谁知道它的话将告诉我们，就填在这里 :-) |
| State                  | 此字段包含以下关键字之一：<br/><br/>       FREE   套接字未分配。<br/><br/>       LISTENING<br/>              套接字正在监听一个连接请求。除非设置 --listening (-l) 或者 --all (-a) 选项，否则不显示。<br/><br/>       CONNECTING<br/>              套接字正要建立连接。<br/><br/>       CONNECTED<br/>              套接字已连接。<br/><br/>       DISCONNECTING<br/>              套接字已断开。<br/><br/>       (empty)<br/>              套接字未连。<br/><br/>       UNKNOWN<br/>              ！不应当出现这种状态的。 |
| PID/Program name       | 处理此套接字的程序进程名和PID。上面关于活动的Internet连接的部分有更详细的信息。 |
| Path                   | 当相应进程连入套接字时显示路径名。                           |
| 活动的IPX套接字        | (this needs to be done by somebody who knows it)             |
| Active NET/ROM sockets | (this needs to be done by somebody who knows it)             |
| Active AX.25 sockets   | (this needs to be done by somebody who knows it)             |



注意 NOTES
       从linux 2.2内核开始 netstat -i 不再显示别名接口的统计信息。要获得每个别名接口的计数器，则需要用 ipchains(8) 命令。



#### 文件 FILES

       /etc/services -- 服务解释文件
    
       /proc -- proc文件系统的挂载点。proc文件系统通过下列文件给出了内核状态信息。
    
       /proc/net/dev -- 设备信息
    
       /proc/net/raw -- RAW套接字信息
    
       /proc/net/tcp -- TCP套接字信息
    
       /proc/net/udp -- UDP套接字信息
    
       /proc/net/igmp -- IGMP组播信息
    
       /proc/net/unix -- Unix域套接字信息
    
       /proc/net/ipx -- IPX套接字信息
    
       /proc/net/ax25 -- AX25套接字信息
    
       /proc/net/appletalk -- DDP(appletalk)套接字信息
    
       /proc/net/nr -- NET/ROM套接字信息
    
       /proc/net/route -- IP路由信息
    
       /proc/net/ax25_route -- AX25路由信息
    
       /proc/net/ipx_route -- IPX路由信息
    
       /proc/net/nr_nodes -- NET/ROM节点列表
    
       /proc/net/nr_neigh -- NET/ROM邻站
    
       /proc/net/ip_masquerade -- 伪装连接
    
       /proc/net/snmp -- 统计



#### 参见 SEE ALSO

​       route(8), ifconfig(8), ipchains(8), iptables(8), proc(5)



## Windows下命令说明

显示协议统计信息和当前 TCP/IP 网络连接

### 范例

- 以数字的形式查看所有监听中的网络端口号和进程id

  > netstat -nao

- 显示使用指定端口号的应用程序的进程 id

  >netstat -nao | findstr port

- 显示tcp连接的应用程序的端口号和进程 id

  > netstat -nop tcp

- 查看路由信息

> netstat -r

### 命令选项总览

```
NETSTAT [-a] [-b] [-e] [-f] [-n] [-o] [-p proto] [-r] [-s] [-t] [-x] [-y] [interval]
```



### 命令选想

| 选项     | 描述                                                         |
| -------- | ------------------------------------------------------------ |
| -a       | 显示所有连接和侦听端口。                                     |
| -b       | 显示在创建每个连接或侦听端口时涉及的可执行文件。在某些情况下，已知可执行文件托管多个独立的组件，此时会显示创建连接或侦听端口时涉及的组件序列。在此情况下，可执行文件的名称位于底部 [] 中，它调用的组件位于顶部，直至达到 TCP/IP。注意，此选项可能很耗时，并且可能因为你没有足够的权限而失败。 |
| -e       | 显示以太网统计信息。此选项可以与 -s 选项结合使用。           |
| -f       | 显示外部地址的完全限定域名(FQDN)。                           |
| -n       | 以数字形式显示地址和端口号。                                 |
| -o       | 显示拥有的与每个连接关联的进程 ID。                          |
| -p proto | 显示 proto 指定的协议的连接；proto<br/>                可以是下列任何一个: TCP、UDP、TCPv6 或 UDPv6。如果与 -s<br/>                选项一起用来显示每个协议的统计信息，proto 可以是下列任何一个:<br/>                IP、IPv6、ICMP、ICMPv6、TCP、TCPv6、UDP 或 UDPv6。 |
| -q       | 显示所有连接、侦听端口和绑定的非侦听 TCP 端口。绑定的非侦听端口不一定与活动连接相关联。 |
| -r       | 显示路由表。                                                 |
| -s       | 显示每个协议的统计信息。默认情况下，显示 IP、IPv6、ICMP、ICMPv6、TCP、TCPv6、UDP 和 UDPv6 的统计信息；<br/>-p 选项可用于指定默认的子网。 |
| -t       | 显示当前连接卸载状态。                                       |
| -x       | 显示 NetworkDirect 连接、侦听器和共享终结点。                |
| -y       | 显示所有连接的 TCP 连接模板。无法与其他选项结合使用。        |
| interval | 重新显示选定的统计信息，各个显示间暂停的间隔秒数。按 CTRL+C 停止重新显示统计信息。如果省略，则 netstat 将打印当前的配置信息一次。 |

