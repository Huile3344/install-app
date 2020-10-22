#!/bin/bash
# 脚本说用：
# 去网站 https://pkg.cfssl.org/ 查看最新版本的 cfssl
ROOT=${1:-"/opt"}/cfssl

if [ ! -d $ROOT ]; then
mkdir -p $ROOT
cd $ROOT
# 下载版本
curl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o cfssl
chmod +x cfssl 
curl https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o cfssljson
chmod +x cfssljson 
curl https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o cfssl-certinfo
chmod +x cfssl-certinfo 
cp cfssl /usr/bin/cfssl
cp cfssljson /usr/bin/cfssljson
cp cfssl-certinfo /usr/bin/cfssl-certinfo
# 生成默认模板文件
cfssl print-defaults config > config.json
cfssl print-defaults csr > csr.json
else
echo "$ROOT exists, cfssl has already install"
fi
