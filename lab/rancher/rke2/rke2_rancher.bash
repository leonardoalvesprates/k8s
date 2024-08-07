#!/bin/bash

green=$(tput setaf 2)
yellow=$(tput setaf 220)
blue=$(tput setaf 6)
normal=$(tput sgr0)

printf "${yellow}>> This script applies to Ubuntu distro only + CertManager (not owned certs) ${normal} \n"
printf "${yellow}>> Script developed to be run as ROOT ${normal} \n"
printf "${yellow}>>> PRE-REQS curl, jq ${normal} \n"
printf "${yellow}$ apt update && apt install jq curl -y ${normal} \n"
printf "${blue}-- INSTALL IT? [YES/NO]: ${normal}"
read INSTALL_PREREQS
case $INSTALL_PREREQS in
YES)
  printf "${yellow}Installing curl and jq ...${normal} \n"
  apt update && apt install jq curl -y
  ;;
NO)
  printf "${yellow}Proceding with no prereqs installation...${normal} \n"
  ;;
esac

curl -s https://raw.githubusercontent.com/rancher/rke/release/v1.3/data/data.json| grep v1.2 | grep rke2 |sed 's/"//g'|awk '{print $2}'|sort
printf "\n"
printf "${blue}-- RKE2 Version: ${normal}"
read RKE2_VERSION
printf "${blue}TLS SANS: ${normal}"
read RKE2_TLS_SANS
printf "${blue}Rancher hostname/URL: ${normal}"
read RANCHER_HOSTNAME

export RKE2_VERSION
export RKE2_TLS_SANS
export RANCHER_VERSION
export RANCHER_HOSTNAME

printf "${yellow}Installing RKE2...${normal} \n"
curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh -
systemctl enable rke2-server

mkdir -p /etc/rancher/rke2/
cat <<EOF > config.sample
tls-san:
  - $RKE2_TLS_SANS
EOF
envsubst < config.sample > /etc/rancher/rke2/config.yaml
systemctl start rke2-server

printf "${yellow}Sleeping 60s ...${normal} \n"
sleep 60

printf "${yellow}Setting KUBECONFIG...${normal} \n"
cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
source <(kubectl completion bash)

printf "${yellow}Latest HELM releases... ${normal} \n"
curl -sL https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
printf "${blue}-- HELM Version: ${normal}"
read HELM_VERSION
export HELM_VERSION
printf "${yellow}Downloading HELM $HELM_VERSION...${normal} \n"
curl -sLO https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz
tar xzf helm-$HELM_VERSION-linux-amd64.tar.gz
chmod 755 linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/helm

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

printf "${yellow}Downloading K9s binary...${normal} \n"
curl -sLO https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz
tar xzf k9s_Linux_x86_64.tar.gz
mv k9s /usr/local/bin/

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
helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION --set global.cattle.psp.enabled=false

printf "${yellow}$ kubectl get pod -A ${normal} \n"
