## 安装最新版 ffmpeg （可以是Linux或者Windows版）

## 修改 video 目录下的 index.html 文件
将
```
http://192.168.0.6:8088/live?port=1935&app=hls&stream=video
```
中的主机地址修改成本机ip地址

## 执行 nginx-install.sh 
安装nginx, nginx 正常启动后

## 访问 nginx 服务地址
如：
```aidl
http://192.168.0.6:8088
```

## 使用 ffmpeg 推流到 nginx 
执行以下 ffmpeg 命令，其中 mp4 文件修改成对应目录的 MP4 文件，ip地址需要对应修改
```aidl
ffmpeg -re -i "D:\test.mp4" -c copy -f flv rtmp://192.168.0.6:1935/hls/video
```