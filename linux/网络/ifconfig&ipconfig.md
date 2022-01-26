# ifconfig & ipconfig

## Linux 下命令 ifconfig 说明

### 范例

- 查看网络接口配置

  >ifconfig

- 查看网络接口ens33的配置

>ifconfig ens33

- 启用网络接口ens33

  > ifconfig ens33 up

- 停止网络接口 ens33

  > ifconfig ens33 down

- 临时修改 ens6 ip地址为 10.0.13.8

  > 重新加载网络接口配置或者启用网络接口将失效
  >
  > ifconfig ens6 10.0.13.8



### ifconfig命令描述
ifconfig - 配置网络接口

```
ifconfig - 配置网络接口
```



### man ifconfig 查看使用手册

#### 描述

```shell
ifconfig 用于配置常驻内核的网络接口。它用于在引导成功时设定网络接口。 此后，只在需要调试及系统调整时才使用。 如没有给出参数， ifconfig 显示当前有效接口的状态。如给定单个接口作为参数，它只显示给出的那个接口的状态；如果给出一个 -a 参数，它会显示所有接口的状态，包括那些停用的接口。 否则就对一个接口进行配置。
```



#### 地址族

如果跟在 interface(接口) 名称后的第一个参数是它支持地址族的名称， 那么这个地址族被用于解码和显示所有的协议地址。 当前支持的地址族包括 inet (TCP/IP，缺省)， inet6 ( IPv6 ) ， ax25 ( AMPR 无线分组 )， ddp ( Appletalk 2 代)， ipx ( Novell IPX ) 和 netrom ( AMPR 无线分组)。按照ISO C标准的规定，以点十进制表示法提供的所有数字可以是十进制、八进制或十六进制（即，前导0x或0X表示十六进制；否则，前导“0”表示八进制；否则，数字解释为十进制）。十六进制和八进制数字的使用不符合RFC，因此不鼓励使用。

#### 命令选项总览

```shell
ifconfig [-v] [-a] [-s] [interface]
ifconfig [-v] interface [aftype] options | address ...
```

#### 命令参数

| 选项                  | 描述                                                         |
| --------------------- | ------------------------------------------------------------ |
| -a                    | 显示当前可用的所有interface(接口)，即使关闭                  |
| -s                    | 显示短列表（如netstat-i）                                    |
| -v                    | 对于某些错误情况，请更加详细                                 |
| interface             | 接口的名称。这通常是一个驱动器名，后跟一个单元号，例如第一个以太网接口的eth0。如果内核支持别名接口，则可以使用eth0:0为eth0的第一个别名指定它们。您可以使用它们来分配第二个地址。要删除别名接口，请使用ifconfig eth0:0 down。注意：对于每个作用域（即具有地址/网络掩码组合的同一网络），如果删除第一个（主）别名，则会删除所有别名。 |
| up                    | 此选项激活接口。如果给接口声明了地址，等于隐含声明了这个选项。 |
| down                  | 此选项使接口驱动设备关闭。                                   |
| [-]arp                | 允许或禁止在接口上使用 ARP 协议。                            |
| [-]promisc            | 允许或禁止接口置于混杂模式。 如果选用，则接口可以接收网络上的所有分组。 |
| [-]allmulti           | 允许或禁止 组播模式（all-multicast） 。 如果选用，则接口可以接收网络上的所有组播分组。 |
| metric N              | 将接口度量值设置为整数 N。 (译注：度量值表示在这个路径上发送一个分组的成本,就是通过多少个路由） |
| mtu N                 | 此选项设定接口的最大传输单元 MTU。                           |
| dstaddr addr          | 为点到点链路(如 PPP )设定一个远程 IP 地址。此选项现已废弃；用 pointopoint 选项替换。 |
| netmask addr          | 为接口设定 IP 网络掩码。缺省值通常是 A，B 或 C 类的网络掩码 (由接口的 IP 地址推出)，但也可设为其它值。 |
| add addr/prefixlen    | 为接口加入一个 IPv6 地址。                                   |
| del addr/prefixlen    | 为接口删除一个 IPv6 地址。                                   |
| tunnel ::aa.bb.cc.dd  | 建立一个新的 SIT (在 IPv4 中的 IPv6 )设备，为给定的目的地址建立通道。 |
| irq addr              | 为接口设定所用的中断值。 并不是所有的设备都能动态更改自己的中断值。 |
| io_addr addr          | 为接口设定起始输入/输出地址。                                |
| mem_start addr        | 设定接口所用的共享内存起始地址。只有少数设备需要。           |
| media type            | 设定接口所用的物理端口或介质类型。并不是所有设备都会更改这项值，而且它们支持的类型可能并相同。典型的    type    是   10base2 (细缆以太网)，  10baseT  (双绞线  10Mbps  以太网)，  AUI  (外部收发单元接口)等等。介质类型为   auto   则用于让设备自动判断介质。同样，并非所有设备都可以这样工作。 |
| [-]broadcast [addr]   | 如果给出了地址参数， 则可以为接口设定该协议的广播地址。 否则，为接口设置(或清除) IFF_BROADCAST 标志。 |
| [-]pointopoint [addr] | 此选项允许接口置为 点到点 模式，这种模式在两台主机间建立一条无人可以监听的直接链路。如果还给出了地址参数，则设定链路另一方的协议地址，正如废弃的 dstaddr 选项的功能。否则，为接口设置(或清除) IFF_POINTOPOINT 标志。 |
| hw class address      | 如接口驱动程序支持，则设定接口的硬件地址。 此选项必须后跟硬件的类型名称和硬件地址等价的可打印 ASCII 字符。当前支持的硬件类型包括 ether (以太网)， ax25 (AMPR AX.25)， ARCnet 和 netrom (AMPR NET/ROM)。 |
| multicast             | 为接口设定组播标志。 通常无须用此选项因为接口本身会正确设定此标志。 |
| address               | 为接口分配的 IP 地址。                                       |
| txqueuelen length     | 为接口设定传输队列的长度。可以为具有高时延的低速接口设定 较小值以避免在象 telnet 这样烦人的交互通信时大量高速的传输。 |



#### 注意

​       从内核版本 2.2 起不再有别名接口的显式接口统计信息了。打印出的源地址统计信息被同一接口的所有别名地址共享。打印出的源地址统计信息被同一接口的所有别名地址共享。 如果你需要每个地址的统计信息，就应该用 ipchains(8) 命令为地址加入显式的记帐规则。

## Windows下命令 ipconfig 说明

Windows 系统中把网卡描述为 adapter (网络适配器)

- 显示适配器信息

  > ipconfig

- 显示适配器详细信息

> ipconfig /all

- 更新所有适配器

  > ipconfig /renew

- 更新所有名称以 EL 开头的连接

  > ipconfig /renew EL*

- 释放所有匹配的连接， 例如 “有线以太网连接 1” 或  “有线以太网连接 2”

  > ipconfig /release *Con*

- 显示有关所有隔离舱的信息

  > ipconfig /allcompartments

- 显示有关所有隔离舱的详细信息

  > ipconfig /allcompartments /all

### 命令选项总览

```
ipconfig [/allcompartments] [/? | /all |
                                 /renew [adapter] | /release [adapter] |
                                 /renew6 [adapter] | /release6 [adapter] |
                                 /flushdns | /displaydns | /registerdns |
                                 /showclassid adapter |
                                 /setclassid adapter [classid] |
                                 /showclassid6 adapter |
                                 /setclassid6 adapter [classid] ]
```

adapter  连接名称 (允许使用通配符 * 和 ?，参见示例)

### 命令参数

| 参数          | 描述                                  |
| ------------- | ------------------------------------- |
| /?            | 显示帮助消息                          |
| /all          | 显示完整配置信息                      |
| /release      | 释放指定适配器的 IPv4 地址            |
| /release6     | 释放指定适配器的 IPv6 地址            |
| /renew        | 更新指定适配器的 IPv4 地址            |
| /renew6       | 更新指定适配器的 IPv6 地址            |
| /flushdns     | 清除 DNS 解析程序缓存                 |
| /registerdns  | 刷新所有 DHCP 租用并重新注册 DNS 名称 |
| /displaydns   | 显示 DNS 解析程序缓存的内容           |
| /showclassid  | 显示适配器允许的所有 DHCP 类 ID       |
| /setclassid   | 修改 DHCP 类 ID                       |
| /showclassid6 | 显示适配器允许的所有 IPv6 DHCP 类 ID  |
| /setclassid6  | 修改 IPv6 DHCP 类 ID                  |

默认情况下，仅显示绑定到 TCP/IP 的每个适配器的 IP 地址、子网掩码和
默认网关。

对于 Release 和 Renew，如果未指定适配器名称，则会释放或更新所有绑定
到 TCP/IP 的适配器的 IP 地址租用。

对于 Setclassid 和 Setclassid6，如果未指定 ClassId，则会删除 ClassId。
