# Mac Homebrew 安装使用说明

homebrew 官网: https://brew.sh/index_zh-cn

## Homebrew 能干什么?

使用 Homebrew 安装 Apple（或您的 Linux 系统）没有预装但 你需要的东西。

    $ brew install python

Homebrew 会将软件包安装到独立目录，并将其文件软链接至 /usr/local 。

    $ cd /usr/local
    $ find Cellar
    Cellar/wget/1.16.1
    Cellar/wget/1.16.1/bin/wget
    Cellar/wget/1.16.1/share/man/man1/wget.1
    
    $ ls -l bin
    bin/wget -> ../Cellar/wget/1.16.1/bin/wget

Homebrew 不会将文件安装到它本身目录之外，所以您可将 Homebrew 安装到任意位置。

轻松创建你自己的 Homebrew 包。

    $ brew create https://foo.com/bar-1.0.tgz
    Created /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/bar.rb

完全基于 Git 和 Ruby，所以自由修改的同时你仍可以轻松撤销你的变更或与上游更新合并。
    
    brew edit wget # 使用 $EDITOR 编辑!

Homebrew 的配方都是简单的 Ruby 脚本：
    
    class Wget < Formula
      homepage "https://www.gnu.org/software/wget/"
      url "https://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz"
      sha256 "52126be8cf1bddd7536886e74c053ad7d0ed2aa89b4b630f76785bac21695fcd"
    
      def install
        system "./configure", "--prefix=#{prefix}"
        system "make", "install"
      end
    end

Homebrew 使 macOS（或您的 Linux 系统）更完整。使用 gem 来安装 RubyGems、用 brew 来安装那些依赖包。

“要安装，请拖动此图标......”不会再出现了。使用 brew cask 安装 macOS 应用程序、字体和插件以及其他非开源软件。

    $ brew cask install firefox
    
制作一个 cask 就像创建一个配方一样简单。
    
    $ brew cask create foo
    Editing /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask/Casks/foo.rb


## 安装 Homebrew：

### 推荐脚本安装方式：

- 执行脚本 
    
      brew-install.sh install
      
- 卸载
    
      brew-install.sh clean


### 官网方式：

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    
**注意**：由于网络原因(服务在国外, 下载网络及其不稳定)，安装过程很可能会出现以下问题
    
-  ==> Downloading and installing Homebrew...

   fatal: unable to access 'https://github.com/Homebrew/brew/': LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to github.com:443 
   
   Failed during: git fetch origin master:refs/remotes/origin/master --tags --force

- ==> Tapping homebrew/core

  Cloning into '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core'...

  fatal: unable to access 'https://github.com/Homebrew/homebrew-core/': LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 54

  Error: Failure while executing: git clone https://github.com/Homebrew/homebrew-core /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core --depth=1

  Error: Failure while executing: /usr/local/bin/brew tap homebrew/core
  
  解决方式：
  
  执行下面这句命令，更换为中科院的镜像：
  
      git clone git://mirrors.ustc.edu.cn/homebrew-core.git/ /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core --depth=1

  把homebrew-core的镜像地址也设为中科院的国内镜像：
  
      cd "$(brew --repo)" 
      
      git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
      
      cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core" 
      
      git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

    
### 手工安装方式：

- 获取官网给的install脚本文件

      curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install >> brew_install
    
- 更改脚本中的资源链接，替换成清华大学的镜像

      BREW_REPO = "https://github.com/Homebrew/brew".freeze
      CORE_TAP_REPO = "https://github.com/Homebrew/homebrew-core".freeze
      
  更改为：
  
      BREW_REPO = "https://mirrors.ustc.edu.cn/brew.git".freeze
      CORE_TAP_REPO = "https://mirrors.ustc.edu.cn/homebrew-core.git".freeze

- 执行脚本

      /usr/bin/ruby brew_install

- 将 homebrew-core 的镜像地址也设为中科院的国内镜像

      cd $(brew --repo)/Library/Taps/homebrew/homebrew-core
      git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
        
        
- 替换 cask 软件仓库（提供 macOS 应用和大型二进制文件）

      cd $(brew --repo)/Library/Taps/caskroom/homebrew-cask
      git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

- 替换 Bottles 源（Homebrew 预编译二进制软件包）

      echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
      source ~/.bash_profile



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

