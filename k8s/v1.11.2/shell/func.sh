#!/usr/bin/env bash
#
# 脚本通用方法

function echo_exec () {
  echo "\$ $@"
  eval $@
  ok=$?
  echo 
  return $ok
}


