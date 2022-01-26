# nmcli

## 

## nmcli命令描述

```
nmcli - 用于控制 NetworkManager 的命令行工具
```

nmcli命令是redhat7或者centos7之后的命令，该命令可以完成网卡上所有的配置工作，并且可以写入配置文件，永久生效。



## nmcli 对象描述

| object       | 描述                                      |
| ------------ | ----------------------------------------- |
| g[eneral]    | NetworkManager的一般状态和操作            |
| n[etworking] | 整体网络控制                              |
| r[adio]      | NetworkManager无线开关                    |
| c[onnection] | NetworkManager 连接                       |
| d[evice]     | NetworkManager 管理的设备                 |
| a[gent]      | NetworkManager secret 代理 或 polkit 代理 |
| m[onitor]    | 监控NetworkManager变更                    |

在拼写不存在冲突情况下可使用字母缩写代替object及其子项



## 常用范例

### 查看接口/设备信息

```
#以下命令等价
nmcli device status

nmcli d status

nmcli d s

nmcli d -s
```



### 查看连接信息

```
#以下命令等价
nmcli connection show

nmcli c show

nmcli c s

nmcli c -s
```



### 启动/停止网卡

```
nmcli device connect ens33
# 等价
nmcli d connect ens33
# 等价
nmcli d c ens33

nmcli device disconnect ens33
# 等价
nmcli d d ens33
```

### 或使用

```
nmcli connection up ens33
# 等价
nmcli c up ens33
# 等价
nmcli c u ens33

nmcli connection down ens33
# 等价
nmcli c d ens33
```

P.S:建议使用 nmcli device disconnect(connect) interface-name
因为使用该命令，在启动某个连接前或发生外部事件时不会自动连接

## 场景流程范例

### 创建网卡/连接

属性别名请参考 [属性别名](#alias) [属性别名](#"PROPERTY ALIASES 属性别名")

- 创建动态获取ip地址的连接,con-name是创建连接的名字，ifname是物理设备，网络接口

  ```
  nmcli c add type ethernet con-name dhcp-ens192 ifname ens192
  ```

- 创建静态ip地址连接

  ```
  nmcli c add type ethernet con-name static-ens192 ifname ens192 ip4 10.0.13.218/24 gw4 10.0.13.1
  ls /etc/sysconfig/network-scripts/
  # 可查看到多了一个网卡 ifcfg-static-ens192 
  cat /etc/sysconfig/network-scripts/ifcfg-static-ens192 
  # 输出如下类型
  TYPE=Ethernet
  PROXY_METHOD=none
  BROWSER_ONLY=no
  BOOTPROTO=none
  IPADDR=10.0.13.218
  PREFIX=24
  GATEWAY=10.0.13.1
  DEFROUTE=yes
  IPV4_FAILURE_FATAL=no
  IPV6INIT=yes
  IPV6_AUTOCONF=yes
  IPV6_DEFROUTE=yes
  IPV6_FAILURE_FATAL=no
  IPV6_ADDR_GEN_MODE=stable-privacy
  NAME=static-ens192
  UUID=7a8c2b90-0a1c-43db-9660-61793d8dcded
  DEVICE=ens192
  ONBOOT=yes
  ```

- 创建bridge静态ip地址连接

  ```
  nmcli c add type bridge con-name ens6 ifname ens6 ip4 10.0.13.6/24 gw4 10.0.13.1
  ```

PS：创建连接的意思，相当于在/etc/sysconfig/network-scripts/目录下创建了一个ifcfg-${con-name}文件，创建多个连接，则会同时创建多个文件。



### 查看设备状态

```
nmcli device status
# 输出类似如下信息
DEVICE        TYPE      STATE   CONNECTION
ens33         ethernet  已连接  ens33
cni0          bridge    已连接  cni0
ens6          bridge    已连接  ens6
virbr0        bridge    已连接  virbr0
```

发现 ethernet 类型的网卡设备是看不到的，只看到了 bridge 类型的网卡设备 ens6 且是启动了的



### 查看连接信息

```
nmcli connection

# 输出类似如下信息
NAME           UUID                                  TYPE      DEVICE
ens33          8ebdfc34-dc2e-3549-817f-ba96ab616e52  ethernet  ens33
cni0           28c6097c-2e4a-4c70-8ac5-53e72adcaac9  bridge    cni0
ens6           3c8ce22b-0503-4978-adb0-8b81d2a8cede  bridge    ens6
virbr0         9a64ea3a-eb84-4121-8caa-d19d661f7c7a  bridge    virbr0
dhcp-ens192    031bd33c-9ef8-4dc0-a9ad-b24e9da229fb  ethernet  --
static-ens192  d474a263-522d-4969-ab92-bfa2e4a4c4ef  ethernet  --

```

dhcp-ens192 和 static-ens192 有连接，但是没有对应设备

针对网卡类型是`ethernet`的虚拟机，需要先新增一个虚拟网卡，否则无法绑定设备，网卡无法启动



### 查看设备信息

```
nmcli c modify static-ens192 ip4 10.0.13.219
```



### 修改IP地址

```
nmcli c modify static-ens192 ip4 10.0.13.219
```

 修改后不会立即生效，需要重新加载或者重新启用一下网卡或者重新连接一下网卡。

对应的网卡文件也会修改，多了一列 `IPADDR1=10.0.13.219`，并不是替换`IPADDR`的值

```
# 重新启用一下网卡
nmcli device connect static-ens192
# 等价 (但不推荐) 重新连接一下网卡
nmcli connection up static-ens192
```



### 修改连接是否为自启（默认自启）

```
nmcli c modify static-ens192 connection.autoconnect no
```



### 配置连接的dns

为连接配置dns

```
nmcli connection modify static-ens192 ipv4.dns 8.8.8.8
```

 为连接添加dns

```
nmcli connection modify static-ens192 +ipv4.dns 8.8.4.4
```

需要重新激活连接方可生效

```
nmcli connection up static-ens192
```



### 删除连接

```
nmcli connection delete dhcp-ens192 static-ens192 ens6
```





## 范例

本节介绍nmcli使用的各种示例。如果您想要更多，请参阅  nmcli-examples(7)手册页。

- nmcli -t -f RUNNING general

  > 告知NetworkManager是否正在运行。

- nmcli -t -f STATE general

  > 显示NetworkManager的总体状态。

- nmcli radio wifi off

  > 关闭Wi-Fi

- nmcli connection show

  > 列出NetworkManager拥有的所有连接。

- nmcli -p -m multiline -f all con show

  > 以multi-line模式显示所有配置的连接。

- nmcli connection show --active

  > 列出所有当前活动的连接。

- nmcli -f name,autoconnect c s

  > 显示所有连接 profile 名称及其自动连接属性。

- nmcli -p connection show "My default em1"

  > 显示 "My default em1" 连接 profile 的详细信息。

- nmcli --show-secrets connection show "My Home Wi-Fi"

  > 显示带有所有密码的 "My Home Wi-Fi" 连接 profile 的详细信息。如果没有 --show-secrets 选项，则不会显示。

- nmcli -f active connection show "My default em1"

  > 显示 "My default em1" 活动连接的详细信息，如IP、DHCP信息等。

- nmcli -f profile con s "My wired connection"

  > 显示带有 "My wired connection" 名称的连接 profile 的静态配置详细信息。

- nmcli -p con up "My wired connection" ifname eth0

  >在接口eth0上激活名为 "My wired connection" 的连接 profile。 -p 选项使nmcli显示激活的进度。

- nmcli con up 6b028a27-6dc9-4411-9886-e9ad1dd43761 ap 00:3A:98:7C:42:D3

>使用UUID 6b028a27-6dc9-4411-9886-e9ad1dd43761连接Wi-Fi连接到BSSID为00:3A:98:7C:42:D3的AP。

- nmcli device status

>显示所有设备的状态。

- nmcli dev disconnect em2

>断开接口em2上的连接，并将设备标记为无法自动连接。因此，在设备的 'autoconnect' 设置为TRUE或用户手动激活连接之前，设备上不会自动激活任何连接。

-  nmcli -f GENERAL,WIFI-PROPERTIES dev show wlan0

  > 显示wlan0接口的详细信息；仅显示 GENERAL 和 WIFI-PROPERTIES 部分。

- nmcli -f CONNECTIONS device show wlp3s0

> 显示Wi-Fi接口wlp3s0的所有可用连接 profiles。

- nmcli dev wifi

> 列出NetworkManager已知的可用Wi-Fi接入点。

- nmcli dev wifi con "Cafe Hotspot 1" password caffeine name "My cafe"

> 创建名为 "My cafe" 的新连接，然后使用密码 "caffeine" 将其连接到 "Cafe Hotspot 1" SSID。这在首次连接到 "Cafe Hotspot 1" 时非常有用。下一次，最好使用nmcli con up id "My cafe" ，这样就可以使用现有的连接 profile，而不需要创建额外的连接 profile。

- nmcli -s dev wifi hotspot con-name QuickHotspot

> 创建热点 profile 并将其连接。打印用户从其他设备连接到热点时应使用的热点密码。

- nmcli dev modify em1 ipv4.method shared

  > 使用em1设备启动IPv4连接共享。在设备断开连接之前，共享将处于活动状态。

- `nmcli dev modify em1 ipv6.address 2001:db8::a:bad:c0de`

  > 将IP地址临时添加到设备。当再次激活同一连接时，该地址将被删除。

- nmcli connection add type ethernet autoconnect no ifname eth0

  > 通过自动IP配置（DHCP）以非交互方式将以太网连接添加到eth0接口，并禁用连接的自动连接标志。

- nmcli c a ifname Maxipes-fik type vlan dev eth0 id 55

  > 以非交互方式添加ID为55的VLAN连接。连接将使用eth0，VLAN接口将命名为Maxipes fik。

- nmcli c a ifname eth0 type ethernet ipv4.method disabled ipv6.method link-local

  > 以非交互方式添加将使用eth0以太网接口且仅配置IPv6链路本地地址的连接。

- nmcli connection edit ethernet-em1-2

  > 在交互式编辑器中编辑现有的“ethernet-em1-2”连接。

- nmcli connection edit type ethernet con-name "yet another Ethernet connection"

  > 在交互式编辑器中添加新的以太网连接。

- nmcli con mod ethernet-2 connection.autoconnect no

  > 修改 'ethernet-2' 连接的 'connection' 设置中的 'autoconnect' 属性。
  >
  > modifies 'autoconnect' property in the 'connection' setting of 'ethernet-2' connection.

- nmcli con mod "Home Wi-Fi" wifi.mtu 1350

  > 修改 'Home Wi-Fi' 连接的 'wifi' 设置中的 'mtu' 属性。

- nmcli con mod em1-1 ipv4.method manual ipv4.addr "192.168.1.23/24 192.168.1.1, 10.10.1.5/8, 10.0.0.11"

  > 设置手动寻址和em1-1 profile 中的地址。

- nmcli con modify ABC +ipv4.dns 8.8.8.8

  > 将Google公共DNS服务器附加到ABC profile 中的DNS服务器。

- nmcli con modify ABC -ipv4.addresses "192.168.100.25/24 192.168.1.1"

  > 从（静态）配置文件ABC中删除指定的IP地址。

- nmcli con import type openvpn file ~/Downloads/frootvpn.ovpn

  > 将OpenVPN配置导入NetworkManager。

- nmcli con export corp-vpnc /home/joe/corpvpn.conf

  > 将NetworkManager VPN配置文件公司vpnc导出为标准Cisco（vpnc）配置。



## 更多范例参考

https://developer-old.gnome.org/NetworkManager/unstable/nmcli-examples.html



## man nmcli 查看使用手册

### 描述

```shell
nmcli是用于控制 NetworkManager 和报告网络状态的命令行工具。它可以用来代替 nm-applet 或其他图形客户端。

nmcli用于根据需要创建、显示、编辑、删除、激活和停用网络连接以及控制和显示网络设备状态。

典型用途包括：
·脚本: 通过nmcli使用NetworkManager，而不是手动管理网络连接。nmcli支持简洁的输出格式这更适合于脚本处理。请注意，NetworkManager还可以执行称为“调度程序脚本”的脚本，以响应网络事件。有关这些调度程序脚本的详细信息，请参阅 NetworkManager(8)。

·服务器、无头计算机和终端: nmcli可用于在无GUI的情况下控制NetworkManager，包括创建、编辑、启动和停止网络连接并查看网络状态。
```



### 命令格式总览

```shell
nmcli [OPTIONS...] {help | general | networking | radio | connection | device | agent | monitor} [COMMAND] [ARGUMENTS...]
```



### 命令选项

| 参数                                                   | 描述                                                         |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| -a \| --ask                                            | 使用此选项时，nmcli将停止并请求任何缺少的必需参数，因此不要将此选项用于脚本等非交互目的。例如，此选项控制如果连接到网络需要密码，是否会提示您输入密码。 |
| -c \| --colors {yes \| no \| auto}                     | 此选项控制颜色输出（使用终端转义序列）。yes 启用颜色，no 禁用颜色，仅当标准输出定向到终端时，auto 生成颜色。默认值为“auto”。<br/><br/>实际使用的颜色按照终端颜色中的说明进行配置。d(5)。有关nmcli支持的颜色名称列表，请参阅“颜色”部分。 |
| --complete-args                                        | nmcli将列出最后一个参数可能的完成情况，而不是执行所需的操作。这对于在shell中实现参数完成非常有用。<br/><br/>退出状态将指示成功，或返回代码65以指示最后一个参数是文件名<br/><br/>NetworkManager附带对GNU Bash的命令完成支持。 |
| -e \|  --escape {yes \| no }                           | 是否转义：\以简洁的表格模式显示的字符。转义字符是\。<br/><br/>如果省略，则默认为yes |
| -f \| --fields {field1,field2... \| all \| common}     | 此选项用于指定应打印哪些字段（列名）。特定命令的有效字段名称不同。通过向--fields选项提供无效值来列出可用字段。all用于打印命令的所有有效字段值。common用于打印命令的公共字段值。<br/><br/>如果省略，默认值是 common。 |
| -g \| --get-values {field1,field2... \| all \| common} | 此选项用于打印特定字段中的值。它基本上是--mode tabular--terse--fields的快捷方式，是检索特定字段值的便捷方式。每行打印一个值，不带标题。<br/><br/>如果指定了节(section)而不是字段，则将打印节(section)名，后跟属于该节(section)的字段的冒号分隔值，所有字段都在同一行上。 |
| -h \| --help                                           | 打印帮助信息                                                 |
| -m \| --mode {tabular \| multiline}                    | 在表格和多行输出之间切换：<br>tabular <br>    输出是一个表，其中每行描述一个条目。列定义条目的特定属性。<br>multiline<br>    每个条目包含多行，每个属性位于其自己的行上。这些值以属性名称作为前缀。<br>如果省略，大多数命令的默认值为 tabular 形式。对于生成更多结构化信息的命令，无法显示在单行上，默认为 multiline。目前，它们是：<br>· nmcli connection show ID<br>· nmcli device show |
| -p \| --pretty                                         | 美化输出。这导致nmcli为用户生成易于读取的输出，即对齐值、打印标题等。 |
| -s \| --show-secrets                                   | 使用此选项时，nmcli将显示操作输出中可能存在的密码和机密。此选项还影响用户输入的回显密码。 |
| -t \| --terse                                          | 简洁输出。此模式是专为计算机（脚本）处理而设计的。           |
| -v \| --version                                        | 显示 nmcli 版本                                              |
| -w \| --wait seconds                                   | 此选项设置nmcli等待NetworkManager完成操作的超时时间。它对于可能需要较长时间才能完成的命令（例如连接激活）特别有用。<br/><br/>指定值0将指示nmcli不等待，而是立即以成功状态退出。默认值取决于执行的命令。 |
| metric M                                               | 把选路表中的路由值字段(由选路进程使用)设为M。                |
| mss M                                                  | 把基于此路由之上的连接的TCP最大报文段长度设为M字节。这通常只用于优化选路设置。默认值为536。 |
| window W                                               | 把基于此路由之上的连接的TCP窗口长度设为W字节。这通常只用于AX.25网络和不能处理背对背形式的帧的设备。 |
| irtt I                                                 | 把基于此路由之上的TCP连接的初始往返时间设为I毫秒(1-12000)。这通常也只用于AX.25网络。如果省略此选项，则使用RFC1122的缺省值300ms。 |
| reject                                                 | 设置一条阻塞路由以使一条路由查找失败。这用于在使用缺省路由前先屏蔽掉一些网络。但这并不起到防火墙的作用。 |
| mod, dyn, reinstate                                    | 设置一条动态的或更改过的路由。这些标志通常只由选路进程来设置。这只用于诊断目的， |
| dev If                                                 | 强制使路由与指定的设备关联，因为否则内核会自己来试图检测相应的设备(通常检查已存在的路由和加入路由的设备的规格)。在多数正常的网络上无需使用。<br/><br/>如果dev  If是命令行上最后一个指定的选项，那么可以省略关键字dev，因为它是缺省值。否则路由修改对象(metric - netmask- gw- dev)无关紧要。 |



### general 命令

```
nmcli general {status | hostname | permissions | logging} [ARGUMENTS...]
```

使用此命令可显示NetworkManager状态和权限。您还可以获取和更改系统主机名，以及NetworkManager日志记录级别和域。

| 参数                                       | 描述                                                         |
| ------------------------------------------ | ------------------------------------------------------------ |
| status                                     | 显示NetworkManager的总体状态。当没有为nmcli general提供其他命令时，这是默认操作。 |
| hostname [hostname]                        | 获取并更改系统主机名。如果没有参数，则打印当前配置的主机名。当您传递主机名时，它将被移交给NetworkManager以设置为新的系统主机名。<br/><br/>请注意，术语“system”主机名也可能被其他程序或工具称为“persistent”或“static”。在大多数发行版中，主机名存储在/etc/hostname文件中。例如，systemd hostnamed服务使用术语“static”主机名，它仅在启动时读取/etc/hostname文件。 |
| permissions                                | 显示调用方对NetworkManager提供的各种已验证操作的权限，如启用和禁用网络、更改Wi-Fi和WWAN状态、修改连接等。 |
| logging [level level] [domains domains...] | 获取并更改NetworkManager日志记录级别和域。不带任何参数，将显示当前日志记录级别和域。要更改日志状态，请提供级别和或域参数。请参阅NetworkManager。可用级别和域值的配置(5)。 |



### networking 控制命令

```
nmcli networking {on | off | connectivity} [ARGUMENTS...]
```

查询NetworkManager网络状态，启用和禁用网络。

| 参数                 | 描述                                                         |
| -------------------- | ------------------------------------------------------------ |
| on, off              | 通过NetworkManager启用或禁用网络控制。禁用网络时，NetworkManager管理的所有接口都将停用。 |
| connectivity [check] | 获取网络连接状态。可选的check参数告诉NetworkManager重新检查连接，否则将显示最新的已知连接状态，而无需重新检查。<br/><br>可能的状态有：<br>none<br>    主机未连接到任何网络。<br>portal<br/>   主机位于捕获门户之后，无法访问完整的Internet。<br/>limited<br/>   主机已连接到网络，但无法访问Internet。<br/>full<br/>   主机已连接到网络，并且可以完全访问Internet<br/>unknown<br/>   找不到连接状态。<br/> |



### radio(无线) 传输控制命令

```
nmcli radio {all | wifi | wwan} [ARGUMENTS...]
```

显示 radio 开关状态，或启用和禁用开关。

| 参数             | 描述                                                         |
| ---------------- | ------------------------------------------------------------ |
| wifi [on \| off] | 在NetworkManager中显示或设置Wi-Fi的状态。如果未提供参数，则打印Wi-Fi状态；on 启用Wi-Fi；off 将禁用Wi-Fi。 |
| wwan [on \| off] | 在NetworkManager中显示或设置WWAN（移动宽带）的状态。如果未提供参数，则打印移动宽带状态；on 可启用移动宽带，off 可禁用移动宽带。 |
| all [on \| off]  | 同时显示或设置前面提到的所有无线电开关。                     |



### activity monitor (活动监视器)命令

```
nmcli monitor
```

观察NetworkManager活动。监视连接状态、设备或连接配置文件中的更改。

另请参阅nmcli连接监视器和nmcli设备监视器，以查看某些设备或连接中的更改。



### connection  管理命令

```
nmcli connection {show | up | down | modify | add | edit | clone | delete | monitor | reload | load | import | export} [ARGUMENTS...]
```

NetworkManager将所有网络配置存储为“连接(connections)”，连接是描述如何创建或连接网络的数据集合（Layer2 详细信息、IP寻址等）。当设备使用连接的配置创建或连接到网络时，连接是“活动的(active)”。可能有多个连接应用于一个设备，但在任何给定时间，该设备上只能有一个连接处于活动状态。附加连接可用于在不同网络和配置之间进行快速切换。

考虑通常连接到启用DHCP的网络的机器，但有时连接到使用静态IP寻址的测试网络。与每次更改网络时手动重新配置eth0不同，设置可以保存为两个连接，两个连接都适用于eth0，一个用于DHCP（称为 default），另一个用于静态寻址详细信息（称为 testing）。连接到启用DHCP的网络时，用户将运行nmcli con up default，连接到静态网络时，用户将运行nmcli con up testing。

| 参数                                                         | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| show [--active] [--order [+-]category:...]                   | 列出内存和磁盘上的连接配置文件，如果设备正在使用该连接配置文件，其中一些连接配置文件也可能处于活动状态。如果没有参数，将列出所有配置文件。当指定--active选项时，仅显示活动配置文件。<br/><br/>--order选项可用于获取连接的自定义顺序。连接可以按活动状态（active）、名称（name）、类型（type）或D总线路径（path）排序。如果根据排序顺序类别，连接相等，则可以指定其他类别。默认排序顺序等效于--order active:name:path. + 没有前缀表示按升序（字母或数字）排序，- 表示逆（降序）排序。类别名称可以缩写（例如--order-a:na）。 |
| show [--active] [id \| uuid \| path \| apath] ID...          | 显示指定连接的详细信息。默认情况下，将同时显示静态配置和活动连接数据。当指定--active选项时，只考虑活动配置文件。使用全局--show secrets选项显示与配置文件关联的机密。<br><br/>如果id不明确，则可以使用id、uuid、path和apath关键字。指定关键字的可选ID包括：<br>id<br>   ID表示连接名称。<br>uuid<br>   ID表示连接UUID。<br/>path<br/>   ID表示格式为/org/freedesktop/NetworkManager/Settings/num或just num的D总线静态连接路径。<br/>apath<br/>   ID表示D总线活动连接路径，格式为/org/freedesktop/NetworkManager/ActiveConnection/num或just num。<br/>可以使用全局--fields选项过滤输出。使用以下值：<br/>profile<br/>   仅显示静态配置文件配置。<br/>active<br/>   仅显示活动连接数据（当配置文件处于活动状态时）<br/><br/>还可以指定特定字段。对于静态配置，请使用nm-settings(5)手册页面中所述的设置和属性名称。对于活动数据，请使用GENERAL、IP4、DHCP4、IP6、DHCP6、VPN。<br/><br/>未向nmcli连接发出命令时，默认操作为 nmcli connection show |
| up [id \| uuid \| path] ID [ifname ifname] [ap BSSID] [passwd-file file] | 激活一个连接。该连接由其名称、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字id、uuid或path。当需要特定设备激活上的连接时，应提供带有接口名称的ifname选项。如果未提供ID，则需要一个ifname，NetworkManager将激活给定ifname的最佳可用连接。对于VPN连接，ifname选项指定基本连接的设备。ap选项指定在Wi-Fi连接情况下应使用的特定ap。<br/>如果未指定--wait选项，则默认超时为90秒。<br/><br/>有关指定关键字的ID的说明，请参见上面的连接显示。<br/><br/>可供选择的方案有：<br/>ifname<br/>   将用于激活的接口。<br/>ap<br/>   命令应连接到的AP的BSSID（用于Wi-Fi连接）。<br/>passwd-file<br/>   某些网络在激活期间可能需要凭据。您可以使用此选项提供这些凭据。文件的每一行应包含一个密码，格式如下：<br/>       setting_name.property_name:the password<br/>   例如，对于带有PSK的WPA Wi-Fi，线路将为<br/>       802-11-wireless-security.psk:secret12345<br/>   对于802.1X密码，线路为<br/>       802-1x.password:my 1X password<br/><br/>nmcli 还接受 wifi-sec 和 wifi strings，而不是802-11-wireless-security。当NetworkManager需要密码但未提供密码时，nmcli 将在使用 --ask 运行时请求密码。如果未传递 --ask，NetworkManager可以询问可能正在运行的另一个秘密代理（通常是GUI秘密代理，如 nm-applet 或 gnome-shell）。 |
| down [id \| uuid \| path \| apath] ID...                     | 停用设备的连接，而不阻止设备进一步自动激活。可以向该命令传递多个连接。<br/><br/>请注意，此命令将停用指定的活动就绪连接，并通过查找设置了“自动连接”标志的合适连接来执行自动激活。请注意，停用的连接配置文件在内部被阻止再次自动连接。因此，在重新启动或用户执行取消阻止自动连接的操作（如修改配置文件或显式激活配置文件）之前，它不会自动连接。<br/><br/>在大多数情况下，您可能希望改用设备断开连接命令。<br/><br/>该连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid、path或apath。<br/><br/>有关指定关键字的ID的说明，请参见上面的连接显示。<br/><br/>如果未指定 --wait 选项，则默认超时为10秒。 |
| modify [--temporary] [id \| uuid \| path] ID {option value \| [+\|-]setting.property value}... | 在连接配置文件中添加、修改或删除属性。<br/><br/>要设置属性，只需指定属性名称，后跟值。空值（“”）将删除属性值。<br/><br/>除了属性外，还可以对某些属性使用短名称。有关详细信息，请参阅“属性别名(PROPERTY ALIASES)”部分。<br/><br/>如果要将项附加到现有值，请使用+属性名称作为前缀。如果只想从容器类型属性中删除一个项，请使用-属性名称作为前缀，并指定要删除的项的值或从零开始的索引（或具有命名选项的属性的选项名称）作为值。+和-修饰符仅对ipv4等多值（容器）属性具有实际效果。ipv4.dns，ipv4.addresses，bond.options等。<br/><br/>有关设置和属性名称及其说明和默认值的完整参考，请参见nm-settings(5)。设置和属性可以缩写，只要它们是唯一的。<br/><br/>该连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid或path 。 |
| add [save {yes \| no}] {option value \| [+\|-]setting.property value}... | 使用指定的属性创建新连接。<br/><br/>您需要使用属性和值对描述新创建的连接。有关完整参考，请参阅 nm-settings(5) 。也可以使用“属性别名(PROPERTY ALIASES)”部分中描述的别名。语法与nmcli connection modify命令的语法相同。<br/><br/>要构建有意义的连接，您至少需要设置连接。为已知的NetworkManager连接类型之一键入属性（或使用类型别名）：<br>          ·   ethernet<br/>           ·   wifi<br/>           ·   wimax<br/>          ·   pppoe<br/>           ·   gsm<br/>           ·   cdma<br/>           ·   infiniband<br/>           ·   bluetooth<br/>           ·   vlan<br/>           ·   bond<br/>           ·   bond-slave<br/>           ·   team<br/>           ·   team-slave<br/>           ·   bridge<br/>           ·   bridge-slave<br/>           ·   vpn<br/>           ·   olpc-mesh<br/>           ·   adsl<br/>           ·   tun<br/>           ·   ip-tunnel<br/>           ·   macvlan<br/>           ·   vxlan<br/>           ·   dummy<br/><br/>示例部分介绍了最典型的用途。<br/><br/>除了属性和值之外，还接受两个特殊选项：<br/>save<br/>    控制连接是否应为持久连接，即NetworkManager应将其存储在磁盘上（默认值：是）。<br/>--<br/>    如果遇到单个--参数，则忽略它。这是为了与nmcli上的旧版本兼容。 |
| edit {[id \| uuid \| path] ID \| [type type] [con-name name] } | 使用交互式编辑器编辑现有连接或添加新连接。<br/>现有连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid或path。<br/>有关指定关键字的ID的说明，请参见上面的连接显示。不提供ID意味着将添加新连接。<br/>交互式编辑器将引导您完成连接编辑，并允许您通过简单的菜单驱动界面根据需要更改连接参数。编辑器指示可以修改的设置和属性，并提供联机帮助。<br/><br/>可用选项：<br/>type<br/>    新连接的类型；有效类型与“连接添加”命令的类型相同。<br/>con-name<br/>    新连接的名称。稍后可以在编辑器中对其进行更改。<br/><br/>有关所有NetworkManager设置和属性名称及其说明，请参见 nm-settings(5) ；示例编辑器会话的 nmcli-examples(7)。 |
| clone [--temporary] [id \| uuid \| path] ID new_name         | 克隆连接。要克隆的连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid或path。有关指定关键字的ID的说明，请参见上面的连接显示。new_name是新克隆连接的名称。除连接外，新连接将是完全相同的副本。id（新名称）和连接。uuid（生成的）属性。<br/><br/>除非指定了--temporary选项，否则新的连接配置文件将保存为持久性，在这种情况下，重新启动NetworkManager后新配置文件将不存在。 |
| delete [id \| uuid \| path] ID...                            | 删除已配置的连接。要删除的连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid或路径。有关指定关键字的ID的说明，请参见上面的连接显示。<br/><br/>如果未指定--wait选项，则默认超时为10秒。 |
| monitor [id \| uuid \| path] ID...                           | 监视连接配置文件活动。每当指定的连接更改时，此命令将打印一行。要监视的连接由其name、UUID或D-Bus路径标识。如果ID不明确，则可以使用关键字ID、uuid或path。有关指定关键字的ID的说明，请参见上面的连接显示。<br/><br/>如果未指定任何连接配置文件，则监视所有连接配置文件。当所有受监视的连接消失时，该命令终止。如果要监视连接创建，请考虑使用 nmcli monitor 命令使用全局监视器。 |
| reload                                                       | 从磁盘重新加载所有连接文件。默认情况下，NetworkManager不监视对连接文件的更改。因此，您需要使用此命令，以便在更改连接配置文件时通知NetworkManager从磁盘重新读取连接配置文件。但是，可以启用自动加载功能，然后NetworkManager将在连接文件发生更改时重新加载连接文件（NetworkManager.conf(5)中的monitor connection files=true）。 |
| load filename...                                             | 从磁盘加载/重新加载一个或多个连接文件。手动编辑连接文件后使用此选项，以确保NetworkManager了解其最新状态。 |
| import [--temporary] type type file file                     | 将外部/外部配置作为NetworkManager连接配置文件导入。输入文件的类型由type选项指定。<br/><br/>目前只支持VPN配置。配置由NetworkManager VPN插件导入。类型值与nmcli连接添加中vpn类型选项的值相同。VPN配置由VPN插件导入。因此，必须安装正确的VPN插件，以便nmcli可以导入数据。<br/><br/>除非指定了--temporary选项，否则导入的连接配置文件将保存为永久性，在这种情况下，重新启动NetworkManager后，新配置文件将不存在。 |
| export [id \| uuid \| path] ID [file]                        | 导出连接。<br/><br/>目前只支持VPN连接。必须安装正确的VPN插件，以便nmcli可以导出连接。如果未提供文件，VPN配置数据将打印到标准输出。 |



###  device 管理命令

```
nmcli device {status | show | set | connect | reapply | modify | disconnect | delete | monitor | wifi | lldp} [ARGUMENTS...]
```

显示和管理网络接口。

| 参数                                                         | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| status                                                       | 打印设备的状态。<br/><br/>如果未向nmcli设备指定命令，则这是默认操作。 |
| show [ifname]                                                | 显示有关设备的详细信息。在没有参数的情况下，检查所有设备。要获取特定设备的信息，必须提供接口名称。 |
| set [ifname] ifname [autoconnect {yes \| no}] [managed {yes \| no}] | 设置设备属性。                                               |
| connect ifname                                               | 连接设备。NetworkManager将尝试查找将被激活的合适连接。它还将考虑未设置为自动连接的连接。如果不存在兼容连接，将创建并激活带有默认设置的新配置文件。这将区分nmcli connection up ifname "\$DEVICE" 和nmcli device connect "$DEVICE"<br/><br/>如果未指定--wait选项，则默认超时为90秒。 |
| reapply ifname                                               | 尝试使用自上次应用以来对当前活动连接所做的更改更新设备。     |
| modify ifname {option value \| [+\|-]setting.property value}... | 修改设备上当前活动的设置。<br/><br/>此命令允许您临时更改特定设备上的活动配置。这些更改不会保留在连接配置文件中。<br/><br/>有关可用属性的列表，请参见 nm-settings(5) 。请注意，无法在已连接的设备上更改某些属性。<br/><br/>也可以使用 PROPERTY ALIASES 部分中描述的别名。语法与nmcli connection modify命令的语法相同。 |
| disconnect ifname...                                         | 断开设备并防止设备在无需用户/手动干预的情况下自动激活更多连接。请注意，断开软件设备的连接可能意味着这些设备将消失。<br/><br/>如果未指定--wait选项，则默认超时为10秒。 |
| delete ifname...                                             | 删除设备。该命令将从系统中删除接口。请注意，这仅适用于软件设备，如bonds、bridges、teams等。命令无法删除硬件设备（如以太网）。<br/><br/>如果未指定--wait选项，则默认超时为10秒。 |
| monitor [ifname...]                                          | 监视设备活动。每当指定的设备更改状态时，此命令将打印一行。<br/><br/>在未指定接口的情况下监视所有设备。当所有指定的设备消失时，监视器终止。如果要监视设备添加，请考虑使用  nmcli monitor 命令全局监视器。 |
| wifi [list [--rescan \| auto \| no \| yes] [ifname ifname] [bssid BSSID]] | 列出可用的Wi-Fi接入点。ifname和bssid选项可分别用于列出特定接口或具有特定bssid的AP。<br/>默认情况下，nmcli确保接入点列表不超过30秒，并在必要时触发网络扫描。--rescan可用于强制或禁用扫描，无论访问点列表有多新鲜。 |
| wifi connect (B)SSID [password password] [wep-key-type {key \| phrase}] [ifname ifname] [bssid BSSID] [name name] [private {yes \| no}] [hidden {yes \| no}] | 连接到SSID或BSSID指定的Wi-Fi网络。该命令查找匹配的连接或创建一个连接，然后在设备上激活它。这是在GUI客户端中单击SSID的命令行对应项。如果网络连接已存在，则可以按如下方式启动（激活）现有配置文件：nmcli con up id name。请注意，如果以前没有连接，则仅支持open、WEP和WPA-PSK网络。还假设IP配置是通过DHCP获得的。<br/><br/>如果未指定--wait选项，则默认超时为90秒。<br/><br/>可供选择的方案有：<br/>password<br/>    安全网络（WEP或WPA）的密码。<br/>wep-key-type<br/>    WEP密钥的类型，ASCII/十六进制密钥的密钥或密码短语的短语。<br/>ifname<br/>    将用于激活的接口。<br/>bssid<br/>    如果指定，创建的连接将仅限于BSSID。<br/>name<br/>    如果指定，连接将使用该名称（否则NM将自己创建一个名称）。<br/>private的<br/>    如果设置为 yes，则连接将仅对创建它的用户可见。否则，连接是系统范围的，这是默认设置。<br/>hidden的<br/>    首次连接到未广播其SSID的AP时设置为 yes。否则将找不到SSID，并且连接尝试将失败。 |
| wifi hotspot [ifname ifname] [con-name name] [ssid SSID] [band {a \| bg}] [channel channel] [password password] | 创建一个Wi-Fi热点。该命令根据Wi-Fi设备功能创建热点连接配置文件，并在设备上激活该配置文件。如果设备/驱动程序支持，热点将使用WPA进行保护，否则将使用WEP。使用连接断开或设备断开来停止热点。<br/>热点的参数可能受可选参数的影响：<br/>ifname<br/>    使用什么Wi-Fi设备。<br/>con-name<br/>    创建的热点连接配置文件的名称。<br/>ssid<br/>    热点的SSID。<br/>band<br/>    要使用的Wi-Fi频段。<br/>channel<br/>    要使用的Wi-Fi频道。<br/>password<br/>    用于创建的热点的密码。如果未提供，nmcli将生成密码。密码为WPA预共享密钥或WEP密钥。<br/><br/>请注意--show secrets全局选项可用于打印热点密码。它非常有用，尤其是在生成密码时。 |
| wifi rescan [ifname ifname] [ssid SSID...]                   | 请求NetworkManager立即重新扫描可用的访问点。NetworkManager会定期扫描Wi-Fi网络，但在某些情况下，手动开始扫描可能会很有用（例如，在恢复计算机后）。通过使用ssid，可以扫描特定ssid，这对于具有隐藏ssid的AP非常有用。您可以提供多个ssid参数以扫描更多ssid。<br/><br/>此命令不显示AP，请使用nmcli设备wifi列表。 |
| lldp [list [ifname ifname]]                                  | 显示通过链路层发现协议（LLDP）学习到的有关相邻设备的信息。ifname选项只能用于列出给定接口的邻居。必须在连接设置中启用该协议 |



###  secret agent 命令

```
nmcli agent {secret | polkit | all}
```

以NetworkManager秘密代理或polkit代理的身份运行nmcli。

| 参数   | 描述                                                         |
| ------ | ------------------------------------------------------------ |
| secret | 将nmcli注册为NetworkManager秘密代理并侦听秘密请求。通常不需要此命令，因为nmcli可以在连接到网络时处理机密。但是，当您使用另一个工具激活连接，并且没有可用的秘密代理（如nm-applet）时，您可能会发现该命令很有用。 |
| polkit | 将nmcli注册为用户会话的polkit代理，并侦听授权请求。通常不需要此命令，因为nmcli可以处理与NetworkManager操作相关的polkit操作（在使用--ask运行时）。但是，如果希望运行简单的基于文本的polkit代理，并且没有桌面环境的代理，则可能会发现该命令很有用。请注意，运行此命令会使nmcli处理所有polkit请求，而不仅仅是与NetworkManager相关的请求，因为该会话只能运行一个polkit代理。 |
| all    | 作为NetworkManager机密和polkit代理运行nmcli。                |



###  <span id="alias">PROPERTY ALIASES 属性别名</span>

除了属性值对之外，连接添加、连接修改和设备修改也接受一些属性的简短形式。它们的存在是为了方便。某些别名可能会同时影响多个连接属性。

下面是别名的概述。实际连接类型用于消除这些选项与同名选项之间的歧义

对多种连接类型（如mtu）有效的。

表1.所有连接的选项

| 别名        | 属性                      | 说明                                                         |
| ----------- | ------------------------- | ------------------------------------------------------------ |
| type        | connection.type           | 此别名还接受bond slave、team slave和bridge slave的值。他们创建以太网连接配置文件。不鼓励使用它们，而支持使用带有主选项的特定类型。 |
| con-name    | connection.id             | 未提供时，将生成默认名称：\<type>\[-\<ifname>]\[-\<num>]     |
| autoconnect | connection.autoconnect    |                                                              |
| ifname      | connection.interface-name | \* 值将被解释为无值，使连接配置文件接口独立。注意：在 * 周围使用引号可抑制外壳扩展。对于bond、team和bridge连接，如果未设置，将生成默认名称。 |
| master      | connection.master         | 此处指定的值将被规范化。可以使用ifname/、uuid/或id/作为前缀来消除歧义。 |
| slave-type  | connection.slave-type     |                                                              |



#### Table 1. Options for all connections

```
┌────────────┬───────────────────────────┬─────────────────────────────────────┐
│Alias       │ Property                  │ Note                                │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│type        │ connection.type           │ This alias also accepts values of   │
│            │                           │ bond-slave, team-slave and          │
│            │                           │ bridge-slave. They create ethernet  │
│            │                           │ connection profiles. Their use is   │
│            │                           │ discouraged in favor of using a     │
│            │                           │ specific type with master option.   │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│con-name    │ connection.id             │ When not provided a default name is │
│            │                           │ generated:                          │
│            │                           │ <type>[-<ifname>][-<num>]).         │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│autoconnect │ connection.autoconnect    │                                     │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│ifname      │ connection.interface-name │ A value of * will be interpreted as │
│            │                           │ no value, making the connection     │
│            │                           │ profile interface-independent.      │
│            │                           │ Note: use quotes around * to        │
│            │                           │ suppress shell expansion.  For      │
│            │                           │ bond, team and bridge connections a │
│            │                           │ default name will be generated if   │
│            │                           │ not set.                            │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│master      │ connection.master         │ Value specified here will be        │
│            │                           │ canonicalized.  It can be prefixed  │
│            │                           │ with ifname/, uuid/ or id/ to       │
│            │                           │ disambiguate it.                    │
├────────────┼───────────────────────────┼─────────────────────────────────────┤
│slave-type  │ connection.slave-type     │                                     │
└────────────┴───────────────────────────┴─────────────────────────────────────┘
```

#### Table 2. PPPoE options

```
┌─────────┬────────────────┐
│Alias    │ Property       │
├─────────┼────────────────┤
│username │ pppoe.username │
├─────────┼────────────────┤
│password │ pppoe.password │
├─────────┼────────────────┤
│service  │ pppoe.service  │
├─────────┼────────────────┤
│parent   │ pppoe.parent   │
└─────────┴────────────────┘
```

#### Table 3. Wired Ethernet options

```
┌───────────┬──────────────────────────┐
│Alias      │ Property                 │
├───────────┼──────────────────────────┤
│mtu        │ wired.mtu                │
├───────────┼──────────────────────────┤
│mac        │ wired.mac-address        │
├───────────┼──────────────────────────┤
│cloned-mac │ wired.cloned-mac-address │
└───────────┴──────────────────────────┘
```

#### Table 4. Infiniband options

```
┌───────────────┬───────────────────────────┐
│Alias          │ Property                  │
├───────────────┼───────────────────────────┤
│mtu            │ infiniband.mtu            │
├───────────────┼───────────────────────────┤
│mac            │ infiniband.mac-address    │
├───────────────┼───────────────────────────┤
│transport-mode │ infiniband.transport-mode │
├───────────────┼───────────────────────────┤
│parent         │ infiniband.parent         │
├───────────────┼───────────────────────────┤
│p-key          │ infiniband.p-key          │
└───────────────┴───────────────────────────┘
```

#### Table 5. Wi-Fi options

```
┌───────────┬─────────────────────────────┐
│Alias      │ Property                    │
├───────────┼─────────────────────────────┤
│ssid       │ wireless.ssid               │
├───────────┼─────────────────────────────┤
│mode       │ wireless.mode               │
├───────────┼─────────────────────────────┤
│mtu        │ wireless.mtu                │
├───────────┼─────────────────────────────┤
│mac        │ wireless.mac-address        │
├───────────┼─────────────────────────────┤
│cloned-mac │ wireless.cloned-mac-address │
└───────────┴─────────────────────────────┘
```

#### Table 6. WiMax options

```
┌──────┬────────────────────┐
│Alias │ Property           │
├──────┼────────────────────┤
│nsp   │ wimax.network-name │
├──────┼────────────────────┤
│mac   │ wimax.mac-address  │
└──────┴────────────────────┘
```

#### Table 7. GSM options

```
┌─────────┬──────────────┐
│Alias    │ Property     │
├─────────┼──────────────┤
│apn      │ gsm.apn      │
├─────────┼──────────────┤
│user     │ gsm.username │
├─────────┼──────────────┤
│password │ gsm.password │
└─────────┴──────────────┘
```

#### Table 8. CDMA options

```
┌─────────┬───────────────┐
│Alias    │ Property      │
├─────────┼───────────────┤
│user     │ cdma.username │
├─────────┼───────────────┤
│password │ cdma.password │
└─────────┴───────────────┘
```

#### Table 9. Bluetooth options

```
┌────────┬──────────────────┬────────────────────────────────────┐
│Alias   │ Property         │ Note                               │
├────────┼──────────────────┼────────────────────────────────────┤
│addr    │ bluetooth.bdaddr │                                    │
├────────┼──────────────────┼────────────────────────────────────┤
│bt-type │ bluetooth.type   │ Apart from the usual panu, nap and │
│        │                  │ dun options, the values of dun-gsm │
│        │                  │ and dun-cdma can be used for       │
│        │                  │ compatibility with older versions. │
│        │                  │ They are equivalent to using dun   │
│        │                  │ and setting appropriate gsm.* or   │
│        │                  │ cdma.* properties.                 │
└────────┴──────────────────┴────────────────────────────────────┘
```

#### Table 10. VLAN options

```
┌────────┬───────────────────────────┐
│Alias   │ Property                  │
├────────┼───────────────────────────┤
│dev     │ vlan.parent               │
├────────┼───────────────────────────┤
│id      │ vlan.id                   │
├────────┼───────────────────────────┤
│flags   │ vlan.flags                │
├────────┼───────────────────────────┤
│ingress │ vlan.ingress-priority-map │
├────────┼───────────────────────────┤
│egress  │ vlan.egress-priority-map  │
└────────┴───────────────────────────┘
```

#### Table 11. Bonding options

```
┌──────────────┬──────────────┬──────────────────────────────────┐
│Alias         │ Property     │ Note                             │
├──────────────┼──────────────┼──────────────────────────────────┤
│mode          │              │ Setting each of these adds the   │
├──────────────┤              │ option to bond.options property. │
│primary       │              │ It's equivalent to the           │
├──────────────┤              │ +bond.options 'option=value'     │
│miimon        │              │ syntax.                          │
├──────────────┤              │                                  │
│downdelay     │              │                                  │
├──────────────┤ bond.options │                                  │
│updelay       │              │                                  │
├──────────────┤              │                                  │
│arp-interval  │              │                                  │
├──────────────┤              │                                  │
│arp-ip-target │              │                                  │
├──────────────┤              │                                  │
│lacp-rate     │              │                                  │
└──────────────┴──────────────┴──────────────────────────────────┘
```

#### Table 12. Team options

```
┌───────┬─────────────┬─────────────────────────────────────┐
│Alias  │ Property    │ Note                                │
├───────┼─────────────┼─────────────────────────────────────┤
│config │ team.config │ Either a filename or a team         │
│       │             │ configuration in JSON format. To    │
│       │             │ enforce one or the other, the value │
│       │             │ can be prefixed with "file://" or   │
│       │             │ "json://".                          │
└───────┴─────────────┴─────────────────────────────────────┘
```

#### Table 13. Team port options

```
┌───────┬──────────────────┬─────────────────────────────────────┐
│Alias  │ Property         │ Note                                │
├───────┼──────────────────┼─────────────────────────────────────┤
│config │ team-port.config │ Either a filename or a team         │
│       │                  │ configuration in JSON format. To    │
│       │                  │ enforce one or the other, the value │
│       │                  │ can be prefixed with "file://" or   │
│       │                  │ "json://".                          │
└───────┴──────────────────┴─────────────────────────────────────┘
```

#### Table 14. Bridge options

```
┌───────────────────┬───────────────────────────┐
│Alias              │ Property                  │
├───────────────────┼───────────────────────────┤
│stp                │ bridge.stp                │
├───────────────────┼───────────────────────────┤
│priority           │ bridge.priority           │
├───────────────────┼───────────────────────────┤
│forward-delay      │ bridge.forward-delay      │
├───────────────────┼───────────────────────────┤
│hello-time         │ bridge.hello-time         │
├───────────────────┼───────────────────────────┤
│max-age            │ bridge.max-age            │
├───────────────────┼───────────────────────────┤
│ageing-time        │ bridge.ageing-time        │
├───────────────────┼───────────────────────────┤
│group-forward-mask │ bridge.group-forward-mask │
├───────────────────┼───────────────────────────┤
│multicast-snooping │ bridge.multicast-snooping │
├───────────────────┼───────────────────────────┤
│mac                │ bridge.mac-address        │
├───────────────────┼───────────────────────────┤
│priority           │ bridge-port.priority      │
├───────────────────┼───────────────────────────┤
│path-cost          │ bridge-port.path-cost     │
├───────────────────┼───────────────────────────┤
│hairpin            │ bridge-port.hairpin-mode  │
└───────────────────┴───────────────────────────┘
```

#### Table 15. VPN options

```
┌─────────┬──────────────────┐
│Alias    │ Property         │
├─────────┼──────────────────┤
│vpn-type │ vpn.service-type │
├─────────┼──────────────────┤
│user     │ vpn.user-name    │
└─────────┴──────────────────┘
```

#### Table 16. OLPC Mesh options

```
┌─────────────┬────────────────────────────────┐
│Alias        │ Property                       │
├─────────────┼────────────────────────────────┤
│ssid         │ olpc-mesh.ssid                 │
├─────────────┼────────────────────────────────┤
│channel      │ olpc-mesh.channel              │
├─────────────┼────────────────────────────────┤
│dhcp-anycast │ olpc-mesh.dhcp-anycast-address │
└─────────────┴────────────────────────────────┘
```

#### Table 17. ADSL options

```
┌──────────────┬────────────────────┐
│Alias         │ Property           │
├──────────────┼────────────────────┤
│username      │ adsl.username      │
├──────────────┼────────────────────┤
│protocol      │ adsl.protocol      │
├──────────────┼────────────────────┤
│password      │ adsl.password      │
├──────────────┼────────────────────┤
│encapsulation │ adsl.encapsulation │
└──────────────┴────────────────────┘
```

#### Table 18. MACVLAN options

```
┌──────┬────────────────┐
│Alias │ Property       │
├──────┼────────────────┤
│dev   │ macvlan.parent │
├──────┼────────────────┤
│mode  │ macvlan.mode   │
├──────┼────────────────┤
│tap   │ macvlan.tap    │
└──────┴────────────────┘
```

#### Table 19. MACsec options

```
┌────────┬────────────────┐
│Alias   │ Property       │
├────────┼────────────────┤
│dev     │ macsec.parent  │
├────────┼────────────────┤
│mode    │ macsec.mode    │
├────────┼────────────────┤
│encrypt │ macsec.encrypt │
├────────┼────────────────┤
│cak     │ macsec.cak     │
├────────┼────────────────┤
│ckn     │ macsec.ckn     │
├────────┼────────────────┤
│port    │ macsec.port    │
└────────┴────────────────┘
```

#### Table 20. VxLAN options

```
┌─────────────────┬────────────────────────┐
│Alias            │ Property               │
├─────────────────┼────────────────────────┤
│id               │ vxlan.id               │
├─────────────────┼────────────────────────┤
│remote           │ vxlan.remote           │
├─────────────────┼────────────────────────┤
│dev              │ vxlan.parent           │
├─────────────────┼────────────────────────┤
│local            │ vxlan.local            │
├─────────────────┼────────────────────────┤
│source-port-min  │ vxlan.source-port-min  │
├─────────────────┼────────────────────────┤
│source-port-max  │ vxlan.source-port-max  │
├─────────────────┼────────────────────────┤
│destination-port │ vxlan.destination-port │
└─────────────────┴────────────────────────┘
```

#### Table 21. Tun options

```
┌────────────┬─────────────────┐
│Alias       │ Property        │
├────────────┼─────────────────┤
│mode        │ tun.mode        │
├────────────┼─────────────────┤
│owner       │ tun.owner       │
├────────────┼─────────────────┤
│group       │ tun.group       │
├────────────┼─────────────────┤
│pi          │ tun.pi          │
├────────────┼─────────────────┤
│vnet-hdr    │ tun.vnet-hdr    │
├────────────┼─────────────────┤
│multi-queue │ tun.multi-queue │
└────────────┴─────────────────┘
```

#### Table 22. IP tunneling options

```
┌───────┬──────────────────┐
│Alias  │ Property         │
├───────┼──────────────────┤
│mode   │ ip-tunnel.mode   │
├───────┼──────────────────┤
│local  │ ip-tunnel.local  │
├───────┼──────────────────┤
│remote │ ip-tunnel.remote │
├───────┼──────────────────┤
│dev    │ ip-tunnel.parent │
└───────┴──────────────────┘
```

#### Table 23. WPAN options

```
┌───────────┬─────────────────┐
│Alias      │ Property        │
├───────────┼─────────────────┤
│mac        │ wpan.mac        │
├───────────┼─────────────────┤
│short-addr │ wpan.short-addr │
├───────────┼─────────────────┤
│pan-id     │ wpan.pan-id     │
└───────────┴─────────────────┘
```

#### Table 24. 6LoWPAN options

```
┌──────┬────────────────┐
│Alias │ Property       │
├──────┼────────────────┤
│dev   │ 6lowpan.parent │
└──────┴────────────────┘
```

#### Table 25. IPv4 options

```
┌──────┬────────────────────────────┬────────────────────────────────────┐
│Alias │ Property                   │ Note                               │
├──────┼────────────────────────────┼────────────────────────────────────┤
│ip4   │ ipv4.addresses ipv4.method │ The alias is equivalent to the     │
│      │                            │ +ipv4.addresses syntax and also    │
│      │                            │ sets ipv4.method to manual. It can │
│      │                            │ be specified multiple times.       │
├──────┼────────────────────────────┼────────────────────────────────────┤
│gw4   │ ipv4.gateway               │                                    │
└──────┴────────────────────────────┴────────────────────────────────────┘
```
#### Table 26. IPv6 options

```
┌──────┬────────────────────────────┬────────────────────────────────────┐
│Alias │ Property                   │ Note                               │
├──────┼────────────────────────────┼────────────────────────────────────┤
│ip6   │ ipv6.addresses ipv6.method │ The alias is equivalent to the     │
│      │                            │ +ipv6.addresses syntax and also    │
│      │                            │ sets ipv6.method to manual. It can │
│      │                            │ be specified multiple times.       │
├──────┼────────────────────────────┼────────────────────────────────────┤
│gw6   │ ipv6.gateway               │                                    │
└──────┴────────────────────────────┴────────────────────────────────────┘
```

#### Table 27. Proxy options

```
┌─────────────┬────────────────────┬───────────────────────────────────┐
│Alias        │ Property           │ Note                              │
├─────────────┼────────────────────┼───────────────────────────────────┤
│method       │ proxy.method       │                                   │
├─────────────┼────────────────────┼───────────────────────────────────┤
│browser-only │ proxy.browser-only │                                   │
├─────────────┼────────────────────┼───────────────────────────────────┤
│pac-url      │ proxy.pac-url      │                                   │
├─────────────┼────────────────────┼───────────────────────────────────┤
│pac-script   │ proxy.pac-script   │ Read the JavaScript PAC (proxy    │
│             │                    │ auto-config) script from file or  │
│             │                    │ pass it directly on the command   │
│             │                    │ line. Prefix the value with       │
│             │                    │ "file://" or "js://" to force one │
│             │                    │ or the other.                     │
└─────────────┴────────────────────┴───────────────────────────────────┘
```




###  COLORS 颜色

隐式着色可以通过空文件/etc/terminal-colors.d/nmcli.disable禁用。

请参见 terminal-colors.d(5) 了解有关着色配置的更多详细信息。nmcli支持的逻辑颜色名称包括：

| 名称                     | 描述                                                         |
| ------------------------ | ------------------------------------------------------------ |
| connection-activated     | A connection that is active.                                 |
| connection-activating    | Connection that is being activated.                          |
| connection-disconnecting | Connection that is being disconnected.                       |
| connection-invisible     | Connection whose details is the user not permitted to see.   |
| connectivity-full        | Conectivity state when Internet is reachable.                |
| connectivity-limited     | Conectivity state when only a local network reachable.       |
| connectivity-none        | Conectivity state when the network is disconnected.          |
| connectivity-portal      | Conectivity state when a captive portal hijacked the connection. |
| connectivity-unknown     | Conectivity state when a connectivity check didn't run.      |
| device-activated         | Device that is connected.                                    |
| device-activating        | Device that is being configured.                             |
| device-disconnected      | Device that is not connected.                                |
| device-firmware-missing  | Warning of a missing device firmware.                        |
| device-plugin-missing    | Warning of a missing device plugin.                          |
| device-unavailable       | Device that is not available for activation.                 |
| manager-running          | Notice that the NetworkManager daemon is available.          |
| manager-starting         | Notice that the NetworkManager daemon is being initially connected. |
| manager-stopped          | Notice that the NetworkManager daemon is not available.      |
| permission-auth          | An action that requires user authentication to get permission. |
| permission-no            | An action that is not permitted.                             |
| permission-yes           | An action that is permitted.                                 |
| prompt                   | Prompt in interactive mode.                                  |
| state-asleep             | Indication that NetworkManager in suspended state.           |
| state-connected-global   | Indication that NetworkManager in connected to Internet.     |
| state-connected-local    | Indication that NetworkManager in local network.             |
| state-connected-site     | Indication that NetworkManager in connected to networks other than Internet. |
| state-connecting         | Indication that NetworkManager is establishing a network connection. |
| state-disconnected       | Indication that NetworkManager is disconnected from a network. |
| state-disconnecting      | Indication that NetworkManager is being disconnected from a network. |
| wifi-signal-excellent    | Wi-Fi network with an excellent signal level.                |
| wifi-signal-fair         | Wi-Fi network with a fair signal level.                      |
| wifi-signal-good         | Wi-Fi network with a good signal level.                      |
| wifi-signal-poor         | Wi-Fi network with a poor signal level.                      |
| wifi-signal-unknown      | Wi-Fi network that hasn't been actually seen (a hidden AP).  |
| disabled                 | A property that is turned off.                               |
| enabled                  | A property that is turned on.                                |



### ENVIRONMENT VARIABLES

nmcli的行为受以下环境变量的影响。

LC_ALL

>  如果设置为非空字符串值，它将覆盖所有其他国际化变量的值。

LC_MESSAGES

> 确定用于国际化消息的区域设置。

LANG

> 为未设置或空的国际化变量提供默认值。



### INTERNATIONALIZATION NOTES

请注意，nmcli已本地化，因此输出取决于您的环境。这一点很重要，尤其是在解析输出时。

将nmcli调用为LC_ALL=C nmcli，以确保在脚本中执行时将区域设置设置为C。

LC_ALL、LC_MESSAGES、LANG变量指定LC_MESSAGES区域设置类别（按该顺序），该类别确定nmcli用于消息的语言。如果没有设置这些变量，则使用C语言环境，并且此语言环境使用英语消息。



### EXIT STATUS

nmcli退出时状态为0如果成功，则在发生错误时返回大于0的值。

| 状态值 | 说明                                                         |
| ------ | ------------------------------------------------------------ |
| 0      | Success – indicates the operation succeeded                  |
| 1      | Unknown or unspecified error.                                |
| 2      | Invalid user input, wrong nmcli invocation.                  |
| 3      | Timeout expired (see --wait option).                         |
| 4      | Connection activation failed.                                |
| 5      | Connection deactivation failed.                              |
| 6      | Disconnecting device failed.                                 |
| 7      | Connection deletion failed.                                  |
| 8      | NetworkManager is not running.                               |
| 10     | Connection, device, or access point does not exist.          |
| 65     | When used with --complete-args option, a file name is expected to follow. |





### NOTES

nmcli接受缩写，只要它们是一组可能选项中唯一的前缀。随着新选项的添加，这些

缩写词不保证保持唯一性。因此，为了脚本编写和长期兼容性，强烈建议拼写

输出完整的选项名称。

### BUGS

​       There are probably some bugs. If you find a bug, please report it to https://bugzilla.gnome.org/ — product NetworkManager.

### SEE ALSO

​       nmcli-examples(7), nm-online(1), NetworkManager(8), NetworkManager.conf(5), nm-settings(5), nm-applet(1), nm-connection-editor(1),
​       terminal-colors.d(5).

