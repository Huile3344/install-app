# nginx-ha 安装

## 方案A：脚本安装
- 执行/opt/shell/purge-win-shell.sh filename
剔除从 windows 拷贝到 linux 的脚本文件换行符多余的 ^M 字符

### 一、修改nginx-ha.properties 指定版本

### 二、执行nginx-ha-install.sh安装nginx

### 三、 修改完 nginx.conf 和 keepalived.conf 文件后，启动 nginx 和 keepalived

启动keepalived
      
    keepalived -D

说明：-D, --log-detail             Detailed log messages

脚本文件  nginx_check.sh 会启动 nginx


## 方案B：手动安装

- 创建nginx主目录

      mkdir -pv /opt/nginx

- 安装编译工具及库文件

      yum -y install make zlib zlib-devel gcc-c++ libtool  openssl openssl-devel


### 一、首先要安装 PCRE

- 0、进入nginx主目录


      cd /opt/nginx

*PCRE 作用是让 Nginx 支持 Rewrite 功能*

- 1、下载 PCRE 安装包

      wget https://nchc.dl.sourceforge.net/project/pcre/pcre/8.42/pcre-8.42.tar.gz

- 2、解压安装包:

      tar xf pcre-8.42.tar.gz

- 3、进入安装包目录

      cd pcre-8.42

- 4、编译安装 

      ./configure
      make && make install

- 5、查看pcre版本

      pcre-config --version

### 二、添加模块 ngx_cache_purge

* 0、进入 nginx 主目录
     
      cd /opt/nginx

* 1、下载 ngx_cache_purge 模块包
     
      wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz

* 2、解压安装包:
     
      tar xf 2.3.tar.gz


### 三、安装 nginx

- 0、进入nginx主目录

      cd /opt/nginx

- 1、下载 nginx

      wget http://nginx.org/download/nginx-1.14.0.tar.gz

- 2、解压安装包:

      tar xf nginx-1.14.0.tar.gz

- 3、进入安装包目录

      cd nginx-1.14.0

- 4、编译安装 

      ./configure --prefix=/opt/nginx/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/opt/nginx/pcre-8.42 --add-module=/opt/nginx/ngx_cache_purge-2.3
      make && make install

- 5、创建软连接

      ln -sf /opt/nginx/nginx/sbin/nginx /usr/sbin/nginx

- 6、查看nginx版本

      nginx -v


### 四、安装 keepalived

- 0、进入nginx主目录

      cd /opt/nginx

- 1、要让 keepalived support IPVS with IPv6 需要安装

      yum -y install libnl libnl-devel libnl3 libnl3-devel libnfnetlink-devel

- 2、下载 keepalived

      wget http://www.keepalived.org/software/keepalived-2.0.8.tar.gz

- 3、解压安装包:

      tar xf keepalived-2.0.8.tar.gz

- 4、进入安装包目录

      cd keepalived-2.0.8

- 5、编译安装 

      ./configure --prefix=/opt/nginx/keepalived
      make && make install

- 6、创建软连接

      ln -sf /opt/nginx/keepalived/sbin/keepalived /usr/sbin/keepalived

- 7、查看keepalived版本

      keepalived -v

- 8、拷贝keepalived配置文件和脚本文件

      cd ..
      mkdir -pv /etc/keepalived
      cp keepalived.conf nginx_check.sh /etc/keepalived
     /opt/shell/purge-win-shell.sh /etc/keepalived/nginx_check.sh

**注意**：由于 nginx_check.sh 文件是从windows上拷贝过去，很可能导致文件无法直接在linux上执行，

需要执行：

    /opt/shell/purge-win-shell.sh /etc/keepalived/nginx_check.sh
      
剔除 nginx_check.sh windows换行符多余的 ^M 字符


### 五、修改完 nginx.conf 和 keepalived.conf 文件后，启动 nginx 和 keepalived

    keepalived -D
    
说明：-D, --log-detail             Detailed log messages
脚本文件  nginx_check.sh 会启动 nginx