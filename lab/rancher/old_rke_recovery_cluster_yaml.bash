#!/bin/bash
OUTPUT=cluster_recovery.yml

echo 'nodes:' > cluster_recovery.yml
kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.nodes | sed 's/{//g' | sed 's/}//g' | sed 's/}//g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' | sed 's/"//g' | sed 's/internalAddress/internal_address/g' | sed 's/hostnameOverride/hostname_override/g' | sed 's/sshKeyPath/ssh_key_path/g' | sed 's/^    /      /g' | sed 's/      address/    - address/g' | sed 's/      controlplane/      - controlplane/g' | sed 's/      etcd/      - etcd/g' | sed 's/      worker/      - worker/g' | sed '/^[[:space:]]*$/d' >> $OUTPUT

echo 'services:' >> cluster_recovery.yml
kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.services | sed 's/{//g' | sed 's/}//g' | sed 's/}//g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' | sed 's/"//g' | sed '/^$/d' | sed '/^[[:space:]]*$/d' | sed 's/^  /    /g' >> $OUTPUT

echo 'network:' >> cluster_recovery.yml
kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.network | sed 's/{//g' | sed 's/}//g' | sed 's/}//g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' | sed 's/"//g' | sed '/^$/d' | sed '/^[[:space:]]*$/d' >> $OUTPUT

echo 'authentication:' >> cluster_recovery.yml
kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.authentication | sed 's/{//g' | sed 's/}//g' | sed 's/}//g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' | sed 's/"//g' | sed '/^$/d' | sed '/^[[:space:]]*$/d' | sed 's/^  /    /g' >> $OUTPUT

echo 'system_images:' >> cluster_recovery.yml
kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.systemImages | sed 's/{//g' | sed 's/}//g' | sed 's/}//g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' | sed 's/"//g' | sed '/^$/d' | sed '/^[[:space:]]*$/d' | sed 's/^  /    /g' >> $OUTPUT

kubectl -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r . > cluster_recovery.rkestate
