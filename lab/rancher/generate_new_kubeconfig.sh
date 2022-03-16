#!/bin/bash
echo "This will generate a new kube config for accessing your RKE-created kubernetes cluster. This script MUST be run on a Kubernetes node."
echo "Please enter the IP of one of your control plane hosts, followed by [ENTER]:"

read cphost

openssl genrsa -out kube-admin.key 2048
openssl req -new -sha256 -key kube-admin.key -subj "/O=system:masters/CN=kube-admin" -out kube-admin.csr
sudo openssl x509 -req -in kube-admin.csr -CA /etc/kubernetes/ssl/kube-ca.pem -CAcreateserial -CAkey /etc/kubernetes/ssl/kube-ca-key.pem -out kube-admin.crt -days 365 -sha256
sudo rm -f /etc/kubernetes/ssl/kube-ca.srl
echo "apiVersion: v1" > new_kube_config.yml
echo "kind: Config" >> new_kube_config.yml
echo "clusters:" >> new_kube_config.yml
echo "- cluster:" >> new_kube_config.yml
echo "    api-version: v1" >> new_kube_config.yml
echo "    certificate-authority-data: $(cat /etc/kubernetes/ssl/kube-ca.pem | base64 -w 0)" >> new_kube_config.yml
echo "    server: \"https://$cphost:6443\"" >> new_kube_config.yml
echo "  name: \"local\"" >> new_kube_config.yml
echo "contexts:" >> new_kube_config.yml
echo "- context:" >> new_kube_config.yml
echo "    cluster: \"local\"" >> new_kube_config.yml
echo "    user: \"kube-admin-local\"" >> new_kube_config.yml
echo "  name: \"local\"" >> new_kube_config.yml
echo "current-context: \"local\"" >> new_kube_config.yml
echo "users:" >> new_kube_config.yml
echo "- name: \"kube-admin-local\"" >> new_kube_config.yml
echo "  user:" >> new_kube_config.yml
echo "    client-certificate-data: $(cat kube-admin.crt | base64 -w 0)" >> new_kube_config.yml
echo "    client-key-data: $(cat kube-admin.key | base64 -w 0)" >> new_kube_config.yml
echo "Done. New kube config file can be found at new_kube_config.yml"

### kubectl + local CP/kubelet + jq
# kubectl --kubeconfig $(docker inspect kubelet --format '{{ range .Mounts }}{{ if eq .Destination "/etc/kubernetes" }}{{ .Source }}{{ end }}{{ end }}')/ssl/kubecfg-kube-node.yaml get configmap -n kube-system full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .currentState.certificatesBundle.\"kube-admin\".config | sed -e "/^[[:space:]]*server:/ s_:.*_: \"https://127.0.0.1:6443\"_" > kubeconfig_admin.yaml
###