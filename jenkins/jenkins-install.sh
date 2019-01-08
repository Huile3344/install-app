#!/bin/bash

# install jdk
java -version > /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 jdk"
	mkdir -pv /opt/jdk
	tar -zxf jdk-8u171-linux-x64.tar.gz -C /opt/jdk
	echo "export JAVA_HOME=/opt/jdk/jdk1.8.0_171" >> /etc/profile
	echo "export JRE_HOME=/opt/jdk/jdk1.8.0_171/jre" >> /etc/profile
	echo "export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH" >> /etc/profile
	source /etc/profile
fi
java -version

# install maven 
mvn -v > /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 maven"
	mkdir -pv /opt/maven
	mkdir -pv /opt/m2/repository
	m2_version=3.6.0
	#wget http://ftp.cuhk.edu.hk/pub/packages/apache.org/maven/maven-3/${m2_version}/binaries/apache-maven-${m2_version}-bin.tar.gz
	tar -zxf apache-maven-${m2_version}-bin.tar.gz -C /opt/maven
	mv /opt/maven/apache-maven-${m2_version}/conf/settings.xml /opt/maven/apache-maven-${m2_version}/conf/settings.xml.bak
	cp settings.xml /opt/maven/apache-maven-${m2_version}/conf/
	ln -s /opt/maven/apache-maven-${m2_version}/conf/settings.xml /opt/m2/
	echo "export M2_HOME=/opt/maven/apache-maven-${m2_version}" >> /etc/profile
	echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /etc/profile
	source /etc/profile
fi
mvn -v

# install docker 
docker verison> /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 docker"
	yum -y install docker-ce-18.06.0.ce-3.el7.x86_64.rpm
fi
docker verison


# install git 
git --version> /dev/null
if [ 0 -ne $? ]; then
	echo "开始安装 git"
	yum -y install git
fi
git --version

# install jenkins 
echo "开始安装 jenkins"
#wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
#yum install jenkins
yum install -y jenkins-2.150.1-1.1.noarch.rpm

# 自动安装完成之后： 
#
#/usr/lib/jenkins/jenkins.war    WAR包 
#
#/etc/sysconfig/jenkins       配置文件
#
#/var/lib/jenkins/       默认的JENKINS_HOME目录
#
#/var/log/jenkins/jenkins.log    Jenkins日志文件

# 命令行执行: visudo 
# 在行内容为：root    ALL=(ALL)       ALL
# 下面添加如下内容
#jenkins ALL=(ALL)       NOPASSWD:ALL

mkdir -pv /opt/jenkins/{conf,jenkins_home,project/dockerfiles}
# 备份配置文件
cp /etc/sysconfig/jenkins /opt/jenkins/conf/jenkins.bak
cp jenkins /etc/sysconfig/jenkins
ln -s /etc/sysconfig/jenkins /opt/jenkins/conf/
chown -R jenkins /opt/jenkins
# 启动 jenkins
systemctl start jenkins
# 开机启动 jenkins
systemctl enable jenkins
# 第一次启动完成后去Jenkins日志文件(/var/log/jenkins/jenkins.log)中获取首次登陆密码

# 安装推荐插件，并额外安装插件Maven Integration plugin，用于构建maven项目,系统管理->插件管理->Avaiable->右上角搜索Maven Integration->Download now and install after restart
# 安装完成后，选择重启jenkins

# 将本地maven仓库的数据复制到/opt/m2/repository
if [ -e repository.zip ]; then
	cp repository.zip /opt/m2/
	unzip repository.zip
	chown -R jenkins /opt/m2
fi

# 配置jenkins job
# 再点击构建即可