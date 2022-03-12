# hostname

## Linux 下命令说明

### 范例

- hostname

  >查看主机名

- hostname -i

  >查看ip

- hostname centos

  >临时将主机名改为 centos，也可使用 set-hostname centos



### hostname命令描述
hostname 用于显示和设置主机名

```
hostname - 显示或设置系统的主机名
domainname - 显示或设置系统的NIS/YP域名
dnsdomainname - 显示系统的DNS域名
nisdomainname - 显示或设置系统的NIS/YP域名
ypdomainname - 显示或设置系统的NIS/YP域名
nodename - 显示或设置系统的DECnet节点名
```



### hostname命令详解

- hostname 没有选项，显示主机名字
- hostname –d 显示机器所属域名
- hostname –f 显示完整的主机名和域名
- hostname –i 显示当前机器的 ip 地址
- `hostname newname` 命令来修改主机名，不会永久保存，当机器重启之后，就失效了
- 修改 `/etc/hostname` 文件，永久保存修改的主机名，重启生效



### man hostname 查看使用手册

#### 描述

```shell
hostname 是一个用来设置或显示当前主机,域或者系统的节点名的程序.许多联网程序使用这些名字来 标识机器.NIS/YP同样也使用域名.
```



##### 获取名字

如果不调用任何参数,程序即显示当前的名字:

hostname 会打印系统的名字为通过 gethostname(2) 函数返回的值.

domainname,nisdomainname,ypdomainname 会打印系统的名字为通过 getdomainname(2) 函数返回的值.这同时也被看作系统的YP/NIS域名.

nodename 会打印系统的DECnet节点名为通过 getnodename(2) 函数返回的值.

dnsdomainname 会打印FQDN(完全资格域名)的域部分.系统的完整的FQDN可使用 hostname --fqdn 返回.



##### 设置名称

如果带一个参数或者带 --file 选项调用的话,命令即设置主机名,NIS/YP域名或者节点名.

注意,只有超级用户才可以修改这些名字.

不可能使用 dnsdomainname 命令(参看下面的 THE FQDN ) 来设置FQDN或者DNS域名.

每次系统启动时,主机名通常在  /etc/rc.d/rc.inet1  或   /etc/init.d/boot   (一般通过读取文件的内容,其中包括了主机名,例如,   /etc/hostname)中设置.



##### FQDN

你不能使用该命令修改FQDN(通过 hostname --fqdn 返回) 或者DNS域名(通过 dnsdomainname 返回).系统的FQDN是一个由 resolver(3) 返回的主机名.

从技术上说:FQDN指的是使用 gethostbyname(2) 以返回 gethostname (2) 所返回主机名的名字.  DNS域名是第一个圆点之后的部分.

因此它依赖于你修改方式的配置(通常在 /etc/host.conf 中).通常(如果hosts文件在DNS或NIS之前解析)你可以在 /etc/hosts 中修改.




#### 命令选项总览

```shell
hostname  [-v]  [-a]  [--alias]  [-d]  [--domain]  [-f]  [--fqdn]  [-i] [--ip-address] [--long] [-s] [--short] [-y] [--yp] [--nis] [-n] [--node]

hostname [-v] [-F filename] [--file filename] [hostname]

domainname [-v] [-F filename] [--file filename] [name]

nodename [-v] [-F filename] [--file filename] [name]

hostname [-v] [-h] [--help] [-V] [--version]

dnsdomainname [-v]
nisdomainname [-v]
ypdomainname [-v]
```



#### 命令参数

| 参数               | 描述                                                         |
| ------------------ | ------------------------------------------------------------ |
| -a,--alias         | 显示主机的别名(如果使用了的话)                               |
| -d,--domain        | 显示DNS域名.不要使用命令 domainname 来获得DNS域名,因为这会显示NIS域名而非DNS域名。可使用 dnsdomainname 替换之 |
| -F,--file filename | 从指定文件中读取主机名。注释(以一个`#'开头的行)可忽略        |
| -f,--fqdn,--long   | 显示FQDN(完全资格域名)。一个FQDN包括一个短格式主机名和DNS域名.除非你正在使用bind或者NIS来作主机查询,否则你可以在/etc/hosts文件中修改FQDN和DNS域名(这是FQDN的一 部分) |
| -h,--help          | 打印用法信息并退出                                           |
| -i,--ip-address    | 显示主机的IP地址(组)                                         |
| -n,--node          | 显示DECnet节点名.如果指定了参数(或者指定了 --file name )，那么root也可以设置一个新的节点名 |
| -s,--short         | 显示短格式主机名.这是一个去掉第一个圆点后面部分的主机名      |
| -V,--version       | 在标准输出上打印版本信息并以成功的状态退出                   |
| -v,--verbose       | 详尽说明并告知所正在执行的                                   |
| -y,--yp,--nis      | 显示NIS域名.如果指定了参数(或者指定了 --file name ),那么root也可以设置一个新的NIS域 |





## Windows下命令说明

- 查看主机名

  > hostname
