#!/bin/bash

green=$(tput setaf 2)
yellow=$(tput setaf 220)
blue=$(tput setaf 6)
normal=$(tput sgr0)

printf "\n"
printf "${yellow}>> This script applies to Ubuntu distro only + CertManager (not owned certs) ${normal} \n"
printf "${yellow}>> Script developed to be run as ROOT ${normal} \n"
printf "${yellow}>>> PRE-REQS curl, jq ${normal} \n"

_prereqs() {
  printf "\n"
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
}

_exportkubeconfig() {
  cp /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/
  export KUBECONFIG=/etc/rancher/rke2/rke2.yaml 
}

_installrke2() {
  printf "\n"
  printf "${yellow}Listing latest RKE2 releases ...${normal} \n"
  curl -sL https://api.github.com/repos/rancher/rke2/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
  printf "${blue}-- RKE2 Version: ${normal}"
  read RKE2_VERSION
  printf "${blue}-- RKE2 CNI (canal/cilium/calico): ${normal}"
  read RKE2_CNI
  printf "${blue}-- TLS SANS: ${normal}"
  read RKE2_TLS_SANS
  printf "${yellow}Installing and enabling RKE2 service...${normal} \n"
  curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=$RKE2_VERSION sh -
  systemctl enable rke2-server
  printf "${yellow}Creating /etc/rancher/rke2/ dir, /etc/rancher/rke2/config.yaml file, starting, and sleeping 60s ...${normal} \n"
  mkdir -p /etc/rancher/rke2/
cat <<EOF > config.sample
tls-san:
  - $RKE2_TLS_SANS
cni:
  - $RKE2_CNI
EOF
  envsubst < config.sample > /etc/rancher/rke2/config.yaml
  systemctl start rke2-server
  sleep 60
  _exportkubeconfig
  kubectl get node -o wide
}

_installhelm() {
  printf "\n"
  printf "${yellow}Listing latest HELM releases... ${normal} \n"
  curl -sL https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
  printf "${blue}-- HELM Version: ${normal}"
  read HELM_VERSION
  export HELM_VERSION
  printf "${yellow}Downloading and installing HELM $HELM_VERSION...${normal} \n"
  curl -sLO https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz
  tar xzf helm-$HELM_VERSION-linux-amd64.tar.gz
  chmod 755 linux-amd64/helm
  mv linux-amd64/helm /usr/local/bin/helm
}

_installcertmanager() {
  _exportkubeconfig
  printf "\n"
  printf "${yellow}Listing latest Cert-Manager releases... ${normal} \n"
  curl -sL https://api.github.com/repos/cert-manager/cert-manager/releases | jq -r '.[].tag_name' | egrep -v "rc|alpha|beta|debug"
  printf "${blue}-- CertManager version: ${normal}"
  read CERTMANAGER_VERSION
  export CERTMANAGER_VERSION
  printf "${yellow}Creating Cert-Manager CRDs...${normal} \n"
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERTMANAGER_VERSION/cert-manager.crds.yaml
  printf "${yellow}Adding Cert-Manager helm repo...${normal} \n"
  helm repo add jetstack https://charts.jetstack.io
  printf "${yellow}Updating helm repos...${normal} \n"
  helm repo update
  printf "${yellow}Installing Cert-Manager $CERTMANAGER_VERSION ...${normal} \n"
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version $CERTMANAGER_VERSION
  printf "${yellow}Sleeping 30 secs ...${normal} \n"
  sleep 30
  printf "${yellow}Listing Cert-Manager PODs ...${normal} \n"
  kubectl -n cert-manager get pods -o wide
}

_installrancher() {
  _exportkubeconfig
  printf "\n"
  printf "${blue}-- Rancher Repo (stable/latest/prime): ${normal}"
  read RANCHER_REPO
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
  printf "${yellow}Updating helm repos...${normal} \n"
  helm repo update
  printf "${yellow}Listing ${RANCHER_REPO} Rancher releases... ${normal} \n"
  helm search repo rancher-$RANCHER_REPO/rancher -l
  printf "${blue}-- Rancher version (e.g 2.7.10): ${normal}"
  read RANCHER_VERSION
  printf "${blue}-- Rancher hostname/URL: ${normal}"
  read RANCHER_HOSTNAME
  printf "${yellow}Creating cattle-system namespace...${normal} \n"
  kubectl create namespace cattle-system
  printf "${yellow}Installing Rancher $RANCHER_VERSION ...${normal} \n"
  helm install rancher rancher-$RANCHER_REPO/rancher --namespace cattle-system --set hostname=$RANCHER_HOSTNAME --version $RANCHER_VERSION --set global.cattle.psp.enabled=false
  printf "${yellow}Sleeping 60 secs ...${normal} \n"
  sleep 60
  kubectl -n cattle-system get po -o wide
}

_nodelocaldns() {
cat <<EOF > /var/lib/rancher/rke2/server/manifests/nodelocal-dns.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-coredns
  namespace: kube-system
spec:
  valuesContent: |-
    nodelocal:
      enabled: true
EOF
  printf "${yellow}Creating /var/lib/rancher/rke2/server/manifests/nodelocal-dns.yaml file and restarting rke2-server.service...${normal} \n"
  systemctl restart rke2-server.service
  kubectl get all -n kube-system -l k8s-app=node-local-dns && kubectl get all -n kube-system -l k8s-app=kube-dns
}

_exit() {
  printf "\n"
  printf "${yellow}$ export KUBECONFIG=/etc/rancher/rke2/rke2.yaml ${normal} \n"
  printf "${yellow}$ source <(kubectl completion bash) ${normal} \n"
  exit
}

_installall() {
  _prereqs
  _installrke2
  _installhelm
  _installcertmanager
  _installrancher
}

_menu() {
  printf "\n"
  printf "${blue}==================================================== ${normal}\n"
  printf "${blue}1) install prereqs ${normal}\n"
  printf "${blue}2) install RKE2 ${normal}\n"
  printf "${blue}3) install HELM ${normal}\n"
  printf "${blue}4) install Cert-Manager (prereq HELM) ${normal}\n"
  printf "${blue}5) install Rancher (prereq HELM + Cert Manager) ${normal}\n"
  printf "${blue}6) exit ${normal}\n"
  printf "${blue} - - - - - - - - - - - - - - - - - - - - - - - - - ${normal}\n"
  printf "${blue}7) install prereqs + RKE2 + HELM + Cert-Manager + Rancher ${normal}\n"
  printf "${blue}8) nodelocal dns (rke2 restart) ${normal}\n"
  printf "\n"
  printf "${blue}-- Option: ${normal}"
  read OPTION
  case $OPTION in
  1)
    _prereqs
    ;;
  2)
    _installrke2
    ;;
  3)
    _installhelm
    ;;
  4)
    _installcertmanager
    ;;
  5)
    _installrancher
    ;;
  6)
    _exit
    ;;
  7)
    _installall
    ;;
  8)
    _nodelocaldns
    ;;
  esac
}

while true
do 
  _menu
done