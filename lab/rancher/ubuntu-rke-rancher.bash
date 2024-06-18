#!/bin/bash

green=$(tput setaf 2)
yellow=$(tput setaf 220)
blue=$(tput setaf 6)
normal=$(tput sgr0)

printf "${yellow}>> This script applies to Ubuntu distro only + CertManager (not owned certs) ${normal} \n"
printf "${yellow}>>> PRE-REQS curl, jq ${normal} \n"
printf "${yellow}$ sudo apt update && sudo apt install jq curl -y ${normal} \n"
printf "${blue}-- INSTALL IT? [YES/NO]: ${normal}"
read INSTALL_PREREQS
case $INSTALL_PREREQS in
YES)
  printf "${yellow}Installing curl and jq ...${normal} \n"
  sudo apt update && sudo apt install jq curl -y
  ;;
NO)
  printf "${yellow}Proceding with no prereqs installation...${normal} \n"
  ;;
esac


printf "${normal} \n"
printf "${blue}-- RKE IP Adress/DNS address (e.g. local node IP, 192.x.x.x): ${normal}"
read IP_ADDRESS
export IP_ADDRESS
printf "${blue}-- Rancher hostname/URL (e.g <PUBLIC_IP>.nip.io): ${normal}"
read RANCHER_HOSTNAME
export RANCHER_HOSTNAME
printf "${yellow}Latest RKE releases... ${normal} \n"
curl -sL https://api.github.com/repos/rancher/rke/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
printf "${blue}-- RKE Version (https://github.com/rancher/rke/releases) e.g v1.2.9: ${normal}"
read RKE_BIN_VERSION
export RKE_BIN_VERSION
printf "${yellow}Downloading RKE binary...${normal}\n"
curl -sLO https://github.com/rancher/rke/releases/download/$RKE_BIN_VERSION/rke_linux-amd64
chmod 755 rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
printf "\n"
printf "${yellow}RKE K8S versions for RKE $RKE_BIN_VERSION: ${normal} \n"
rke config -list-version -all
printf "${normal} \n"
printf "${blue}-- RKE K8S Version: ${normal}"
read K8S_VERSION
export K8S_VERSION


printf "${yellow}Latest HELM releases... ${normal} \n"
curl -sL https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
printf "${blue}-- HELM Version: ${normal}"
read HELM_VERSION
export HELM_VERSION
printf "${yellow}Downloading HELM $HELM_VERSION...${normal} \n"
curl -sLO https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz
tar xzf helm-$HELM_VERSION-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
sudo mv linux-amd64/helm /usr/local/bin/helm

printf "${blue}-- Rancher Repo (stable/latest/prime): ${normal}"
read RANCHER_REPO
export RANCHER_REPO
case $RANCHER_REPO in
stable)
  printf "${yellow}Adding Rancher $RANCHER_REPO repo...${normal} \n"
  helm repo add rancher-$RANCHER_REPO https://releases.rancher.com/server-charts/$RANCHER_REPO
  ;;
latest)
  printf "${yellow}Adding Rancher $RANCHER_REPO repo...${normal} \n"
  helm repo add rancher-$RANCHER_REPO https://releases.rancher.com/server-charts/$RANCHER_REPO
  ;;
prime)
  printf "${yellow}Adding Rancher $RANCHER_REPO repo...${normal} \n"
  helm repo add rancher-$RANCHER_REPO https://charts.rancher.com/server-charts/$RANCHER_REPO
  ;;
esac

helm search repo rancher-$RANCHER_REPO/rancher -l 
printf "${blue}-- Rancher version (e.g 2.7.10): ${normal}"
read RANCHER_VERSION
export RANCHER_VERSION

printf "${yellow}Latest Cert-Manager releases... ${normal} \n"
curl -sL https://api.github.com/repos/cert-manager/cert-manager/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
printf "${blue}-- CertManager version: ${normal}"
read CERTMANAGER_VERSION
export CERTMANAGER_VERSION

printf "${yellow}Changing SSH AllowTcpForwarding to yes... ${normal} \n"
sudo sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
printf "${yellow}Loading br_netfilter...${normal} \n"
sudo modprobe br_netfilter
printf "${yellow}Setting and loading net.ipv4.ip_forward=1 ... ${normal} \n"
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
printf "${yellow}Setting and loading net.bridge.bridge-nf-call-iptables=1 ... ${normal} \n"
sudo bash -c 'echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
printf "${yellow}Downloading and installing docker engine ... ${normal} \n"
sudo curl https://releases.rancher.com/install-docker/20.10.sh | sh
sudo usermod -G docker ubuntu
printf "${yellow}Creating ssh keys... ${normal} \n"
ssh-keygen -q -t rsa -N '' -f $HOME/.ssh/id_rsa <<<y >/dev/null 2>&1
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
###
printf "${yellow}Downloading latest kubectl binary...${normal} \n"
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 kubectl
sudo mv kubectl /usr/local/bin/
printf "${yellow}Downloading K9s binary...${normal} \n"
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
printf "${yellow}Running rke up...${normal} \n"
rke up --ignore-docker-version
printf "${yellow}Exporting KUBECONFIG to kube_config_cluster.yml file...${normal} \n"
export KUBECONFIG=kube_config_cluster.yml
#source <(kubectl completion bash)
printf "${yellow}Listing RKE/K8S nodes...${normal} \n"
kubectl get nodes -o wide
###

printf "${yellow}Creating cattle-system namespace...${normal} \n"
kubectl create namespace cattle-system
printf "${yellow}Creating Cert-Manager CRDs...${normal} \n"
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERTMANAGER_VERSION/cert-manager.crds.yaml

printf "${yellow}Adding Cert-Manager helm repo...${normal} \n"
helm repo add jetstack https://charts.jetstack.io
printf "${yellow}Updating helm repos...${normal} \n"
helm repo update
printf "${yellow}Installing Cert-Manager $CERTMANAGER_VERSION ...${normal} \n"
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version $CERTMANAGER_VERSION
####
printf "${yellow}Sleeping 120 secs ...${normal} \n"
sleep 120

printf "${yellow}Listing Cert-Manager PODs ...${normal} \n"
kubectl -n cert-manager get pods -o wide

printf "${yellow}Installing Rancher $RANCHER_VERSION ...${normal} \n"
#helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION
helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION --set global.cattle.psp.enabled=false

printf "${yellow}$ export KUBECONFIG=kube_config_cluster.yml ${normal} \n"
printf "${yellow}$ source <(kubectl completion bash) ${normal} \n"
printf "${yellow}$ kubectl get pod -A ${normal} \n"
#
# kubectl create namespace cattle-system
# kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=cert/fullchain1.pem --key=cert/privatekey.pem
# helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher26.prateslabs.com.br --set bootstrapPassword=**** --set ingress.tls.source=secret --version 2.6.3
#

#
# helm get values rancher -n cattle-system > values.yml
# helm upgrade rancher rancher-stable/rancher -n cattle-system --values values.yml --version 2.5.11
#