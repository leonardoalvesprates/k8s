#!/bin/bash

build() {
 echo "Building cluster.yml..."
 IFS=''
 while read line
 do
  word=$(echo "$line" |awk -F ":" '{print $1}')
  new_word=$(echo "$line" |awk -F ":" '{print $1}' | perl -pe 's/([a-z0-9])([A-Z])/$1_\L$2/g')
  echo "$line"| sed "s/$word/$new_word/g" >>cluster.yml
 done< <(kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig | yq r -P -)

 echo "Building cluster.rkestate..."
 kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r . > cluster.rkestate
}

#Downloading jq and yq
curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 755 jq-linux64 
mv jq-linux64 jq
curl -LO https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64
chmod 755 yq_linux_amd64
mv yq_linux_amd64 yq

#exporting $PATH
export PATH=$(pwd):$PATH

#running build function
build