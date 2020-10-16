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
    
# Linux Tips

## Linux 脚本

### 脚本中的 `set -e` 和 `set +e` 及其他选项
- **`set -e`** ： 执行的时候如果出现了返回值为非零，整个脚本 就会立即退出 
- **`set +e`**： 执行的时候如果出现了返回值为非零将会继续执行下面的脚本 

| 选项名 | 快捷开关 | 含义 |
| ---- | --- | ---- |		
| allexport | -a | 从这个选项中被设置开始就自动标明要输出的新变量或修改过的变量，直至选项被复位 |
| braceexpand | -B | 打开花括号扩展，它是一个默认设置 |
| emacs | | 使用emacs内置编辑器进行命令行编辑，是一个默认设置 |
| errexit | -e | 当命令返回一个非零退出状态（失败）时退出。读取初始化文件时不设置 |
| histexpand | -H | 执行历史替换时打开!和!!扩展，是一个默认设置 |
| history | | 打开命令行历史、默认为打开 |
| ignoreeof	| | 禁止用EOF(Ctrl+D)键退出shell。必须键入exit才能退出。等价于设置shell变量IGNOREEOF=10 |
| keyword | -k | 将关键字参数放到命令的环境中 |
| interactive-comments | | 对于交互式shell，把#符后面的文本作为注释 |
| monitor | -m | 设置作业控制 |
| noclobber	| -C | 防止文件在重定向时被重写 |
| noexec | -n | 读命令，但不执行。用来检查脚本的语法。交互式运行时不开启 |
| noglob | -d | 禁止用路径名扩展。即关闭通配符 |
| notify | -b | 后台作业完成时通知用户 |
| nounset | -u | 扩展一个未设置的变量时显示一个错误信息 |
| onecmd | -t |在读取和执行命令后退出 |
| physical | -P |设置时，在键入cd或pwd禁止符号链接。用物理目录代替 |
| privileged | -p |设置后，shell不读取.profile或ENV文件，且不从环境继承shell函数，将自动为setuid脚本开启特权 |
| verbose | -v 	为调试打开verbose模式 |
| vi | | 使用vi内置编辑器进行命令行编辑 |
| xtrace | -x | 为调试打开echo模式 |

### 基于上一个命令结果，执行其他命令
```
if [ "$?"-ne 0]; then echo "command failed"; exit 1; fi
```
可以替换成： 
```
command ||  echo "command failed"; exit 1; （这种写法并不严谨，我当时的场景是执行ssh "commond"，
所以可以返回退出码后面通过[ #？ -eq 0 ]来做判断，如果是在shell中无论成功还是失败都会exit）
command || (echo "command failed"; exit 1);
```
或者使用： 
```
if ! command; then echo "command failed"; exit 1; fi
```

      