# nginx docker 安装使用说明

- 根据需要修改 nginx-install.sh 一下三项
    
      # docker stack 使用的yml文件名称，默认：stack.yml
      STACK_YML=stack.yml
      # 默认提供使用的 stack 辅助脚本文件，方便使用
      STACK_SHELL=stack.sh
      # docker stack 使用的 STACK 名称
      STACK_NAME=nginx

- 给 nginx-install.sh 文件添加执行权限

      chmod +x nginx-install.sh
      
- 执行安装命令安装

      ./nginx-install.sh install <安装目录>

- 执行移除命令，清楚所有安装的文件

      ./nginx-install.sh clean <安装目录>
      
- 其他说明

    - 进入安装目录使用使用stack脚本
    
    - nginx-install.sh 安装脚本 help 命令
    
          ./nginx-install.sh help
          
    - stack.sh stack脚本 help 命令
    
          ./stack.sh help 

## docker 方式配置

