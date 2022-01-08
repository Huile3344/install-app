# nodejs 安装

## 方案A：脚本安装



## 方案B：手动安装

- 手动下载最新版nodejs的linux安装包

  > [nodejs官方下载地址](https://nodejs.org/zh-cn/download/	"nodejs下载")

- wget 下载指定版本安装包

  > wget https://nodejs.org/dist/v16.13.1/node-v16.13.1-linux-x64.tar.xz

- 解压安装包

      xz -d node-*.tar.xz
      tar -xvf node-*.tar

- 迁移应用

  ```
  mkdir -pv /opt/app
  mv node-* /opt/app/node
  ```

- 配置软连接，使全局都可以使用node命令

      # /opt/bin 需要提前已经加入到 PATH 环境变量中
      ln -s /opt/app/node/bin/node /opt/bin/node  --将node源文件映射到/opt/bin下的node文件
      ln -s /opt/app/node/bin/npm /opt/bin/npm

- 迁移应用

  ```
  mkdir -pv /opt/app
  mv node-* /opt/app/node
  ```

- 配置node文件安装路径

  ```
  cd /opt/app/node
  mkdir node_global
  mkdir node_cache
  npm config set prefix "node_global"
  npm config set cache "node_cache"
  ```

- 测试安装cnpm

  ```
  npm install cnpm -g
  # npm install cnpm -g --registry=https://registry.npm.taobao.org
  ```

  同时确认一下是否安装到 node_global 文件夹下

