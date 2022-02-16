# git 使用常见问题

## GitHub.com 无法访问，连接超时
### 连接超时
使用 git clone 、 git pull 、 git push 经常出现类似如下错误信息:
```shell
$ git push
ssh: connect to host github.com port 22: Connection timed out
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```
### 分析：怀疑连接不到 github.com
命令窗口: ping github.com
```shell
C:\Users\glodon>ping github.com

Pinging github.com [20.205.243.166] with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.

20.205.243.166 的 Ping 统计信息:
    数据包: 已发送 = 3，已接收 = 0，丢失 = 3 (100% 丢失)，
Control-C
^C
```

由此可知访问GitHub网络不同。应该是dns解析github网址异常导致的， 考虑在 `C:\Windows\System32\drivers\etc\hosts` 文件中添加域名和ip信息
```shell
## github
192.30.255.112  github.com git
185.31.16.184 github.global.ssl.fastly.net
```

先试试直接ping github 的 ip 192.30.255.112
```shell
C:\Users\glodon>ping 192.30.255.112

Pinging 192.30.255.112 with 32 bytes of data:
Reply from 192.30.255.112: bytes=32 time=361ms TTL=42
Reply from 192.30.255.112: bytes=32 time=274ms TTL=42
Reply from 192.30.255.112: bytes=32 time=350ms TTL=42
Reply from 192.30.255.112: bytes=32 time=361ms TTL=42

Ping statistics for 192.30.255.112:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 274ms, Maximum = 361ms, Average = 336ms

```
可以发现是可以正常ping通的

### 错误解决
编辑 `C:\Windows\System32\drivers\etc\hosts` 文件，添加如下域名和ip信息
```shell
## github
192.30.255.112  github.com git
185.31.16.184 github.global.ssl.fastly.net
```

再次操作 ping github.com
```shell
C:\Users\glodon>ping github.com

Pinging github.com [192.30.255.112] with 32 bytes of data:
Reply from 192.30.255.112: bytes=32 time=363ms TTL=42
Reply from 192.30.255.112: bytes=32 time=349ms TTL=42
Reply from 192.30.255.112: bytes=32 time=253ms TTL=42
Reply from 192.30.255.112: bytes=32 time=359ms TTL=42

Ping statistics for 192.30.255.112:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 253ms, Maximum = 363ms, Average = 331ms

```

并再次进行 git clone 、 git pull 、 git push 操作，发现之前提示的 `Connection timed out` 消失了，可以正常访问仓库了

## clone 仓库，没有任何报错信息，但是也没成功 clone 仓库
使用 `git clone` 命令克隆仓库，若命令执行没有报错，但是又没有 clone 下来仓库，那么可是换个协议试试，因为 git/https/ssh三者的协议地址是不一样的
这种情况常会出现类似如下内容:
```shell
$ git clone https://xxx.xxx.com/a/b/app.git
Cloning into 'app'...

# 此时命令已经结束了，但是没有任何报错，也没clone仓库到本地
```

换个协议试试，一般就正常了
```shell
$ git clone --depth=1 ssh://yyyy.yyyy.com/a/b/app.git
Cloning into 'app'...
The authenticity of host '[yyyy.yyyy.com] ([x.x.x.x])' can't be established.
RSA key fingerprint is SHA256:XXX.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[yyyy.yyyy.com] ([x.x.x.x])' (RSA) to the list of known hosts.
remote: Enumerating objects: 110, done.
remote: Counting objects: 100% (110/110), done.
remote: Compressing objects: 100% (100/100), done.
remote: Total 110 (delta 2), reused 110 (delta 2), pack-reused 0
Receiving objects: 100% (110/110), 1.35 MiB | 2.32 MiB/s, done.
Resolving deltas: 100% (2/2), done.
Checking connectivity... done.

```

## git 如何删除已经add的文件

使用 git rm 命令即可，有两种选择,
一种是 git rm –cached “文件路径”，不删除物理文件，仅将该文件从缓存中删除；
一种是 git rm –f “文件路径”，不仅将该文件从缓存中删除，还会将物理文件删除（不会回收到垃圾桶）。

git –如何撤销已放入缓存区（Index区）的修改
修改或新增的文件通过 git add –all命令全部加入缓存区（index区）之后，使用 git status 查看状态
（git status -s 简单模式查看状态，第一列本地库和缓存区的差异，第二列缓存区和工作目录的差异），
提示使用 git reset HEAD 来取消缓存区的修改。
不添加参数，撤销所有缓存区的修改。
另外可以使用 git rm –cached 文件名 ，可以从缓存区移除文件，使该文件变为未跟踪的状态，
同时下次提交时从本地库中删除。
注：
没有带参数的 git reset 命令，默认执行了 –mixed 参数，即用reset版本库到指定版本，并重置缓存区，在上面的命令中指定的目录版本是HEAD，即当前版本，所以实际上没有任何修改，仅是重置了缓存区。


## git不同账户对应不同网站

目前很多公司都会有各自的git仓库管理网站，如 github、gitlab、coding、bitbucket 等，不同网址对应不同的账户，
默认git pull/push 使用的 SSH keys 文件是: id_rsa.pub 和 id_rsa，针对的是一个特定的账号，就无法适用上面的场景。

### 生成各个网址的 ssh key
```shell
# 进入用户目录下的 .ssh 文件夹
cd C:\Users\<用户名>\.ssh
# 生成各个网址的 私钥:id_rsa 和 公钥:id_rsa.pub
ssh-keygen -t ed25519 -C <your_email@example.com> -f id_rsa_<suffix>
```

以 test 用户生成 github ssh key 为例 

```shell
cd C:\Users\test\.ssh
ssh-keygen -t ed25519 -C your_email@example.com -f id_rsa_github
# 生成 id_rsa_github 和 id_rsa_github.pub
```

### 配置 config 文件
配置 C:\Users\<用户名>\.ssh\config 文件
```shell

# github
Host github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa_github
User your_name

# coding

# bitbucket

# gitlab
```

### 拷贝公钥:id_rsa.pub内容到网址
进入网址个人信息设置，拷贝 id_rsa.pub 内容到 ssh keys。后续即可正常访问各个网站的仓库