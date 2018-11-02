# keepalived 安装 

*[Keepalived安装与配置](https://blog.csdn.net/xyang81/article/details/52554398)*

*[Keepalived+Nginx实现高可用（HA）](https://blog.csdn.net/xyang81/article/details/52556886)*

## 方案A：脚本安装

* 一、修改 keepalived.properties 指定安装版本

* 二、执行 keepalived-install.sh安装 keepalived


## 方案B：手动安装

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


