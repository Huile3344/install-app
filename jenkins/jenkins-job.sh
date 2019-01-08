#!/bin/bash

VERSION=$(grep --max-count=1 '<version>' pom.xml | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')
PROJECT=$(grep --max-count=1 '<artifactId>' pom.xml | awk -F '>' '{print $2}' | awk -F '<' '{print $1}')

BUILD_TIME=$(date '+%Y-%m-%d %T')
#BRANCH=$(git branch | awk '{print $2}')
#BRANCH=dev
#COMMIT_ID=$(git rev-parse refs/remotes/$BRANCH^{commit})

IMAGE=$PROJECT:$VERSION
JAR_FILE=$PROJECT-$VERSION.jar

TARGET=$(pwd)/target
DOCKER_SPACE=$TARGET/docker
mkdir -pv $DOCKER_SPACE
cp $(pwd)/docker/Dockerfile $DOCKER_SPACE
ln $TARGET/$JAR_FILE $DOCKER_SPACE
cd $DOCKER_SPACE

sudo docker ps | grep $PROJECT | grep -v grep > /dev/null
if [ 0 -eq $? ]; then
  echo "杀死容器$PROJECT"
  sudo docker stop $PROJECT > /dev/null
fi
sudo docker ps -a | grep $PROJECT | grep -v grep
if [ 0 -eq $? ]; then
  echo "删除容器$PROJECT"
  sudo docker rm $PROJECT > /dev/null
fi
sudo docker images | grep $PROJECT | grep -v grep > /dev/null
if [ 0 -eq $? ]; then
  echo "删除容器$PROJECT镜像"
  echo "sudo docker rmi $PROJECT"
  sudo docker rmi $PROJECT
fi

echo "生成$PROJECT"
echo "sudo docker build . -t $IMAGE"
sudo docker build . -t $IMAGE
echo "sudo docker images $IMAGE"
sudo docker images $IMAGE

echo "启动容器$PROJECT"
echo "sudo docker run -d --name $PROJECT --net host --restart always -p 9000:9000 --add-host centerpeer1:192.168.1.106 --add-host centerpeer2:192.168.1.106 --add-host rabbitmqserver:192.168.1.106 $IMAGE"
sudo docker run -d --name $PROJECT --net host --restart always -p 9000:9000 --add-host centerpeer1:192.168.1.106 --add-host centerpeer2:192.168.1.106 --add-host rabbitmqserver:192.168.1.106 $IMAGE
echo "部署启动成功！"