#!/bin/bash
# hflxhn@163.com
# Tue Aug 25 15:04:07 CST 2020
# ffmpeg ===> rtsp -> rtmp

cmd=/opt/lnmp/nginx/ffmpeg;
source=${1};
target=${2};

function rtspToRtmp() {
    num=`ps -ef | grep ffmpeg | grep ${cmd} | grep ${source} | wc -l`;
    if [[ ${num} != 0 ]]; then
        echo ${target} push stream success;
        return;
    fi

    ${cmd} -re -rtsp_transport tcp -i ${source} \
    -vcodec copy \
    -an \
    -tune zerolatency \
    -preset ultrafast \
    -f flv \
    ${target} &>/dev/null &
}

function killTarget() {
    pid=`ps -ef | grep ffmpeg | grep ${cmd} | grep ${source} | awk '{print $2}'`;
    kill -9 ${pid};
}

rtspToRtmp;

if [[ ${3} == 'kill' ]]; then
    killTarget
fi
