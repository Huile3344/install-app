#!/bin/bash

# install linux jdk
java -version > /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 jdk"
	mkdir -pv /opt/jdk
	tar -zxf jdk-8u201-linux-x64.tar.gz -C /opt/jdk
	echo "export JAVA_HOME=/opt/jdk/jdk1.8.0_201" >> /etc/profile
	echo "export JRE_HOME=/opt/jdk/jdk1.8.0_201/jre" >> /etc/profile
	echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile
	source /etc/profile
fi
java -version


# install linux maven
mvn -v > /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 maven"
	mkdir -pv /opt/m2/repository
	m2_version=3.6.0
	if [ -e apache-maven-${m2_version}-bin.tar.gz ]; then
	    wget http://ftp.cuhk.edu.hk/pub/packages/apache.org/maven/maven-3/${m2_version}/binaries/apache-maven-${m2_version}-bin.tar.gz
        if [ 0 -ne $? ]; then
            echo "maven 安装包下载失败。"
            exit 1
        fi
	fi
	tar -zxf apache-maven-${m2_version}-bin.tar.gz -C /opt/m2
	mv /opt/m2/apache-maven-${m2_version}/conf/settings.xml /opt/m2/apache-maven-${m2_version}/conf/settings.xml.bak
	cp settings.xml /opt/m2/apache-maven-${m2_version}/conf/
	ln -s /opt/m2/apache-maven-${m2_version}/conf/settings.xml /opt/m2/
	echo "export M2_HOME=/opt/m2/apache-maven-${m2_version}" >> /etc/profile
	echo "export PATH=\$M2_HOME/bin:\$PATH" >> /etc/profile
	source /etc/profile
fi
mvn -v

# 将已有的maven仓库的数据复制到/opt/m2/repository
if [ -e repository.zip ]; then
	unzip repository.zip -d /opt/m2/
#	chown -R jenkins /opt/m2
fi


# install linux docker
docker verison> /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 docker"
	yum -y install docker-ce-18.06.0.ce-3.el7.x86_64.rpm
	if [ 0 -ne $? ]; then
	    echo "docker 安装失败。"
	    exit 1
	fi
fi
docker verison


# install git 
git --version> /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 git"
	yum -y install git
	if [ 0 -ne $? ]; then
	    echo "git 安装失败。"
	    exit 1
	fi
fi
git --version


# pull jenkins 镜像
echo "开始安装 jenkins 镜像"
mkdir -pv /opt/jenkins/jenkins_home
docker pull jenkins/jenkins:tls
if [ 0 -ne $? ]; then
    echo "pull jenkins 镜像失败。"
    exit 1
fi


docker run -d --restart always -u root -p 8080:8080 -p 50000:50000 \
	-v /opt/jenkins/jenkins_home:/var/jenkins_home \
	-v /usr/lib64/libltdl.so.7:/usr/lib/x86_64-linux-gnu/libltdl.so.7 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(which docker):/usr/bin/docker \
	-v /usr/lib64/libpcre.so.1:/usr/lib/x86_64-linux-gnu/libpcre.so.1 \
    -v $(which git):/usr/bin/git \
	-v /opt/jdk/jdk1.8.0_201:/docker-java-home \
	-v /opt/m2:/opt/m2 \
    -v ~/.ssh:/var/jenkins_home/.ssh \
	--name=jenkins jenkins/jenkins:lts

# 安装推荐插件，并额外安装插件Maven Integration plugin，用于构建maven项目,系统管理->插件管理->Avaiable->右上角搜索Maven Integration->Download now and install after restart
# 安装完成后，选择重启jenkins

# 配置jenkins job
# 再点击构建即可