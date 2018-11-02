# install-app
各种应用部署安装方式汇总，如：纯手动执行说明脚本+半自动shell脚本+docker方式+k8s方式安装应用

**注意**：shell.tar.gz 默认解压缩放在/opt目录下，压缩包shell目录中包含了以下shell文件
  * centos7-alibaba-yum.sh 执行后更新 yum 源为阿里 yum 源
  * close_yum-cron.sh 关闭 CentOS 中 yum 自动更新软件功能
  * **log.sh** shell脚本 source 该文件后，可支持各种级别shell日志输出(日志带色彩)，大部分脚本中都有对该文件的引用
  * **purge-win-shell.sh** 执行 /opt/shell/purge-win-shell.sh filename 剔除从 windows 拷贝到 linux 的脚本文件换行符多余的 ^M 字符  