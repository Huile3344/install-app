http://video.com/live?port=1935&app=hls&stream=b
rtmp://video.com/hls/b

ffmpeg -i /dev/video0 -f flv rtmp://video.com/hls/b

"rtsp://admin:Admin123@172.24.7.210:1005/h264/ch1/main/av_stream"

ffmpeg -re -rtsp_transport tcp -i "rtsp://admin:Admin123@172.24.7.210:1005/h264/ch1/main/av_stream" -f flv -vcodec libx264 -vprofile baseline -acodec aac -tune zerolatency -preset ultrafast -ar 44100 -strict -2 -ac 1 -f flv -s 1280x720 -q 10 "rtmp://video.com/hls/b"

/opt/lnmp/nginx/ffmpeg -re -rtsp_transport tcp -i "rtsp://admin:Admin123@172.24.6.209/h264/ch1/main/av_stream" -vcodec copy -an -tune zerolatency -preset ultrafast -f flv "rtmp://172.24.0.5/hls/robot7-210"



/opt/lnmp/nginx/ffmpeg -re -rtsp_transport tcp -i "rtsp://admin:Admin123@172.24.6.209/h264/ch1/main/av_stream" -f flv -vcodec copy -vprofile baseline -acodec aac -tune zerolatency -preset ultrafast -ar 44100 -strict -2 -ac 1 -f flv -s 1280x720 -q 10 "rtmp://172.24.0.5/hls/robot7-2"







ffmpeg -re -rtsp_transport tcp -i "rtsp://admin:Admin123@172.24.6.209/h264/ch1/main/av_stream" -f flv -vcodec libx264 -vprofile baseline -acodec aac -tune zerolatency -preset ultrafast -ar 44100 -strict -2 -ac 1 -f flv -s 1280x720 -q 10 "rtmp://172.24.0.5/hls/robot7-210"















/opt/lnmp/nginx/ffmpeg -re -rtsp_transport tcp -i "rtsp://admin:Admin123@172.24.6.209/h264/ch1/main/av_stream" -vcodec copy -an -tune zerolatency -preset ultrafast -f flv "rtmp://172.24.0.5/hls/robot7-210"

ffmpeg -re -i /dev/video0 -vcodec libx264 -preset ultrafast -f flv -s 1280x720 -q 10 "rtmp://video.com/hls/b"
