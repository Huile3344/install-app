#!/bin/bash

kubectl get nodes

read -p "Choose a node to tear down(删除节点). : " node
if [ -z "$node" ]; then
    exit 0;
fi 
kubectl drain $node --delete-local-data --force --ignore-daemonsets
kubectl delete node $node

echo "success teared down node : $node"
