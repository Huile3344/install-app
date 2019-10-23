# linux 常用命令

## 磁盘相关命令

### du

df -h 显示磁盘空间满，但实际未占用满——问题分析

- 命令查看各个目录的占用空间，找到占用较多空间的目录,

```aidl
du  -h  / --max-depth=1  | sort -gr
```

- 查看 inode 的使用率

查看 inode 的使用率，怀疑 inode 不够导致此问题

```aidl
du -i
```

- 使用 lsof 检查

使用 lsof 检查，怀疑是不是有可能文件已被删除，但是进程还存活的场景

```aidl
lsof | grep delete
```

