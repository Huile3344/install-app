# fastdfs 安装

*[FastDFS分布式文件系统集群安装与配置](https://blog.csdn.net/xyang81/article/details/52928230)*

## 方案A：脚本安装

### 一、修改 fastdfs.properties 指定安装版本

### 二、执行 fastdfs-install.sh安装 fastdfs


## 方案B：手动安装

* 创建 fastdfs 主目录
     
      mkdir -pv /opt/fastdfs

* 安装编译工具及库文件
     
      yum -y install make cmake gcc gcc-c++

### 一、 安装 fastdfs 前置环境 libfastcommon

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

* 1、下载 libfastcommon 安装包
     
      wget wget https://github.com/happyfish100/libfastcommon/archive/V1.0.39.tar.gz

* 2、解压安装包:
     
      tar xf V1.0.39.tar.gz

* 3、进入安装包目录
     
      cd libfastcommon-1.0.39

* 4、编译安装
     
      ./make.sh && ./make.sh install


### 二、安装 fastdfs

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

* 1、下载 libfatscommon 安装包
     
      wget https://github.com/happyfish100/fastdfs/archive/V5.11.tar.gz

* 2、解压安装包:
     
      tar xf V5.11.tar.gz

* 3、进入安装包目录
     
      cd fastdfs-5.11

* 4、编译安装
     
      ./make.sh && ./make.sh install

* 5、启动服务测试

重命名配置文件
     
      cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
      cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
      cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf
      cp /opt/fastdfs/fastdfs-5.11/conf/http.conf /etc/fdfs/http.conf
      cp /opt/fastdfs/fastdfs-5.11/conf/mime.types /etc/fdfs/mime.types
      tracker.conf storage.conf 这两个配置文件需要修改，相应的二进制文件安装后就已经放在 /usr/bin 目录下，

查看命令 
     
      ll /usr/bin | grep fdfs
      
启动tracker
     
      fdfs_trackerd /etc/fdfs/tracker.conf start

启动tracker
     
      fdfs_storaged /etc/fdfs/storage.conf start

* 6、执行文件上传命令
     
      fdfs_upload_file /etc/fdfs/client.conf /data/test.txt

返回ID号，说明文件上传成功

### 三、fastdfs-nginx-module作用说明

FastDFS 通过 Tracker 服务器，将文件放在 Storage 服务器存储，但是同组存储服务器之间需要进入文件复制流程，有同步延迟的问题。
假设 Tracker 服务器将文件上传到了 192.168.1.202，上传成功后文件 ID已经返回给客户端。
此时 FastDFS 存储集群机制会将这个文件同步到同组存储 192.168.1.203，在文件还没有复制完成的情况下，
客户端如果用这个文件 ID 在 192.168.1.203上取文件，就会出现文件无法访问的错误。
而 fastdfs-nginx-module 可以重定向文件连接到源服务器（192.168.1.202）上取文件，避免客户端由于复制延迟导致的文件无法访问错误。

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

* 1、下载 fastdfs-nginx-module 安装包
     
      wget https://github.com/happyfish100/fastdfs-nginx-module/archive/V1.20.tar.gz

* 2、解压安装包:
     
      tar xf V1.20.tar.gz

* 3、修改安装包含fastdfs-nginx-module模块的 nginx 时 make 阶段报如下错误: /usr/local/include/fastdfs/fdfs_define.h:15:27: 致命错误：common_define.h：没有那个文件或目录
     
      cp /opt/fastdfs/fastdfs-nginx-module-1.20/src/config /opt/fastdfs/fastdfs-nginx-module-1.20/src/config.bak
      cp /opt/fastdfs/fastdfs-nginx-module-1.20/src/mod_fastdfs.conf /etc/fdfs/
      sed -i "s@/usr/local/include@/usr/include/fastdfs /usr/include/fastcommon/@g" /opt/fastdfs/fastdfs-nginx-module-1.20/src/config

网上的另外一种创建软连接的方式无效:     
      ln -sv /usr/include/fastcommon /usr/local/include/fastcommon 
      ln -sv /usr/include/fastdfs /usr/local/include/fastdfs 
      ln -sv /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so


*安装nginx*

### 四、安装 PCRE

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

PCRE 作用是让 Nginx 支持 Rewrite 功能

* 1、下载 PCRE 安装包
     
      wget https://nchc.dl.sourceforge.net/project/pcre/pcre/8.42/pcre-8.42.tar.gz

* 2、解压安装包:
     
      tar xf pcre-8.42.tar.gz

* 3、进入安装包目录
     
      cd pcre-8.42

* 4、编译安装 
     
      ./configure
      make && make install

* 5、查看pcre版本
     
      pcre-config --version

### 五、添加模块 ngx_cache_purge

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

* 1、下载 ngx_cache_purge 模块包
     
      wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz

* 2、解压安装包:
     
      tar xf 2.3.tar.gz


### 六、安装 nginx

* 0、进入 fastdfs 主目录
     
      cd /opt/fastdfs

* 1、下载 nginx
     
      wget http://nginx.org/download/nginx-1.14.0.tar.gz

* 2、解压安装包:
     
      tar xf nginx-1.14.0.tar.gz

* 3、进入安装包目录
     
      cd nginx-1.14.0

* 4、编译安装 安装nginx和fastdfs-nginx-module模块
     
      ./configure --prefix=/opt/fastdfs/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-pcre=/opt/fastdfs/pcre-8.42 --add-module=/opt/fastdfs/fastdfs-nginx-module-1.20/src  --add-module=/opt/fastdfs/ngx_cache_purge-2.3
      make && make install

* 5、创建软连接
     
      ln -s /opt/nginx/nginx/sbin/nginx /usr/sbin/nginx

* 6、查看nginx版本
     
      nginx -v


