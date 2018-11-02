# nginx 安装

## 方案一：脚本安装

- 1、修改nginx.properties 指定版本

- 2、执行nginx-install.sh安装 nginx


## 方案二：手动安装

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

- 2、解压安装包

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

      ln -s /opt/nginx/nginx/sbin/nginx /usr/sbin/nginx

- 6、查看nginx版本

      nginx -v
      
- 7、修改 nginx.conf

nginx启动默认使用安装目录/opt/nginx/nginx下的conf目录下的nginx.conf

然后执行运行
      
    nginx

启动nginx服务
