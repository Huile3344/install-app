# nmtui

## Linux 下命令说明

### 命令描述

```
nmtui - 用于控制NetworkManager的文本用户界面
```

### 范例

```
nmtui
```

命令行执行 nmtui ，打开文本用户界面，可按需 `编辑连接`、`启用连接`、`设置系统主机名` 。这种方式主要对于那些不熟悉网卡配置文件(`/etc/sysconfig/network-scripts/`目录下的网卡配置文件)和命令行(`nmcli`调整网络)的用户有很大帮助。使用 nmtui 修改的内容会对应修改到 `/etc/sysconfig/network-scripts/`下的网卡配置文件中



### 描述

```shell
nmtui 是一个基于curses的TUI应用程序，用于与NetworkManager交互。启动nmtui时，系统会提示用户选择要执行的活动，除非将其指定为第一个参数。
```



### 命令格式总览

```shell
nmtui-edit | nmtui edit  {name | id}

nmtui-connect | nmtui connect  {name | uuid | device | SSID}

nmtui-hostname | nmtui hostname
```



### 活动选项

| 活动(activity) | 描述                                                         |
| -------------- | ------------------------------------------------------------ |
| edit           | 显示支持添加、修改、查看和删除连接的连接编辑器。它提供了与 nm-connection-editor 类似的功能。 |
| connect        | 显示可用连接的列表，以及激活或停用连接的选项。nm-applet 提供类似的功能。 |
| hostname       | 设置系统hostname                                             |



与上述活动相对应，nmtui还附带名为nmtui edit、nmtui connect和nmtui hostname的二进制文件，以跳过活动的选择。







