#!/bin/bash

source /opt/shell/log.sh

# docker stack 使用的yml文件名称，默认：stack.yml
STACK_YML=stack.yml
# 默认提供使用的 stack 辅助脚本文件，方便使用
STACK_SHELL=stack.sh
# docker stack 使用的 STACK 名称
STACK_NAME=nginx

case "`uname`" in
CYGWIN*) cygwin=true;;
# mac
Darwin*) darwin=true;;
OS400*) os400=true;;
HP-UX*) hpux=true;;
esac

function install () {
  h1 "prepare install Homebrew"
  if [ ! -e brew_install ]; then
      echo_exec "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install > brew_install"
      if [ $darwin ]; then
          h1 "替换 Homebrew 源"
          echo_exec "sed -i '' 's|\"https://github.com/Homebrew/brew\"|\"https://mirrors.ustc.edu.cn/brew.git\"|g' brew_install"
          h1 "替换 Homebrew Core 源"
sed -i '' "/\"update\"/i\\
  system \"git\", \"clone\", \"git://mirrors.ustc.edu.cn/homebrew-core.git\", \"#{HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-core\", \"--depth=1\"
" brew_install
          h1 "替换 Homebrew Cask 源"
sed -i '' "/\"update\"/i\\
  system \"git\", \"clone\", \"git://mirrors.ustc.edu.cn/homebrew-cask.git\", \"#{HOMEBREW_REPOSITORY}/Library/Taps/caskroom/homebrew-cask\", \"--depth=1\"
" brew_install
      else
          exit 1
      fi
  fi

  h1 "start install Homebrew"
  echo_exec "/usr/bin/ruby brew_install"

  h1 "替换 Homebrew Bottles 源"
  echo_exec "echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile"
  echo_exec "source ~/.bash_profile"

  h1 "success installed Homebrew"



  h1 "替换 Bottles 源"
  echo_exec "echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile"
  echo_exec "source ~/.bash_profile"

  echo_exec "brew update"
  echo_exec "brew doctor" || success $"Have Fun!" && exit 0
  success $"Have Fun!"
}

function help () {
    echo "usage: $1 STACK_NAME [install|clean]"
    echo "    install             -- install Homebrew for Mac"
    echo "    clean               -- clean and remove Homebrew for Mac."
}

case $1 in
    clean)
        # brew --version > /dev/null || success $"Homebrew not exists!" && exit 0
        # echo_exec "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\""
        if [ ! -e brew_uninstall ]; then
            echo_exec "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall > brew_uninstall"
        fi
        echo_exec "/usr/bin/ruby brew_uninstall" || success $"Homebrew not exists!" && exit 0
        success $"clean and Homebrew successfully!"
    ;;
    install)
        install
    ;;
    help|*)
        help $0
    ;;
esac
