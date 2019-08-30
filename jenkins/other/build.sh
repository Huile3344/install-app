#!/usr/bin/env bash
set -e
active=${1:-dev}
registry=10.0.10.22/library
checked=${2:-NOT}
errorSend=${3}
registry_vps=10.0.10.22/library
timestamp=`date +%Y%m%d%H%M%S`

module=`pwd`
printf "检索到Dockerfile：\n%s\n" "${module}"

sendMsgUrl="http://39.108.138.206:8999/weixin/appchat/send"

# echo `git log | grep -e 'commit [a-zA-Z0-9]*' | wc -l`
files=`git diff --name-only HEAD~ HEAD`
printf "git提交的文件：\n%s\n" "${files[@]}"
authors=`git log --oneline -1 --format=%an`
printf "git提交作者：\n%s\n" "${authors[@]}"

module=`echo ${module%_*}`
module=`echo ${module##*/}`

if [ -n "$errorSend" ]; then
exit 1
fi


echo "准备操作的项目："
printf "%s\n" "${module}"

echo "$checked"

if [ "$checked" == "RIGHT" ]; then

echo "开始构建：$registry_vps/$module:$active-$timestamp"
docker build --build-arg ACTIVE=${active} -t ${registry_vps}/${module}:${active}-${timestamp} .
echo "上传镜像：$registry_vps/$module:$active-$timestamp"
docker push ${registry_vps}/${module}:${active}-${timestamp}
echo "开始标记版本为$active镜像：$registry_vps/$module:$active-$timestamp"
docker tag ${registry_vps}/${module}:${active}-${timestamp} ${registry_vps}/${module}:${active}
docker push ${registry_vps}/${module}:${active}
if ["$active" != "dev"]; then
echo "var1=\`docker service ls --format \"{{.Name}} {{.Replicas}}\" | grep $updatedModule | awk '{printf \$2}' | awk -F / '{printf \$1}'\`" >> deploy
echo "var2=\`docker service ls --format \"{{.Name}} {{.Replicas}}\" | grep $updatedModule | awk '{printf \$2}' | awk -F / '{printf \$2}'\`" >> deploy
echo -e "if [ \$var2 -ne 1 -a \$var1 -eq 1 ];then \n echo '[WARNING]存活节点数为1，不给发布.......' \n exit 1 \n fi" >> deploy
fi

echo "docker service update -d --log-driver json-file --log-opt max-size=100m --log-opt max-file=1 --with-registry-auth --image $registry/$module:$active-$timestamp ota_$module" > deploy

echo "构建完成！"

fi