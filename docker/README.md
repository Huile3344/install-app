# Docker 拙见

Docker(moby) GitHub: **https://github.com/moby/moby** 基于Go语言。2017年年初，docker公司将原先的docker项目改名为moby，并创建了docker-ce(开源项目)和docker-ee(闭源项目)。

Docker 官网：**https://www.docker.com**  Docker安装、使用、文档等

Docker Hub：**https://hub.docker.com** 搜索镜像，获取镜像说明、使用方式和常用配置，也可获取镜像的Dockerfile内容

**推荐书籍**：*《Lucene实战(第2版)》*，大部分样例与该书籍对应

# docker 常用命令

## docker image ls --filter

目前支持如下的过滤器。

- dangling：可以指定 true 或者 false，仅返回悬虚镜像（true），或者非悬虚镜像（false）。
      
      docker image ls --filter dangling=true

- before：需要镜像名称或者 ID 作为参数，返回在之前被创建的全部镜像。

- since：与 before 类似，不过返回的是指定镜像之后创建的全部镜像。

- label：根据标注（label）的名称或者值，对镜像进行过滤。docker image ls命令输出中不显示标注内容。

- reference：其他的过滤方式可以使用 reference。
    
  使用 reference 完成过滤并且仅显示标签为 latest 的示例
      
      docker image ls --filter=reference="*:latest"

## docker image prune

可以通过 docker image prune 命令移除全部的悬虚镜像。如果添加了 -a 参数，Docker 会额外移除没有被使用的镜像（那些没有被任何容器使用的镜像）。如果添加了 -f 参数，Docker 会强制移除没有被使用的镜像（不会有确认提示）。

#  什么是容器

# 虚拟化和容器

# 主流的容器技术有哪些

# Paas(Platform as a Service) 和 Caas(Container as a Service)，容器云(阿里云，华为云，腾讯云)

#  docker是什么

#  为什么要了解docker，docker能给我提供什么

# docker入门（概念）

# docker环境搭建和使用

# docker的网络

# docker使用中的小坑

# docker & jenkins

## jenkins容器

## jenkins使用docker

## jenkins容器中使用宿主机docker(Docker-in-Docker for CI)

# Dockerfile最佳实践，参考学习别人的Dockerfile书写

# java代码自动打包jar的镜像方式

## Dockerfile

## maven plugin of docker

# 集群、编排：容器编排技术有哪些，各自特点，以及后续学习推荐

- 容器集群并不是许多容器的简单堆积，而是以容器技术为基础的包含部署、调度、网
  络、存储等方面的有机整体。在容器集群之上可以构建更高层的服务系统 ，如动态伸缩的
  任务队列服务、企业级的业务平台、分布式的数据计算服务等。作为底层计算资源和上层
  业务服务的都合剂，以按需使用的方式提供基于容器的云端运行环境的平台，形成了 一种
  具有独特价值的服务，这类场景被称为容器即服务 。
 
# docker 使用代理
```
$ vim /lib/systemd/system/docker.service
# 在 ExecStart= 上面加上以下3行内容，注意：HTTPS_PROXY已要设置和HTTP_PROXY一样，除非开了https的代理
Environment="HTTP_PROXY=http://10.181.4.8:7890/"
Environment="HTTPS_PROXY=http://10.181.4.8:7890/"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,docker.io,aliyuncs.com"

# 重新加载docker配置并重启
$ systemctl daemon-reload && systemctl restart docker.service
```