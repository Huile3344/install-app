#!/bin/bash
# 脚本说用：
# 1. 替换Linux脚本文件中的中文换行符，避免从windows移植到的linux上的脚本文件无法执行
# 2. 未指定文件/文件夹添加执行权限
#
# 使用说明，脚本后面指定的参数，可以是多个文件，或者多个目录下的特定规则的文件
#
# 使用示例：
# $ /opt/shell/purge-win-shell.sh test.sh
# $ /opt/shell/purge-win-shell.sh *.sh /opt/installer/arthas/*.sh

for i in "$@"; do
  if [ -f "$i" ]; then
    vi  -e  -s  -c  "%s/\r//g"  -c "wq"  $i
    echo "file: $i"
  else
    echo "dir: $i"
  fi
  chmod +x $i
done
