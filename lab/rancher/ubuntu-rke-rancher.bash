#!/bin/bash

green=$(tput setaf 2)
normal=$(tput sgr0)

printf " ####### This applies only to Ubuntu 20.04 + CertManager (not owned certs) ###### \n"
printf "RKE IP Adress/DNS address: "
read IP_ADDRESS
printf "Rancher hostname/URL: "
read RANCHER_HOSTNAME
printf "RKE Version (https://github.com/rancher/rke/releases) e.g v1.2.9: "
read RKE_BIN_VERSION  
printf "${green}Downloading and installing RKE binary...${normal}\n"
curl -sLO https://github.com/rancher/rke/releases/download/$RKE_BIN_VERSION/rke_linux-amd64
chmod 755 rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
printf "\n"
printf "${green}k8s versions for RKE $RKE_BIN_VERSION: \n"
rke config -list-version -all
printf "${normal} \n"
printf "K8S Version: "
read K8S_VERSION
printf "Rancher Repo (stable/latest): "
read RANCHER_REPO     
printf "Rancher version: "
read RANCHER_VERSION
printf "CertManager version (e.g. v1.5.1 - Rancher 2.5.x / v1.7.1 - Rancher 2.6.x): "
read CERTMANAGER_VERSION

export IP_ADDRESS
export RKE_BIN_VERSION
export K8S_VERSION
export RANCHER_REPO
export RANCHER_VERSION
export RANCHER_HOSTNAME
export CERTMANAGER_VERSION

printf "${green}Changing SSH AllowTcpForwarding to yes...${normal} \n"
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
printf "${green}Loading br_netfilter...${normal} \n"
sudo modprobe br_netfilter
printf "${green}Setting and loading net.ipv4.ip_forward=1 ${normal} \n"
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
printf "${green}Setting and loading net.bridge.bridge-nf-call-iptables=1 ${normal} \n"
sudo bash -c 'echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
printf "${green}Downloading and installing docker engine ${normal} \n"
sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh
sudo usermod -G docker ubuntu
ssh-keygen -q -t rsa -N '' -f $HOME/.ssh/id_rsa <<<y >/dev/null 2>&1
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
###
printf "${green}Downloading latest kubectl binary...${normal} \n"
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
sudo mv kubectl /usr/local/bin/
printf "${green}Downloading Helm 3.6.3...${normal} \n"
curl -sLO https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar xzf helm-v3.6.3-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm
printf "${green}Downloading K9s binary...${normal} \n"
curl -sLO https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xzf k9s_Linux_x86_64.tar.gz
sudo mv k9s /usr/local/bin/

###
cat <<EOF> cluster.sample
nodes:
    - address: $IP_ADDRESS
      user: ubuntu
      role:
        - controlplane
        - etcd
        - worker
kubernetes_version: $K8S_VERSION
#cluster_name: rkeranchercluster
services:
  etcd:
    snapshot: true
    creation: 1h
    retention: 24h
#authentication:
#    strategy: x509
#    sans:
#      - "100.26.46.85"
#      - "ec2-100-26-46-85.compute-1.amazonaws.com"
#ingress:
#  provider: nginx
#  options:
#    error-log-level: "debug"
#addons_include:
#    - https://raw.githubusercontent.com/leonardoalvesprates/k8s/master/lab/rancher/daemonset-nginx-controller-controller.yml
#enable_cri_dockerd: true
EOF
envsubst < cluster.sample > cluster.yml
###
rke up --ignore-docker-version
export KUBECONFIG=kube_config_cluster.yml
source <(kubectl completion bash)
kubectl get nodes
###
helm repo add rancher-$RANCHER_REPO https://releases.rancher.com/server-charts/$RANCHER_REPO
kubectl create namespace cattle-system
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERTMANAGER_VERSION/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version $CERTMANAGER_VERSION
####
sleep 120
#helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION
helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION --set global.cattle.psp.enabled=false


#
# kubectl create namespace cattle-system
# kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=cert/fullchain1.pem --key=cert/privatekey.pem
# helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher26.prateslabs.com.br --set bootstrapPassword=**** --set ingress.tls.source=secret --version 2.6.3
#

#
# helm get values rancher -n cattle-system > values.yml
# helm upgrade rancher rancher-stable/rancher -n cattle-system --values values.yml --version 2.5.11
#