#!/bin/bash 
#
# 手动生成集群证书
# 
# ca-config.json 字段说明：
# ca-config.json：可以定义多个Profiles，分别指定不同的过期时间、使用场景等参数；后续在签名证书的时候使用某个Profile。这里定义了两个Profile，一个用于kubernetes，一个用于etcd。但因为这篇文档不涉及到kubernetes的配置，所以kubenretes段是不使用的。
# signing：表示该证书可用于签名其他证书；生成的ca.pem证书中CA=TRUE
# server auth：表示client可以使用该ca对server提供的证书进行验证
# client auth：表示server可以用该ca对client提供的证书进行验证
#  
# 最佳实践： 在实际生产中，为了简化etcd的管理，我们通常不会为服务端和客户端各生成一套证书，而是生成一套即可以用于服务端也可以同时用于客户端的证书。在我们上面生成etcd的ca证书的时候，可以看到etcd-ca-config.json中etcd的证书useags中同时有server auth和client auth。也就是说，基于我们的ca证书生成的etcd证书本身就可以同时用于服务端与客户端。然而，我们在生成etcd服务端证书的时候，在etcd-server-csr.json中指定了hosts，所以该证书只能被指定的hosts列表中的主机使用，要想所有的客户端都能使用这个证书。最简单的方法就是和生成etcd客户端证书时一样，直接将hosts留空。反过来，也就是说，我们可以直接将生成的etcd客户端证书用于服务端。


# 获取当前包含脚本文件的主目录
SCRIPT_FILE=$(readlink -f $0)
export PKI_ROOT=$(dirname $SCRIPT_FILE)
cd $PKI_ROOT

source "ca.properties"

PKI_PATH=${PKI_PATH:-"pki"}
if [ ! -d $PKI_PATH ]; then
  mkdir -p $PKI_PATH
else
  rm -rf $PKI_PATH/*
fi
cd $PKI_PATH

# 证书相关参数
#export CERT_NAMES='[{"C":"CN","ST":"Guangdong","L":"Guangzhou","O":"k8s","OU":"System"}]'
#CERT_SERVER_ADDRS=${1:-}
#CERT_PEER_ADDRS=${2:-}
#CERT_CLIENT_ADDRS=${3:-}

function gen-ca() {
  NAME=$1
  if [ $# -gt 1 ]; then
    HOSTS=$2
  else
    HOSTS=
  fi
  echo 'echo {"CN":"'$NAME'","hosts":[],"key":{"algo":"rsa","size":2048},"names":'$CERT_NAMES'} | cfssl gencert -config='$PKI_ROOT'/ca-files/ca-config.json -ca=ca.pem -ca-key=ca-key.pem \
            -profile='$NAME' -hostname="'$HOSTS'" - | 
        cfssljson -bare '$NAME
  # 指定了hosts，则该证书只能被指定的hosts列表中的主机使用，要想所有的客户端都能使用这个证书，直接将hosts留空
  echo '{"CN":"'$NAME'","hosts":[],"key":{"algo":"rsa","size":2048},"names":'$CERT_NAMES'}' |  
        cfssl gencert -config=$PKI_ROOT/ca-files/ca-config.json -ca=ca.pem -ca-key=ca-key.pem \
            -profile=$NAME -hostname="$HOSTS" - | 
        cfssljson -bare $NAME
  # 生成三个文件：${NAME}.pem, ${NAME}-key.pem, ${NAME}.csr

  if [ 0 -eq $? ]; then
    echo "verify data ${NAME}.pem"
    openssl x509 -in ${NAME}.pem -text -noout
    cp ${NAME}-key.pem ${NAME}.key
    cp ${NAME}.pem ${NAME}.crt
  fi
  echo -e "----------------------------------------------------------------------------\n"

}

echo "开始生成 etcd pki 证书"
echo "etcd pki path is :`pwd`"

echo -e "\n1. 生成ca证书："
echo 'echo {"CN":"ca","key":{"algo":"rsa","size":2048},"CERT_NAMES":'$CERT_NAMES'} | cfssl gencert -initca - | cfssljson -bare ca -'
echo '{"CN":"ca","key":{"algo":"rsa","size":2048},"CERT_NAMES":'$CERT_NAMES'}' | cfssl gencert -initca - | cfssljson -bare ca -
#cfssl gencert -initca ca-csr.json | cfssljson -bare ca
# 执行后会生成三个文件：
# ca-key.pem : CA的私有key
# ca.pem : CA证书
# ca.csr : CA的证书请求文件
echo "verify data ca.pem"
openssl x509 -in ca.pem -text -noout
cp ca-key.pem ca.key
cp ca.pem ca.crt
echo -e "----------------------------------------------------------------------------\n"

echo -e "\n2. 生成etcd服务端证书："
gen-ca server $CERT_SERVER_ADDRS
# cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-server-csr.json | cfssljson -bare server

echo -e "\n3. 生成peer端证书："
gen-ca peer $CERT_PEER_ADDRS

echo -e "\n4. 生成etcd客户端证书："
gen-ca client $CERT_CLIENT_ADDRS

echo "etcd 证书生成完成"
